@echo off
setlocal enabledelayedexpansion
mode con: cols=80 lines=30
color 0A

:: Created by Daniel Chege
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║          MYSQL NAVIGATOR - Created by            ║
echo  ║                 Daniel Chege                     ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
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

:CONNECT_MYSQL
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               MYSQL CONNECTION                   ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
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
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║           CONTINUOUS MYSQL OPERATIONS            ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
if defined current_db echo Current Database: %current_db%
echo.
echo   1. Run Query
echo   2. List Databases
echo   3. Select Database
echo   4. Show Tables (if database selected)
echo   5. Describe Table (if database selected)
echo   6. Backup Database
echo   7. Export Database
echo   8. Import Database
echo   9. Drop Database (if selected)
echo   A. Delete Database
echo   B. Exit
echo.

choice /c 123456789AB /n /m "Select operation (1-11): "

if errorlevel 11 exit /b
if errorlevel 10 goto DELETE_DATABASE
if errorlevel 9 goto DROP_DATABASE
if errorlevel 8 goto IMPORT_DATABASE
if errorlevel 7 goto EXPORT_DATABASE
if errorlevel 6 goto BACKUP_DATABASE
if errorlevel 5 goto DESCRIBE_TABLE
if errorlevel 4 goto SHOW_TABLES
if errorlevel 3 goto SELECT_DATABASE
if errorlevel 2 goto LIST_DATABASES
if errorlevel 1 goto RUN_QUERY

:DROP_DATABASE
cls
if not defined current_db (
    echo ERROR: No database selected to drop!
    pause
    goto CONTINUOUS_OPERATIONS
)
echo.
echo WARNING: You are about to drop the database '%current_db%'.
echo This action is irreversible and will delete all data in the database.
echo.
choice /c YN /n /m "Are you sure you want to drop this database? (Y/N): "
if errorlevel 2 goto CONTINUOUS_OPERATIONS
if errorlevel 1 (
    mysql %auth_cmd% -e "DROP DATABASE %current_db%;" >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Failed to drop database '%current_db%'. Ensure you have sufficient privileges.
    ) else (
        echo Database '%current_db%' dropped successfully.
        set "current_db="
    )
)
pause
goto CONTINUOUS_OPERATIONS

:DELETE_DATABASE
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               DELETE DATABASE                    ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
set /p "db_to_delete=Enter database name to delete: "

:: Verify database exists
mysql %auth_cmd% -e "USE %db_to_delete%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Database '%db_to_delete%' not found!
    pause
    goto CONTINUOUS_OPERATIONS
)

echo WARNING: You are about to delete the database '%db_to_delete%'.
echo This action is irreversible and will delete all data in the database.
echo.
choice /c YN /n /m "Are you sure you want to delete this database? (Y/N): "
if errorlevel 2 goto CONTINUOUS_OPERATIONS
if errorlevel 1 (
    mysql %auth_cmd% -e "DROP DATABASE %db_to_delete%;" >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Failed to delete database '%db_to_delete%'. Ensure you have sufficient privileges.
    ) else (
        echo Database '%db_to_delete%' deleted successfully.
    )
)
pause
goto CONTINUOUS_OPERATIONS

:LIST_DATABASES
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               AVAILABLE DATABASES                ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
mysql %auth_cmd% -e "SHOW DATABASES;"
pause
goto CONTINUOUS_OPERATIONS

:SELECT_DATABASE
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               SELECT DATABASE                    ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
set /p "current_db=Enter database name to select: "

:: Verify the selected database exists
mysql %auth_cmd% -e "USE %current_db%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Database '%current_db%' not found!
    pause
    goto CONTINUOUS_OPERATIONS
)

echo Database '%current_db%' selected successfully.
pause
goto CONTINUOUS_OPERATIONS

:SHOW_TABLES
cls
if not defined current_db (
    echo ERROR: No database selected!
    pause
    goto CONTINUOUS_OPERATIONS
)
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               TABLES IN %current_db%             ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
pause
goto CONTINUOUS_OPERATIONS

