WITH MonthlyTransactions AS (
    SELECT
        u.id AS user_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m-01') AS transaction_month,
        COUNT(*) AS transaction_count
    FROM
        users_customuser u
    JOIN
        savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY
        u.id, DATE_FORMAT(s.transaction_date, '%Y-%m-01')
),
AverageMonthlyTransactions AS (
    SELECT
        user_id,
        AVG(transaction_count) AS avg_monthly_transactions
    FROM
        MonthlyTransactions
    GROUP BY
        user_id
),
CategorizedUsers AS (
    SELECT
        user_id,
        CASE
            WHEN avg_monthly_transactions >= 10 THEN '"High Frequency"'
            WHEN avg_monthly_transactions BETWEEN 3 AND 9 THEN '"Medium Frequency"'
            ELSE '"Low Frequency"'
        END AS frequency_category,
        avg_monthly_transactions
    FROM
        AverageMonthlyTransactions
)
SELECT
    frequency_category,
    COUNT(DISTINCT user_id) AS customer_count,
    ROUND(AVG(avg_monthly_transactions), 1) AS avg_transactions_per_month
FROM
    CategorizedUsers
GROUP BY
    frequency_category
ORDER BY
    CASE
        WHEN frequency_category = '"High Frequency"' THEN 1
        WHEN frequency_category = '"Medium Frequency"' THEN 2
        ELSE 3
    END;
