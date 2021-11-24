#!/bin/bash

confirm() {
  read -r -p "$1 [Y/n] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

echo ""
echo "========================================================================="
echo "You will be walked through a series of steps to get your account setup."
echo "It is important that all steps are completed successfully in order for"
echo "everthing to function correctly. If you're unsure about any step, ask"
echo "for help." 
echo "========================================================================="
echo ""

echo ""
echo "========================================================================="
echo "Add public SSH key to GitHub's allowed SSH keys"
echo "========================================================================="
echo ""

cat ~/.ssh/id_rsa.pub
echo ""
echo "Copy and add the above SSH public key (starting with \"ssh-rsa\") to GitHub's allowed SSH keys and press the RETURN key once that is complete." 
read

echo ""
echo "========================================================================="
echo "Set your account's default git identity by providing your email address"
echo "and full name."
echo "========================================================================="
echo ""

read -p "Enter your email address: " EMAIL 
git config --global user.email "$EMAIL" 
read -p "Enter your full name: " FULL_NAME
git config --global user.name "$FULL_NAME" 

echo ""
echo "========================================================================="
echo "Setup is complete!"
echo "========================================================================="
echo ""

cat ~/GETTING_STARTED.md

echo "You can reference this information at a later date in the"
echo "GETTING_STARTED.md file in your home directory."
echo ""

