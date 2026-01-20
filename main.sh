#!/usr/bin/bash



DBMS_DIR="DBMS"

# Ensure DBMS directory exists
if [[ ! -d "$DBMS_DIR" ]]; then
    mkdir "$DBMS_DIR"
fi

menu=(
    "Create_Database"
    "List_Databases"
    "Connect_Database"
    "Drop_Database"
    "Exit"
)

while true
do
    echo "==============================="
    echo "        DBMS Main Menu         "
    echo "==============================="

    PS3="DBMS> "

    select choice in "${menu[@]}"
    do
        case $REPLY in

# ==================================================
# 1) Create Database
# ==================================================
1)
    while true
    do
        read -p "Enter Database Name or [0] to return: " db_name

        if [[ "$db_name" == "0" ]]; then
            break
        fi

        if [[ -z "$db_name" ]]; then
            echo "Error: Database name cannot be empty"
            continue
        fi

        if (( ${#db_name} < 3 )); then
            echo "Error: Name must be at least 3 characters"
            continue
        fi

        if [[ ! "$db_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
            echo "Error: Invalid database name"
            echo "Allowed: letters, numbers, underscore (must start with letter)"
            continue
        fi

        if [[ -d "$DBMS_DIR/$db_name" ]]; then
            echo "Error: Database already exists"
            continue
        fi

        mkdir "$DBMS_DIR/$db_name"
        echo "Database '$db_name' created successfully."
        break
    done

    read -p "Press Enter to return to main menu..."
    break
;;

# ==================================================
# 2) List Databases
# ==================================================
2)
    dbs=$(ls -d "$DBMS_DIR"/*/ 2>/dev/null | sed 's|DBMS/||;s|/||')

    if [[ -z "$dbs" ]]; then
        echo "No Databases Found."
    else
        echo "Available Databases:"
        echo "$dbs"
    fi

    read -p "Press Enter to return to main menu..."
    break
;;

# ==================================================
# 3) Connect Database
# ==================================================
3)
    dbs=$(ls -d "$DBMS_DIR"/*/ 2>/dev/null | sed 's|DBMS/||;s|/||')

    if [[ -z "$dbs" ]]; then
        echo "No Databases Found."
        read -p "Press Enter to return to main menu..."
        break
    fi

    echo "Select Database to Connect or [0] to return:"

    select db in $dbs
    do
        if [[ "$REPLY" == "0" ]]; then
            break
        fi

        if [[ -n "$db" && -d "$DBMS_DIR/$db" ]]; then
            echo "Connected to database '$db'"

            export CURRENT_DB="$DBMS_DIR/$db"

            # ===============================
            # IMPORTANT PART (FIX)
            # ===============================
            bash table.sh


            echo "Disconnected from database '$db'"
            read -p "Press Enter to return to main menu..."
            break
        else
            echo "Invalid selection. Please choose a valid database number."
        fi
    done

    break
;;

# ==================================================
# 4) Drop Database
# ==================================================
4)
    dbs=$(ls -d "$DBMS_DIR"/*/ 2>/dev/null | sed 's|DBMS/||;s|/||')

    if [[ -z "$dbs" ]]; then
        echo "No Databases Found to Drop."
        read -p "Press Enter to return to main menu..."
        break
    fi

    echo "Select Database to Drop or [0] to return:"

    select db in $dbs
    do
        if [[ "$REPLY" == "0" ]]; then
            break
        fi

        if [[ -n "$db" && -d "$DBMS_DIR/$db" ]]; then
            read -p "Are you sure you want to drop '$db'? [y/n]: " confirm

            if [[ "$confirm" =~ ^[yY]$ ]]; then
                rm -r "$DBMS_DIR/$db"
                echo "Database '$db' dropped successfully."
            else
                echo "Drop cancelled."
            fi
            break
        else
            echo "Invalid selection."
        fi
    done

    read -p "Press Enter to return to main menu..."
    break
;;

# ==================================================
# 5) Exit
# ==================================================
5)
    echo "Exiting DBMS..."
    exit
;;

# ==================================================
# Invalid Choice
# ==================================================
*)
    echo "Invalid choice. Please select a number from the menu."
    read -p "Press Enter to return to main menu..."
    break
;;
        esac
    done
done
