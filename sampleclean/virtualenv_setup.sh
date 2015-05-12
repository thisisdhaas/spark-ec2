export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7
export WORKON_HOME=/root/.env
export PROJECT_HOME=/root/ampcrowd/
source /usr/local/bin/virtualenvwrapper.sh
export AMT_CALLBACK_HOST=`cat /root/spark-ec2/master-domain`

export C_FORCE_ROOT=1
export PGDATA=/mnt/ampcrowd/data/
