#!/usr/bin/bash
pause() {
    read -p "Press Enter to continue..." < /dev/tty
}

get_pk_index() {
    local meta_file="$1"
    local idx=1
    while IFS= read -r line
    do
        local flag
        flag=$(cut -d':' -f3 <<< "$line")

        if [[ "$flag" == "PK" ]]; then
            echo "$idx"
            return 0
        fi

        ((idx++))
    done < "$meta_file"

    echo 0
    return 1
}


PS3="TABLES> "

menu=(
"Create_Table"
"List_Tables"
"Insert_Into_Table"
"Select_From_Table"
"Delete_From_Table"
"Update_Table"
"Drop_Table"
"Back"
)

name_regex='^[a-zA-Z][a-zA-Z0-9_]*$'

while true
do
    echo "==============================="
    echo "         Tables Menu           "
    echo "==============================="

    select choice in "${menu[@]}"
    do
        case $REPLY in

# ==========================================================
# 1) Create Table
# ==========================================================
1)
    echo -n "Enter Table Name or [0] to return: "
    read -r table_name < /dev/tty

    if [[ "$table_name" == "0" ]]; then
        break
    fi

    if [[ -z "$table_name" || ! "$table_name" =~ $name_regex ]]; then
        echo "Error: Invalid table name"
        echo "Allowed: letters, numbers, underscore (must start with letter)"
        echo "Press Enter to return..."
        read -r < /dev/tty
        break
    fi

    if [[ -f "$CURRENT_DB/$table_name" ]]; then
        echo "Error: Table already exists"
        echo "Press Enter to return..."
        read -r < /dev/tty
        break
    fi

    echo -n "Enter number of columns: "
    read -r col_count < /dev/tty

    if [[ ! "$col_count" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid number of columns"
        echo "Press Enter to return..."
        read -r < /dev/tty
        break
    fi

    meta="$CURRENT_DB/$table_name.meta"
    data="$CURRENT_DB/$table_name"
    > "$meta"
    > "$data"

    pk_defined=false
    table_error=false
    error_msg=""

    for (( i=1; i<=col_count; i++ ))
    do
        echo "-----------------------"
        echo "Column $i"

        echo -n "Name: "
        read -r col_name < /dev/tty

        if [[ ! "$col_name" =~ $name_regex ]]; then
            table_error=true
            error_msg="Invalid column name: $col_name"
            break
        fi

        echo "1) int"
        echo "2) string"
        echo -n "Choose type: "
        read -r type_choice < /dev/tty

        if [[ "$type_choice" == "1" ]]; then
            col_type="int"
        elif [[ "$type_choice" == "2" ]]; then
            col_type="string"
        else
            table_error=true
            error_msg="Invalid data type selection"
            break
        fi

        echo -n "Primary Key? (y/n): "
        read -r is_pk < /dev/tty

        if [[ "$is_pk" == "y" ]]; then
            if [[ "$pk_defined" == true ]]; then
                table_error=true
                error_msg="Only one Primary Key is allowed"
                break
            fi

            if [[ "$col_type" != "int" ]]; then
                table_error=true
                error_msg="Primary Key must be of type int"
                break
            fi

            pk_defined=true
            echo "$col_name:$col_type:PK" >> "$meta"
        elif [[ "$is_pk" == "n" ]]; then
            echo "$col_name:$col_type" >> "$meta"
        else
            table_error=true
            error_msg="Invalid PK choice (must be y or n)"
            break
        fi
    done

    if [[ "$table_error" == true ]]; then
        rm -f "$meta" "$data"
        echo "Table creation failed"
        echo "Reason: $error_msg"
        echo "Press Enter to return..."
        read -r < /dev/tty
        break
    fi

    if [[ "$pk_defined" == false ]]; then
        rm -f "$meta" "$data"
        echo "Table creation failed"
        echo "Reason: Table must have a Primary Key"
        echo "Press Enter to return..."
        read -r < /dev/tty
        break
    fi

    echo "Table '$table_name' created successfully"
    echo "Press Enter to return to Tables Menu..."
    read -r < /dev/tty
    break
;;



# ==========================================================
# 2) List Tables
# ==========================================================
2)
    tables=($(ls "$CURRENT_DB" | grep -v "\.meta$"))

    if [[ ${#tables[@]} -eq 0 ]]; then
        echo "No Tables Found in this database"
        echo "You can create a table first"
        echo "Press Enter to return to Tables Menu..."
        read -r < /dev/tty
        break
    fi

    echo "Available Tables:"
    for table in "${tables[@]}"; do
        echo "- $table"
    done

    echo "Press Enter to return to Tables Menu..."
    read -r < /dev/tty
    break
;;


# ==========================================================
# 3) Insert Into Table
# ==========================================================
3)
    tables=($(ls "$CURRENT_DB" | grep -v "\.meta$"))

    if [[ ${#tables[@]} -eq 0 ]]; then
        echo "No Tables Found in this database"
        echo "Create a table first, then try again"
        echo "Press Enter to return to Tables Menu..."
        read -r < /dev/tty
        break
    fi

    echo "Available Tables:"
    for i in "${!tables[@]}"; do
        echo "$((i+1))) ${tables[$i]}"
    done

    echo -n "Choose table number: "
    read -r choice < /dev/tty

    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#tables[@]} )); then
        echo "Invalid table selection"
        echo "Press Enter to return to Tables Menu..."
        read -r < /dev/tty
        break
    fi

    table="${tables[$((choice-1))]}"
    meta="$CURRENT_DB/$table.meta"
    data="$CURRENT_DB/$table"

    row=""
    pk_value=""
    pk_index=0
    col_index=1

    while IFS= read -r line
    do
        name=$(cut -d':' -f1 <<< "$line")
        type=$(cut -d':' -f2 <<< "$line")
        flag=$(cut -d':' -f3 <<< "$line")

        echo -n "Enter $name ($type): "
        read -r value < /dev/tty

        if [[ -z "$value" ]]; then
            echo "Insert failed: value cannot be empty"
            echo "Press Enter to return to Tables Menu..."
            read -r < /dev/tty
            break 2
        fi

        if [[ "$type" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
            echo "Insert failed: '$name' must be an integer"
            echo "Press Enter to return to Tables Menu..."
            read -r < /dev/tty
            break 2
        fi

        if [[ "$type" == "string" && ! "$value" =~ $name_regex ]]; then
            echo "Insert failed: '$name' has invalid format"
            echo "Allowed: letters, numbers, underscore (must start with letter)"
            echo "Press Enter to return to Tables Menu..."
            read -r < /dev/tty
            break 2
        fi

        if [[ "$flag" == "PK" ]]; then
            pk_value="$value"
            pk_index=$col_index
        fi

        row="${row:+$row:}$value"
        ((col_index++))
    done < "$meta"

    if [[ "$pk_index" -eq 0 ]]; then
        echo "Insert failed: table has no Primary Key defined"
        echo "Press Enter to return to Tables Menu..."
        read -r < /dev/tty
        break
    fi

    while IFS= read -r r
    do
        if [[ "$(cut -d':' -f$pk_index <<< "$r")" == "$pk_value" ]]; then
            echo "Insert failed: duplicate Primary Key"
            echo "Press Enter to return to Tables Menu..."
            read -r < /dev/tty
            break 2
        fi
    done < "$data"

    echo "$row" >> "$data"
    echo "Row inserted successfully into table '$table'"
    echo "Press Enter to return to Tables Menu..."
    read -r < /dev/tty
    break
;;


# ==========================================================
# 4) Select From Table (All / PK / Projection)
# ==========================================================
4)
    tables=($(ls "$CURRENT_DB" | grep -v "\.meta$"))
    if [[ ${#tables[@]} -eq 0 ]]; then
        echo "No Tables Found"
        read -r < /dev/tty
        break
    fi

    echo "Available Tables:"
    for i in "${!tables[@]}"; do
        echo "$((i+1))) ${tables[$i]}"
    done

    read -r choice < /dev/tty
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#tables[@]} )); then
        echo "Invalid table selection"
        read -r < /dev/tty
        break
    fi

    table="${tables[$((choice-1))]}"
    meta="$CURRENT_DB/$table.meta"
    data="$CURRENT_DB/$table"

    echo "1) Select All"
    echo "2) Select By Primary Key"
    echo "3) Select Specific Columns (Projection)"
    echo "4) Back"
    read -r sel < /dev/tty

    # ---------- Select All ----------
    if [[ "$sel" == "1" ]]; then
        [[ ! -s "$data" ]] && echo "Table is empty" || cat "$data"
        read -r < /dev/tty
        break
    fi

    # ---------- Select By PK ----------
    if [[ "$sel" == "2" ]]; then
        #pk_index=$(grep -n ":PK" "$meta" | cut -d':' -f1)
        pk_index=$(get_pk_index "$meta")

        read -p "Enter Primary Key: " pk < /dev/tty

        found=false
        while IFS= read -r row
        do
            if [[ "$(cut -d':' -f$pk_index <<< "$row")" == "$pk" ]]; then
                echo "$row"
                found=true
                break
            fi
        done < "$data"

        [[ "$found" == false ]] && echo "No record found"
        read -r < /dev/tty
        break
    fi

    # ---------- Projection ----------
    if [[ "$sel" == "3" ]]; then
        columns=()
        while IFS= read -r line; do
            columns+=("$(cut -d':' -f1 <<< "$line")")
        done < "$meta"

        echo "Available Columns:"
        for i in "${!columns[@]}"; do
            echo "$((i+1))) ${columns[$i]}"
        done

        read -r selected < /dev/tty

        if [[ -z "$selected" || ! "$selected" =~ ^[0-9\ ]+$ ]]; then
            echo "Invalid selection"
            read -r < /dev/tty
            break
        fi

        used=()
        for c in $selected
        do
            if (( c < 1 || c > ${#columns[@]} )); then
                echo "Column out of range"
                read -r < /dev/tty
                break 2
            fi

            if [[ " ${used[*]} " =~ " $c " ]]; then
                echo "Duplicate column selection"
                read -r < /dev/tty
                break 2
            fi
            used+=("$c")
        done

        while IFS= read -r row
        do
            out=""
            for c in $selected; do
                out="${out:+$out:}$(cut -d':' -f$c <<< "$row")"
            done
            echo "$out"
        done < "$data"

        read -r < /dev/tty
        break
    fi

    break
;;

# ==========================================================
# 5) Delete From Table
# ==========================================================
5)
    tables=($(ls "$CURRENT_DB" | grep -v "\.meta$"))
    if [[ ${#tables[@]} -eq 0 ]]; then
        echo "No Tables Found"
        read -r < /dev/tty
        break
    fi

    for i in "${!tables[@]}"; do
        echo "$((i+1))) ${tables[$i]}"
    done

    read -r choice < /dev/tty
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#tables[@]} )); then
        echo "Invalid table selection"
        read -r < /dev/tty
        break
    fi

    table="${tables[$((choice-1))]}"
    meta="$CURRENT_DB/$table.meta"
    data="$CURRENT_DB/$table"

    #pk_index=$(grep -n ":PK" "$meta" | cut -d':' -f1)
    pk_index=$(get_pk_index "$meta")
    if (( pk_index == 0 )); then
         echo "Internal Error: Primary Key not defined"
         read -r < /dev/tty
    break
    fi
    read -p "Enter PK to delete: " pk < /dev/tty

    if [[ -z "$pk" ]]; then
        echo "PK cannot be empty"
        read -r < /dev/tty
        break
    fi

    temp="$CURRENT_DB/.tmp_delete"
    found=false
    > "$temp"

    while IFS= read -r row
    do
        if [[ "$(cut -d':' -f$pk_index <<< "$row")" == "$pk" ]]; then
            found=true
        else
            echo "$row" >> "$temp"
        fi
    done < "$data"

    if [[ "$found" == true ]]; then
        mv "$temp" "$data"
        echo "Row deleted successfully"
    else
        rm -f "$temp"
        echo "No record found"
    fi

    read -r < /dev/tty
    break
;;


# ==========================================================
# 6) Update Table
# ==========================================================
6)
    tables=($(ls "$CURRENT_DB" | grep -v "\.meta$"))
    if [[ ${#tables[@]} -eq 0 ]]; then
        echo "No Tables Found"
        read -r < /dev/tty
        break
    fi

    echo "Available Tables:"
    for i in "${!tables[@]}"; do
        echo "$((i+1))) ${tables[$i]}"
    done

    read -r choice < /dev/tty
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#tables[@]} )); then
        echo "Invalid table selection"
        read -r < /dev/tty
        break
    fi

    table="${tables[$((choice-1))]}"
    meta="$CURRENT_DB/$table.meta"
    data="$CURRENT_DB/$table"

    # ====== get PK index =====
    pk_index=$(get_pk_index "$meta")
    if (( pk_index == 0 )); then
        echo "Internal Error: Primary Key not defined"
        read -r < /dev/tty
        break
    fi

    read -p "Enter Primary Key: " pk < /dev/tty
    if [[ -z "$pk" ]]; then
        echo "Primary Key cannot be empty"
        read -r < /dev/tty
        break
    fi

    # ====== check PK exists first 
    pk_found=false
    while IFS= read -r row
    do
        if [[ "$(cut -d':' -f$pk_index <<< "$row")" == "$pk" ]]; then
            pk_found=true
            break
        fi
    done < "$data"

    if [[ "$pk_found" == false ]]; then
        echo "No record found with this Primary Key"
        read -r < /dev/tty
        break
    fi

    # ====== collect non-PK columns
    columns=()
    types=()
    indexes=()
    idx=1

    while IFS= read -r line
    do
        col_name=$(cut -d':' -f1 <<< "$line")
        col_type=$(cut -d':' -f2 <<< "$line")
        col_flag=$(cut -d':' -f3 <<< "$line")

        if [[ "$col_flag" != "PK" ]]; then
            columns+=("$col_name")
            types+=("$col_type")
            indexes+=("$idx")
        fi
        ((idx++))
    done < "$meta"

    if [[ ${#columns[@]} -eq 0 ]]; then
        echo "No columns available to update"
        read -r < /dev/tty
        break
    fi

    echo "Available Columns:"
    for i in "${!columns[@]}"; do
        echo "$((i+1))) ${columns[$i]}"
    done

    read -p "Choose column number: " col_choice < /dev/tty
    if [[ ! "$col_choice" =~ ^[0-9]+$ ]] || (( col_choice < 1 || col_choice > ${#columns[@]} )); then
        echo "Invalid column selection"
        read -r < /dev/tty
        break
    fi

    target_index="${indexes[$((col_choice-1))]}"
    target_type="${types[$((col_choice-1))]}"

    read -p "Enter new value: " new_val < /dev/tty
    if [[ -z "$new_val" ]]; then
        echo "Value cannot be empty"
        read -r < /dev/tty
        break
    fi

    # ====== type validation
    if [[ "$target_type" == "int" && ! "$new_val" =~ ^[0-9]+$ ]]; then
        echo "Invalid integer value"
        read -r < /dev/tty
        break
    fi

    if [[ "$target_type" == "string" && ! "$new_val" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        echo "Invalid string format"
        read -r < /dev/tty
        break
    fi

    # ====== update row
    temp="$CURRENT_DB/.tmp_update"
    > "$temp"

    while IFS= read -r row
    do
        if [[ "$(cut -d':' -f$pk_index <<< "$row")" == "$pk" ]]; then
            fields=($(echo "$row" | tr ':' ' '))
            fields[$((target_index-1))]="$new_val"
            echo "$(IFS=:; echo "${fields[*]}")" >> "$temp"
        else
            echo "$row" >> "$temp"
        fi
    done < "$data"

    mv "$temp" "$data"
    echo "Row updated successfully"
    read -r < /dev/tty
    break
;;


# ==========================================================
# 7) Drop Table
# ==========================================================
7)
    tables=($(ls "$CURRENT_DB" | grep -v "\.meta$"))
    if [[ ${#tables[@]} -eq 0 ]]; then
        echo "No Tables Found"
        read -r < /dev/tty
        break
    fi

    for i in "${!tables[@]}"; do
        echo "$((i+1))) ${tables[$i]}"
    done

    read -r choice < /dev/tty
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#tables[@]} )); then
        echo "Invalid table selection"
        read -r < /dev/tty
        break
    fi

    table="${tables[$((choice-1))]}"
    rm -f "$CURRENT_DB/$table" "$CURRENT_DB/$table.meta"
    echo "Table dropped successfully"
    read -r < /dev/tty
    break
;;

# ==========================================================
# 8) Back
# ==========================================================
8)
    exit 0
;;
*)
    echo "Invalid choice. Please select a valid number from the menu."
    read -p "Press Enter to continue..." < /dev/tty
    break
;;

        esac
    done
done
