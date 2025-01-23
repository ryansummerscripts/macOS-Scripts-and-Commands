#!/bin/bash

# Function to create symlinks
function create_symlink() {
  echo "
.................................................

🔗 Creating symlink for:

\"$1\" into \"$2\"...
"
  sudo ln -s "$1" "$2"
  if [ $? -eq 0 ]; then
    echo "
✅ Done: Symlink created successfully."
    ((symlink_count++)) # Increment success counter
  else
    echo "
❌ Sorry: Failed to create symlink. Please try Again...
"
  fi
}

# Step 1: Prompt for Source files
echo "
===============================================================================================

ℹ️  Usage: This script will first prompt for a source file/folder, and then a destination folder.

When finished, it should successfully create a new symlink (alias) pointing to the source path.

Step 1: Drag and drop SOURCE file(s)/folder(s) into this terminal window and press Enter.

Step 2: Drag and drop a DESTINATION folder into this terminal window and press Enter.

===============================================================================================
"
echo "📂 Step 1 of 2: Please drag and drop one or more SOURCE files/folders into this terminal window, then press Enter:"
read -r input

# Process input to handle escaped spaces and special characters
eval "set -- $input"

# Initialize Counters
symlink_count=0
source_count=$#

# Validate Source Paths
if [ "$source_count" -eq 0 ]; then
    echo "
❌ No valid source paths provided. Please drag and drop valid files or folders."
    exit 1
fi

for source in "$@"; do
  if [ ! -e "$source" ]; then
    echo "
❌ Invalid source path: \"$source\""
    exit 1
  fi
done

# Step 2: Prompt for Destination folder
echo "
📁 Step 2 of 2: Please drag and drop the DESTINATION folder into this terminal window, then press Enter:
"
read -r dest_input

# Process and validate the destination path
destination="$(eval echo "$dest_input")"

if [ ! -d "$destination" ]; then
  echo "❌ Invalid destination path: \"$destination\""
  exit 1
fi

# Create symlinks
for source in "$@"; do
  basename=$(basename "$source")
  create_symlink "$source" "$destination/$basename"
done

# Final Summary
echo "
=================================================

Finished ✅

Results:

📊 Total source paths found: $source_count

🔗 Total symlinks successfully created: $symlink_count

Signing off now... ✌️

================================================="
