# Spark environment hook
#  -- loads config options via NFS

if [ -r /home/jovyan/spark-env.sh ]; then
    source /home/jovyan/spark-env.sh
fi
