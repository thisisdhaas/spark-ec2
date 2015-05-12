#!/bin/bash

# make sure all of our environment variables are set.
source /root/.bash_profile

# Initialize the db on a big ephemeral drive
sudo -E -u postgres initdb92
sudo -E -u postgres pg_ctl start
sleep 4 # let the db start up
sudo -u postgres createuser --superuser ampcrowd
sudo -u postgres createdb -O ampcrowd -U ampcrowd ampcrowd

# Make sure rabbitmq is running
rabbitmq-server -detached

# Make sure nginx is running
service nginx restart

# Make sure the virtualenv is active
workon ampcrowd

# Kill off the hive metastore, in case it had stale information
if [ -d "/root/sampleclean-async/metastore_db" ]; then
    rm -rf /root/sampleclean-async/metastore_db
fi

# Set up the sampleclean DB
pushd $PROJECT_HOME
scripts/reset_db.sh

# Run the crowd server
scripts/run.sh
popd
