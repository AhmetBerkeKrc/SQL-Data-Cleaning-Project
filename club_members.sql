CREATE SCHEMA club_members;

SET search_path = club_members;

---- DATABASE SETUP ----

CREATE TABLE members (
	full_name TEXT,
	age INTEGER,
	marital_status TEXT,
	email TEXT,
	phone VARCHAR(12),
	full_address TEXT,
	job_title TEXT,
	membership_date TEXT
);

SELECT * FROM members;

COPY members(full_name, age, marital_status, email, phone, full_address, job_title, membership_date)
FROM 'C:\Users\HP\Desktop\datasets\git\club_member_info.csv'
DELIMITER ','
CSV HEADER
NULL AS '';


-------- DATA CLEANING -------- 

CREATE TABLE plygrnd AS SELECT * FROM members; -- I created a playground table to implement manipulations throughout the project

ALTER TABLE plygrnd ADD COLUMN row_id SERIAL;  -- It is a good practice to have a unique identifier for each row.


--******************************************************************

---- full_name

SELECT * FROM plygrnd;

SELECT COUNT(*)
FROM plygrnd
WHERE full_name IS NULL;

-- Checking the names contain any characters other than letters and space.
SELECT full_name 
FROM plygrnd
WHERE full_name ~'[^a-zA-Z\s]';

-- Some names have '???' in front of them. We need to handle it by removing them.
UPDATE plygrnd
SET full_name = REGEXP_REPLACE(full_name,'\?{3}','') 
WHERE full_name ~'\?{3}';

-- Trim the white spaces of names. 
UPDATE plygrnd
SET full_name = TRIM(full_name);

