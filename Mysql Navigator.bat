@echo off
setlocal enabledelayedexpansion
mode con: cols=80 lines=30
color 0A

:: Created by Daniel Chege
echo  --------------------------------------------------
echo              MYSQL NAVIGATOR
echo              Created by Daniel Chege
echo  --------------------------------------------------
echo.

:: Check if mysql exists
where mysql >nul 2>&1 || (
    echo ERROR: mysql not found. Ensure MySQL is installed and added to your PATH.
    pause
    exit /b
)

:: Ensure directories for imports and exports exist
if not exist "imports" mkdir imports
if not exist "exports" mkdir exports
if not exist "backups" mkdir backups

:CONNECT_MYSQL
cls
echo.
echo  --------------------------------------------------
echo            START MYSQL CONNECTION
echo           Created by Daniel Chege
echo  --------------------------------------------------
echo.
set /p "server=Enter Server Name (default: localhost): "
if "%server%"=="" set "server=localhost"

set /p "username=Enter Username (default: root): "
if "%username%"=="" set "username=root"

:: Hide password input using VBScript
echo WScript.StdOut.WriteLine WScript.StdIn.ReadLine > hide_password.vbs
echo Enter Password: 
for /f "delims=" %%p in ('cscript //nologo hide_password.vbs') do set "password=%%p"
del hide_password.vbs

:: Set up the authentication command
set "auth_cmd=-h %server% -u %username%"
if not "%password%"=="" set "auth_cmd=%auth_cmd% -p%password%"

:: Test connection
mysql %auth_cmd% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to connect to MySQL. Check your credentials and try again.
    pause
    goto CONNECT_MYSQL
)

set "current_db="

:CONTINUOUS_OPERATIONS
cls
echo.
echo  --------------------------------------------------
echo                 MYSQL OPERATIONS
echo              Created by Daniel Chege
echo  --------------------------------------------------
if defined current_db echo Current Database: %current_db%
echo.
echo   1. Run Query (Free-form)
echo   2. Run Pre-Built Operations
echo   3. List Databases
echo   4. Select Database
echo   5. Backup Database
echo   6. Export Database
echo   7. Import Database
echo   8. Drop Database
echo   9. Delete Database Content
echo   A. Exit
echo.

choice /c 123456789A /n /m "Select operation (1-10): "

if errorlevel 10 exit /b
if errorlevel 9 goto DELETE_DATABASE
if errorlevel 8 goto DROP_DATABASE
if errorlevel 7 goto IMPORT_DATABASE
if errorlevel 6 goto EXPORT_DATABASE
if errorlevel 5 goto BACKUP_DATABASE
if errorlevel 4 goto SELECT_DATABASE
if errorlevel 3 goto LIST_DATABASES
if errorlevel 2 goto PRE_BUILT_OPERATIONS
if errorlevel 1 goto RUN_QUERY

:RUN_QUERY
cls
echo.
echo  --------------------------------------------------
echo                  RUN QUERY
echo  --------------------------------------------------
echo.
if not defined current_db (
    echo ERROR: Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)

:QUERY_LOOP
set /p "query=Enter your SQL query (or type EXIT to return to the main menu): "
if /i "%query%"=="EXIT" goto CONTINUOUS_OPERATIONS
if "%query%"=="" (
    echo ERROR: No query specified.
    pause
    goto QUERY_LOOP
)

mysql %auth_cmd% -D %current_db% -e "%query%"
if errorlevel 1 (
    echo ERROR: Failed to execute query. Please check your syntax.
) else (
    echo Query executed successfully.
)
pause
goto QUERY_LOOP

:SELECT_DATABASE
cls
echo.
echo  --------------------------------------------------
echo               SELECT DATABASE
echo  --------------------------------------------------
echo.
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
set /p "db_name=Enter database name to select: "
if "%db_name%"=="" (
    echo ERROR: No database specified.
    pause
    goto CONTINUOUS_OPERATIONS
)

:: Verify database exists
mysql %auth_cmd% -e "USE %db_name%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Database '%db_name%' does not exist or access denied.
    pause
    goto CONTINUOUS_OPERATIONS
)

set "current_db=%db_name%"
echo Database '%db_name%' selected successfully.
pause
goto CONTINUOUS_OPERATIONS

