-- Ten model łączy transakcje z wewnętrznego systemu z udanymi transakcjami PSP

WITH raw_transactions AS (
    SELECT * FROM {{ ref('stg_transactions') }}
),

successful_psp_transactions AS (
    SELECT * FROM {{ ref('stg_psp_transactions') }}
)

SELECT
    t.transaction_id,
    t.transaction_at,
    t.user_id,
    t.game_id,
    t.amount,
    t.currency,
    psp.psp_transaction_id,
    CASE
        WHEN psp.original_transaction_id IS NOT NULL THEN 'Reconciled'
        ELSE 'Unreconciled'
    END AS reconciliation_status,
    (psp.original_transaction_id IS NOT NULL) as is_reconciled

FROM raw_transactions AS t
LEFT JOIN successful_psp_transactions AS psp
    ON t.transaction_id = psp.original_transaction_id
