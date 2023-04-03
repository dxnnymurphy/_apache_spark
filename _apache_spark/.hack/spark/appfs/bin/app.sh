#!/bin/bash

SCRIPT_DIRNAME=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_BASENAME=$( basename "${BASH_SOURCE[0]}" )

PrintHelp() {
    echo
    echo "======================================================================================"
    echo "Data > Spark"
    echo "======================================================================================"
    echo
    echo "## Authors"
    echo "        - Daniel Murphy (dannymurphy_7@icloud.com)
    echo
    echo "## Instructions:"
    echo
    echo "Usage:"
    echo "> $SCRIPT_BASENAME [subcommand]"
    echo
    echo "Allowed subcommands:"
    echo "        --help"
    echo
    echo "        --start"
    echo "        --start-pyspark"
    echo "======================================================================================"
    echo
}

##################
### Configure
##################

Configure() {
    if [ -f "/home/danny/.envrc" ]; then
        source /home/danny/.envrc
    fi

    TTYD_ENABLED=${TTYD_ENABLED:-false}
    JUPYTER_ENABLED=${JYPYTER_ENABLED:-false}

    TTYD_PORT=${TTYD_PORT:-"44040"}

    SPARK_NO_DAEMONIZE=${SPARK_NO_DAEMONIZE:-true}

    SPARK_MASTER_INSTANCE_ENABLED=${SPARK_MASTER_INSTANCE_ENABLED:-false}
    SPARK_WORKER_INSTANCE_ENABLED=${SPARK_WORKER_INSTANCE_ENABLED:-false}
    SPARK_DRIVER_INSTANCE_ENABLED=${SPARK_DRIVER_INSTANCE_ENABLED:-false}

    SPARK_MASTER_HOST=${SPARK_MASTER_HOST:-"0.0.0.0"}
    SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-"7077"}
    SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-"57077"}

    SPARK_WORKER_HOST=${SPARK_WORKER_HOST:-"0.0.0.0"}
    SPARK_WORKER_PORT=${SPARK_WORKER_PORT:-"8077"}
    SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-"58077"}
    SPARK_WORKER_MASTER_URL=${SPARK_WORKER_MASTER_URL:-"spark://127.0.0.1:7077"}

    SPARK_DRIVER_MASTER_URL=${SPARK_DRIVER_MASTER_URL:-"spark://127.0.0.1:7077"}
}

#####################
### StartApplication
#####################

StartApplication() {
    _StartService_Foreground_spark $@
}

_StartService_Background_ttyd() {
    /usr/bin/nohup /usr/bin/ttyd --port $TTYD_PORT bash > /proc/1/fd/1 2>&1 &
}

_StartService_Background_jupyter() {
    /usr/bin/nohup /bin/bash -c ". ~/.bashrc; conda activate base; jupyter lab; conda deactivate;" > /proc/1/fd/1 2>&1 &
}

_StartService_Foreground_spark() {  
    env > /home/danny/.envrc
    chmod 400 /home/danny/.envrc

    if [ "$SPARK_MASTER_INSTANCE_ENABLED" = true ]; then
        _StartService_Foreground_spark_master $@
    elif [ "$SPARK_WORKER_INSTANCE_ENABLED" = true ]; then
        _StartService_Foreground_spark_worker $@
    elif [ "$SPARK_DRIVER_INSTANCE_ENABLED" = true ]; then
        _StartService_Background_ttyd $@
        _StartService_Background_jupyter $@

        _StartService_Foreground_sleep_for_very_long $@
    else
        echo "[_StartService_Foreground_spark] ERROR: Not a single spark instance has been enabled. Will sleep for very long ..." 

        _StartService_Foreground_sleep_for_very_long $@
    fi
}

_StartService_Foreground_spark_master() {
    cd /home/danny/.danny/opt/spark/spark/current;
    /usr/bin/nohup /bin/bash -c ". ~/.bashrc; conda activate danny; sbin/start-master.sh; conda deactivate;" > /proc/1/fd/1 2>&1
}

_StartService_Foreground_spark_worker() {
    cd /home/danny/.danny/opt/spark/spark/current;
    /usr/bin/nohup /bin/bash -c ". ~/.bashrc; conda activate danny; sbin/start-worker.sh $SPARK_WORKER_MASTER_URL; conda deactivate;" > /proc/1/fd/1 2>&1
}

_StartService_Foreground_sleep_for_very_long() {
    sleep 1000000
}

StartApplication_pyspark() {
    cd /home/danny/.danny/opt/spark/spark/current;
    bin/pyspark --supervise \
        --master $SPARK_DRIVER_MASTER_URL \
        --packages org.apache.spark:spark-sql-kafka-0-10_2.13:3.3.1 \
        --conf "spark.driver.extraJavaOptions=-Dhttp.proxyHost=10.150.32.10 -Dhttp.proxyPort=3128 -Dhttps.proxyHost=10.150.32.10 -Dhttps.proxyPort=3128"
}

##################
### Main
##################

main() {
    if [ -z "$1" ] || [ "$1" == "--help" ]; then
        PrintHelp
        exit 0
    fi

    Configure

    subcommand=$1
    shift

    case $subcommand in

        --start)
            StartApplication $@
            ;;
        
        --start-pyspark)
            StartApplication_pyspark $@
            ;;

    esac
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    main $@
fi
