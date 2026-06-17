CREATE DATABASE BankDB;
USE BankDB;

-- customer table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    dob DATE,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    address VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- account table
CREATE TABLE Accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    account_type ENUM('Savings','Current','Fixed Deposit'),
    balance DECIMAL(12,2) DEFAULT 0.00,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Transactions Table
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    type ENUM('Deposit','Withdrawal','Transfer'),
    amount DECIMAL(12,2),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Loans Table
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    loan_type ENUM('Home','Car','Personal','Education'),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);


-- Customers
INSERT INTO Customers (first_name, last_name, dob, email, phone, address)
VALUES 
('Ramesh', 'Kumar', '1990-05-14', 'ramesh@gmail.com', '9876543210', 'Hyderabad'),
('Sita', 'Reddy', '1995-08-20', 'sita@gmail.com', '9876501234', 'Bangalore');

-- Accounts
INSERT INTO Accounts (customer_id, account_type, balance)
VALUES 
(1, 'Savings', 25000.00),
(2, 'Current', 50000.00);

-- Transactions
INSERT INTO Transactions (account_id, type, amount)
VALUES
(1, 'Deposit', 10000.00),
(1, 'Withdrawal', 2000.00),
(2, 'Deposit', 15000.00);

-- Loans
INSERT INTO Loans (customer_id, loan_type, loan_amount, interest_rate, start_date, end_date)
VALUES
(1, 'Home', 500000.00, 7.5, '2023-01-01', '2033-01-01'),
(2, 'Car', 300000.00, 8.0, '2024-02-01', '2029-02-01');

-- Select all customers
SELECT * FROM Customers;

SELECT DISTINCT account_type FROM Accounts;

-- Display all accounts having balance greater than 50,000
SELECT * FROM Accounts WHERE balance > 50000;

-- Display all customers ordered by last name in ascending order
SELECT * FROM Customers ORDER BY last_name ASC;

-- Display loans where loan amount is greater than 100,000 and loan type is Home Loan
SELECT * FROM Loans 
WHERE loan_amount > 100000 AND loan_type = 'Home Loan';


 -- Display accounts that are Savings accounts or have balance greater than 100,000
SELECT * FROM Accounts 
WHERE account_type = 'Savings' OR balance > 100000;

-- Display customers who are not from Hyderabad
SELECT * FROM Customers 
WHERE NOT address = 'Hyderabad';
 
--- Insert a new customer record into the Customers table
INSERT INTO Customers (first_name, last_name, email, phone, city)
VALUES ('Ravi', 'Kumar', 'ravi@email.com', '9876543210', 'Chennai');

-- Display customers whose email address is NULL(empty values)
SELECT * FROM Customers WHERE email IS NULL;

-- Increase the balance of account ID 2 by 5,000
UPDATE Accounts SET balance = balance + 5000 WHERE account_id = 2;

-- Delete the customer whose customer ID is 5
DELETE FROM Customers WHERE customer_id = 5;

-- Display the top 5 accounts with the highest balance
SELECT * FROM Accounts ORDER BY balance DESC LIMIT 5;


-- Find the minimum and maximum account balance
SELECT MIN(balance) AS MinBalance, MAX(balance) AS MaxBalance FROM Accounts;

-- Find the total number of customers
SELECT COUNT(*) AS TotalCustomers FROM Customers;

-- Calculate the total bank balance across all accounts
SELECT SUM(balance) AS TotalBankBalance FROM Accounts;

-- Calculate the average account balance
SELECT AVG(balance) AS AverageBalance FROM Accounts;

-- Display customers whose first name starts with 'R'
SELECT * FROM Customers WHERE first_name LIKE 'R%';  

-- Display customers whose email ends with '.com'
SELECT * FROM Customers WHERE email LIKE '%.com';     


-- Display accounts that are either Savings or Current accounts
SELECT * FROM Accounts WHERE account_type IN ('Savings','Current');


-- Display loans whose amount is between 50,000 and 200,000
SELECT * FROM Loans WHERE loan_amount BETWEEN 50000 AND 200000;


-- Display customer names along with their account type and balance
SELECT c.first_name, a.account_type, a.balance
FROM Customers c
INNER JOIN Accounts a ON c.customer_id = a.customer_id;

-- Display all customers along with their account details, including customers without accounts
SELECT c.first_name, a.account_type, a.balance
FROM Customers c
LEFT JOIN Accounts a ON c.customer_id = a.customer_id;

-- Display all accounts along with customer details, including accounts without customers
SELECT c.first_name, a.account_type, a.balance
FROM Customers c
RIGHT JOIN Accounts a ON c.customer_id = a.customer_id;


-- Display pairs of customers who belong to the same city
SELECT A.first_name AS Customer1, B.first_name AS Customer2, A.city
FROM Customers A, Customers B
WHERE A.city = B.city AND A.customer_id <> B.customer_id;

-- Add a DOB column to the Customers table
ALTER TABLE Customers ADD dob DATE;


-- Remove the DOB column from the Customers table
ALTER TABLE Customers DROP COLUMN dob;

-- Modify the balance column datatype in Accounts table
ALTER TABLE Accounts MODIFY balance DECIMAL(15,2);

-- Categorize accounts based on balance as Low, Medium, or High
SELECT account_id, balance,
CASE 
    WHEN balance < 10000 THEN 'Low Balance'
    WHEN balance BETWEEN 10000 AND 50000 THEN 'Medium Balance'
    ELSE 'High Balance'
END AS BalanceStatus
FROM Accounts;



-- 

-- Create a trigger to automatically update account balance after a transaction
DELIMITER $$

CREATE TRIGGER update_balance_after_transaction
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    IF NEW.type = 'Deposit' THEN
        UPDATE Accounts 
        SET balance = balance + NEW.amount 
        WHERE account_id = NEW.account_id;
    ELSEIF NEW.type = 'Withdrawal' THEN
        UPDATE Accounts 
        SET balance = balance - NEW.amount 
        WHERE account_id = NEW.account_id;
    END IF;
END$$

DELIMITER ;


-- Create a stored procedure to transfer money between two accounts
DELIMITER $$

CREATE PROCEDURE TransferMoney(
    IN sender_id INT,
    IN receiver_id INT,
    IN amount DECIMAL(12,2)
)
BEGIN
    -- Deduct from sender
    INSERT INTO Transactions (account_id, type, amount)
    VALUES (sender_id, 'Withdrawal', amount);

    -- Add to receiver
    INSERT INTO Transactions (account_id, type, amount)
    VALUES (receiver_id, 'Deposit', amount);
END$$

DELIMITER ;