-- There are redundant spaces around single quotion mark ('). I remove them.  
SELECT 
	RTRIM((split_part(full_name, '''', 1)), ' ') || '''' ||
	LTRIM((split_part(full_name, '''', 2)),' ')
FROM plygrnd
WHERE full_name LIKE '%''%';

UPDATE plygrnd
SET full_name =
	RTRIM((split_part(full_name, '''', 1)), ' ') || '''' ||
	LTRIM((split_part(full_name, '''', 2)),' ')
WHERE full_name LIKE '%''%';

-- Capitalize the names
UPDATE plygrnd 
SET full_name = INITCAP(full_name);


--******************************************************************

---- marital_status

-- Checking the distinct values of marital_status. 

SELECT DISTINCT(marital_status)
FROM plygrnd;

/* There are 6 different statuses currently: divored, single, [null], separated, divorced, married. 
We need to fix the spelling mistake of "divored" and replace [null] values with 'Unknown'. */ 

UPDATE plygrnd
SET marital_status = 'divorced'
WHERE marital_status = 'divored';

UPDATE plygrnd
SET marital_status = 'Unknown'
WHERE marital_status IS NULL;

-- Capitalize the categories.
UPDATE plygrnd
SET marital_status = INITCAP(marital_status);

--******************************************************************

---- email Column

/* There are some certain rules to check on emails  
1) It is always good practice to avoid white spaces if there are any.
2) Emails must have '@' and '.' characters. We may need to remove the samples that don't meet this criteria
3) We need to standardize emails as lowercase.
4) For such a club registiration project, most of the time, emails must be unique to each member. So, it could 
   be a good approach to check duplicates.
*/


-- Rule #1 Avoiding whitespaces
UPDATE plygrnd
SET email = TRIM(email);

SELECT email
FROM plygrnd
WHERE email ~ '\s'; -- No emails with white space

-- Rule #2 Making sure there is no email without '@' and '.'.

SELECT email 
FROM plygrnd
WHERE email NOT LIKE '%@%'
	  OR email NOT LIKE '%.%'; -- Curent emails do not violate this criteria

/*
	For a further analysis, let's also check there is no email contain double @ or consecutive dots ('..').
*/

SELECT email 
FROM plygrnd
WHERE email ~ '(\.\.)+'; -- No consecutive dots.

SELECT email 
FROM plygrnd
WHERE email ~ '@.*@'; -- No email with double @. 

-- Rule #3 Convert mails to lowercase

UPDATE plygrnd
SET email = LOWER(email);

-- Rule #4 Checking the duplicates


SELECT * 
FROM plygrnd p 
JOIN (
SELECT 
	email
FROM plygrnd
GROUP BY email
HAVING COUNT(*) != 1) e
ON p.email= e.email;


/* 
   There are duplicates emails, so registirations. I joined the duplicate emails with members table so I can see the difference between 
   each duplicate registiration. When I observed the join result, one of them (Haskell Braden) has different age in each registiration. I will 
   remove the one with the absurd age value (322).
*/

DELETE FROM plygrnd
WHERE full_name = 'Haskell Braden'
	  AND age = 322;

/*
	Rest of the duplicates differ in marital_status column or completly same within themselves. It would be benefitial to make 
	marital_status column 'Unknown' for the duplicate registiratons which have more than one distinct marital_status.
*/

UPDATE plygrnd
SET marital_status = 'Unknown'
WHERE full_name IN (
	SELECT 
		full_name
	FROM plygrnd
	GROUP BY full_name
	HAVING COUNT(DISTINCT(marital_status)) > 1
);

/* Now, we can remove all duplicates confidently */

WITH cte AS (
    SELECT 
        row_id,  
        email,
        ROW_NUMBER() OVER (PARTITION BY email ORDER BY row_id) AS rn
    FROM plygrnd
)

DELETE FROM plygrnd
WHERE row_id IN (
    SELECT row_id
    FROM cte
    WHERE rn > 1  
);

--******************************************************************

-- age Column

/*
	When I was dealing with the email column, we saw an absurd age. I suspect the existence of more values like this.
	I will first check if there are any value greater than 100. I assume that those ages are values their last 
	digit was pressed or inserted by mistake or something. However, this is just an assumption. In real life,
	we need to consider the limitations of the project or the consequences of the such a manipulation. 
*/

SELECT * FROM plygrnd
WHERE age > 100;

/*
	There are 14 ages greater than 100. I will remove the last digit of each year. To do this, it is enough to divide them
	by 10 since they are integer values.
*/

UPDATE plygrnd
SET age = (age / 10)
WHERE age > 100;

--******************************************************************

-- phone Column

/*
	For the phone numbers, first, I will check the null values. I will simply replace nulls with 'Unknown'. 
	Next, I will check the phone numbers if they contain any invalid characters. I will replace the invalid ones
	with 'INVALID NUM'
*/

SELECT COUNT(*) 
FROM plygrnd
WHERE phone IS NULL; -- There are 9 null numbers in total.

-- Setting the null values as Unknown
UPDATE plygrnd
SET phone = 'Unknown'
WHERE phone IS NULL;

-- Checking Invalid Characters
SELECT * 
FROM plygrnd
WHERE phone ~ '[^0-9-]'; -- It seems like phone numbers does not contain any invalid characters


--******************************************************************

-- full_address Column

/*
 Full address has a pretty good structre. We can clearly see it is built as 
 	'[street_number] [street_name], [city], [state] '.
 we can create new columns out of each component of the full_address column. 
*/


SELECT 
	MAX(LENGTH(TRIM(SPLIT_PART(full_address, ' ',1))))
FROM plygrnd; -- Street number has maximum 5 characters. That's why we can apply lpad for the numbers less then 5 characters


ALTER TABLE plygrnd
ADD COLUMN street_num TEXT,
ADD COLUMN street TEXT,
ADD COLUMN city TEXT,
ADD COLUMN state TEXT;


WITH cte AS (
SELECT
	row_id,
	LPAD(TRIM(SPLIT_PART(full_address, ' ',1)), 5, '0') AS street_num,
	INITCAP(SUBSTRING(SPLIT_PART(full_address, ',',1), POSITION(' ' IN full_address)+1)) AS street,
	INITCAP(TRIM(SPLIT_PART(full_address, ',',2))) AS city,
	INITCAP(TRIM(SPLIT_PART(full_address, ',',3))) AS state
FROM plygrnd
)

UPDATE plygrnd AS p 
SET
	street_num = cte.street_num,
	street = cte.street,
	city = cte.city,
	state = cte.state
FROM cte
WHERE p.row_id = cte.row_id;


-- Check the existince of unusual characters in address columns.
SELECT street_num, street, city, state
FROM plygrnd 
WHERE street_num ~ '[^0-9]'
	  OR street ~ '[^a-zA-Z\s]'
	  OR city ~ '[^a-zA-Z\s]'
	  OR state ~ '[^a-zA-Z\s]';

/* According to this query, there is only one state name 'Tej+F823as' that violates the rule.
this state should be 'Texas' since the city is Houston within the related row.*/

UPDATE plygrnd
SET state = 'Texas'
WHERE state = 'Tej+F823as';

-- Updating the full address
UPDATE plygrnd
SET full_address = street_num || ' ' || street || ', ' ||
				   city || ', ' || state;
SELECT * FROM plygrnd;


--******************************************************************

-- job_title

/*
	As a result of my observation, I found job_title clean. I will implement usual procedures like
	trimming, capatilizing, checking if unusual characters and replacing nulls. Some job titles also 
	include their position levels (I, II, III, and IV). We could also create maybe extra columns which
	indicate their positions. However, I will not do it.
*/

-- 
-- Checking null values.
SELECT COUNT(*)
FROM plygrnd
WHERE job_title IS NULL; -- There are 39 null values in total.

UPDATE plygrnd
SET job_title = 'Unknown'
WHERE job_title IS NULL;

-- Trimming
UPDATE plygrnd
SET job_title = TRIM(job_title);

-- Checking unusual characters
SELECT job_title
FROM plygrnd
WHERE job_title ~ '[^a-zA-ZIV\s/]'; -- I checked alphabet, rome numbers, space, and slash (/). There are no other character than these ones.

SELECT * FROM plygrnd;


--******************************************************************

-- membership_date

/*
	This column also looked clean to me. I will apply the same procedure.
*/

-- Trimming white spaces
UPDATE plygrnd
SET membership_date = TRIM(membership_date);

-- Checking nulls
SELECT COUNT(*)
FROM plygrnd
WHERE membership_date IS NULL; -- No null value

-- Checking unusual characters
SELECT membership_date
FROM plygrnd
WHERE membership_date ~ '[^0-9/]'; -- Data is also clean in terms of this aspect

SELECT membership_date
FROM plygrnd;

/* I want to reformat date text as YYYY-MM-DD so I can convert them to DATE type*/

-- Updating TEXT format
UPDATE plygrnd
SET membership_date =
	SPLIT_PART(membership_date, '/',3) || '-' ||
	LPAD(SPLIT_PART(membership_date, '/',1),2,'0') || '-' ||
	LPAD(SPLIT_PART(membership_date, '/',2),2,'0');

-- Altering column type
ALTER TABLE plygrnd
ALTER COLUMN membership_date
SET DATA TYPE DATE
USING membership_date::DATE;

SELECT * 
FROM plygrnd
LIMIT(10);



--******************************************************************

-- FINAL TABLE

CREATE TABLE cleaned AS
SELECT 
    full_name, age, marital_status, email, phone, full_address,
    street_num, street, city, state, job_title, membership_date
FROM plygrnd;


SELECT * FROM cleaned;



















