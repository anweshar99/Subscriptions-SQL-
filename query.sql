/*
Imagine you run a popular streaming service that offers subscriptions to users worldwide. Customers from different countries can subscribe to your service in their local currencies. You have three main tables storing customer data, subscription details, and payment information.

Customer Table: Contains information about each customer, such as a unique customer ID, their subscription status (active or inactive), the country they are from, and the currency they use for payments.

Subscription Table: Stores details of each subscription, including a unique subscription ID, the customer it belongs to (referenced by the customer ID), the date when the subscription was renewed, and the subscription's duration in months.

Payment Table: Holds payment-related data, such as a unique payment ID, the subscription it is associated with (referenced by the subscription ID), the payment amount made by the customer, and the date when the payment was made.

Now, we want to find out the average payment amount received from customers who are currently active subscribers and have renewed their subscription during the month of July 2023. Since customers worldwide pay in their local currencies, we need to convert the payment amounts to USD (United States Dollars) for analysis.

For instance, if a customer is from Canada and paid in Canadian Dollars (CAD), we will convert their payment amount to USD using the exchange rate of 1 CAD = 1.25 USD. Similarly, for customers from the UK paying in British Pounds (GBP), we will convert their payment amount to USD using the exchange rate of 1 GBP = 0.8 USD, and so on for other currencies. The exchange rates are as follows:
1 EUR (Euro) = 0.9 USD (USD to EUR)
1 JPY (Japanese Yen) = 110.0 USD (USD to JPY)
1 INR (Indian Rupee) = 81.0 USD (USD to INR)

The final output will show the customer_id and their average payment amount in both USD and the customer's local currency, along with the exchange rate used for the conversion. If a customer's local currency is USD, the average payment amount in their currency will be the same as the average payment in USD, and the exchange rate will be 1.0.
*/

create database subscription;
use subscription;

-- data preparation

create table customers(
customer_id int unique,
subscription_status varchar (20),
country varchar (20),
currency varchar (20)
);

create table subscriptions(
subscription_id int unique,
customer_id int,
renewal_date varchar (20),
subscription_length int);

create table payments(
payment_id int unique,
subscription_id int,
amount double,
payment_date date);

load data infile "customers.csv"
into table customers
fields terminated by ','
enclosed by '"'
LINES TERMINATED BY '\r\n'
ignore 1 lines;

load data infile "subscriptions.csv"
into table subscriptions
fields terminated by ','
enclosed by '"'
LINES TERMINATED BY '\r\n'
ignore 1 lines;

load data infile "payments.csv"
into table payments
fields terminated by ','
enclosed by '"'
LINES TERMINATED BY '\r\n'
ignore 1 lines;

-- #5

/* find out the average payment amount received from customers who are currently 
active subscribers and have renewed their subscription during the month of July 2023. */

-- cust id | avg payment amt (USD) | avg payment amt (local) | exchange rate

------------------------------------------------------------------
alter table subscriptions
modify column renewal_date date;
update subscriptions
set renewal_date = str_to_date(renewal_date, "%d-%m-%Y");

-------------------------------------------------------------------

with t as 
(
select customer_id, currency, renewal_date, amount,
	case
		when currency = "CAD" then 1.25
        when currency = "GBP" then 0.80
        when currency = "EUR" then 0.90
        when currency = "JPY" then 110
        when currency = "INR" then 81
        else 1
	end as exchange_rate
from customers c inner join subscriptions s using(customer_id) inner join payments p using(subscription_id)
where subscription_status = "active" and renewal_date >= "2023-07-01" and renewal_date < "2023-08-01"
)

select t.customer_id, 
concat("USD ",round((t.amount/t.exchange_rate),2)) as payment_amt, 
concat(currency," ",t.amount) as amt_local_currency, 
t.exchange_rate
from t;