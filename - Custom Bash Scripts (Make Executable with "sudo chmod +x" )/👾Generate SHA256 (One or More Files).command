#!/bin/bash

# Colors
BOLD="\033[1m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
MAGENTA="\033[1;35m"
RESET="\033[0m"

# Function to generate SHA256 hashes
function generate_sha256() {
    for file in "$@"; do
        filename="$(basename "$file")"
        echo -e "
.................................................

🔍 ${BOLD}Hashing:${RESET} \"${GREEN}$filename${RESET}\"..."

        if [ -f "$file" ]; then
            # Get precise file size
            bytes=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
            size_mb=$(awk "BEGIN {printf \"%.2f\", $bytes/1024/1024}")
            size="${size_mb} MB"
            
            # Measure hash time
            start=$(gdate +%s%3N 2>/dev/null || date +%s)
            hash=$(shasum -a 256 "$file" | awk '{print $1}')
            end=$(gdate +%s%3N 2>/dev/null || date +%s)
            duration=$((end - start))
            
            echo -e "📦 ${BOLD}Size:${RESET} ${GREEN}$size${RESET}"
            echo -e "🔐 ${BOLD}SHA256:${RESET} ${GREEN}$hash${RESET}"
            echo -e "⏱️  ${BOLD}Took:${RESET} ${GREEN}${duration}ms${RESET}"
            ((hashed_count++))
        else
            echo -e "❌ ${RED}Skipped:${RESET} \"$filename\" is not a valid file."
        fi
    done
}

# Prompt for file paths
echo -e "
📝 ${BOLD}${GREEN}Please drag and drop one or more files into this terminal window, then press Enter:${RESET}
"
read -r input

# Process input to handle escaped spaces and special characters
eval "set -- $input"

# Initialize Counters
hashed_count=0
file_count=$#

# Validate file count
if [ "$file_count" -eq 0 ]; then
    echo -e "
❌ ${RED}No files provided.${RESET} Please drag and drop one or more valid files and run again. 

.command left the chat...
"
    exit 1
fi

# Run the hash function on all files
generate_sha256 "$@"

# Final Summary
echo -e "
=================================================

Results:

📊 Total files found: $file_count"
echo "
✅ Total SHA256 hashes generated: $hashed_count


Let's hash it out next time ✌️

=================================================
"
