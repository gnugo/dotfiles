#!/bin/bash

# Define log file
LOGDIR=~/dotfiles/logs
LOGFILE=$LOGDIR/update_system.log

# Create log directory if it doesn't exist
mkdir -p $LOGDIR

# Function to log messages with timestamp and separator
log() {
    echo "------------------------------------------------------------" | tee -a $LOGFILE
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
    echo "------------------------------------------------------------" | tee -a $LOGFILE
}

# Check if git is installed, if not, install it
if ! command -v git &> /dev/null; then
    log "Git is not installed. Installing git..."
    sudo apt update | tee -a $LOGFILE
    sudo apt install git -y | tee -a $LOGFILE
fi

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

# Prompt for SSH key file name
read -p "Enter a name for the SSH key file (default is id_ed25519): " KEY_NAME
KEY_NAME=${KEY_NAME:-id_ed25519}

# Generate SSH key if it doesn't exist
SSH_KEY=~/.ssh/$KEY_NAME
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
git clone git@github.com:gnugo/dotfiles.git ~/dotfiles | tee -a $LOGFILE

# Rename the original .bashrc if it exists
if [ -f ~/.bashrc ]; then
    log "Renaming the original .bashrc to .bashrc_default..."
    mv ~/.bashrc ~/.bashrc_default | tee -a $LOGFILE
else
    log "No existing .bashrc file found. Skipping renaming."
fi

# Copy the new .bashrc from the repo to home
if [ -f ~/dotfiles/.bashrc ]; then
    log "Copying the new .bashrc from the repo to your home folder..."
    cp ~/dotfiles/.bashrc ~/ | tee -a $LOGFILE
else
    log "No .bashrc file found in the repo. Skipping copy."
fi

# Create the scripts folder in home if it doesn't exist
log "Creating a scripts folder in your home directory if it doesn't exist..."
mkdir -p ~/scripts | tee -a $LOGFILE

# Copy scripts from the repo to the scripts folder in home
if [ -d ~/dotfiles/scripts ]; then
    log "Copying scripts from the repo to your shiny new scripts folder..."
    cp ~/dotfiles/scripts/* ~/scripts/ | tee -a $LOGFILE
else
    log "No scripts folder found in the repo. Skipping copy."
fi

# Navigate to the repo directory
cd ~/dotfiles

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

