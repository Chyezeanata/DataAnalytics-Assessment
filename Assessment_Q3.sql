WITH LastTransactionDates AS (
    SELECT
        p.id AS plan_id,
        p.owner_id,
        CASE
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Unknown'
        END AS type,
        MAX(s.transaction_date) AS last_transaction_date
    FROM
        plans_plan p
    LEFT JOIN
        savings_savingsaccount s ON p.id = s.plan_id
    WHERE
        p.is_deleted = 0
        AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
    GROUP BY
        p.id, p.owner_id, type
),
InactiveAccounts AS (
    SELECT
        ltd.plan_id,
        ltd.owner_id,
        ltd.type,
        ltd.last_transaction_date,
        CASE
            WHEN ltd.last_transaction_date IS NULL THEN 366
            ELSE DATEDIFF('2025-05-18', ltd.last_transaction_date) -- Using the current date for consistency
        END AS inactivity_days
    FROM
        LastTransactionDates ltd
    WHERE
        ltd.last_transaction_date IS NULL OR DATEDIFF('2025-05-18', ltd.last_transaction_date) > 365
)
SELECT
    InactiveAccounts.plan_id,
    InactiveAccounts.owner_id,
    InactiveAccounts.type,
    InactiveAccounts.last_transaction_date,
    InactiveAccounts.inactivity_days
FROM
    InactiveAccounts;
