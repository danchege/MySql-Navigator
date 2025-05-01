# MySQL Navigator

## Overview
MySQL Navigator is a command-line tool designed to simplify MySQL database management. It provides an interactive menu-driven interface for performing common database operations such as running queries, managing databases, and handling tables. This tool is written in a batch script and requires MySQL to be installed and accessible via the system's PATH.

# MySQL Navigator 

## **Overview**
MySQL Navigator is batch script designed with the help of Artificial Intelligence to simplify MySQL database management tasks using CMD. It provides a user-friendly interface for performing common operations such as running queries, listing databases, exporting/importing databases, and backing up databases.


## Features

### 1. MySQL Connection
- Connect to a MySQL server by providing:
  - Server name (default: `localhost`)
  - Username (default: `root`)
  - Password (hidden input for security)
- Automatically verifies the connection before proceeding.

### 2. Database Operations
- **List Databases**: View all available databases on the server.
- **Select Database**: Choose a database to work with.
- **Backup Database**:
  - Backup the current database.
  - Backup all databases.
- **Export Database**:
  - Export the current database to an SQL file.
  - Export another database by specifying its name.
- **Import Database**: Import an SQL file into the current database.
- **Drop Database**:
  - Drop the currently selected database.
  - Drop another database by specifying its name.
- **Delete Database Content**:
  - Delete all tables in the current database.
  - Delete all tables in another database.

### 3. Table Operations
- **Show Tables**: List all tables in the selected database.
- **Describe Table**: View the structure of a specific table.
- **Create Table**:
  - Define table name, columns, and data types.
  - Optionally set a primary key.
- **Insert Records**: Add new records to a table by specifying column values.
- **Update Records**: Modify existing records in a table using a `SET` and `WHERE` clause.
- **Delete Records**: Remove records from a table using a `WHERE` clause.
- **Truncate Table**: Delete all records from a table without dropping its structure.
- **Alter Table**:
  - Add a new column.
  - Drop an existing column.
  - Modify the data type of an existing column.

### 4. Query Execution
- **Run Query**: Execute custom SQL queries on the selected database.

### 5. Pre-Built Operations
- **ALTER TABLE**: Add, drop, or modify columns in a table.
- **TRUNCATE TABLE**: Delete all records from a table.
- **CREATE TABLE**: Create a new table with user-defined columns and data types.
- **INSERT INTO**: Add new records to a table.
- **UPDATE**: Modify existing records in a table.
- **DELETE**: Remove records from a table.
- **DESCRIBE TABLE**: View the structure of a table.
- **SHOW DATABASES**: List all databases on the server.

## Usage Instructions

### Prerequisites
1. MySQL must be installed and added to the system's PATH.
2. Ensure the following directories exist in the same folder as the script:
   - `imports`: For SQL files to be imported.
   - `exports`: For exported SQL files.
   - `backups`: For database backup files.

### Running the Script
1. Double-click the `MySql Navigator.bat` file or run it from the command line.
2. Follow the on-screen prompts to perform operations.

### Menu Navigation
- Use the numeric or letter keys to select options from the menu.
- Confirm actions when prompted to avoid accidental changes.

## Example Scenarios

### 1. Delete Database Content
- Choose option `9` from the main menu.
- Select whether to delete content from the current database or another database.
- Confirm the deletion to remove all tables from the selected database.

### 2. Backup a Database
- Choose option `5` from the main menu.
- Select whether to back up the current database or all databases.
- The backup file will be saved in the `backups` directory with a timestamp.

### 3. Run a Custom Query
- Choose option `1` from the main menu.
- Enter your SQL query when prompted.
- View the query results directly in the terminal.

---

## Error Handling
- The script provides detailed error messages for common issues, such as:
  - Invalid database or table names.
  - Failed MySQL connections.
  - Permission issues during operations.

---

## Notes
- This tool is designed for educational and personal use. Use caution when performing destructive operations like dropping databases or truncating tables.
- Always back up your data before making significant changes.

---

## Author
**Created by Daniel Chege**  
Feel free to modify and extend the script to suit your needs!
