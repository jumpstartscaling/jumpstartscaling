#!/bin/bash
# Wrapper for deploy.sh to make it double-clickable on macOS
# Usage: Double-click to run. Arguments can be passed if run from terminal.

# Get the directory where this script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change into that directory
cd "$DIR"

# Run the main deployment script, passing any arguments
./deploy.sh "$@"

# Keep the terminal window open if double-clicked
echo ""
echo "Process completed. You can close this window."
read -p "Press any key to exit..."
