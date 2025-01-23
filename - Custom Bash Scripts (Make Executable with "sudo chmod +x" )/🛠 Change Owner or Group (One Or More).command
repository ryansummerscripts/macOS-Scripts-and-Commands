#!/bin/bash

# Function to change owner and group
function change_owner_group() {
  sudo chown -R "$USER:staff" "$1"
  if [ $? -eq 0 ]; then
    echo "
✅ Owner and group changed: \"$1\""
    ((owner_changed_count++)) # Increment success counter
  else
    echo "
❌ Failed to change owner/group: \"$1\""
  fi
}

# Prompt for file paths
echo "
📝 Please drag and drop one or more files or directories into this terminal window, then press Enter:
"
read -r input

# Process input to handle escaped spaces and special characters
eval "set -- $input"

# Initialize Counters
owner_changed_count=0
file_count=$#

# Validate file count
if [ "$file_count" -eq 0 ]; then
    echo "
❌ No valid files provided. Please drag and drop valid files."
    exit 1
fi

# Loop through each file path and execute the change_owner_group function
for filepath in "$@"; do
  if [ -e "$filepath" ]; then
    echo "
.................................................

🔄 Changing owner and group for: \"$filepath\"..."
    change_owner_group "$filepath"
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
✅ Total files successfully processed: $owner_changed_count

================================================="
