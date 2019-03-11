#!/bin/bash

#exit on any errors
set -e

R_MAJOR_VERSION=3
R_VERSION=3.5.0
RSTUDIO_VERSION=1.1.453

# Install apt-get-utils for apt-get-builddep
sudo apt-get update
sudo apt-get install -y wget 

sudo apt-get build-dep r-base

sudo apt-get install -y libsecret-1-dev libsodium-dev libssl-dev # Required by R keyring package
sudo apt-get install -y texlive-full # Required by RMarkdown knit to pdf
sudo apt-get install -y libxml2-dev # Required by xml2
sudo apt-get install -y unixodbc-dev # Required by odbc

# Download R
wget https://cran.r-project.org/src/base/R-${R_MAJOR_VERSION}/R-${R_VERSION}.tar.gz
tar -xzf R-${R_VERSION}.tar.gz
cd R-${R_VERSION}
./configure --enable-R-shlib --with-blas --with-lapack
make
sudo make install
cd ..

# Install packrat at the system level
echo 'install.packages("packrat", repos = "http://cran.us.r-project.org")' | sudo R --vanilla

# Download RStudio Server
sudo apt-get -y install gdebi-core
wget https://download2.rstudio.org/rstudio-server-stretch-$RSTUDIO_VERSION-amd64.deb
sudo gdebi rstudio-server-stretch-$RSTUDIO_VERSION-amd64.deb

# Stop apt-get from auto-updating or installing R
sudo apt-mark hold r-base

# Start RStudio Server
sudo rstudio-server restart || true


echo "now set your user password (required for RStudio Server login) with 'sudo passwd <USERNAME>'"

