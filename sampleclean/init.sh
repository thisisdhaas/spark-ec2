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
    git clone https://github.com/sjyk/sampleclean-async.git

    # install postgres
    yum install -y postgresql92-server

    # Initialize the db on a big ephemeral drive
    export PGDATA=/mnt/sampleclean/data/
    sudo -E -u postgres initdb92

    # Fix the authentication configuration
    pushd /root/spark-ec2/sampleclean
    cp pg_hba.conf /var/lib/pgsql92/data/pg_hba.conf

    # Start postgres
    chkconfig postgresql92 on
    service postgresql92 start

    # Create the database and user
    sudo -u postgres createuser --superuser sampleclean
    createdb -O sampleclean -U sampleclean sampleclean

    # Install rabbitmq and dependencies
    yum install -y erlang
    wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.3.5/rabbitmq-server-3.3.5-1.noarch.rpm
    rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
    yum install -y rabbitmq-server-3.3.5-1.noarch.rpm

    # Install python2.7 and create a virtualenv
    yum install -y python27 python27-devel
    wget wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py -O - | python27
    easy_install-2.7 pip
    pip2.7 install virtualenvwrapper
    cat virtualenv_setup.sh >> /root/.bash_profile
    source /root/.bash_profile
    mkvirtualenv sampleclean
    workon sampleclean
    popd

    # Install python requirements
    pushd sampleclean-async/src/main/python/crowd_server
    yum install -y libpng-devel
    # Crazy hacks to get matplotlib working
    pip install --download . matplotlib==1.4.0 # this will fail to build, but download successfully
    tar xzf matplotlib-1.4.0.tar.gz
    cp setupext.py matplotlib-1.4.0/setupext.py
    rm matplotlib-1.4.0.tar.gz
    tar czf matplotlib-1.4.0.tar.gz matplotlib-1.4.0
    pip install matplotlib-1.4.0.tar.gz

    # and the rest of the python packages
    pip2.7 install -r requirements.txt
fi

# Pre-package tachyon version
#else
#  case "$TACHYON_VERSION" in
#    0.3.0)
#      wget https://s3.amazonaws.com/Tachyon/tachyon-0.3.0-bin.tar.gz
#      ;;
#    0.4.0)
#      wget https://s3.amazonaws.com/Tachyon/tachyon-0.4.0-bin.tar.gz
#      ;;
#    0.4.1)
#      wget https://s3.amazonaws.com/Tachyon/tachyon-0.4.1-bin.tar.gz
#      ;;
#    *)
#      echo "ERROR: Unknown Tachyon version"
#      return -1
#  esac

#  echo "Unpacking Tachyon"
#  tar xvzf tachyon-*.tar.gz > /tmp/spark-ec2_tachyon.log
#  rm tachyon-*.tar.gz
#  mv `ls -d tachyon-*` tachyon
#fi

popd