:LIST_DATABASES
cls
echo.
echo  --------------------------------------------------
echo               LIST DATABASES
echo  --------------------------------------------------
echo.
mysql %auth_cmd% -e "SHOW DATABASES;"
pause
goto CONTINUOUS_OPERATIONS

:SHOW_TABLES
cls
echo.
echo  --------------------------------------------------
echo                SHOW TABLES
echo                Created by Daniel Chege
echo  --------------------------------------------------
echo.
if not defined current_db (
    echo ERROR: Please select a database first.
    pause
    goto PRE_BUILT_OPERATIONS
)
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
if errorlevel 1 (
    echo ERROR: Failed to retrieve tables. Check your connection or permissions.
    pause
    goto PRE_BUILT_OPERATIONS
)
pause
goto PRE_BUILT_OPERATIONS

:DESCRIBE_TABLE
cls
echo.
echo  --------------------------------------------------
echo               DESCRIBE TABLE
echo  --------------------------------------------------
echo.
if not defined current_db (
    echo ERROR: Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)
echo Available tables:
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
echo.
set /p "table=Enter table name to describe: "
if "%table%"=="" (
    echo ERROR: No table specified.
    pause
    goto CONTINUOUS_OPERATIONS
)
mysql %auth_cmd% -D %current_db% -e "DESCRIBE %table%;"
pause
goto CONTINUOUS_OPERATIONS

:BACKUP_DATABASE
cls
echo  --------------------------------------------------
echo               BACKUP DATABASE
echo  --------------------------------------------------
echo.
echo Backup options:
echo   1. Backup current database (%current_db%)
echo   2. Backup all databases
echo   3. Back to menu
echo.
choice /c 123 /n /m "Select option (1-3): "

if errorlevel 3 goto CONTINUOUS_OPERATIONS
if errorlevel 2 goto BACKUP_ALL_DATABASES
if errorlevel 1 goto BACKUP_SINGLE_DATABASE

:BACKUP_ALL_DATABASES
cls
echo Backing up all databases...
echo.

REM Create backup directory if it doesn't exist
if not exist "backups" mkdir backups

REM Get current timestamp for backup file
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set "date=%%c-%%a-%%b"
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set "time=%%a%%b"
)

set "backup_file=backups\all_databases_%date%_%time%.sql"

REM Backup all databases except system ones
echo Backing up all user databases to: %backup_file%
mysqldump %auth_cmd% --all-databases --routines --events --triggers --add-drop-database > "%backup_file%"

if errorlevel 1 (
    echo ERROR: Backup failed.
) else (
    echo.
    echo Backup completed successfully!
    echo Location: %backup_file%
    echo.
    echo Backup file contents:
    dir "%backup_file%"
)
pause
goto CONTINUOUS_OPERATIONS

:BACKUP_SINGLE_DATABASE
cls
if "%current_db%"=="" (
    echo No database selected.
    pause
    goto BACKUP_DATABASE
)

REM Create backup directory if it doesn't exist
if not exist "backups" mkdir backups

REM Get current timestamp for backup file
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set "date=%%c-%%a-%%b"
)
for /f "tokens=1-2 delims=: " %%a in ('time /t') do (
    set "time=%%a%%b"
)

set "backup_file=backups\%current_db%_%date%_%time%.sql"

echo Backing up database '%current_db%' to: %backup_file%
mysqldump %auth_cmd% --routines --events --triggers %current_db% > "%backup_file%"

if errorlevel 1 (
    echo ERROR: Backup failed.
) else (
    echo.
    echo Backup completed successfully!
    echo Location: %backup_file%
    echo.
    echo Backup file contents:
    dir "%backup_file%"
)
pause
goto CONTINUOUS_OPERATIONS

:EXPORT_DATABASE
cls
echo.
echo  --------------------------------------------------
echo               EXPORT DATABASE
echo  --------------------------------------------------
echo.
if not defined current_db (
    echo ERROR: No database selected. Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)
echo Current Database: %current_db%
echo.
echo   1. Export Current Database
echo   2. Export Another Database
echo   3. Back to Main Menu
echo.
choice /c 123 /n /m "Select option (1-3): "

if errorlevel 3 goto CONTINUOUS_OPERATIONS
if errorlevel 2 goto EXPORT_ANOTHER_DATABASE
if errorlevel 1 goto EXPORT_CURRENT_DATABASE

