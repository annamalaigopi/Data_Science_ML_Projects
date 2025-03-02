-- sprint-9_project task-1

use modelcarsdb;

-- task-1.1 top 10 customers by credit limit
-- desc products
select customernumber, customername, creditlimit 
from customers 
order by 1 asc
limit 10;

-- task-1.2 average credit limit by country

select country, avg(creditlimit) as average_credit_limit 
from customers 
group by country 
limit 0, 500;


-- task-1.3 number of customers in each state

select state, count(*) as number_of_customers from customers
group by state;

-- task-1.4 customers with no orders

select * from customers
where customernumber not in (select customernumber from orders);


-- task-1.5 total sales per customer

select customername, sum(total_amount) as total_sales
from customers 
inner join orders  using (customernumber)
group by customername;

-- task-1.6 customers and their assigned sales representatives
-- select * from customers;
-- select * from employees;

select customername, lastname as salesrepresentative from customers 
left join employees  on customers.salesRepEmployeeNumber = employees.employeenumber;

-- task-1.7 retrieve customer information with their most recent payment details

select customername,contactlastname,contactfirstname,paymentdate,amount
from customers 
inner join payments  using (customernumber)
where paymentdate = (select max(paymentdate) from payments
where customernumber = customers.customernumber);

-- task-1.8 identify the customers who have exceeded their credit limit
-- select * from customers;
-- select * from orders;

select customername, creditlimit, sum(orders.total_amount) as total_orders
from customers 
inner join orders  using (customernumber) 
group by customername, creditlimit
having sum(orders.total_amount) > creditlimit
limit 0, 500;

-- task-1.9 find the names of all customers who have placed an order for a product from a specific product line

select customername from customers 
inner join orders using(customernumber) 
inner join orderdetails using(ordernumber) 
inner join products using(productcode) 
where productline = 'classic cars'
limit 0, 400;

-- task-1.10 find the names of all customers who have placed an order for a product with the highest buy price

select customername from customers 
inner join orders using(customernumber) 
inner join orderdetails using(ordernumber) 
inner join products using(productcode) 
where buyprice = (select max(buyprice) from products);

-- sprint-9_project task-2

-- task-2.1 count employees per office (assuming you have an employees table with an officecode foreign key)

select officecode, count(employeenumber) as employeecount
from offices 
join employees using(officecode) 
group by officecode; 

-- task-2.2 identify offices with fewer employees

select officeCode, count(*) as employee_count
from employees
group by officeCode
having employee_count < 5;  

-- task-2.3 list office codes, cities, and territories

select  officeCode, city, territory
from offices;

-- task-2.4 find offices with no employees assigned to them
-- select * from employees;

select officecode,city from offices 
left join employees using(officecode) 
where employees.employeeNumber is null;

-- task-2.5 retrieve the most profitable office based on total sales
-- select * from offices;
-- select * from orders;
-- select * from orderdetails;
-- select * from employees;

select officecode ,sum(quantityordered * priceeach) as total_sales 
from offices 
left join employees  using (officecode )
left join customers  on employees .employeenumber = customers .salesrepemployeenumber
left join orders  using (customernumber) 
left join orderdetails using (ordernumber)
group by officecode
order by total_sales desc limit 1;

-- task-2.6 find the office with the highest number of employees

select officecode, city, country, count(employeenumber) as employee_count
from offices 
left join employees  using (officecode )
group by officecode, city, country
order by employee_count desc
limit 1;


-- task-2.7 find the average credit limit for customers in each office
-- select * from offices;
-- select * from customers;
select customerNumber, avg(creditlimit) as averagecreditlimit
from customers 
join offices using(postalCode) 
group by  customerNumber
limit 0, 500;

-- task-2.8 find the number of offices in each country

select country, count(*) as office_count
from offices 
group by country;

-- sprint-9_project task-3

-- task-3.1 count the number of products in each product line

select productline, count(productcode) as productcount
from products
group by productline;

-- task-3.2 find the product line with the highest average product price

select productline, avg(msrp) as averagemsrp
from products
group by productline
order by avg(msrp) desc
limit 1;

-- task-3.3 find all products with a price within a certain range

select productcode, productname, msrp
from products
where msrp between 50 and 100;

-- task-3.4 find the total sales amount for each product line
-- select * from products;
-- select * from productlines;
select productline, sum(quantityordered * priceeach) as totalsales
from products 
join orderdetails using (productcode)
group by productline
order by totalsales desc;

-- task-3.5 identify products with low inventory levels

select productname, productcode, quantityinstock
from products
where quantityinstock < 10;

-- task-3.6 retrieve the most expensive product based on msrp

select productcode, productname, msrp
from products
order by msrp desc
limit 1;

-- task-3.7 calculate total sales for each product
-- select * from products;
-- select * from orderdetails;

select productname, productcode, sum(quantityordered * priceeach) as totalsales
from products 
join orderdetails using (productcode)
group by productcode, productname
order by totalsales desc;

-- task-3.8 identify the top selling products

delimiter //

create procedure gettopsellingproducts(in topn int)
begin
    select productname, sum(orderdetails.quantityordered) as totalquantityordered
    from products 
    join orderdetails od on products.productcode = orderdetails.productcode
    group by  productname
    order by totalquantityordered desc
    limit topn;
end 
//

delimiter ;  

drop procedure gettopsellingproducts;

-- task-3.9 retrieve products with low inventory levels within specific product lines

select productname, productline, quantityinstock
from products 
where productline in ('classic cars', 'motorcycles');

-- task-3.10 find the names of all products that have been ordered by more than 10 customers

select productname from products 
join orderdetails  using(productcode) 
join orders using(ordernumber) 
join customers using (customernumber) 
group by productname
having count(distinct customernumber) > 10;


-- task-3.11 find the names of all products that have been ordered more than the average number of orders for their product line

select productname from products 
join orderdetails using (productcode)
group by productcode, productline
having sum(quantityordered) > (select avg(quantityordered)
from products join orderdetails using (productcode)
where productline = productline)
limit 0, 400;



