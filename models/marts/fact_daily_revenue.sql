-- Ten model buduje tabelę faktów, która agreguje dzienne przychody.

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

psp_transactions as (
    select * from {{ ref('stg_psp_transactions') }}
),

games as (
    select * from {{ ref('dim_games') }}
),

exchange_rates as (
    select * from {{ ref('stg_exchange_rates') }}
),

-- Łączymy wszystkie źródła i dokonujemy konwersji walut
revenue_calculation as (
    select
        t.transaction_id,
        cast(t.transaction_at as date) as revenue_date,
        coalesce(g.genre, 'Unknown') as genre,
        t.product_type,
        t.payment_method,
        t.amount * er.rate as revenue_in_target_currency
    from transactions as t
    inner join psp_transactions as psp
        on t.transaction_id = psp.original_transaction_id
    left join games as g
        on t.game_id = g.game_id
    left join exchange_rates as er
        on cast(t.transaction_at as date) = er.rate_date and t.currency = er.currency_from
),

final as (
    select
        revenue_date,
        genre,
        product_type,
        payment_method,

        count(transaction_id) as total_transactions,
        sum(revenue_in_target_currency) as total_revenue_usd

    from revenue_calculation
    group by
        revenue_date,
        genre,
        product_type,
        payment_method
)

select * from final
order by revenue_date desc