:EXPORT_CURRENT_DATABASE
set "export_file=exports\%current_db%_export.sql"
echo Exporting current database '%current_db%' to: %export_file%
mysqldump %auth_cmd% %current_db% > "%export_file%"
if errorlevel 1 (
    echo ERROR: Export failed.
) else (
    echo Database exported successfully to: %export_file%
)
pause
goto CONTINUOUS_OPERATIONS

:EXPORT_ANOTHER_DATABASE
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
set /p "db_to_export=Enter the name of the database to export: "
if "%db_to_export%"=="" (
    echo ERROR: No database specified.
    pause
    goto CONTINUOUS_OPERATIONS
)
set "export_file=exports\%db_to_export%_export.sql"
echo Exporting database '%db_to_export%' to: %export_file%
mysqldump %auth_cmd% %db_to_export% > "%export_file%"
if errorlevel 1 (
    echo ERROR: Export failed.
) else (
    echo Database exported successfully to: %export_file%
)
pause
goto CONTINUOUS_OPERATIONS

:IMPORT_DATABASE
cls
echo.
echo  --------------------------------------------------
echo               IMPORT DATABASE
echo  --------------------------------------------------
echo.
echo Available import files in imports directory:
dir /b "imports\*.sql"
echo.
set /p "import_file=Enter the name of the SQL file to import (from imports directory): "
if "%import_file%"=="" (
    echo ERROR: No file specified.
    pause
    goto CONTINUOUS_OPERATIONS
)

:: Append .sql extension if not provided
if /i "%import_file:~-4%" NEQ ".sql" set "import_file=%import_file%.sql"

if not exist "imports\%import_file%" (
    echo ERROR: File not found: imports\%import_file%
    pause
    goto CONTINUOUS_OPERATIONS
)

echo.
choice /c CN /n /m "Do you want to (C)reate a new database or (N)ot? "
if errorlevel 2 goto IMPORT_TO_EXISTING

:CREATE_NEW_DATABASE
set /p "new_db=Enter the name of the new database to create: "
if "%new_db%"=="" (
    echo ERROR: No database name specified.
    pause
    goto CONTINUOUS_OPERATIONS
)

:: Create the new database
mysql %auth_cmd% -e "CREATE DATABASE %new_db%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to create database '%new_db%'. It may already exist.
    pause
    goto CONTINUOUS_OPERATIONS
)

:: Use the new database for import
set "current_db=%new_db%"
echo Database '%new_db%' created successfully.
goto IMPORT_FILE

:IMPORT_TO_EXISTING
if not defined current_db (
    echo ERROR: No database selected. Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)

:IMPORT_FILE
echo Importing into database: %current_db%
mysql %auth_cmd% %current_db% < "imports\%import_file%"
if errorlevel 1 (
    echo ERROR: Import failed.
) else (
    echo Database imported successfully.
    echo Refreshing database list...
    mysql %auth_cmd% -e "SHOW DATABASES;"
)
pause
goto CONTINUOUS_OPERATIONS

:DROP_DATABASE
cls
echo.
echo  --------------------------------------------------
echo               DROP DATABASE
echo  --------------------------------------------------
echo.
if not defined current_db (
    echo ERROR: No database selected. Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)
echo Current Database: %current_db%
echo.
echo   1. Drop Current Database
echo   2. Drop Another Database
echo   3. Back to Main Menu
echo.
choice /c 123 /n /m "Select option (1-3): "

if errorlevel 3 goto CONTINUOUS_OPERATIONS
if errorlevel 2 goto DROP_ANOTHER_DATABASE
if errorlevel 1 goto DROP_CURRENT_DATABASE

:DROP_CURRENT_DATABASE
set /p "confirm=Are you sure you want to drop the current database '%current_db%'? (Y/N): "
if /i "%confirm%" neq "Y" goto CONTINUOUS_OPERATIONS
mysql %auth_cmd% -e "DROP DATABASE %current_db%;"
if errorlevel 1 (
    echo ERROR: Failed to drop database '%current_db%'.
) else (
    echo Database '%current_db%' dropped successfully.
    set "current_db="
)
pause
goto CONTINUOUS_OPERATIONS

