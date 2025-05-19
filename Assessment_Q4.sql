WITH CustomerTransactionSummary AS (
    SELECT
        u.id AS customer_id,
        u.name,
        u.date_joined,
        COUNT(s.id) AS total_transactions,
        SUM(s.confirmed_amount) AS total_transaction_value_kobo
    FROM
        users_customuser u
    LEFT JOIN
        savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY
        u.id, u.name, u.date_joined
)
SELECT
    cts.customer_id,
    cts.name,
    TIMESTAMPDIFF(MONTH, cts.date_joined, CURRENT_DATE) AS tenure_months,
    cts.total_transactions,
    ROUND(
        (cts.total_transactions / TIMESTAMPDIFF(MONTH, cts.date_joined, CURRENT_DATE)) * 12 * (0.001 * cts.total_transaction_value_kobo / cts.total_transactions),
        2
    ) AS estimated_clv
FROM
    CustomerTransactionSummary cts
WHERE
    TIMESTAMPDIFF(MONTH, cts.date_joined, CURRENT_DATE) > 0 AND cts.total_transactions > 0
ORDER BY
    estimated_clv DESC;
