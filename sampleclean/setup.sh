#!/bin/bash

# make sure all of our environment variables are set.
source /root/.bash_profile

# Initialize the db on a big ephemeral drive
sudo -E -u postgres initdb92
sudo -E -u postgres pg_ctl start
sleep 4 # let the db start up
sudo -u postgres createuser --superuser sampleclean
sudo -u postgres createdb -O sampleclean -U sampleclean sampleclean

# Make sure rabbitmq is running
rabbitmq-server -detached

# Make sure the virtualenv is active
workon sampleclean

# Kill off the hive metastore, in case it had stale information
if [ -d "/root/sampleclean-async/metastore_db" ]; then
    rm -rf /root/sampleclean-async/metastore_db
fi

# Set up the sampleclean DB
pushd $PROJECT_HOME
./reset_db.sh
popd
