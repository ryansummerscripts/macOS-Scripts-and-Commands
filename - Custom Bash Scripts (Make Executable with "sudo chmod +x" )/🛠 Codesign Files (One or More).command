#!/bin/bash

# Function to clear quarantine attributes and code sign a file
function prep() {
    for file in "$@"; do
        echo "
.................................................

🔄 Signing: \"$file\"...
"
        sudo xattr -cr "$file"                            # Clear extended attributes
        sudo xattr -r -d com.apple.quarantine "$file"     # Remove quarantine flag
        sudo codesign --force --deep --sign - "$file"     # Code sign with ad-hoc identity
        if [ $? -eq 0 ]; then
            echo "
✅ Signed \"$file\""
            ((signed_count++))  # Increment signed counter on success
        else
            echo "
❌ Failed. Please use a valid file type...: \"$file\"
"
        fi
    done
}

# Prompt for file paths
echo "
📝 Please drag and drop one or more files or apps into this terminal window, then press Enter:
"
read -r input

# Process input to handle escaped spaces and special characters
eval "set -- $input"

# Initialize Counters
signed_count=0
file_count=$#

# Validate file count
if [ "$file_count" -eq 0 ]; then
    echo "
❌ No files provided. Please drag and drop one or more valid files and run again. 

.command left the chat...
"
    exit 1
fi

# Run the prep function on all files
prep "$@"

# Final Summary
echo "
=================================================

Results:

📊 Total files found: $file_count"
echo "
✅ Total files successfully signed: $signed_count

Signing off now ✌️

================================================="
