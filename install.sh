#!/bin/bash

# Exit on any errors
set -e

R_VERSION=3.6.2
R_MAJOR_VERSION=`echo $R_VERSION | cut -d. -f1`
RSTUDIO_VERSION=1.2.5033
R_SHINY_SERVER_VERSION=1.5.12.933
PYTHON3_VERSION=3.6.2

# Update yum
sudo yum update 

# Base packages
sudo yum install -y \
  gcc \
  pkgconfig \
  openssl-devel \
  unixODBC \
  unixODBC-devel \
  wget \
  screen

# Add the EPEL repo for yum
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release-latest-7.noarch.rpm || true

# Required by R Roxygen package
sudo yum install -y libxml2-devel
sudo yum install -y texlive-titling # Required by RMarkdown knit to pdf


# Required by R build
sudo yum install -y 
  java-1.8.0-openjdk java-1.8.0-openjdk-devel \
  gcc-gfortran \
  gcc-c++ \
  bzip2-devel \
  libcurl-devel

# Install optional python $PYTHON3_VERSION in /usr/bin

sudo yum -y install libffi-devel sqlite-devel

WD=`pwd`
      mkdir tmp
      cd tmp
      wget https://www.python.org/ftp/python/$PYTHON3_VERSION/Python-$PYTHON3_VERSION.tgz
      tar -xzvf Python-$PYTHON3_VERSION.tgz
      cd Python-$PYTHON3_VERSION
      ./configure --prefix=/usr/bin/python-$PYTHON3_VERSION --enable-shared --enable-optimizations --enable-loadable-sqlite-extensions
      make
      make install
cd $WD

# Install pip

curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
python get-pip.py

# Install virtualenv
sudo pip install --upgrade virtualenv

# Install R
       
wget https://cran.r-project.org/src/base/R-${R_MAJOR_VERSION}/R-${R_VERSION}.tar.gz

tar -xzvf R-$R_VERSION.tar.gz
cd R-$R_VERSION
./configure \
  --enable-memory-profiling \
  --enable-R-shlib \
  --with-blas \
  --with-lapack \
  --with-x=no
make
make install
export PATH=$PATH:/usr/local/lib64/R/bin/
cd ..

# Workaround for R reticulate package references non-existent lib
sudo ln -s /usr/lib64/libpython2.7.so.1.0 /usr/lib64/libpython2.7.so


# Install packrat at the system level
echo 'install.packages("packrat", repos = "http://cran.us.r-project.org")' | sudo /usr/local/bin/R --vanilla

# Download RStudio Server
wget https://download2.rstudio.org/server/centos6/x86_64/rstudio-server-rhel-$RSTUDIO_VERSION-x86_64.rpm
# Install RStudio Server
sudo yum install -y --nogpgcheck rstudio-server-rhel-$RSTUDIO_VERSION-x86_64.rpm
# Stop yum from auto-updating R
echo "exclude=R-* R.x86* libR*"  | sudo tee -a /etc/yum.conf

# Start RStudio Server
sudo rstudio-server restart || true

# Install R Shiny Server
  wget https://download3.rstudio.org/centos6.3/x86_64/shiny-server-$R_SHINY_SERVER_VERSION-x86_64.rpm
  sudo yum install --nogpgcheck shiny-server-$R_SHINY_SERVER_VERSION-x86_64.rpm

