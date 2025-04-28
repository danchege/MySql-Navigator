@echo off
setlocal enabledelayedexpansion
mode con: cols=80 lines=30
color 0A

:: Check if mysql exists
where mysql >nul 2>&1 || (
    echo ERROR: mysql not found. Ensure MySQL is installed and added to your PATH.
    pause
    exit /b
)

:MAIN_MENU
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║           MYSQL DATABASE NAVIGATOR v2.1          ║
echo  ║               By Daniel Chege                    ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo   1. Connect to MySQL
echo   2. Exit
echo.
choice /c 12 /n /m "Select option: "

if errorlevel 2 exit /b
if errorlevel 1 goto CONNECT_MYSQL
goto MAIN_MENU

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

set /p "password=Enter Password: "
:: Remove any leading/trailing spaces from password
set "password=%password: =%"

:: Set up the authentication command
set "auth_cmd=-h %server% -u %username%"
if not "%password%"=="" set "auth_cmd=%auth_cmd% -p%password%"

:: Test connection
mysql %auth_cmd% -e "SELECT 1;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to connect to MySQL. Check your credentials and try again.
    pause
    goto MAIN_MENU
)

set "current_db="
goto MAIN_OPTIONS

:MAIN_OPTIONS
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               DATABASE OPERATIONS                ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
if defined current_db echo Current Database: %current_db%
echo.
echo   1. List Databases
echo   2. Select Database
echo   3. Run Query
echo   4. Backup Database
echo   5. Export Database
echo   6. Import Database
echo   7. Return to Main Menu
echo.
choice /c 1234567 /n /m "Select operation: "

if errorlevel 7 goto MAIN_MENU
if errorlevel 6 goto IMPORT_DATABASE
if errorlevel 5 goto EXPORT_DATABASE
if errorlevel 4 goto BACKUP_DATABASE
if errorlevel 3 goto RUN_QUERY
if errorlevel 2 goto SELECT_DATABASE
if errorlevel 1 goto LIST_DATABASES

:LIST_DATABASES
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               AVAILABLE DATABASES               ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
mysql %auth_cmd% -e "SHOW DATABASES;"
pause
goto MAIN_OPTIONS

:SELECT_DATABASE
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               DATABASE COMMANDS                   ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo Available databases:
mysql %auth_cmd% -e "SHOW DATABASES;"
echo.
echo Examples of commands you can use:
echo - CREATE DATABASE dbname;
echo - USE dbname;
echo - SHOW TABLES;
echo - CREATE TABLE tablename (...);
echo - SELECT * FROM tablename;
echo.
echo Type your MySQL commands (type 'exit' to return to main menu):
echo --------------------------------------------------------

:COMMAND_LOOP
set /p "cmd=mysql> "
if /i "%cmd%"=="exit" goto MAIN_OPTIONS
if /i "%cmd%"=="quit" goto MAIN_OPTIONS
mysql %auth_cmd% -e "%cmd%"
goto COMMAND_LOOP

:SHOW_TABLES
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               TABLES IN %current_db%             ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
echo.
mysql %auth_cmd% -D %current_db% -e "SHOW TABLES;"
pause
goto SELECT_DATABASE

:DESCRIBE_TABLE
cls
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
goto SELECT_DATABASE

:RUN_QUERY
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ║               RUN SQL QUERY                     ║
echo  ║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
echo  ╚══════════════════════════════════════════════════╝
if defined current_db echo Current Database: %current_db%
echo.
set /p "query=Enter SQL Query to Run: "
if defined current_db (
    mysql %auth_cmd% -D %current_db% -e "%query%"
) else (
    mysql %auth_cmd% -e "%query%"
)
if errorlevel 1 (
    echo ERROR: Query execution failed.
)
pause
goto MAIN_OPTIONS

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

:: Get timestamp for backup file
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)

set "default_backup=%db_to_backup%_%mydate%_%mytime%.sql"
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
goto MAIN_OPTIONS

:BACKUP_ALL
echo.
:: Get timestamp for backup file
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)

set "default_backup=all_databases_%mydate%_%mytime%.sql"
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
goto MAIN_OPTIONS

:EXPORT_DATABASE
cls
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
        goto EXPORT_DATABASE
    )
)

:: Verify database exists
mysql %auth_cmd% -e "USE %db_to_export%;" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Database '%db_to_export%' not found!
    pause
    goto EXPORT_DATABASE
)

:: Get timestamp for export file
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a%%b)

set "default_export=%db_to_export%_%mydate%_%mytime%.sql"
set /p "export_file=Enter export filename (default: %default_export%): "
if "%export_file%"=="" set "export_file=%default_export%"
if not "%export_file:~-4%"==".sql" set "export_file=%export_file%.sql"

echo.
echo Exporting database...
:: Add extra options to make the SQL file more readable
mysqldump %auth_cmd% --databases %db_to_export% --add-drop-database --add-drop-table --comments --complete-insert --dump-date > "%export_file%"
if errorlevel 1 (
    echo ERROR: Export failed. Please check:
    echo - Database name is correct
    echo - You have write permissions in this folder
    echo - Enough disk space is available
) else (
    echo Database exported successfully as: %export_file%
    echo Location: %CD%\%export_file%
    echo Note: This is a standard SQL file that can be:
    echo - Opened with any text editor
    echo - Imported directly into MySQL
    echo - Used for backup and restoration
)
pause
goto MAIN_OPTIONS

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
set /p "import_file=Enter SQL file to import: "
if not exist "%import_file%" (
    echo ERROR: File '%import_file%' not found!
    echo Current directory: %CD%
    echo Make sure the file exists in this directory.
    pause
    goto IMPORT_DATABASE
)

echo.
echo Importing database...
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
goto MAIN_OPTIONS
