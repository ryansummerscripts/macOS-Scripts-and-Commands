#!/bin/bash

# Function to clear quarantine attributes
function prep() {
  sudo xattr -rd com.apple.quarantine "$1"
  if [ $? -eq 0 ]; then
    echo "
✅ Quarantine Removed: \"$1\""
    ((quarantine_removed_count++)) # Increment success counter
  else
    echo "
❌ Failed to remove quarantine: \"$1\""
  fi
}

# Prompt for file paths
echo "
📝 Please drag and drop one or more .dmg files into this terminal window, then press Enter:
"
read -r input

# Process input to handle escaped spaces and special characters
eval "set -- $input"

# Initialize Counters
quarantine_removed_count=0
file_count=$#

# Validate file count
if [ "$file_count" -eq 0 ]; then
    echo "
❌ No valid files provided. Please drag and drop valid files."
    exit 1
fi

# Loop through each file path and execute the prep function
for filepath in "$@"; do
  if [ -e "$filepath" ]; then
    echo "
.................................................

🔄 Removing quarantine from: \"$1\"..."  
    prep "$filepath"
  else
    echo "
❌ Skipping invalid file or path: \"$filepath\""
  fi
done

# Display final confirmation with counters
echo "
=================================================

Results:

📊 Total files found: $file_count"
echo "
✅ Total files successfully processed: $quarantine_removed_count

================================================="
