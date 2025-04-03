#!/bin/bash

# Directory name to clone FreshRSS into
TARGET_DIR="FreshRSS"

# Check if the directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo "The directory '$TARGET_DIR' already exists. Skipping clone."
else
    echo "Cloning the latest branch from https://github.com/FreshRSS/FreshRSS.git into '$TARGET_DIR'..."
    git clone --branch latest https://github.com/FreshRSS/FreshRSS.git "$TARGET_DIR"
    
    if [ $? -eq 0 ]; then
        echo "Successfully cloned into '$TARGET_DIR'."
    else
        echo "Failed to clone the repository. Please check your connection or repository URL."
    fi
fi