#!/usr/bin/env bash


case "$1" in
    scheduler)
	airflow initdb
	echo "Starting scheduler run at "$(date)
	airflow "$@"
        ;;
    worker)
        echo "Starting worker"
        airflow "$@"
        ;;
    webserver)
        echo "Starting webserver"
	airflow create_user -r Admin -u airflow -f firstname -l lastname -p password -e example@example.com
        airflow "$@"
        ;;
    initdb)
        airflow "$@"
        ;;
    dev)
        # For dev purposes run in this mode to run no services and do things in 
        # a bash shell without killing the container's entrypoint.
        sleep infinity
        ;;
    *)
        "$@"
        ;;
esac