:DROP_ANOTHER_DATABASE
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
set /p "db_to_drop=Enter the name of the database to drop: "
if "%db_to_drop%"=="" (
    echo ERROR: No database specified.
    pause
    goto CONTINUOUS_OPERATIONS
)
set /p "confirm=Are you sure you want to drop the database '%db_to_drop%'? (Y/N): "
if /i "%confirm%" neq "Y" goto CONTINUOUS_OPERATIONS
mysql %auth_cmd% -e "DROP DATABASE %db_to_drop%;"
if errorlevel 1 (
    echo ERROR: Failed to drop database '%db_to_drop%'.
) else (
    echo Database '%db_to_drop%' dropped successfully.
    if "%db_to_drop%"=="%current_db%" set "current_db="
)
pause
goto CONTINUOUS_OPERATIONS

:DELETE_DATABASE
cls
echo.
echo  --------------------------------------------------
echo               DELETE DATABASE CONTENT
echo  --------------------------------------------------
echo.
echo   1. Delete Current Database Content
echo   2. Delete Another Database Content
echo   3. Back to Main Menu
echo.
choice /c 123 /n /m "Select option (1-3): "

if errorlevel 3 goto CONTINUOUS_OPERATIONS
if errorlevel 2 goto DELETE_ANOTHER_DATABASE
if errorlevel 1 goto DELETE_CURRENT_DATABASE

:DELETE_CURRENT_DATABASE
if not defined current_db (
    echo ERROR: No database selected. Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)
set /p "confirm=Are you sure you want to delete all tables in the current database '%current_db%'? (Y/N): "
if /i "%confirm%" neq "Y" goto CONTINUOUS_OPERATIONS

:: Delete all tables in the current database
for /f "delims=" %%t in ('mysql %auth_cmd% -D %current_db% -N -e "SHOW TABLES;"') do (
    echo Deleting table: %%t
    mysql %auth_cmd% -D %current_db% -e "DROP TABLE %%t;"
    if errorlevel 1 (
        echo ERROR: Failed to delete table '%%t'.
    ) else (
        echo Table '%%t' deleted successfully.
    )
)

echo.
echo All tables in the current database '%current_db%' have been deleted.
pause
goto CONTINUOUS_OPERATIONS

:DELETE_ANOTHER_DATABASE
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
set /p "db_to_delete=Enter the name of the database to delete content from: "
if "%db_to_delete%"=="" (
    echo ERROR: No database specified.
    pause
    goto CONTINUOUS_OPERATIONS
)
set /p "confirm=Are you sure you want to delete all tables in the database '%db_to_delete%'? (Y/N): "
if /i "%confirm%" neq "Y" goto CONTINUOUS_OPERATIONS

:: Delete all tables in the specified database
for /f "delims=" %%t in ('mysql %auth_cmd% -D %db_to_delete% -N -e "SHOW TABLES;"') do (
    echo Deleting table: %%t
    mysql %auth_cmd% -D %db_to_delete% -e "DROP TABLE %%t;"
    if errorlevel 1 (
        echo ERROR: Failed to delete table '%%t'.
    ) else (
        echo Table '%%t' deleted successfully.
    )
)

echo.
echo All tables in the database '%db_to_delete%' have been deleted.
pause
goto CONTINUOUS_OPERATIONS

:PRE_BUILT_OPERATIONS
cls
if not defined current_db (
    echo ERROR: No database selected! Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)
echo.
echo  --------------------------------------------------
echo           PRE-BUILT SQL OPERATIONS
echo           Created by Daniel Chege
echo  --------------------------------------------------
echo.
echo Current Database: %current_db%
echo.
echo   1. ALTER TABLE (Add/Drop/Modify columns)
echo   2. TRUNCATE TABLE (Delete all records)
echo   3. CREATE TABLE (New table)
echo   4. INSERT INTO (Add records)
echo   5. UPDATE (Modify records)
echo   6. DELETE (Remove records)
echo   7. DESCRIBE TABLE
echo   8. SHOW DATABASES
echo   9. Back to Main Menu
echo.

choice /c 123456789 /n /m "Select operation (1-9): "

if errorlevel 9 goto CONTINUOUS_OPERATIONS
if errorlevel 8 goto SHOW_DATABASES
if errorlevel 7 goto DESCRIBE_TABLE
if errorlevel 6 goto DELETE_RECORDS
if errorlevel 5 goto UPDATE_RECORDS
if errorlevel 4 goto INSERT_RECORDS
if errorlevel 3 goto CREATE_TABLE
if errorlevel 2 goto TRUNCATE_TABLE
if errorlevel 1 goto ALTER_TABLE

