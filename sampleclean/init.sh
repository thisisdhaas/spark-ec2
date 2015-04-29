#!/bin/bash

pushd /root

if [ -d "sampleclean-async" ]; then
  echo "Sampleclean seems to be installed. Exiting."
  popd
  return 0
fi

SAMPLECLEAN_VERSION=0.0.1

# Github tag:
if [[ "$SAMPLECLEAN_VERSION" == *\|* ]]
then
  # Not yet supported
  echo ""
else
    # clone the sampleclean git repo
    git clone https://github.com/sjyk/sampleclean-async.git -b master

    # install postgres
    echo "Setting up postgres..."
    yum install -y postgresql92-server
    yum install -y postgresql92-devel

    # Fix the authentication configuration
    pushd /root/spark-ec2/sampleclean
    cp pg_hba.conf /var/lib/pgsql92/data/pg_hba.conf
    popd

    # Install rabbitmq and dependencies
    echo "Setting up rabbitmq..."
    yum install -y erlang
    wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.3.5/rabbitmq-server-3.3.5-1.noarch.rpm
    rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    yum install -y rabbitmq-server-3.3.5-1.noarch.rpm
    rm rabbitmq-server-3.3.5-1.noarch.rpm

    # Install and set up nginx and ssl certificates
    echo "Setting up nginx..."
    yum install -y nginx
    pushd /root/spark-ec2/sampleclean
    cp nginx.conf /etc/nginx/nginx.conf
    echo "Setting up ssl certificates..."
    if [ -f sampleclean1_eecs_berkeley_edu_chained.cer ]; then
	echo "Production certs found, installing..."
	cp sampleclean1_eecs_berkeley_edu_chained.cer /etc/pki/tls/certs/sampleclean_chained.cer
	cp sampleclean1.eecs.berkeley.edu-san.key /etc/pki/tls/certs/sampleclean.key
    else
	echo "No production certs found, installing development certs..."
	cp /root/sampleclean-async/src/main/python/crowd_server/crowd_server/ssl/development.crt /etc/pki/tls/certs/sampleclean_chained.cer
	cp /root/sampleclean-async/src/main/python/crowd_server/crowd_server/ssl/development.key /etc/pki/tls/certs/sampleclean.key
    fi
    popd

    # Install AMT credentials
    echo "Installing AMT credentials..."
    pushd /root/spark-ec2/sampleclean
    AMT_ACCESS_KEY=`cat amt_credentials.csv | grep Access | cut -d "=" -f 2 | tr -d '\r'`
    AMT_SECRET_KEY=`cat amt_credentials.csv | grep Secret | cut -d "=" -f 2 | tr -d '\r'`
    popd
    pushd /root/sampleclean-async/src/main/python/crowd_server/crowd_server
    sed "s/AMT_ACCESS_KEY = 'CHANGEME'/AMT_ACCESS_KEY = '$AMT_ACCESS_KEY'/" < private_settings.py.default > tmp1
    sed "s/AMT_SECRET_KEY = 'CHANGEME'/AMT_SECRET_KEY = '$AMT_SECRET_KEY'/" < tmp1 > private_settings.py
    rm tmp1
    popd

    # Install emacs because it is king.
    yum install -y emacs

    # Install python2.7 and create a virtualenv
    echo "Setting up python virtualenv..."
    yum install -y python27 python27-devel
    wget wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python27
    easy_install-2.7 pip
    pip2.7 install virtualenvwrapper
    rm setuptools-7.0.zip
    pushd /root/spark-ec2/sampleclean
    cat virtualenv_setup.sh >> /root/.bash_profile
    popd
    source /root/.bash_profile
    mkvirtualenv sampleclean
    workon sampleclean

    # Install python requirements
    echo "Installing matplotlib..."
    yum install -y libpng-devel
    yum install -y freetype-devel
    # Crazy hacks to get matplotlib working
    pip install --download . matplotlib==1.4.0 # this will fail to build, but download successfully
    tar xzf matplotlib-1.4.0.tar.gz
    cp spark-ec2/sampleclean/setupext.py matplotlib-1.4.0/setupext.py
    rm matplotlib-1.4.0.tar.gz
    tar czf matplotlib-1.4.0.tar.gz matplotlib-1.4.0
    pip install matplotlib-1.4.0.tar.gz
    rm matplotlib-1.4.0.tar.gz
    rm -rf matplotlib-1.4.0

    # and the rest of the python packages
    echo "Installing remaining python requirements..."
    pushd sampleclean-async/src/main/python/crowd_server
    pip2.7 install -r requirements.txt

    # no need for the sites fixture
    rm basecrowd/fixtures/initial_data.json
    popd
fi
popd
