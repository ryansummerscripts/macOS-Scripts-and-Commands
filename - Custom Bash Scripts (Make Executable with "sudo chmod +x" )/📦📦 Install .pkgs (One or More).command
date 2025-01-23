#!/bin/bash

# Function to install a .pkg file
function install_pkg() {
  echo "
.................................................

📦 Installing \"$1\"...
"
  sudo installer -pkg "$1" -target /
  if [ $? -eq 0 ]; then
    echo "
✅ Successfully installed: \"$1\""
    ((installed_count++))  # Increment the counter on success
  else
    echo "
❌ Failed to install: \"$1\""
  fi
}

# Prompt for folder or file paths
echo "
======================================================================

Usage: Please drag and drop either:

📁  A FOLDER containing .pkg files, OR

📦  Multiple .pkg FILES into this terminal window, then press Enter:

======================================================================
"
read -r input

# Process input to handle escaped spaces and special characters
eval "set -- $input"

# Initialize installation counter
installed_count=0

# Detect if input is a directory
if [ "$#" -eq 1 ] && [ -d "$1" ]; then
  folder_path="$1"
  echo "
📂 Folder detected: \"$folder_path\""
  cd "$folder_path" || { echo "
❌ Failed to navigate to \"$folder_path\""; exit 1; }

  # Process all .pkg files in the folder
  for pkg in *.pkg; do
    if [ -f "$pkg" ]; then
      echo "
🔄 Preparing to install: \"$pkg\"..."
      install_pkg "$pkg"
    fi
  done

# Detect if multiple files are provided
elif [ "$#" -ge 1 ]; then
  echo "
📄 Multiple .pkg files detected. Processing each file..."
  for pkg in "$@"; do
    if [ -f "$pkg" ] && [[ "$pkg" == *.pkg ]]; then
      echo "
🔄 Preparing to install: \"$pkg\"..."
      install_pkg "$pkg"
    else
      echo "
❌ Skipping invalid file: \"$pkg\" (not a .pkg file or does not exist)"
    fi
  done
else
  echo "
❌ Invalid input. Please drag and drop either a folder or .pkg files."
  exit 1
fi

# Display final confirmation with the number of successful installations
echo "
=================================================

Finished ✅

Results:

📊 Total .pkg files installed successfully: $installed_count

Until next time ✌️

================================================="
