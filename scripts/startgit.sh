#!/bin/bash

# Define log file
LOGDIR=~/scripts/logs
LOGFILE=$LOGDIR/update_system.log

# Create log directory if it doesn't exist
mkdir -p $LOGDIR

# Function to log messages with timestamp and separator
log() {
    echo "------------------------------------------------------------" | tee -a $LOGFILE
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    echo "------------------------------------------------------------" | tee -a $LOGFILE
}

# Check if xclip is installed, if not, install it
if ! command -v xclip &> /dev/null; then
    log "xclip is not installed. Installing xclip..."
    sudo apt update | tee -a $LOGFILE
    sudo apt install xclip -y | tee -a $LOGFILE
fi

# Prompt for user email for SSH key if not already set
if [ -z "$EMAIL" ]; then
    read -p "Enter your email address for SSH key: " EMAIL
fi

# Generate SSH key if it doesn't exist
SSH_KEY=~/.ssh/id_ed25519
if [ ! -f "$SSH_KEY" ]; then
    log "Generating a new SSH key with email $EMAIL..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f $SSH_KEY -N "" | tee -a $LOGFILE
    log "Copying the SSH key to clipboard..."
    cat "$SSH_KEY.pub" | xclip -selection clipboard
    log "SSH key generated and copied to clipboard. Please add it to your GitHub account."
    echo "SSH key generated and copied to clipboard. Please add it to your GitHub account."
    read -p "Press Enter to continue after adding the SSH key to GitHub..."
fi

# Update the system
log "Updating the system..."
sudo apt update | tee -a $LOGFILE && sudo apt upgrade -y | tee -a $LOGFILE

# Clone the git repository using SSH
log "Cloning git repository using SSH..."
git clone git@github.com:gnugo/dotfiles.git ~/repo | tee -a $LOGFILE

# Rename the original .bashrc
log "Renaming the original .bashrc to .bashrc_default..."
mv ~/.bashrc ~/.bashrc_default | tee -a $LOGFILE

# Copy the new .bashrc from the repo to home
log "Copying the new .bashrc from the repo to your home folder..."
cp ~/repo/.bashrc ~/ | tee -a $LOGFILE

# Create the scripts folder in home
log "Creating a scripts folder in your home directory.."
mkdir -p ~/scripts | tee -a $LOGFILE

# Copy scripts from the repo to the scripts folder in home
log "Copying scripts from the repo to  new scripts folder..."
cp ~/repo/scripts/* ~/scripts/ | tee -a $LOGFILE

# Navigate to the repo directory
cd ~/repo

# Initialize the repo as a git repository and set the remote origin using SSH
log "Initializing git repository and setting remote origin using SSH..."
git init | tee -a $LOGFILE
git remote add origin git@github.com:gnugo/dotfiles.git | tee -a $LOGFILE

# Pull the latest changes from the remote repository
log "Pulling latest changes from the remote repository..."
git pull origin main | tee -a $LOGFILE

log "------------------------------------------------------------"
log "All done!"
log "Your repo is also set up and synchronized."
log "------------------------------------------------------------"
