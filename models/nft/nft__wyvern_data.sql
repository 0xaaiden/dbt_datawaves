with wyvern_atomic_match as (
  select *
  from {{ var('wyvern_atomic_match') }}
)

select
  dt,
  call_tx_hash as tx_hash,
  call_block_number as block_number,
  addrs[1] as buyer,
  addrs[8] as seller,
  uints[4] as original_amount,
  addrs[6] as original_currency_address,
  case
    when {{ substring('calldatabuy', 1, 4) }} in ({{ binary_literal('68f0bcaa') }}) then 'Bundle Trade'
    else 'Single Item Trade'
  end as trade_type,
  case
    when {{ substring('calldatabuy', 1, 4) }} in ({{ binary_literal('fb16a595') }}, {{ binary_literal('23b872dd') }})
      then 'erc721'
    when {{ substring('calldatabuy', 1, 4) }} in ({{ binary_literal('23b872dd') }}, {{ binary_literal('f242432a') }})
      then 'erc1155'
  end as erc_standard,
  addrs[0] as exchange_contract_address,
  case
    when {{ substring('calldatabuy', 1, 4) }} in ({{ binary_literal('fb16a595') }}, {{ binary_literal('96809f90') }})
      then {{ binary_to_address(substring('calldatabuy', 81, 20)) }}
    when {{ substring('calldatabuy', 1, 4) }} in ({{ binary_literal('fb16a595') }}, {{ binary_literal('96809f90') }})
      then addrs[4]
    else addrs[4]
  end as nft_contract_address,
  case
    when addrs[6] = '0x0000000000000000000000000000000000000000' then '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'
    else addrs[6]
  end as currency_token,
  case
    when {{ substring('calldatabuy', 1, 4) }} in ({{ binary_literal('fb16a595') }}, {{ binary_literal('96809f90') }})
      then cast({{ binary_to_numeric(substring('calldatabuy', 101, 32)) }} as {{ dbt_utils.type_string() }})
    when substring(calldatabuy, 1, 4) in ({{ binary_literal('23b872dd') }}, {{ binary_literal('f242432a') }})
      then cast({{ binary_to_numeric(substring('calldatabuy', 69, 32)) }} as {{ dbt_utils.type_string() }})
  end as token_id

from wyvern_atomic_match

where
  (addrs[3] = '0x5b3256965e7c3cf26e11fcaf296dfc8807c01073'
    or addrs[10] = '0x5b3256965e7c3cf26e11fcaf296dfc8807c01073')
  and call_success = true