:CREATE_TABLE
setlocal enabledelayedexpansion
cls
echo.
echo  --------------------------------------------------
echo               CREATE TABLE
echo  --------------------------------------------------
echo.
set /p "table=Enter new table name: "
if "!table!"=="" (
    echo ERROR: No table name specified.
    pause
    endlocal
    goto PRE_BUILT_OPERATIONS
)

echo.
set /p "columns=Enter number of columns: "
if "!columns!"=="" set "columns=1"
set /a "columns=!columns!" 2>nul
if !columns! LSS 1 (
    echo ERROR: Number of columns must be at least 1.
    pause
    endlocal
    goto PRE_BUILT_OPERATIONS
)

set "create_query=CREATE TABLE !table! ("
set "primary_key="
set "current_column=1"

:CREATE_TABLE_LOOP
if !current_column! GTR !columns! goto CREATE_TABLE_FINISH

cls
echo  --------------------------------------------------
echo               CREATE TABLE: !table!
echo  --------------------------------------------------
echo.
echo Column !current_column! of !columns!
echo Name: 
set /p "col_name=Enter column name: "
if "!col_name!"=="" (
    echo ERROR: Column name cannot be empty.
    pause
    goto CREATE_TABLE_LOOP
)

:CREATE_TABLE_DATATYPE
cls
echo  --------------------------------------------------
echo               CREATE TABLE: !table!
echo  --------------------------------------------------
echo.
echo Column !current_column! of !columns!: [!col_name!]
echo.
echo Select data type:
echo   1. INT            - Whole numbers               
echo   2. VARCHAR(255)   - Variable-length text       
echo   3. TEXT          - Long text                  
echo   4. DATE          - Date only                  
echo   5. DATETIME      - Date and time             
echo   6. DECIMAL(10,2) - Numbers with decimals      
choice /c 123456 /n /m "Select data type (1-6): "
set "data_type="

if !errorlevel! EQU 6 (
    set "data_type=DECIMAL(10,2)"
) else if !errorlevel! EQU 5 (
    set "data_type=DATETIME"
) else if !errorlevel! EQU 4 (
    set "data_type=DATE"
) else if !errorlevel! EQU 3 (
    set "data_type=TEXT"
) else if !errorlevel! EQU 2 (
    set "data_type=VARCHAR(255)"
) else if !errorlevel! EQU 1 (
    set "data_type=INT"
)

if "!data_type!"=="" (
    echo ERROR: Invalid data type selection. Please try again.
    pause
    goto CREATE_TABLE_DATATYPE
)

echo.
echo Selected data type: [!data_type!]
echo.
choice /c YN /n /m "Confirm this data type? (Y/N): "
if !errorlevel! EQU 2 goto CREATE_TABLE_DATATYPE

cls
echo  --------------------------------------------------
echo               CREATE TABLE: !table!
echo  --------------------------------------------------
echo.
echo Column !current_column! of !columns!
echo Name: [!col_name!]
echo Type: [!data_type!]
echo.
choice /c YN /n /m "Make this column a primary key? (Y/N): "
set "pk_choice=!errorlevel!"

if !current_column! GTR 1 set "create_query=!create_query!,"

if !pk_choice! EQU 2 (
    set "create_query=!create_query! !col_name! !data_type!"
) else (
    if defined primary_key (
        echo ERROR: Table can only have one primary key. Column will be set as NOT NULL instead.
        set "create_query=!create_query! !col_name! !data_type! NOT NULL"
        pause
    ) else (
        set "primary_key=!col_name!"
        if "!data_type!"=="INT" (
            set "create_query=!create_query! !col_name! !data_type! PRIMARY KEY AUTO_INCREMENT"
        ) else (
            set "create_query=!create_query! !col_name! !data_type! PRIMARY KEY"
        )
    )
)

echo.
echo Column [!col_name!] added successfully.
set /a "current_column+=1"
if !current_column! LEQ !columns! (
    echo.
    echo Press any key to continue with next column...
    pause >nul
)
goto CREATE_TABLE_LOOP

