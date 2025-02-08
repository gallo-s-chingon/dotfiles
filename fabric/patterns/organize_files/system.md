#!/usr/bin/env python3
import os
import shutil
from pathlib import Path
import sys

def verify_fd_installed():
    """Check if fd-find is installed."""
    import subprocess
    try:
        subprocess.run(['fd', '--version'], capture_output=True)
        return True
    except FileNotFoundError:
        print("Error: fd-find is not installed. Please install it using 'brew install fd'")
        return False

def get_files_one_level_deep(directory):
    """Get all files one level deep in the directory."""
    try:
        # Using fd-find to get files one level deep
        import subprocess
        result = subprocess.run(
            ['fd', '--max-depth', '1', '--type', 'f'],
            capture_output=True,
            text=True,
            cwd=directory
        )
        files = result.stdout.strip().split('\n')
        return [f for f in files if f]  # Remove empty strings
    except Exception as e:
        print(f"Error getting files: {e}")
        return []

def create_directories(files, directory):
    """Create directories based on file names."""
    created_dirs = []
    for file in files:
        dir_name = os.path.splitext(file)[0]
        dir_path = os.path.join(directory, dir_name)
        try:
            if not os.path.exists(dir_path):
                os.makedirs(dir_path)
                created_dirs.append(dir_path)
                print(f"Created directory: {dir_path}")
        except Exception as e:
            print(f"Error creating directory {dir_path}: {e}")
    return created_dirs

def move_and_rename_files(files, directory):
    """Move files to their directories and rename them."""
    moved_files = []
    for file in files:
        try:
            base_name = os.path.splitext(file)[0]
            source = os.path.join(directory, file)
            target_dir = os.path.join(directory, base_name)
            target_file = os.path.join(target_dir, "system.md")
            
            # Verify source exists
            if not os.path.exists(source):
                print(f"Source file not found: {source}")
                continue
                
            # Verify target directory exists
            if not os.path.exists(target_dir):
                print(f"Target directory not found: {target_dir}")
                continue
                
            # Check if target already exists
            if os.path.exists(target_file):
                print(f"Warning: {target_file} already exists. Skipping.")
                continue
                
            # Move and rename
            shutil.move(source, target_file)
            moved_files.append((source, target_file))
            print(f"Moved and renamed: {source} -> {target_file}")
            
        except Exception as e:
            print(f"Error processing {file}: {e}")
    
    return moved_files

def main():
    if not verify_fd_installed():
        return

    # Get current directory
    directory = os.getcwd()
    
    # Get files
    print("\nGetting files...")
    files = get_files_one_level_deep(directory)
    if not files:
        print("No files found to process.")
        return
    
    print("\nFound files:")
    for file in files:
        print(f"  {file}")
    
    # Confirm with user
    response = input("\nProceed with creating directories and moving files? (y/n): ")
    if response.lower() != 'y':
        print("Operation cancelled.")
        return
    
    # Create directories
    print("\nCreating directories...")
    created_dirs = create_directories(files, directory)
    
    # Move and rename files
    print("\nMoving and renaming files...")
    moved_files = move_and_rename_files(files, directory)
    
    # Summary
    print("\nOperation complete!")
    print(f"Created {len(created_dirs)} directories")
    print(f"Moved and renamed {len(moved_files)} files")

if __name__ == "__main__":
    main()
