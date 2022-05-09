{{
  cte_import([
    ('nft_whale', 'nft_whale'),
    ('smart_nft_trader', 'smart_nft_trader'),
    ('smart_nft_holder', 'smart_nft_holder'),
  ])
}}

select
  address,
  label,
  label_type
from smart_nft_trader

union all

select
  address,
  label,
  label_type
from nft_whale

union all

select
  address,
  label,
  label_type
from smart_nft_holder