:CREATE_TABLE_FINISH
cls
echo  --------------------------------------------------
echo               CREATE TABLE: !table!
echo  --------------------------------------------------
echo.
echo Creating table with query:
set "create_query=!create_query!);"
echo !create_query!
echo.
mysql %auth_cmd% -D %current_db% -e "!create_query!"
if !errorlevel! EQU 0 (
    echo Table created successfully.
    echo.
    echo Table structure:
    mysql %auth_cmd% -D %current_db% -e "DESCRIBE !table!;"
) else (
    echo ERROR: Failed to create table.
)
endlocal
pause
goto PRE_BUILT_OPERATIONS

:INSERT_RECORDS
cls
echo Insert Records
echo -------------
echo.
echo Available tables:
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
echo.
set /p "table=Enter table name: "
echo.
echo Table structure:
mysql %auth_cmd% -D %current_db% -e "DESCRIBE %table%;"
echo.

set "cols="
set "vals="
for /f "tokens=1,2" %%a in ('mysql %auth_cmd% -D %current_db% -N -e "DESCRIBE %table%;"') do (
    set /p "val=Enter value for %%a: "
    if not defined cols (
        set "cols=%%a"
        set "vals='!val!'"
    ) else (
        set "cols=!cols!,%%a"
        set "vals=!vals!,'!val!'"
    )
)

echo.
mysql %auth_cmd% -D %current_db% -e "INSERT INTO %table% (%cols%) VALUES (%vals%);"
echo.
mysql %auth_cmd% -D %current_db% -e "SELECT * FROM %table%;"
pause
goto PRE_BUILT_OPERATIONS

:UPDATE_RECORDS
cls
echo.
echo  --------------------------------------------------
echo               UPDATE RECORDS
echo  --------------------------------------------------
echo.
echo Available tables:
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
echo.
set /p "table=Enter table name: "
if "%table%"=="" (
    echo ERROR: No table specified.
    pause
    goto PRE_BUILT_OPERATIONS
)
echo.
echo Current records:
mysql %auth_cmd% -D %current_db% -e "SELECT * FROM %table%;"
echo.
set /p "set_clause=Enter SET clause (e.g., column=value): "
if "%set_clause%"=="" (
    echo ERROR: No SET clause specified.
    pause
    goto PRE_BUILT_OPERATIONS
)
set /p "where_clause=Enter WHERE clause (leave empty to update all records): "
set "update_query=UPDATE %table% SET %set_clause%"
if not "%where_clause%"=="" set "update_query=%update_query% WHERE %where_clause%"
set /p "confirm=Are you sure you want to execute: %update_query%? (Y/N): "
if /i "%confirm%" neq "Y" goto PRE_BUILT_OPERATIONS
mysql %auth_cmd% -D %current_db% -e "%update_query%;"
if errorlevel 1 (
    echo ERROR: Failed to update records.
) else (
    echo Records updated successfully.
)
pause
goto PRE_BUILT_OPERATIONS

:DELETE_RECORDS
cls
echo.
echo  --------------------------------------------------
echo               DELETE RECORDS
echo  --------------------------------------------------
echo.
echo Available tables:
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
echo.
set /p "table=Enter table name: "
if "%table%"=="" (
    echo ERROR: No table specified.
    pause
    goto PRE_BUILT_OPERATIONS
)
echo.
echo Current records:
mysql %auth_cmd% -D %current_db% -e "SELECT * FROM %table%;"
echo.
set /p "where_clause=Enter WHERE clause (leave empty to delete all records): "
set "delete_query=DELETE FROM %table%"
if not "%where_clause%"=="" set "delete_query=%delete_query% WHERE %where_clause%"
set /p "confirm=Are you sure you want to execute: %delete_query%? (Y/N): "
if /i "%confirm%" neq "Y" goto PRE_BUILT_OPERATIONS
mysql %auth_cmd% -D %current_db% -e "%delete_query%;"
if errorlevel 1 (
    echo ERROR: Failed to delete records.
) else (
    echo Records deleted successfully.
)
pause
goto PRE_BUILT_OPERATIONS

:ALTER_TABLE
cls
echo.
echo  --------------------------------------------------
echo               ALTER TABLE
echo  --------------------------------------------------
echo.
echo Available tables:
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
echo.
set /p "table=Enter table name to alter: "
if "%table%"=="" (
    echo ERROR: No table specified.
    pause
    goto ALTER_TABLE
)

echo.
echo ALTER TABLE options:
echo   1. ADD COLUMN
echo   2. DROP COLUMN
echo   3. MODIFY COLUMN
echo   4. Back
echo.

