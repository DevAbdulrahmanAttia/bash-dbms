# 🗄️ Bash DBMS - Simple Database Management System

A lightweight, command-line based Database Management System written in pure Bash. This project provides a simple yet functional relational database with table creation, data insertion, querying, updating, and deletion capabilities.

---

## 📋 Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Validation Rules](#validation-rules)
- [Architecture](#architecture)
- [Usage Guide](#usage-guide)
- [Code Examples](#code-examples)
- [Use Cases Checklist](#use-cases-checklist)

---

## ✨ Features

- **Database Management**: Create, list, connect, and drop databases
- **Table Operations**: Full CRUD operations on tables
- **Data Types**: Support for `int` and `string` data types
- **Primary Keys**: Enforce unique primary keys with automatic validation
- **Query Operations**: 
  - Select all records
  - Select by primary key
  - Projection (select specific columns)
- **Data Validation**: Comprehensive input validation for all operations
- **Temporary Data**: Uses `.meta` files to store schema metadata

---

## 🚀 Installation

1. Clone or download the project:
```bash
cd /path/to/dbms_project
```

2. Make scripts executable:
```bash
chmod +x main.sh table.sh
```

3. Run the main menu:
```bash
./main.sh
```

---

## ⚡ Quick Start

```bash
# Start the DBMS
./main.sh

# From main menu:
# 1) Create_Database
# 2) List_Databases
# 3) Connect_Database
# 4) Drop_Database
# 5) Exit

# After connecting to a database, access table operations:
# 1) Create_Table
# 2) List_Tables
# 3) Insert_Into_Table
# 4) Select_From_Table
# 5) Delete_From_Table
# 6) Update_Table
# 7) Drop_Table
# 8) Back
```

---

## 🔍 Validation Rules

### Database Name Validation

| Rule | Requirement | Example | Status |
|------|-------------|---------|--------|
| **Minimum Length** | At least 3 characters | `mydb`, `users_db` | ✅ |
| **Invalid: Too Short** | Less than 3 characters | `db`, `x` | ❌ |
| **Starting Character** | Must start with a letter | `users_db`, `Database1` | ✅ |
| **Invalid: Starts with Number** | Cannot start with digit | `1database`, `2users` | ❌ |
| **Valid Characters** | Letters, numbers, underscore | `my_database_1`, `Users2024` | ✅ |
| **Invalid Characters** | No spaces, hyphens, or special chars | `my-db`, `my db`, `my@db` | ❌ |
| **Duplicate Check** | Cannot create existing database | Already exists | ❌ |

**Validation Regex**:
```regex
^[a-zA-Z][a-zA-Z0-9_]*$
```

---

### Table Name Validation

| Rule | Requirement | Example | Status |
|------|-------------|---------|--------|
| **Format** | Same as database names | `employees`, `user_logs` | ✅ |
| **Starting Character** | Must start with letter | `table1`, `Data2024` | ✅ |
| **Valid Characters** | Letters, numbers, underscore | `emp_data`, `log_entries` | ✅ |
| **Invalid Characters** | No spaces or special chars | `emp-data`, `my table` | ❌ |
| **Duplicate Check** | Cannot create existing table | Already exists in database | ❌ |

**Validation Regex**:
```regex
^[a-zA-Z][a-zA-Z0-9_]*$
```

---

### Column Validation

| Rule | Requirement | Example | Status |
|------|-------------|---------|--------|
| **Column Name Format** | Same regex as table/database names | `user_id`, `first_name` | ✅ |
| **Data Type** | Only `int` or `string` | `int`, `string` | ✅ |
| **Invalid Type** | No other types allowed | `float`, `text`, `date` | ❌ |
| **Primary Key Count** | Only ONE primary key per table | Max 1 PK | ✅ |
| **Multiple PKs** | Cannot have multiple primary keys | 2+ PKs | ❌ |
| **PK Type Constraint** | Primary key MUST be `int` | `int` type | ✅ |
| **String as PK** | Cannot use string as primary key | `string` type | ❌ |
| **Mandatory PK** | Every table MUST have a primary key | At least 1 | ✅ |
| **No PK** | Table creation fails without PK | 0 PKs | ❌ |

---

### Insert Data Validation

| Rule | Requirement | Example | Status |
|------|-------------|---------|--------|
| **Empty Value Check** | No empty values allowed | `value=""` | ❌ |
| **Integer Type Check** | Must be numeric for `int` columns | `123`, `999` | ✅ |
| **Invalid Integer** | Non-numeric for `int` columns | `abc`, `12.5` | ❌ |
| **String Format** | Must follow identifier format | `John`, `user_1` | ✅ |
| **Invalid String** | Starting with number or special char | `1user`, `@admin` | ❌ |
| **Duplicate Primary Key** | PK must be unique | Existing PK value | ❌ |
| **New Unique PK** | New records must have unique PK | New unique value | ✅ |

---

### Select Query Validation

| Rule | Requirement | Example | Status |
|------|-------------|---------|--------|
| **Select All** | Shows all records | Option 1 | ✅ |
| **Select by PK** | Enter valid PK to retrieve | Valid PK value | ✅ |
| **Invalid PK** | No record found error | Non-existent PK | ❌ |
| **Column Projection** | Select specific column numbers | `1`, `2 3` | ✅ |
| **Invalid Column Range** | Out of range column selection | `99` (if only 3 columns) | ❌ |
| **Duplicate Columns** | Cannot select same column twice | `1 1` | ❌ |
| **Empty Table** | Displays "Table is empty" | No records | ℹ️ |

---

### Delete Validation

| Rule | Requirement | Example | Status |
|------|-------------|---------|--------|
| **Empty PK Check** | Primary key cannot be empty | Empty input | ❌ |
| **Record Existence** | Must find record before deletion | Valid PK | ✅ |
| **Invalid PK** | No record found with that PK | Non-existent PK | ❌ |
| **Permanent Deletion** | Removes record from table | Record deleted | ✅ |

---

### Update Validation

| Rule | Requirement | Example | Status |
|------|-------------|---------|--------|
| **Empty PK Check** | Primary key cannot be empty | Empty input | ❌ |
| **Record Existence** | Must verify record exists | Valid PK | ✅ |
| **Invalid PK** | Fails if record not found | Non-existent PK | ❌ |
| **Column Selection** | Must choose valid column | 1-based valid column | ✅ |
| **Invalid Column** | Out of range column selection | Column doesn't exist | ❌ |
| **Cannot Update PK** | Primary key columns cannot be updated | PK = read-only | 🔒 |
| **Empty New Value** | New value cannot be empty | Empty input | ❌ |
| **Type Validation** | Must match column data type | Correct type | ✅ |
| **Integer Type Check** | New value must be numeric for `int` | `123` | ✅ |
| **Invalid Integer** | Non-numeric for `int` columns | `abc` | ❌ |
| **String Format Check** | Must follow identifier format | `new_value` | ✅ |
| **Invalid String** | Must start with letter | `1invalid` | ❌ |

---

## 🏗️ Architecture

```
dbms_project/
├── main.sh              # Main menu and database operations
├── table.sh             # Table operations (CRUD)
├── DBMS/                # Directory to store databases
│   └── database_name/   # Each database folder
│       ├── table1       # Table data file (colon-separated)
│       ├── table1.meta  # Table metadata (schema definition)
│       └── table2.meta  # Another table's schema
└── README.md            # This file
```

### File Formats

**Table Data Format** (`:` separated values):
```
field1:field2:field3
value1:value2:value3
```

**Metadata File Format** (`.meta` files):
```
column_name:data_type[:PK]
user_id:int:PK
name:string
age:int
```

---

## 📖 Usage Guide

### 1. Creating a Database

```bash
# Select option 1 from main menu: "Create_Database"
# Enter database name following validation rules
# Database created in DBMS/ directory

DBMS> Create_Database
Enter Database Name or [0] to return: my_company
Database 'my_company' created successfully.
```

**Validations Applied**:
- ✅ Name length ≥ 3 characters
- ✅ Starts with letter
- ✅ Only letters, numbers, underscore
- ✅ Not already existing

---

### 2. Creating a Table

```bash
# Select option 1 from Tables menu: "Create_Table"
# Provide table name and column definitions

TABLES> Create_Table
Enter Table Name or [0] to return: employees
Enter number of columns: 3
-----------------------
Column 1
Name: emp_id
Choose type: 1) int  2) string
Choose type: 1
Primary Key? (y/n): y
-----------------------
Column 2
Name: emp_name
Choose type: 1) int  2) string
Choose type: 2
Primary Key? (y/n): n
...

Table 'employees' created successfully
```

**Validations Applied**:
- ✅ Column names follow identifier format
- ✅ Only `int` or `string` types allowed
- ✅ Exactly one primary key required
- ✅ Primary key must be `int` type
- ✅ Unique table names per database

---

### 3. Inserting Data

```bash
# Select option 3: "Insert_Into_Table"
# Follow column-by-column data entry

TABLES> Insert_Into_Table
Choose table number: 1

Enter emp_id (int): 101
Enter emp_name (string): John_Doe
Enter emp_salary (int): 50000

Row inserted successfully into table 'employees'
```

**Validations Applied**:
- ✅ No empty values
- ✅ Integer validation for `int` columns
- ✅ String format validation for `string` columns
- ✅ Duplicate primary key check
- ✅ All required fields must be filled

---

### 4. Querying Data

#### Select All Records
```bash
TABLES> Select_From_Table
Choose table number: 1
1) Select All
2) Select By Primary Key
3) Select Specific Columns (Projection)
4) Back

Choose: 1

Output:
101:John_Doe:50000
102:Jane_Smith:55000
103:Bob_Johnson:48000
```

#### Select By Primary Key
```bash
Choose: 2
Enter Primary Key: 101

Output:
101:John_Doe:50000
```

#### Select Specific Columns (Projection)
```bash
Choose: 3
Available Columns:
1) emp_id
2) emp_name
3) emp_salary

Enter column numbers (space-separated): 2 3

Output:
John_Doe:50000
Jane_Smith:55000
Bob_Johnson:48000
```

**Validations Applied**:
- ✅ Valid PK format
- ✅ Column numbers within range
- ✅ No duplicate column selections
- ✅ Graceful handling of empty tables

---

### 5. Updating Data

```bash
# Select option 6: "Update_Table"
# Choose table, find record by PK, select column to update

TABLES> Update_Table
Choose table number: 1
Enter Primary Key: 101

Available Columns:
1) emp_name
2) emp_salary

Choose column number: 2
Enter new value: 52000

Row updated successfully
```

**Validations Applied**:
- ✅ Record must exist (by PK)
- ✅ Primary key column cannot be updated
- ✅ New value type must match column type
- ✅ No empty values allowed
- ✅ String format validation

---

### 6. Deleting Data

```bash
# Select option 5: "Delete_From_Table"
# Enter primary key of record to delete

TABLES> Delete_From_Table
Choose table number: 1
Enter PK to delete: 103

Row deleted successfully
```

**Validations Applied**:
- ✅ PK cannot be empty
- ✅ Record existence check
- ✅ Permanent deletion

---

## 💻 Code Examples

### Example 1: Validation Regex Pattern

```bash
# Database/Table/Column name validation pattern
name_regex='^[a-zA-Z][a-zA-Z0-9_]*$'

# Test examples:
if [[ "my_database" =~ $name_regex ]]; then
    echo "Valid name"  # ✅ Passes
fi

if [[ "1database" =~ $name_regex ]]; then
    echo "Valid name"  # ❌ Fails (starts with digit)
fi

if [[ "my-db" =~ $name_regex ]]; then
    echo "Valid name"  # ❌ Fails (contains hyphen)
fi
```

### Example 2: Integer Type Validation

```bash
# Validate integer input for int columns
col_value="12345"

if [[ "$col_value" =~ ^[0-9]+$ ]]; then
    echo "Valid integer: $col_value"  # ✅ Passes
else
    echo "Invalid integer: $col_value"  # ❌ Fails
fi

# Negative examples:
col_value="abc"       # ❌ Non-numeric
col_value="12.5"      # ❌ Decimal (not integer)
col_value="-123"      # ❌ Negative (not allowed)
```

### Example 3: String Type Validation

```bash
# Validate string input for string columns
col_value="John_Smith"

if [[ "$col_value" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo "Valid string: $col_value"  # ✅ Passes
else
    echo "Invalid string: $col_value"  # ❌ Fails
fi

# Negative examples:
col_value="John Smith"    # ❌ Contains space
col_value="123_user"      # ❌ Starts with digit
col_value="user@domain"   # ❌ Contains special character
col_value="_admin"        # ❌ Starts with underscore (not allowed)
```

### Example 4: Primary Key Uniqueness Check

```bash
# Extract primary key column index
get_pk_index() {
    local meta_file="$1"
    local idx=1
    while IFS= read -r line; do
        local flag=$(cut -d':' -f3 <<< "$line")
        if [[ "$flag" == "PK" ]]; then
            echo "$idx"
            return 0
        fi
        ((idx++))
    done < "$meta_file"
    echo 0
    return 1
}

# Check for duplicate primary key
pk_value="101"
pk_index=$(get_pk_index "$CURRENT_DB/$table.meta")

# Search for existing primary key
while IFS= read -r row; do
    if [[ "$(cut -d':' -f$pk_index <<< "$row")" == "$pk_value" ]]; then
        echo "Insert failed: duplicate Primary Key"
        exit 1
    fi
done < "$CURRENT_DB/$table"

echo "Primary Key is unique - proceed with insert"
```

### Example 5: Projection (Select Specific Columns)

```bash
# Read all column names
columns=()
while IFS= read -r line; do
    columns+=("$(cut -d':' -f1 <<< "$line")")
done < "$meta_file"

# Display available columns
echo "Available Columns:"
for i in "${!columns[@]}"; do
    echo "$((i+1))) ${columns[$i]}"
done

# Read user selection
read -r selected  # User input: "1 3" for columns 1 and 3

# Extract specific columns from each row
while IFS= read -r row; do
    out=""
    for c in $selected; do
        out="${out:+$out:}$(cut -d':' -f$c <<< "$row")"
    done
    echo "$out"
done < "$data_file"
```

### Example 6: Data Persistence Flow

```bash
# Update operation flow:
temp="$CURRENT_DB/.tmp_update"
> "$temp"  # Create temporary file

# Read original data and update matching row
while IFS= read -r row; do
    if [[ "$(cut -d':' -f$pk_index <<< "$row")" == "$pk" ]]; then
        # Update this row
        fields=($(echo "$row" | tr ':' ' '))
        fields[$((target_index-1))]="$new_val"
        echo "$(IFS=:; echo "${fields[*]}")" >> "$temp"
    else
        # Keep unchanged rows
        echo "$row" >> "$temp"
    fi
done < "$data"

# Atomic replacement
mv "$temp" "$data"
echo "Row updated successfully"
```

---

## ✅ Use Cases Checklist

### Database Operations

- [ ] Create database with valid 3+ character name
- [ ] Create database starting with letter
- [ ] Reject database name with invalid characters
- [ ] Reject duplicate database name
- [ ] List all created databases
- [ ] Connect to existing database
- [ ] Drop existing database with confirmation
- [ ] Return to main menu from all dialogs

### Table Operations

- [ ] Create table with valid name format
- [ ] Define multiple columns for table
- [ ] Enforce one primary key per table
- [ ] Require primary key as `int` type
- [ ] Reject table creation without primary key
- [ ] Reject duplicate column names
- [ ] Reject invalid column data types
- [ ] List all tables in connected database
- [ ] Drop table with confirmation
- [ ] Display error on empty table list

### Insert Operations

- [ ] Insert row with all required columns
- [ ] Reject empty column values
- [ ] Validate integer values in `int` columns
- [ ] Validate string format in `string` columns
- [ ] Reject non-numeric input for `int` columns
- [ ] Reject invalid string format for `string` columns
- [ ] Enforce unique primary keys
- [ ] Reject duplicate primary key insert
- [ ] Persist data to table file
- [ ] Confirm successful insertion

### Select Operations

- [ ] Select all records from table
- [ ] Display "Table is empty" message when appropriate
- [ ] Select single record by primary key
- [ ] Display "No record found" for invalid PK
- [ ] Project specific columns using column numbers
- [ ] Reject out-of-range column numbers
- [ ] Reject duplicate column selections in projection
- [ ] Display records in correct format
- [ ] Handle empty table gracefully

### Update Operations

- [ ] Find record by primary key
- [ ] Display "No record found" for invalid PK
- [ ] List non-primary key columns for update
- [ ] Prevent primary key column updates
- [ ] Validate new value type matches column type
- [ ] Reject empty values on update
- [ ] Persist updated data to file
- [ ] Confirm successful update
- [ ] Maintain data integrity across updates

### Delete Operations

- [ ] Find record by primary key
- [ ] Display "No record found" for invalid PK
- [ ] Permanently remove matching record
- [ ] Maintain remaining records integrity
- [ ] Reject empty primary key input
- [ ] Confirm successful deletion

### Error Handling

- [ ] Handle missing DBMS directory creation
- [ ] Handle file I/O errors gracefully
- [ ] Provide clear error messages
- [ ] Allow retry after error
- [ ] Return to menu after operations
- [ ] Manage temporary files cleanup

### Data Format Validation

- [ ] Store table data with colon-separated format
- [ ] Store metadata with column definitions
- [ ] Parse metadata for column properties
- [ ] Extract primary key index correctly
- [ ] Handle column count validation
- [ ] Properly format output data

### User Interface

- [ ] Display clear main menu
- [ ] Display clear tables menu
- [ ] Show proper prompts for each input
- [ ] Display available options before selection
- [ ] Allow [0] to return from submenus
- [ ] Provide "Press Enter" prompts between sections
- [ ] Handle invalid menu selections

---

## 🔐 Security Considerations

⚠️ **Important Notes**:
- This is a learning/educational project, not for production use
- No encryption of data
- No user authentication/authorization
- All data stored as plain text files
- No transaction support
- No concurrent access protection

---

## 📝 Log and Testing

### Test Case Template

```bash
# Test: Database Name Validation
TEST_NAME="Database Creation - Valid Name"
TEST_CASE="mycompany_db"
EXPECTED="Database created successfully"

TEST_NAME="Database Creation - Too Short"
TEST_CASE="db"
EXPECTED="Error: Name must be at least 3 characters"

TEST_NAME="Database Creation - Invalid Character"
TEST_CASE="my-company"
EXPECTED="Error: Invalid database name"
```

---

## 🤝 Contributing

To enhance this project, consider:
- Adding more data types (float, date, etc.)
- Implementing SQL-like query syntax
- Adding data backup/restore functionality
- Implementing indexes for faster lookups
- Adding transaction support
- Creating GUI interface

---

## 📄 License

This project is for educational purposes.

---

## 📞 Support

For issues or questions:
1. Check validation rules in [Validation Rules](#validation-rules)
2. Review code examples in [Code Examples](#code-examples)
3. Verify all use cases are covered in [Use Cases Checklist](#use-cases-checklist)

---

**Last Updated**: January 2026  
**Version**: 1.0.0
