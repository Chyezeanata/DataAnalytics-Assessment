SELECT
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 AND sa.confirmed_amount > 0 THEN sa.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 AND sa.confirmed_amount > 0 THEN sa.id END) AS investment_count,
    SUM(sa.confirmed_amount) / 100 AS total_deposits
FROM 
    users_customuser u
JOIN 
    savings_savingsaccount sa ON u.id = sa.owner_id
JOIN 
    plans_plan p ON sa.plan_id = p.id
WHERE 
    sa.confirmed_amount > 0
GROUP BY 
    u.id, u.first_name, u.last_name
HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN sa.id END) > 0
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN sa.id END) > 0
ORDER BY 
    total_deposits DESC;
