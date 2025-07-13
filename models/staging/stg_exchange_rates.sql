-- Ten model przygotowuje kursy wymiany walut do użycia w dalszych modelach.

with source as (

    select * from {{ source('gog_raw_data', 'exchange_rates') }}

),

rates_to_target as (
    select
        cast(date as date) as rate_date,
        currency_from,
        currency_to,
        rate
    from source
    where currency_to = '{{ var('target_currency') }}'
),


all_dates as (
    select distinct cast(date as date) as rate_date from source
),

target_currency_identity_rate as (
    select
        rate_date,
        '{{ var('target_currency') }}' as currency_from,
        '{{ var('target_currency') }}' as currency_to,
        1.0 as rate
    from all_dates
),

final_rates as (
    select * from rates_to_target
    union all
    select * from target_currency_identity_rate
)

select
    rate_date,
    currency_from,
    rate
from final_rates
