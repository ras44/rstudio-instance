#!/bin/bash

#exit on any errors
set -e

R_VERSION=4.0.3
R_MAJOR_VERSION=`echo $R_VERSION | cut -d. -f1`
RSTUDIO_VERSION=1.4.1103
R_SHINY_SERVER_VERSION=1.5.16.958
DOCKER_VERSION=5:20.10.3~3-0~ubuntu-focal

confirm() {
  read -r -p "Error detected, continue? [Y/n] " response
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
  echo "Installing Linux packages"
  echo "========================================================================="
  echo ""

  apt-get update && apt-get install -y \
    gcc \
    zip

  # Required by R Roxygen package
  apt-get install -y libxml2-dev

  # install libpqxx-dev required for redshift queries from jupyter #167
  apt-get install -y libpqxx-dev


  echo ""
  echo "========================================================================="
  echo "Installing pip for python 3"
  echo "========================================================================="
  echo ""

  apt-get install -y python3-pip

  # original version is: pip 20.0.2 from /usr/lib/python3.8/dist-packages

  echo ""
  echo "========================================================================="
  echo "Installing Python libraries"
  echo "========================================================================="
  echo ""

  apt-get install -y python3-venv


  echo ""
  echo "========================================================================="
  echo " Installing docker"
  echo "========================================================================="
  echo ""

  # Required by docker
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

  apt-get install docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io


  echo ""
  echo "========================================================================="
  echo "Installing profiles to be run in /etc/profile.d upon login"
  echo "========================================================================="
  echo ""

  cp install/profile_rstudio_instance.sh /etc/profile.d/profile_rstudio_instance.sh

  # note: ensure etc/profile.d/ scripts have u+r; if not set umask in etc/profile and etc/bashrc and resource
  chmod 644 /etc/profile.d/profile_rstudio_instance.sh

  # source the bashrc and hence profile scripts
  source /etc/bash.bashrc

  echo ""
  echo "========================================================================="
  echo "Installing R"
  echo "========================================================================="
  echo ""

  # Required by RJava package
  apt-get install -y openjdk-8-jdk

  # Required by curl package
  apt-get install -y libcurl4-openssl-dev libssl-dev

  apt-get install -y gdebi-core

  curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${R_VERSION}_1_amd64.deb
  gdebi -n r-${R_VERSION}_1_amd64.deb

  ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
  ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

  # workaround for #100, R reticulate package references non-existent lib
  # ln -sf /usr/lib64/libpython2.7.so.1.0 /usr/lib64/libpython2.7.so

  # chmod a+r /opt/R/4.0.3/lib/R/etc/Makeconf
  # chmod a+r /opt/R/4.0.3/lib/R/etc/ldpaths
  # chmod a+r /opt/R/4.0.3/lib/R/etc/Rprofile.site

  echo ""
  echo "========================================================================="
  echo "Installing R Packages"
  echo "========================================================================="
  echo ""

  cd install && Rscript install.R && cd ..


  echo ""
  echo "========================================================================="
  echo "Setting up system Rprofile.site in /usr/lib64/R/etc/"
  echo "========================================================================="
  echo ""

  mkdir -p /usr/local/lib64/R/etc

  if [ -f /usr/local/lib64/R/etc/Rprofile.site ]; then
    current_dt=$(date "+%Y%m%d%H%M%S")
     mv /opt/R/$R_VERSION/lib/R/etc/Rprofile.site /opt/R/$R_VERSION/lib/R/etc/Rprofile.site.bak.$current_dt
  fi
  cp install/r_config_files/Rprofile.site /opt/R/$R_VERSION/lib/R/etc/Rprofile.site
  #chmod 644 !$


  echo ""
  echo "========================================================================="
  echo "Downloading RStudio Server"
  echo "========================================================================="
  echo ""

  wget https://download2.rstudio.org/server/centos7/x86_64/rstudio-server-rhel-$RSTUDIO_VERSION-x86_64.rpm


  echo ""
  echo "========================================================================="
  echo "Installing and starting RStudio Server"
  echo "========================================================================="
  echo ""

  apt-get install -y r-base

  apt-get install -y gdebi-core
  wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-$RSTUDIO_VERSION-amd64.deb
  gdebi -n rstudio-server-$RSTUDIO_VERSION-amd64.deb


  echo ""
  echo "========================================================================="
  echo "Replacing RStudio Server config files with customized versions"
  echo "========================================================================="
  echo ""

  if [ -f /etc/rstudio/rserver.conf ]; then
    current_dt=$(date "+%Y%m%d%H%M%S")
    mv /etc/rstudio/rserver.conf /etc/rstudio/rserver.conf.bak.$current_dt
  fi
  cp install/rstudio_server_config_files/rserver.conf /etc/rstudio/rserver.conf

  if [ -f /etc/rstudio/rsession.conf ]; then
    current_dt=$(date "+%Y%m%d%H%M%S")
    mv /etc/rstudio/rsession.conf /etc/rstudio/rsession.conf.bak.$current_dt
  fi
  cp install/rstudio_server_config_files/rsession.conf /etc/rstudio/rsession.conf

  # restart rstudio-server and confirm continue if no rsession error
  rstudio-server restart || confirm


  echo ""
  echo "========================================================================="
  echo "Installing R Shiny Server"
  echo "========================================================================="
  echo ""

  sudo su - \
  -c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""

  apt-get install -y gdebi-core
  wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$R_SHINY_SERVER_VERSION-amd64.deb
  gdebi -n shiny-server-$R_SHINY_SERVER_VERSION-amd64.deb


  echo ""
  echo "========================================================================="
  echo " Stopping automatic updates from apt and snap"
  echo "========================================================================="
  echo ""

  apt-get purge update-manager update-notifier unattended-upgrades
  sudo systemctl mask snapd.service
  # to re-enable snapd:
  # sudo systemctl unmask snapd.service
  # snap refresh

  echo ""
  echo "========================================================================="
  echo "Installing AWS CLI"
  echo "========================================================================="
  echo ""

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install




echo ""
echo "========================================================================="
echo "Installation is complete!"
echo "========================================================================="
echo ""