choice /c 1234 /n /m "Select operation (1-4): "

if errorlevel 4 goto PRE_BUILT_OPERATIONS
if errorlevel 3 goto MODIFY_COLUMN
if errorlevel 2 goto DROP_COLUMN
if errorlevel 1 goto ADD_COLUMN

:ADD_COLUMN
cls
echo.
set /p "column_name=Enter new column name: "
if "%column_name%"=="" (
    echo ERROR: Column name is required.
    pause
    goto ALTER_TABLE
)
echo.
echo Available data types:
echo   1. INT
echo   2. VARCHAR(255)
echo   3. TEXT
echo   4. DATE
echo   5. DATETIME
echo   6. DECIMAL(10,2)
choice /c 123456 /n /m "Select data type (1-6): "
set "data_type="
if errorlevel 6 set "data_type=DECIMAL(10,2)"
if errorlevel 5 set "data_type=DATETIME"
if errorlevel 4 set "data_type=DATE"
if errorlevel 3 set "data_type=TEXT"
if errorlevel 2 set "data_type=VARCHAR(255)"
if errorlevel 1 set "data_type=INT"
mysql %auth_cmd% -D %current_db% -e "ALTER TABLE %table% ADD COLUMN %column_name% %data_type%;"
if errorlevel 1 (
    echo ERROR: Failed to add column.
) else (
    echo Column added successfully.
)
pause
goto ALTER_TABLE

:DROP_COLUMN
cls
echo.
echo Current columns in table %table%:
mysql %auth_cmd% -D %current_db% -e "DESCRIBE %table%;"
echo.
set /p "column_name=Enter column name to drop: "
if "%column_name%"=="" (
    echo ERROR: Column name is required.
    pause
    goto ALTER_TABLE
)
set /p "confirm=Are you sure you want to drop column '%column_name%'? (Y/N): "
if /i "%confirm%" neq "Y" goto ALTER_TABLE
mysql %auth_cmd% -D %current_db% -e "ALTER TABLE %table% DROP COLUMN %column_name%;"
if errorlevel 1 (
    echo ERROR: Failed to drop column.
) else (
    echo Column dropped successfully.
)
pause
goto ALTER_TABLE

:MODIFY_COLUMN
cls
echo.
echo Current columns in table %table%:
mysql %auth_cmd% -D %current_db% -e "DESCRIBE %table%;"
echo.
set /p "column_name=Enter column name to modify: "
if "%column_name%"=="" (
    echo ERROR: Column name is required.
    pause
    goto ALTER_TABLE
)
echo.
echo Available data types:
echo   1. INT
echo   2. VARCHAR(255)
echo   3. TEXT
echo   4. DATE
echo   5. DATETIME
echo   6. DECIMAL(10,2)
choice /c 123456 /n /m "Select new data type (1-6): "
set "data_type="
if errorlevel 6 set "data_type=DECIMAL(10,2)"
if errorlevel 5 set "data_type=DATETIME"
if errorlevel 4 set "data_type=DATE"
if errorlevel 3 set "data_type=TEXT"
if errorlevel 2 set "data_type=VARCHAR(255)"
if errorlevel 1 set "data_type=INT"
mysql %auth_cmd% -D %current_db% -e "ALTER TABLE %table% MODIFY COLUMN %column_name% %data_type%;"
if errorlevel 1 (
    echo ERROR: Failed to modify column.
) else (
    echo Column modified successfully.
)
pause
goto ALTER_TABLE

:TRUNCATE_TABLE
cls
echo.
echo  --------------------------------------------------
echo               TRUNCATE TABLE
echo  --------------------------------------------------
echo.
echo Available tables:
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
echo.
set /p "table=Enter table name to truncate: "
if "%table%"=="" (
    echo ERROR: No table specified.
    pause
    goto PRE_BUILT_OPERATIONS
)
set /p "confirm=Are you sure you want to delete ALL records from table '%table%'? (Y/N): "
if /i "%confirm%" neq "Y" goto PRE_BUILT_OPERATIONS
mysql %auth_cmd% -D %current_db% -e "TRUNCATE TABLE %table%;"
if errorlevel 1 (
    echo ERROR: Failed to truncate table.
) else (
    echo Table truncated successfully.
)
pause
goto PRE_BUILT_OPERATIONS
