#!/bin/bash

# Function to echo in a fancy way
fancy_echo() {
  printf "\n%b\n" "$1"
}

# 1. Install Xcode Command Line Tools
if ! command -v brew &>/dev/null; then
    fancy_echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    # Wait for the user to manually click "Install" in the dialog box
    read -p "Press any key to continue after Xcode Command Line Tools installation..."
fi

# 2. Install Homebrew
if ! command -v brew &>/dev/null; then
    fancy_echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. Install applications and tools via Homebrew
fancy_echo "Installing applications and command-line tools..."
brew install git node python # Example tools

# 4. Configure Git
fancy_echo "Configuring Git..."
git config --global user.name "Nick Brinkel"
git config --global user.email "Nickbrinkel@gmail.com"

# 5. Run system preference changes (optional, be careful!)
# Example: show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles YES
killall Finder # Restart Finder to apply changes

fancy_echo "Setup complete! Please restart your terminal."
