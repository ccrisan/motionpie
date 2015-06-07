#!/bin/bash

NGINX_PID=/var/run/nginx.pid
NGINX_CONF=/data/etc/nginx.conf
RASPIMJPEG_CONF=/data/etc/raspimjpeg.conf
MOTIONEYE_CONF=/data/etc/motioneye.conf
STREAMEYE_PORT=8080
STREAMEYE_LOG=/var/log/streameye.log

function start_nginx() {
    mkdir -p /var/tmp/nginx
    if ! [ -r $NGINX_CONF ]; then
        return
    fi

    nginx -c $NGINX_CONF
}

function stop_nginx() {
    if [ -r $NGINX_PID ]; then
        pid=$(cat $NGINX_PID)
        kill -TERM "$pid" &>/dev/null
        count=0
        while kill -0 "$pid" &>/dev/null && [ $count -lt 5 ]; do
            sleep 1
            count=$(($count + 1))
        done
        kill -KILL "$pid" &>/dev/null
    fi
}

function start_raspimjpeg() {
    raspimjpeg_opts=""
    while read line; do
        if echo "$line" | grep false &>/dev/null; then
            continue
        fi
        if echo "$line" | grep true &>/dev/null; then
            line=$(echo $line | cut -d ' ' -f 1)
        fi
        raspimjpeg_opts="$raspimjpeg_opts --$line"
    done < $RASPIMJPEG_CONF
    
    streameye_opts="-l -p $STREAMEYE_PORT"
    if [ -r $MOTIONEYE_CONF ] && grep 'log-level debug' $MOTIONEYE_CONF >/dev/null; then
        raspimjpeg_opts="$raspimjpeg_opts -d"
        streameye_opts="$streameye_opts -d"
    fi

    raspimjpeg.py $raspimjpeg_opts 2>$STREAMEYE_LOG | streameye $streameye_opts &>$STREAMEYE_LOG &
}

function stop_raspimjpeg() {
    pid=$(ps | grep raspimjpeg.py | grep -v grep | tr -s ' ' | sed -e 's/^\s//' | cut -d ' ' -f 1)
    if [ -z "$pid" ]; then
        return
    fi
    
    kill -HUP "$pid" &>/dev/null
    count=0
    while kill -0 "$pid" &>/dev/null && [ $count -lt 5 ]; do
        sleep 1
        count=$(($count + 1))
    done
    kill -KILL "$pid" &>/dev/null
}

case "$1" in
    start)
        start_nginx
        start_raspimjpeg
        ;;

    stop)
        stop_nginx
        stop_raspimjpeg
        ;;

    restart|reload)
        stop_nginx
        stop_raspimjpeg
        start_nginx
        start_raspimjpeg
        ;;

    *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac

