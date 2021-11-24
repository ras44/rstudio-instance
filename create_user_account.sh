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


if confirm "Would you like to create and set up a user account?"; then

  echo ""
  echo "========================================================================="
  echo "Setting up user account"
  echo "========================================================================="
  echo ""
  
  read -p "Enter the USERNAME for the account you would like to create: " ACCT_USERNAME
  adduser --gecos "" --disabled-password $ACCT_USERNAME
  usermod -aG sudo $ACCT_USERNAME
  usermod -aG docker $ACCT_USERNAME

fi

if confirm "Would you like to create and set up a password for the user account (required for RStudio Server)?"; then

  echo ""
  echo "Now enter a temporary password for the account just created."
  echo ""
  passwd $ACCT_USERNAME

fi

if confirm "Would you like to perform installations and configurations for the user account?"; then

 
  cp install_as_user.sh /home/$ACCT_USERNAME/
  cp setup.sh /home/$ACCT_USERNAME/
  chown -R $ACCT_USERNAME /home/$ACCT_USERNAME

  sudo -u $ACCT_USERNAME /home/$ACCT_USERNAME/install_as_user.sh

echo "========================================================================="
echo "Have the user this instance is being set up for SSH in and run setup.sh"
echo "in their home directory. If you set this instance up for yourself, exit"
echo "this session and SSH back in before running setup.sh in your home"
echo "directory."
echo "========================================================================="
echo ""

fi
