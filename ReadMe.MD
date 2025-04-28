MySQL Navigator

A powerful batch script for managing MySQL databases through an interactive command-line interface.

Requirements

1.MySQL Server
   - MySQL Server installed and running
   - MySQL must be accessible from command line
   - `mysql` and `mysqldump` commands must be in system PATH

2. System Requirements
   - Windows Operating System
   - Command Prompt (CMD) or PowerShell
   - Basic understanding of MySQL commands

Installation

1. Download `MySql Navigator.bat` to your preferred location
2. No additional installation needed - it's ready to run!

Features

1. Database Management
   - List all databases
   - Select and use databases
   - Run custom MySQL queries

2. Backup Operations
   - Backup specific database
   - Backup all databases
   - Timestamped backup files
   - Standard SQL format output

3. Import/Export
   - Export databases to SQL files
   - Import databases from SQL files
   - Create new databases during import
   - Import into existing databases

How to Use

1. Starting the Script
   - Double-click `MySql Navigator.bat`, or
   - Run from command line: `.\MySql Navigator.bat`

2.First-Time Setup
   - Enter your MySQL server details:
     - Server (default: localhost)
     - Username
     - Password

3.Main Operations
   ```
   1. List Databases
   2. Select Database
   3. Run Query
   4. Backup Database
   5. Export Database
   6. Import Database
   7. Return to Main Menu
   ```

4. Backup/Export
   - Select option 4 or 5
   - Choose database to backup/export
   - Default filename includes timestamp
   - Files saved in .sql format

5. Import
   - Select option 6
   - Choose to create new or use existing database
   - Select SQL file to import
   - Follow the prompts

Tips

1. Running Queries
   - After selecting a database, you can run any valid MySQL query
   - Type your query and press Enter
   - Results will be displayed in the console

2.Backup Files
   - Backups are saved in the same directory as the script
   - Format: `database_YYYY-MM-DD_HHMM.sql`
   - Can be opened with any text editor
   - Directly importable to MySQL

3.Security
   - Avoid using root credentials
   - Create a dedicated user with necessary permissions
   - Keep your backup files secure

Troubleshooting

1. Common Issues
   - "MySQL not recognized": Add MySQL to system PATH
   - "Access denied": Check credentials and permissions
   - "Database not found": Verify database name
   - "Import failed": Check file format and permissions

2. Error Messages
   - The script provides detailed error messages
   - Check the console output for specific issues
   - Verify file permissions and disk space

Support

For issues or suggestions:
1. Check the troubleshooting section
2. Verify MySQL installation
3. Ensure proper permissions
4. Check system PATH settings
