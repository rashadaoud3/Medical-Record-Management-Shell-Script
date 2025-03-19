# Medical Record Management System using Shell Script

## Description
This project is a simple shell script-based system for managing medical test records. The script provides functionality to add, search, update, and calculate average test values. It ensures that medical records are handled efficiently and accurately, with built-in input validation for various fields such as Patient ID, Test Name, Date, Result, Unit, and Status.

## Features
- Add new medical test records.
- Search for test records by Patient ID.
- Update existing test results.
- Retrieve average test values for each test.
- Input validation to ensure data integrity.

## Installation Instructions
1. **Clone the repository:**
   ```bash
   cd medical-record-management-shell-script
2. **Navigate to the project directory:**
   ```bash
   git clone https://github.com/yourusername/medical-record-management-shell-script.git
3. **Make the script executable:**
   ```bash
   chmod +x script_name.sh
4. **Run the script:**
   ```bash
   ./script_name.sh
 
## Usage
1. **When you run the script, a menu will appear with the following options:**
-Add a new medical test record
-Search for tests by patient ID
-Update an existing test result
-Retrieve average test values
-Exit
2. **Each option will prompt the user for inputs. Follow the instructions to enter the required information.**

## Example:
To add a new test record, select option 1, and then provide the necessary details:

-Patient ID (7 digits)

-Test Name (alphabetic)

-Date (YYYY-MM format)

-Result (numeric)

-Unit (g/dL, mg/dL, mm Hg)

-Status (pending, completed, reviewed)

