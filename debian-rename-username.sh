#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run this script as root or with sudo."
  exit 1
fi

# Prompt for the current username
read -p "Enter the CURRENT username to change: " OLD_USER

# Check if the user exists
if ! id "$OLD_USER" &>/dev/null; then
  echo "Error: User '$OLD_USER' does not exist."
  exit 1
fi

# Prompt for the new username
read -p "Enter the NEW username: " NEW_USER

# Validate new username is not empty
if [ -z "$NEW_USER" ]; then
  echo "Error: New username cannot be empty."
  exit 1
fi

# Check if the new username already exists
if id "$NEW_USER" &>/dev/null; then
  echo "Error: Username '$NEW_USER' is already taken."
  exit 1
fi

# Prompt for the new full display name (optional)
read -p "Enter the NEW full display name (Press Enter to skip): " FULL_NAME

echo "------------------------------------------------"
echo "Preparing to rename '$OLD_USER' to '$NEW_USER'..."
echo "------------------------------------------------"

# Terminate active processes for the old user
echo "Stopping any active processes for $OLD_USER..."
pkill -9 -u "$OLD_USER" 2>/dev/null
sleep 1

# Rename user and migrate home directory
echo "Renaming user and moving home directory..."
if usermod -l "$NEW_USER" -d "/home/$NEW_USER" -m "$OLD_USER"; then
  echo "Successfully renamed user login and home directory."
else
  echo "Error: Failed to change username/home directory. Ensure no lingering processes are running."
  exit 1
fi

# Rename the primary group
echo "Updating primary group name..."
if groupmod -n "$NEW_USER" "$OLD_USER" 2>/dev/null; then
  echo "Successfully updated group name."
else
  echo "Notice: Primary group could not be renamed (it may not exist or matches another name)."
fi

# Update full name if provided
if [ -not -z "$FULL_NAME" ]; then
  echo "Updating full display name..."
  chfn -f "$FULL_NAME" "$NEW_USER"
fi

echo "------------------------------------------------"
echo " Done! User '$OLD_USER' is now '$NEW_USER'."
echo " Please check if any manual configurations (cron jobs, sudoers)"
echo " need to be updated for the new name."
echo "------------------------------------------------"
