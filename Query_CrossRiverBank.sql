-- Q1 Customer Risk Analysis: Identify customers with low credit scores and high-risk loans to predict potential defaults and prioritize risk mitigation strategies.
select customer_id, name, credit_score, risk_category 
from customer_table 
where credit_score <600 and risk_category = 'High' 
order by credit_score Asc;

-- Q2 Loan Purpose Insights: Determine the most popular loan purposes and their associated revenues to align financial products with customer demands
select loan_purpose, count(loan_purpose) as Loan_Count, sum(loan_amount) as total_revenue 
from loan_table 
group by loan_purpose 
order by Loan_Count;

-- Q3 High-Value Transactions: Detect transactions that exceed 30% of their respective loan amounts to flag potential fraudulent activities
SELECT 
    t.transaction_id,
    t.customer_id,
    t.loan_id,
    t.transaction_amount,
    l.loan_amount
FROM
    transaction_table AS t
        JOIN
    loan_table AS l ON l.loan_id = t.loan_id
WHERE
    t.transaction_amount > (0.3 * l.loan_amount);

-- Q4 Missed EMI Count: Analyze the number of missed EMIs per loan to identify loans at risk of default and suggest intervention strategies
select loan_id, customer_id,
count(case when
transaction_type = 'Missed EMI' then 1 end) as Missed_EMI_Count
from transaction_table 
group by loan_id, customer_id order by Missed_EMI_Count desc;

-- Q5 Regional Loan Distribution: Examine the geographical distribution of loan disbursements to assess regional trends and business opportunities.
SELECT
COUNT(l.loan_id) AS total_loans,
SUBSTRING_INDEX(c.address, ',', -1) AS region, #Extracting last part of the address
SUM(l.loan_amount) AS total_loan_amount
from customer_table c 
JOIN loan_table l 
ON c.customer_id=l.customer_id
GROUP BY region
ORDER BY total_loan_amount DESC;

-- Q6 Loyal Customers: List customers who have been associated with Cross River Bank for over five years and evaluate their loan activity to design loyalty programs.
select c.customer_id, c.name, count(l.customer_id) as loan_count, sum(l.loan_amount) as total_loan_amount
from customer_table as c 
join loan_table as l on c.customer_id = l.customer_id
where c.customer_since <= date_sub(curdate(), interval 5 year)
group by c.customer_id, c.name
order by loan_count desc;

-- Q7 High-Performing Loans: Identify loans with excellent repayment histories to refine lending policies and highlight successful products.
SELECT loan_id, customer_id, repayment_history, loan_purpose
FROM loan_table
WHERE repayment_history >= 8
ORDER BY repayment_history DESC;

-- Q8 Age-Based Loan Analysis: Analyze loan amounts disbursed to customers of different age groups to design targeted financial products.
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '61+'
    END AS age_group, 
    COUNT(age) AS loan_count, SUM(l.loan_amount) AS total_loan_amount
FROM Customer_table c
JOIN Loan_Table l ON c.customer_id = l.customer_id
GROUP BY age_group
order by age_group asc;

-- Q9 Seasonal Transaction Trends: Examine transaction patterns over years and months to identify seasonal trends in loan repayments.
SELECT 
    YEAR(STR_TO_DATE(t.transaction_date, '%m/%d/%Y')) AS year,
    MONTHNAME(STR_TO_DATE(t.transaction_date, '%m/%d/%Y')) AS month_name,
    COUNT(repayment_history) AS loan_repayments
FROM transaction_table AS t
JOIN loan_table AS l ON l.loan_id = t.loan_id
WHERE t.transaction_type = 'EMI Payment' 
GROUP BY year, month_name
ORDER BY year DESC, FIELD(month_name, 
    'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 'December');

-- Q10 Fraud Detection: Highlight potential fraud by identifying mismatches between customer address locations and transaction IP locations.
-- Not working
SELECT c.customer_id, c.address AS customer_address,b.location as transaction_location,b.ip_address
FROM customer_table c 
JOIN behavior_logs_collection b ON c.customer_id=b.customer_id
WHERE b.location NOT LIKE CONCAT('%', SUBSTRING_INDEX(c.address, ',', -1), '%') 
order by customer_id;

-- Q 11 Repayment History Analysis: Rank loans by repayment performance using window functions.
select loan_id, customer_id, repayment_history,
dense_rank () over (order by repayment_history desc) as rank_number 
from loan_table;

-- Q12 Credit Score vs. Loan Amount: Compare average loan amounts for different credit score ranges.
select 
	case 
when credit_score < 500 then 'very low (0-499)'
when credit_score Between 500 and 650 then 'Low (500-650)'
when credit_score between 651 and 750 then  'Medium (651-750)'
else 'high (750-900)'
End  
as credit_score_category,
avg(loan_amount) as avg_loan_amount
from customer_table as c
join loan_table as l on c.customer_id=l.customer_id
group by credit_score_category
order by credit_score_category desc;

-- Q 13 Top Borrowing Regions: Identify regions with the highest total loan disbursements
SELECT SUBSTRING_INDEX(c.address, ',', -1) AS region, SUM(l.loan_amount) AS total_disbursement
FROM Customer_table c
JOIN Loan_Table l ON c.customer_id = l.customer_id
GROUP BY region
ORDER BY total_disbursement DESC;

-- Q14 Early Repayment Patterns: Detect loans with frequent early repayments and their impact on revenue.
SELECT loan_id, COUNT(transaction_type) AS early_repayment_count
FROM Transaction_table
WHERE transaction_type = 'Prepayment'
GROUP BY loan_id
ORDER BY early_repayment_count DESC;

-- Q 15 Feedback Correlation: Correlate customer feedback sentiment scores with loan statuses. (Not working)
SELECT l.loan_status, AVG(f.sentiment_score) AS avg_feedback_score
FROM customer_feedback_collection as f
join loan_table as l on l.loan_id=f.loan_id
GROUP BY loan_status;

