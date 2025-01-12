# SQL-Data-Cleaning-Project

This project focuses on cleaning a dataset containing club member information. The dataset, named `club_member_info.csv`, consists of 2000 rows and was obtained with permission from iweld's **data_cleaning** project. 

## Project Overview  
The main goals of this project were:  
1. **Handling Missing Values**:  
   - Replaced `NULL` values with "Unknown" for better data consistency.  
2. **Regex-Based Formatting**:  
   - Corrected formatting errors and enforced consistent patterns using regex.  
3. **Address Parsing**:  
   - Split the `full_address` column into four new columns:  
     - **Street Number**  
     - **Street Name**  
     - **City**  
     - **State**  
4. **Date Conversion**:  
   - Converted string-based date values into PostgreSQL's native `DATE` format.  

## Dataset Description  
The dataset contains the following columns:  
- **`full_name`**: The full name of the club member.  
- **`age`**: The age of the member. Initially stored as a string and later cleaned and validated.  
- **`marital_status`**: The marital status of the member (e.g., Single, Married).  
- **`email`**: The email address of the member, cleaned for format consistency using regex.  
- **`phone`**: A 12-character field storing the member's phone number.  
- **`full_address`**: The complete address of the member, later parsed into separate fields for street number, street name, city, and state.  
- **`job_title`**: The occupation or job title of the member.  
- **`membership_date`**: The date when the member joined the club, initially stored as a string and converted into a proper `DATE` format.  

## Tools Used  
- **PostgreSQL**:  
  All cleaning operations were performed directly in PostgreSQL using SQL queries.  

## Skill Level  
This is an **entry-level project** designed to practice data cleaning techniques and SQL skills.  

## Acknowledgment  
The dataset was obtained with permission from 👉 [iweld's repository](https://github.com/iweld/data_cleaning). I highly encourage  you to check out his excellent work!  


  
