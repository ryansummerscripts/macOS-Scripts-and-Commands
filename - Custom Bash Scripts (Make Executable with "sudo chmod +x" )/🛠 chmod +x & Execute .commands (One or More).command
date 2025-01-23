#!/bin/bash

# Function to make a .command file executable and run it
function process_command_file() {
    chmod +x "$1"
    if [ $? -eq 0 ]; then
        echo "✅ Made executable: \"$1\""
        "./$1"
        if [ $? -eq 0 ]; then
            echo "🚀 Successfully executed: \"$1\""
            ((executed_count++)) # Increment the success counter
        else
            echo "❌ Failed to execute: \"$1\""
        fi
    else
        echo "❌ Failed to make executable: \"$1\""
    fi
}

# Prompt for file paths
echo "📝 Please drag and drop one or more .command files into this terminal window, then press Enter:"
read -r input

# Process input to handle escaped spaces and special characters
eval "set -- $input"

# Initialize counters
executed_count=0
file_count=$#

# Validate file count
if [ "$file_count" -eq 0 ]; then
    echo "❌ No valid files provided. Please drag and drop valid .command files."
    exit 1
fi

# Loop through each .command file and process it
for file in "$@"; do
    if [ -f "$file" ]; then
        echo "🔄 Processing: \"$file\"..."
        process_command_file "$file"
    else
        echo "❌ Skipping invalid file or path: \"$file\""
    fi
done

# Display final confirmation with counters
echo "✅ All valid .command files have been processed."
echo "📊 Total .command files found: $file_count"
echo "🚀 Total .command files successfully executed: $executed_count"
