-- Name: David Schwartzman
-- Date 12/07/2024
-- In this script I will populate my table with 50,000, 100,000 and then 150,000 records.



-- Set necessary settings

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;
SET GLOBAL max_allowed_packet = 256 * 1024 * 1024;  -- 256 MB

 CREATE TABLE accounts (
   account_num CHAR(5) PRIMARY KEY,    -- 5-digit account number (e.g., 00001, 00002, ...)
   branch_name VARCHAR(50),            -- Branch name (e.g., Brighton, Downtown, etc.)
   balance DECIMAL(10, 2),             -- Account balance, with two decimal places (e.g., 1000.50)
   account_type VARCHAR(50)            -- Type of the account (e.g., Savings, Checking)
 );

ALTER TABLE accounts MODIFY account_num CHAR(6);


-- Drop the existing procedure if it exists
DROP PROCEDURE IF EXISTS generate_accounts;

-- Change delimiter to allow semicolons inside the procedure
DELIMITER $$

-- Create the procedure to generate accounts
CREATE PROCEDURE generate_accounts()
BEGIN
  DECLARE i INT DEFAULT 100002;
  DECLARE branch_name VARCHAR(50);
  DECLARE account_type VARCHAR(50);

  -- Loop to generate 50,000 account records
  WHILE i <= 150000 DO
    -- Randomly select a branch from the list of branches
    SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
    -- Randomly select an account type
    SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
    
    -- Insert account record
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 6, '0'),                   -- Account number, padded to 5 digits
      branch_name,                       -- Randomly selected branch name
      ROUND((RAND() * 100000), 2),       -- Random balance between 0 and 100,000
      account_type                       -- Randomly selected account type (Savings/Checking)
    );

    SET i = i + 1;
  END WHILE;
END$$

-- Reset the delimiter back to the default semicolon
DELIMITER ;

-- Execute the procedure to generate records
CALL generate_accounts();

-- Verify record count
SELECT count(*) FROM accounts;

-- Display first 10 records
SELECT * FROM accounts LIMIT 10;

select count(*) from accounts;