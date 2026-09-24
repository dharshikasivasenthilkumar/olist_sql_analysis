E-commerce Sales, Delivery & Satisfaction Analysis

BUSINESS PROBLEM

Acting as an analyst for an online marketplace, this project uses SQL to analyse ~100K orders and Power BI to visualise the results, answering key questions about revenue trends, customer retention, product performance, and delivery reliability for management.

DATASET

Olist Brazilian E-Commerce Public Dataset (Kaggle): https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce ~100K orders placed between 2016 and 2018, across 8 linked tables (orders, order items, payments, reviews, customers, sellers, products, and category translations).

TOOLS

MySQL 8 (data modelling and analysis), Power BI (interactive dashboard)

BUSINESS QUESTIONS

~How does monthly revenue trend, and what's the month-over-month growth? 

~Which product categories bring in the most revenue, and which have the highest average order value? 

~What share of customers place more than one order? 

~Which states generate the most revenue and the most orders? 

~Which categories have the lowest review scores? 

~What's the average delivery time, and what percentage of orders arrive late? 

~Do late deliveries get lower review scores?

~Which states have the worst delivery performance?

~What are the top recommendations based on all of the above? ✅

DATA CLEANING NOTES

~All revenue, category, and delivery metrics are filtered to order_status = 'delivered'.

~Excluded September-December 2016 from the monthly revenue trend, since order volume was very low during the platform's early rollout and distorted month-over-month growth figures.

~One row (out of 99,223) in order_reviews had a CSV parsing issue, likely caused by a comment containing an unescaped comma or line break. This corrupted only the review date fields for that row; review_score remained valid and was retained in the analysis.

~Used LEFT JOIN with COALESCE when joining product categories to their English translations, since a small number of categories had no matching row in the translation table. This kept ~1,400 orders (labelled unknown) in the revenue totals instead of silently dropping them.

~Delivery time and late-delivery metrics exclude orders with a missing actual or estimated delivery date, since no valid comparison can be made for those.

~Categories and states with very few orders (fewer than 30) were excluded from the review-score and delivery-performance rankings, to avoid small-sample noise 
producing misleadingly extreme results.


KEY FINDINGS

~Revenue grew roughly 8x through 2017 before stabilising. Monthly revenue rose from ~₹112K in January 2017 to a peak of ~₹988K in November 2017 (+52.4% month-over-month, likely tied to Black Friday), then levelled off through 2018 with growth mostly within a few percentage points each month.

~A small number of categories drive very different kinds of revenue. health_beauty (₹12.3L) and bed_bath_table (₹10.2L) lead on order volume, both averaging under ₹150 per order. computers, by contrast, generates far less total revenue (₹2.2L) from only 177 orders, but has by far the highest average order value at ₹1,235 — more than 5x the next highest category.

~Repeat purchases are rare. Only 3.0% of customers (2,801 of 93,358) placed more than one delivered order across the ~2-year dataset window, pointing to a real retention gap rather than a data artefact.

~Revenue is heavily concentrated in one state. São Paulo (SP) leads by a wide margin with 40,501 orders and ₹50.7L in revenue — roughly 3.3x the next highest state, Rio de Janeiro (RJ, 12,350 orders, ₹17.6L). Minas Gerais (MG) is third (11,354 orders, ₹15.5L). Together, SP, RJ and MG account for the large majority of national revenue, showing the business is still concentrated in Brazil's southeast rather than evenly spread nationally.

~Deliveries average 12.5 days, with 1 in 12 orders arriving late. Across 96,470 delivered orders, the average delivery time is 12.5 days, and 8.11% (7,826 orders) arrived after their estimated delivery date.

~Delivery performance varies sharply by state, and the slowest states are not the biggest revenue states. Alagoas (AL) has the worst performance: 24.5 days average delivery time and a 23.93% late rate — roughly 3x the national late rate. Maranhão (MA, 21.5 days, 19.67% late) and Piauí (PI, 19.4 days, 15.97% late) are also well above average. By contrast, the top revenue states from Finding 4 perform close to or better than the national average (RJ: 15.2 days, 13.47% late; SC: 14.9 days, 9.76% late), suggesting delivery problems are concentrated in states outside the main revenue base — worth investigating whether this is a logistics network gap.

DASHBOARD

Interactive Power BI dashboard covering revenue trends, category and state performance, and a dedicated delivery & satisfaction page comparing review scores for on-time vs late orders.


<img width="756" height="505" alt="image" src="https://github.com/user-attachments/assets/0bcc5ce5-5f0e-482d-b5f8-aedf4f79b88b" />


RECOMMENDATIONS

~Address the low repeat-purchase rate. With only 3% of customers returning, consider post-purchase engagement (follow-up emails, discount incentives on a second order) to convert more first-time buyers into repeat customers.

~Prioritise logistics investment in the worst-performing states. AL, MA and PI have late-delivery rates 2-3x the national average and noticeably longer delivery times, despite contributing relatively little revenue. Reviewing carrier coverage or fulfilment options for these states could reduce late deliveries without requiring changes to the core SP/RJ/MG logistics network.

Author

Dharshika Sivasenthilkumar — MSc Big Data and Business Intelligence, University of Greenwich linkedin.com/in/dharshika-s
