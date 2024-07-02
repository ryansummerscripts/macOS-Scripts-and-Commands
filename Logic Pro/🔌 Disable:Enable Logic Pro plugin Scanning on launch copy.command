#!/bin/bash

# Get the current setting
current_state=$(defaults read com.apple.logic10 AudioUnitAutoScanAtLaunch 2>/dev/null)

# Toggle the setting
if [ "$current_state" == "1" ]; then
    echo "Disabling plugin scan at launch..."
    defaults write com.apple.logic10 AudioUnitAutoScanAtLaunch -bool false
else
    echo "Enabling plugin scan at launch..."
    defaults write com.apple.logic10 AudioUnitAutoScanAtLaunch -bool true
fi

# Confirm the change
new_state=$(defaults read com.apple.logic10 AudioUnitAutoScanAtLaunch)
if [ "$new_state" == "1" ]; then
    echo "Plugin scan at launch is now enabled."
else
    echo "Plugin scan at launch is now disabled."
fi
