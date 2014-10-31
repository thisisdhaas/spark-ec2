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
    git clone https://github.com/sjyk/sampleclean-async.git -b ampcampdemo

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
