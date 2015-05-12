export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7
export WORKON_HOME=/root/.env
export PROJECT_HOME=/root/ampcrowd/
source /usr/local/bin/virtualenvwrapper.sh
if [ -f "/root/spark-ec2/master-domain" ]; then
    export AMT_CALLBACK_HOST=`cat /root/spark-ec2/master-domain`
else
    export AMT_CALLBACK_HOST=`cat /root/spark-ec2/cluster-url | cut -d ':' -f 2 | cut -d "/" -f 3`
fi

export C_FORCE_ROOT=1
export PGDATA=/mnt/ampcrowd/data/
