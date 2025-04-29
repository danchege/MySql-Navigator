MySql Navigator.

# MySQL Navigator - README

## **Overview**
MySQL Navigator is an AI generated batch script designed to simplify MySQL database management tasks. It provides a user-friendly interface for performing common operations such as running queries, listing databases, exporting/importing databases, and backing up databases.

---

## **Requirements**
### **System Requirements**
1. **Operating System**: Windows
2. **MySQL**: Ensure MySQL is installed and added to the system's PATH.
   - To verify, run `mysql --version` in the Command Prompt.
3. **Permissions**: The user must have sufficient privileges to perform database operations.

### **Folder Structure**
The script automatically creates the following directories if they do not exist:
- imports: For storing SQL files to be imported.
- exports: For storing exported SQL files.
- backups: For storing database backups.

---

## **How to Use**
### **1. Setup**
1. Place the script (`Mysql Navigator.bat`) in a directory of your choice.
2. Ensure MySQL is installed and accessible via the command line.

### **2. Running the Script**
1. Double-click the `Mysql Navigator.bat` file to start the script.
2. Follow the on-screen prompts to perform operations.

---

## **Features**
### **Main Menu**
After connecting to MySQL, the script displays the following options:
```
1. Run Query
2. List Databases
3. Select Database
4. Show Tables (if database selected)
5. Describe Table (if database selected)
6. Backup Database
7. Export Database
8. Import Database
9. Drop Database (if selected)
A. Delete Database
B. Exit
```

### **Feature Details**
#### **1. Run Query**
- Allows you to execute SQL queries on the currently selected database.
- Type `exit` to return to the main menu.

#### **2. List Databases**
- Displays all available databases on the MySQL server.

#### **3. Select Database**
- Lets you select a database to work with.
- Verifies that the database exists before proceeding.

#### **4. Show Tables**
- Displays all tables in the currently selected database.

#### **5. Describe Table**
- Prompts you to enter a table name and displays its structure.

#### **6. Backup Database**
- **Option 1**: Backup a specific database.
- **Option 2**: Backup all databases.
- Backups are stored in the backups folder with a timestamped filename.

#### **7. Export Database**
- Exports a database to an SQL file.
- The file is saved in the exports folder.

#### **8. Import Database**
- **Option 1**: Import into a new database.
  - Prompts for a new database name and validates it.
  - Creates the database and imports the SQL file.
- **Option 2**: Import into an existing database.
  - Prompts for an existing database name and validates it.
  - Imports the SQL file into the selected database.
- SQL files must be placed in the imports folder.

#### **9. Drop Database**
- Drops the currently selected database after confirmation.
- This action is irreversible.

#### **A. Delete Database**
- Prompts for a database name and deletes it after confirmation.
- Verifies that the database exists before deletion.

#### **B. Exit**
- Exits the script.

---

## **Error Handling**
1. **MySQL Not Found**:
   - If MySQL is not installed or not added to the PATH, the script will display an error and exit.
2. **Invalid Database Name**:
   - Database names must contain only letters, numbers, and underscores.
3. **File Not Found**:
   - For import/export operations, the script checks if the specified file exists.
4. **Insufficient Privileges**:
   - If the user lacks the necessary privileges, the script will display an error.

---

## **Security**
- Password input is hidden using a VBScript to ensure security.
- The script deletes the temporary VBScript immediately after use.

---

## **Example Usage**
### **1. Importing a New Database**
1. Select option `8` (Import Database).
2. Choose option `1` (Import new database).
3. Enter a valid database name (e.g., `my_database`).
4. Place the SQL file in the imports folder (e.g., `imports\my_database.sql`).
5. The script creates the database and imports the SQL file.

### **2. Backing Up a Database**
1. Select option `6` (Backup Database).
2. Choose option `1` (Backup specific database).
3. Enter the database name or press Enter to use the currently selected database.
4. The backup file is saved in the backups folder.

---

## **Notes**
- Ensure the MySQL server is running before using the script.
- Use valid SQL syntax for queries and import files.
- Always verify backups and exports for completeness.

---

## **Credits**
**Created by**: Daniel Chege  
This script is designed with the help of various AIs to simplify MySQL database management for users of all skill levels.
