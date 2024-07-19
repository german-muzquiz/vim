#!/bin/bash

# Filter entries in tags file that may be needed in the input file.

TAGS_FILE=$1
INPUT_FILE=$2

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <TAGS_FILE> <INPUT_FILE>"
    exit 1
fi

SITE_PACKAGES=$(python -c 'import site; print(site.getsitepackages()[0])')

function find_module_file_in_tags() {
    module=$1
    # Replace dots with slashes, including relative imports
    module_path=$(echo "$module" | sed 's|\.|/|g; s|//|../|g')
    local_file="${module_path}.py"
    if [ -f "$local_file" ]; then
        echo "$local_file"
        return
    fi
    local_file="${module_path}/__init__.py"
    if [ -f "$local_file" ]; then
        echo "$local_file"
        return
    fi
    # If not found, search in the Python environment's library directory
    full_path="$SITE_PACKAGES/${module_path}.py"
    if [ -f "$full_path" ]; then
        echo "$full_path"
        return
    fi
    ini_path="$SITE_PACKAGES/${module_path/.py/}/__init__.py"
    if [ -f "$ini_path" ]; then
        echo "$ini_path"
        return
    fi

}

# Function to find the file where a module might be defined
function find_module_file() {
    module=$1
    # Replace dots with slashes, including relative imports
    module_path=$(echo "$module" | sed 's|\.|/|g; s|//|../|g')
    local_file="${module_path}.py"
    if [ -f "$local_file" ]; then
        echo "$local_file"
        return
    fi
    local_file="${module_path}/__init__.py"
    if [ -f "$local_file" ]; then
        echo "$local_file"
        return
    fi
    # If not found, search in the Python environment's library directory
    full_path="$SITE_PACKAGES/${module_path}.py"
    if [ -f "$full_path" ]; then
        echo "$full_path"
        return
    fi
    ini_path="$SITE_PACKAGES/${module_path/.py/}/__init__.py"
    if [ -f "$ini_path" ]; then
        echo "$ini_path"
        return
    fi
}

function process_file() {
    py_file=$1
    already_processed=$2

    # Read all import statements from the Python file
    imports=$(grep -E '^import |^from ' "$py_file" | sed -E 's/(import|from) //' | cut -d' ' -f1)
    echo "Processing file: $py_file with $(echo "$imports" | wc -l) imports"

    # Loop through each import and find the corresponding file, add it to an array
    module_files=()
    while read -r module; do
        if [ -n "$module" ]; then
            module_file=$(find_module_file "$module")
            # if not empty, add it
            if [ -n "$module_file" ]; then
                module_files+=("$module_file")
            fi
        fi
    done <<<"$imports"

    # recursive call to process each of the imported files
    all_files=("${module_files[@]}")
    for module_file in "${module_files[@]}"; do
        # if not processed, process it
        if [[ ! " ${already_processed[@]} " =~ " ${module_file} " ]]; then
            echo "Processing file: $module_file"
            dependency_files=$(process_file "$module_file" "$(printf "%s " "${already_processed[@]}")")
            all_files=("${all_files[@]}" "${dependency_files[@]}")
        fi
    done

    # remove duplicates from the array
    IFS=" " read -r -a module_files <<< "$(echo "${module_files[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"

    # return the array to the calling function
    echo "${module_files[@]}"
}

echo "Processing file: $INPUT_FILE"
files=$(process_file "$INPUT_FILE")
echo "Module files: ${files[*]}"
