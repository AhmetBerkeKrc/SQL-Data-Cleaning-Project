# SQL-Data-Cleaning-Project

This project focuses on cleaning a dataset containing club member information. The dataset, named `club_member_info.csv`, consists of 2000 rows and was obtained with permission from [iweld's data_cleaning repository](https://github.com/iweld/data_cleaning).  

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

## Tools Used  
- **PostgreSQL**:  
  All cleaning operations were performed directly in PostgreSQL using SQL queries.  

## Skill Level  
This is an **entry-level project** designed to practice data cleaning techniques and SQL skills.  

## Acknowledgment  
The dataset was obtained with permission from [iweld's repository](https://github.com/iweld/data_cleaning). Don't hesitate to check out his excellent work!  

## How to Use  
1. Clone this repository:  
   ```bash
   git clone https://github.com/yourusername/club-member-data-cleaning.git
