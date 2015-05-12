
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7
export WORKON_HOME=/root/.env
export PROJECT_HOME=/root/ampcrowd/
source /usr/local/bin/virtualenvwrapper.sh
source /root/spark-ec2/ec2-variables.sh
export AMT_CALLBACK_HOST=$MASTER_DOMAIN
export C_FORCE_ROOT=1
export PGDATA=/mnt/ampcrowd/data/
