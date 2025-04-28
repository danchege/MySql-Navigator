🧭 MySQL Navigator
A powerful batch script for managing MySQL databases through an interactive command-line interface. 🚀

🛠️ Requirements
MySQL Server 🔧

MySQL Server installed and running 🔥

MySQL must be accessible from the command line 💻

mysql and mysqldump commands must be in the system PATH 🛣️

System Requirements 💻

Windows Operating System 🪟

Command Prompt (CMD) or PowerShell ⚡

Basic understanding of MySQL commands 🧠

📥 Installation
Download MySql Navigator.bat to your preferred location 📂

No additional installation needed – it’s ready to run! 🎉

🛠️ Features
Database Management 🗂️

List all databases 📋

Select and use databases 📑

Run custom MySQL queries 🔍

Backup Operations 💾

Backup specific database 💥

Backup all databases 🏆

Timestamped backup files 🕒

Standard SQL format output 📝

Import/Export 🔄

Export databases to SQL files 🗄️

Import databases from SQL files 📥

Create new databases during import ➕

Import into existing databases 🔄

📝 How to Use
Starting the Script 🎬

Double-click MySql Navigator.bat, or

Run from command line: .\MySql Navigator.bat 🖥️

First-Time Setup 🛠️

Enter your MySQL server details 🌐:

Server (default: localhost) 🏠

Username 👤

Password 🔑

Main Operations 🎮

mathematica
Copy
Edit
1. List Databases 🗃️
2. Select Database 📂
3. Run Query 🖋️
4. Backup Database 💾
5. Export Database 💼
6. Import Database 📥
7. Return to Main Menu 🔙
Backup/Export 💼

Select option 4 or 5 🔢

Choose database to backup/export 🏆

Default filename includes timestamp 🕒

Files saved in .sql format 📜

Import 🔄

Select option 6 🔢

Choose to create a new or use an existing database 🏗️

Select SQL file to import 📥

Follow the prompts 👣

💡 Tips
Running Queries 🖋️

After selecting a database, you can run any valid MySQL query 🧑‍💻

Type your query and press Enter ⏎

Results will be displayed in the console 📊

Backup Files 💾

Backups are saved in the same directory as the script 🗂️

Format: database_YYYY-MM-DD_HHMM.sql 🗓️

Can be opened with any text editor ✍️

Directly importable to MySQL 🔄

Security 🔒

Avoid using root credentials 🚫

Create a dedicated user with necessary permissions 👤

Keep your backup files secure 🔐

⚠️ Troubleshooting
Common Issues 🛠️

"MySQL not recognized": Add MySQL to system PATH 🛣️

"Access denied": Check credentials and permissions 🔑

"Database not found": Verify database name 📛

"Import failed": Check file format and permissions 📝

Error Messages ⚠️

The script provides detailed error messages 🧐

Check the console output for specific issues 🖥️

Verify file permissions and disk space 💽