
with source as (

    select * from {{ source('gog_raw_data', 'psp_transactions') }}

),

stg_psp_transactions as (
 
    select
        psp_transaction_id,
        original_transaction_id,
        psp_amount,
        psp_currency,
        status,
        cast(psp_timestamp as timestamp) as psp_processed_at
    from source
    where lower(status) = 'success'

)

select * from stg_psp_transactions
