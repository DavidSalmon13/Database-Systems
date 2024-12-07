-- Name: David Schwartzman
-- Date 12/07/2024
-- In this script I will test point and range queries with and without indexes


-- creating an index on account_type and account_balance (range query 1 and range query 2)
   CREATE INDEX idx_account_type_balance ON accounts(account_type, balance);
   DROP INDEX idx_account_type_balance ON accounts;
   
   -- creating an index on branch name and balance (point query 2)
   CREATE INDEX idx_branch_balance ON accounts (branch_name, balance);
   DROP INDEX idx_branch_balance ON accounts;
   
   -- creating an index on branch name and acount type (point query 1)
   CREATE INDEX idx_branch_type ON accounts (branch_name, account_type);
   DROP INDEX idx_branch_type ON accounts;

DELIMITER $$
 DROP procedure if EXISTS calculate_avg_exec_time;
CREATE PROCEDURE calculate_avg_exec_time(query_string TEXT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE total_time BIGINT DEFAULT 0;
    DECLARE exec_time BIGINT;
    DECLARE avg_time BIGINT;
    DECLARE stmt_var TEXT; -- Declare a variable to hold the query as a TEXT (or VARCHAR)

    -- Loop to execute the query 10 times
    WHILE i <= 10 DO
        -- Capture the start time
        SET start_time = NOW(6);

        -- Check if the query string is not empty
        IF query_string IS NOT NULL AND query_string != '' THEN
            -- Assign the query string to stmt_var
            SET @stmt_var = query_string;

            -- Prepare the statement dynamically
            PREPARE stmt FROM @stmt_var;  -- Using 'stmt_var' to prepare the query
            
            -- Execute the prepared statement
            EXECUTE stmt;
            
            -- Deallocate the prepared statement after execution
            DEALLOCATE PREPARE stmt;
        ELSE
            -- If the query string is null or empty, raise an error
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Query string is empty or null';
        END IF;

        -- Capture the end time
        SET end_time = NOW(6);

        -- Calculate the time difference in microseconds
        SET exec_time = TIMESTAMPDIFF(MICROSECOND, start_time, end_time);

        -- Accumulate the total execution time
        SET total_time = total_time + exec_time;

        -- Increment the counter
        SET i = i + 1;
    END WHILE;

    -- Calculate the average execution time
    SET avg_time = total_time / 10;

    -- Return the average execution time
    SELECT avg_time AS non_indexed_point_query_2_time; -- 100,000 records
END$$

DELIMITER ;




-- set @start_time = now(6);


-- select count(*) 
-- from accounts
-- where account_type = 'savings' and balance > 20000; 

 -- SET @end_time = NOW(6);
 -- SELECT 
 -- TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
   -- TIMESTAMPDIFF(SECOND, @start_time, @end_time) AS execution_time_seconds;

-- range query 1
call calculate_avg_exec_time('select count(*) 
from accounts
where account_type = ''savings'' and balance > 20000');

-- range query 2
call calculate_avg_exec_time('SELECT * FROM accounts
WHERE account_type = ''Savings''
AND balance BETWEEN 5000 AND 20000');

-- point query 1
call calculate_avg_exec_time('select * from accounts
where branch_name = ''Downtown''
and  account_type = ''savings''');

-- point query 2
call calculate_avg_exec_time('select * from accounts
where branch_name = ''Perryridge''
and balance = 5000');


-- I completed all the code, all i need to do now is to increase the size of the table 
-- to 100,000 and to continue to mesuear the times.