:DESCRIBE_TABLE
cls
if not defined current_db (
    echo ERROR: No database selected!
    pause
    goto CONTINUOUS_OPERATIONS
)
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               DESCRIBE TABLE                     ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Available tables:
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
echo.
set /p "table=Enter table name to describe: "
mysql %auth_cmd% -D %current_db% -e "DESCRIBE %table%;"
pause
goto CONTINUOUS_OPERATIONS

:RUN_QUERY
cls
if not defined current_db (
    echo ERROR: No database selected! Please select a database first.
    pause
    goto CONTINUOUS_OPERATIONS
)
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               RUN SQL QUERY                      ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Current Database: %current_db%
echo.
echo Note: Type "exit" to return to the main menu.
echo.

:QUERY_LOOP
set /p "query=Enter SQL Query to Run: "
if /i "%query%"=="exit" goto CONTINUOUS_OPERATIONS

mysql %auth_cmd% -D %current_db% -e "%query%"
if errorlevel 1 (
    echo ERROR: Query execution failed. Please check your query.
) else (
    echo Query executed successfully.
)
echo.
goto QUERY_LOOP

:BACKUP_DATABASE
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               BACKUP DATABASE                    ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
echo Backup Options:
echo 1. Backup specific database
echo 2. Backup all databases
echo.
choice /c 12 /n /m "Select backup option (1-2): "

if errorlevel 2 goto BACKUP_ALL
if errorlevel 1 goto BACKUP_SPECIFIC

:BACKUP_SPECIFIC
echo.
if defined current_db (
    echo Current database: %current_db%
    echo Press Enter to backup this database or type a different name.
)
set /p "db_to_backup=Enter database name to backup: "
if "%db_to_backup%"=="" (
    if defined current_db (
        set "db_to_backup=%current_db%"
    ) else (
        echo No database specified!
        pause
        goto BACKUP_DATABASE
    )
)

:: Verify database exists
mysql %auth_cmd% -e "USE %db_to_backup%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Database '%db_to_backup%' not found!
    pause
    goto BACKUP_DATABASE
)

:: Create a folder for the database backup
if not exist "backups\%db_to_backup%" mkdir "backups\%db_to_backup%"

:: Get timestamp for backup file
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)

set "default_backup=backups\%db_to_backup%\%db_to_backup%_%mydate%_%mytime%.sql"
set /p "backup_name=Enter backup filename (default: %default_backup%): "
if "%backup_name%"=="" set "backup_name=%default_backup%"

echo.
echo Creating backup...
mysqldump %auth_cmd% --databases %db_to_backup% > "%backup_name%"
if errorlevel 1 (
    echo ERROR: Backup failed. Please check:
    echo - Database name is correct
    echo - You have write permissions in this folder
    echo - Enough disk space is available
) else (
    echo Backup created successfully as: %backup_name%
    echo Location: %CD%\%backup_name%
)
pause
goto CONTINUOUS_OPERATIONS

:BACKUP_ALL
echo.
:: Create a folder for all database backups
if not exist "backups\all_databases" mkdir "backups\all_databases"

:: Get timestamp for backup file
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)

set "default_backup=backups\all_databases\all_databases_%mydate%_%mytime%.sql"
set /p "backup_name=Enter backup filename (default: %default_backup%): "
if "%backup_name%"=="" set "backup_name=%default_backup%"

echo.
echo Creating backup of all databases...
mysqldump %auth_cmd% --all-databases > "%backup_name%"
if errorlevel 1 (
    echo ERROR: Backup failed. Please check:
    echo - You have sufficient privileges
    echo - You have write permissions in this folder
    echo - Enough disk space is available
) else (
    echo Backup created successfully as: %backup_name%
    echo Location: %CD%\%backup_name%
)
pause
goto CONTINUOUS_OPERATIONS

