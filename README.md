# DataAnalytics-Assessment

Explanation of the Approach: Q1
The provided MYSQL query directly addresses the request to find customers with at least one funded savings plan AND 
one funded investment plan, sorted by their total deposits. Here's a breakdown of how it achieves this:

1.	Identifying Funded Accounts: The WHERE sa.confirmed_amount > 0 clause is crucial.
    It filters out any savings accounts (both regular savings and investment funds) that haven't received any confirmed deposits,
  	ensuring we only consider "funded" plans.
  	
2.	Distinguishing Savings and Investments: The query uses conditional aggregation with CASE statements inside COUNT(DISTINCT ...)
   to differentiate between regular savings plans and investment funds:
  	
o	CASE WHEN p.is_regular_savings = 1 AND sa.confirmed_amount > 0 THEN sa.id END: This identifies the id of savings accounts that are marked
 as regular savings (p.is_regular_savings = 1) and have a confirmed amount greater than zero. The COUNT(DISTINCT ...)
then counts the number of unique such accounts for each user.

o	CASE WHEN p.is_a_fund = 1 AND sa.confirmed_amount > 0 THEN sa.id END: Similarly, this identifies and counts the unique investment fund accounts (p.is_a_fund = 1) 
with a confirmed amount greater than zero.

3.	Calculating Total Deposits: SUM(sa.confirmed_amount) / 100 calculates the total confirmed deposits for each user 
across all their savings and investment accounts. The division by 100 suggests a conversion from a smaller unit (like cents) to a larger unit.

4.	Grouping by Customer: The GROUP BY u.id, u.first_name, u.last_name clause groups the results by individual users,
   allowing the aggregate functions (COUNT and SUM) to operate on each customer's data.
  	
5.	Filtering for Customers with Both: The HAVING clause is the key to ensuring that only customers with at least one funded savings plan AND
   at least one funded investment plan are included in the final result:
o	COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN sa.id END) > 0: This ensures the user has at least one distinct regular savings account
(note that the WHERE clause already filtered for confirmed_amount > 0).

o	AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN sa.id END) > 0: This ensures the same user also has at least one distinct investment fund account
(again, already funded due to the WHERE clause).

6.	Sorting by Total Deposits: Finally, ORDER BY total_deposits DESC arranges the resulting customers in descending order based on their total_deposits, 
placing the customers with the highest total deposits at the top.

In short, the query cleverly uses conditional counting within a grouped result set and a HAVING clause to pinpoint customers
who meet the specific criteria of having at least one funded account of each type and then presents them ordered by their overall investment activity.



Explanation of the Approach: Q2

The query performs a multi-step aggregation to first count monthly transactions per user, then average those counts per user, 
categorize users based on their average monthly activity, and finally summarize the distribution and average activity within each category.

MonthlyTransactions CTE: This first step counts the number of transactions for each user in each month. 
It joins the users_customuser table with the savings_savingsaccount table (assuming transaction details are within this table or a related one,
based on the transaction_date column). It groups the results by user_id and the first day of the transaction month (%Y-%m-01).

AverageMonthlyTransactions CTE: This CTE takes the results from MonthlyTransactions and calculates the average number of transactions per month for each user. 
It groups by user_id and uses the AVG() aggregate function on the transaction_count.

CategorizedUsers CTE: This CTE categorizes each user based on their avg_monthly_transactions:

Users with an average of 10 or more transactions per month are labeled '"High Frequency"'.
Users with an average between 3 and 9 (inclusive) are labeled '"Medium Frequency"'.
Users with an average less than 3 are labeled '"Low Frequency"'.

Final SELECT Statement: This final part of the query summarizes the categorized users:

It groups the results by frequency_category.
COUNT(DISTINCT user_id) counts the number of unique customers within each frequency category.
ROUND(AVG(avg_monthly_transactions), 1) calculates the average of the average monthly transactions for each category, rounded to one decimal place.
The ORDER BY clause ensures the categories are displayed in a logical order (High, Medium, Low).






Explanation of the Approach: Q3

The query first finds the last transaction date for all active savings and investment accounts. 
Then, it calculates the period of inactivity and filters for those accounts where the last transaction was more than 365 days ago

LastTransactionDates CTE:

It joins the plans_plan table with the savings_savingsaccount table to link plans with their transaction dates.
It filters for active plans (p.is_deleted = 0) that are either regular savings or investment funds.
It uses MAX(s.transaction_date) to find the most recent transaction date for each plan.
It categorizes each plan as 'Savings' or 'Investment' based on the is_regular_savings and is_a_fund flags.
It groups the results by plan_id, owner_id, and the determined type to get the latest transaction date for each account.

InactiveAccounts CTE:

It takes the results from LastTransactionDates.
It calculates the inactivity_days for each account.
If last_transaction_date is NULL (meaning no transactions ever), it assigns an inactivity of 366 days (to be greater than 365).
Otherwise, it calculates the difference in days between a fixed reference date ('2025-05-18', which seems to be used for consistency, likely close to the current date when the query was written) and the last_transaction_date.
It filters for accounts where last_transaction_date is NULL OR the inactivity_days is greater than 365.
Final SELECT Statement:

It selects the plan_id, owner_id, type, last_transaction_date, and inactivity_days from the InactiveAccounts CTE.
This provides a list of all active savings and investment accounts that meet the criteria of having no transactions in the last year.


Explanation of the Approach: Q4

CustomerTransactionSummary CTE:

The query joins the users_customuser table (aliased as u) with the savings_savingsaccount table (aliased as s) on the owner_id
to link customers to their savings accounts (assuming transactions are recorded at the account level).

It selects the customer's id, name, and date_joined.

COUNT(s.id) calculates the total number of transactions for each customer.

SUM(s.confirmed_amount) calculates the total value of all transactions in kobo (as indicated by the alias).
It groups the results by customer_id, name, and date_joined to aggregate transaction data per customer.


Final SELECT Statement:

It selects the customer_id and name from the CTE.
TIMESTAMPDIFF(MONTH, cts.date_joined, CURRENT_DATE) calculates the account tenure in months by finding the difference between 
the date_joined and the current date (May 19, 2025, based on the context).

It retrieves the total_transactions from the CTE.

The estimated_clv is calculated using the provided formula:
(cts.total_transactions / TIMESTAMPDIFF(MONTH, cts.date_joined, CURRENT_DATE)): This calculates the average number of transactions per month.
* 12: This annualizes the average monthly transactions.
* (0.001 * cts.total_transaction_value_kobo / cts.total_transactions): This calculates the average profit per transaction.  
cts.total_transaction_value_kobo / cts.total_transactions: This gives the average transaction value in kobo.
0.001 * ...: This applies the 0.1% profit margin (0.1 / 100 = 0.001).
ROUND(..., 2): This rounds the final CLV to two decimal places.

The WHERE clause filters out customers with a tenure of 0 months or zero total transactions to avoid division by zero errors and to focus on customers with some activity.
ORDER BY estimated_clv DESC sorts the results in descending order of the calculated CLV, showing the customers with the highest estimated lifetime value first
