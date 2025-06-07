# macOS-Scripts-and-Commands
Various collection of my personal macOS scripts and terminal commands

To run any of the .command files, you may first need to de-quarantine them as well as make them executable.

🧼 De-Quarantining, Signing & Granting Execute Permissions:

By default, macOS flags & quarantines unsigned files downloaded from the internet, preventing these from being ran simply by double clicking them. If you wish to run a .command script by double clicking it, you can remove their quarantine attributes as well as sign the script.

1. Copy the command below inside the "quotes" (including the space at the end of 'prep'):

"function prep() {
    for file in "$@"; do
        sudo xattr -cr "$file" # clears all extended attributes
        sudo xattr -r -d com.apple.quarantine "$file" # removes the quarantine flag to bypass macOS Gatekeeper warnings
        sudo codesign --force --deep --sign - "$file" # signs the file and it's contents with an ad-hoc signature
        sudo chmod +x "$file" # grants execute permission to the file, allowing it to run
    done
}
prep " 

2. Paste the command into terminal and drag and drop the .command file onto the Terminal window, then press Enter.
Example:

function prep() {
    for file in "$@"; do
        sudo xattr -cr "$file"
        sudo xattr -r -d com.apple.quarantine "$file"
        sudo codesign --force --deep --sign - "$file"
        sudo chmod +x "$file"
    done
}
prep /Users/YOURUSERNAME/Downloads/NAMEOFCOMMAND.command

3. Type your password and hit Enter again (password will be invisible).

4. The command file should now open as usual when double clicking it.

If unsure about safety, confirm that these scripts are safe by asking chatgpt or upload them to virus total.

Enjoy!