:EXPORT_DATABASE
cls
:EXPORT_DATABASE_LOOP
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               EXPORT DATABASE                    ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
if defined current_db (
    echo Current database: %current_db%
    echo Press Enter to export this database or type a different name.
)
set /p "db_to_export=Enter database name to export: "
if "%db_to_export%"=="" (
    if defined current_db (
        set "db_to_export=%current_db%"
    ) else (
        echo No database specified!
        pause
        goto EXPORT_DATABASE_LOOP
    )
)

:: Verify database exists
mysql %auth_cmd% -e "USE %db_to_export%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Database '%db_to_export%' not found!
    pause
    goto EXPORT_DATABASE_LOOP
)

:: Set default export file name
set "default_export=exports\%db_to_export%.sql"
set /p "export_file=Enter export filename (default: %default_export%): "
if "%export_file%"=="" set "export_file=%default_export%"
if not "%export_file:~-4%"==".sql" set "export_file=%export_file%.sql"

echo.
echo Exporting database to '%export_file%'...
mysqldump %auth_cmd% --databases %db_to_export% > "%export_file%"
if errorlevel 1 (
    echo ERROR: Export failed. Please check:
    echo - Database name is correct
    echo - You have write permissions in this folder
    echo - Enough disk space is available
) else (
    echo Database exported successfully as: '%export_file%'
    echo Location: %CD%\%export_file%
)
pause
goto CONTINUOUS_OPERATIONS

:IMPORT_DATABASE
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               IMPORT DATABASE                    ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Import Options:
echo 1. Import new database
echo 2. Import into existing database
echo.
choice /c 12 /n /m "Select import option (1-2): "

if errorlevel 2 goto IMPORT_EXISTING_DB
if errorlevel 1 goto IMPORT_NEW_DB

:IMPORT_NEW_DB
echo.
set /p "new_db=Enter new database name: "

:: Validate database name (only letters, numbers, and underscores allowed)
for /f "delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_" %%A in ("%new_db%") do (
    echo ERROR: Invalid database name! Only letters, numbers, and underscores are allowed.
    pause
    goto IMPORT_DATABASE
)

:: Check if database already exists
mysql %auth_cmd% -e "USE %new_db%;" >nul 2>&1
if not errorlevel 1 (
    echo ERROR: Database '%new_db%' already exists!
    pause
    goto IMPORT_DATABASE
)

echo Creating database %new_db%...
mysql %auth_cmd% -e "CREATE DATABASE %new_db%;"
if errorlevel 1 (
    echo ERROR: Failed to create database.
    pause
    goto IMPORT_DATABASE
)
set "target_db=%new_db%"
goto DO_IMPORT_DB

:IMPORT_EXISTING_DB
echo.
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
set /p "target_db=Enter existing database name: "
:: Verify database exists
mysql %auth_cmd% -e "USE %target_db%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Database '%target_db%' not found!
    pause
    goto IMPORT_DATABASE
)

:DO_IMPORT_DB
echo.
set /p "import_file=Enter SQL file to import (default: imports\%target_db%.sql): "
if "%import_file%"=="" set "import_file=imports\%target_db%.sql"
if not "%import_file:~-4%"==".sql" set "import_file=%import_file%.sql"

if not exist "%import_file%" (
    echo ERROR: File '%import_file%' not found!
    echo Current directory: %CD%\imports
    echo Make sure the file exists in the 'imports' directory.
    pause
    goto IMPORT_DATABASE
)

echo.
echo Importing database from '%import_file%'...
mysql %auth_cmd% %target_db% < "%import_file%"
if errorlevel 1 (
    echo ERROR: Import failed. Please check:
    echo - The SQL file is valid
    echo - You have sufficient privileges
    echo - The file contains valid MySQL commands
) else (
    echo Database imported successfully into '%target_db%'
)
pause
goto CONTINUOUS_OPERATIONS