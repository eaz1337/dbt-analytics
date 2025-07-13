with source as (
    
    select * from {{ source('gog_raw_data', 'raw_transactions') }}

),

stg_transactions as (

    select
        transaction_id,
        user_id,
        game_id,
        cast(transaction_date as timestamp) as transaction_at,
        amount,
        currency,
        payment_method,
        product_type

    from source

)

select * from stg_transactions
