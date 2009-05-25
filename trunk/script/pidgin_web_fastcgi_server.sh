#!/bin/bash
#
# pidgin_web_fastcgi_server.sh : pidgin_web fastcgi daemon start/stop script
#
# version : 0.04
#
# chkconfig: 2345 84 16
# description: pidgin_web fastcgi daemon start/stop script
# processname: fcgi
# pidfile: /home/gugu/workspace/webpidgin/Pidgin-Web/script/pidgin.pid
#
# 2007-04-28 by A clever guy

# Load in the best success and failure functions we can find
if [ -f /etc/rc.d/init.d/functions ]; then
    . /etc/rc.d/init.d/functions
else
    # Else locally define the functions
    success() {
        echo -e "\n\t\t\t[ OK ]";
        return 0;
    }

    failure() {
        local error_code=$?
        echo -e "\n\t\t\t[ Failure ]";
        return $error_code
    }
fi

RETVAL=0
prog="pidgin_web"
SU=su
EXECUSER=gugu
EXECDIR=/home/gugu/workspace/webpidgin/Pidgin-Web
PID=/home/gugu/workspace/webpidgin/Pidgin-Web/script/pidgin.pid
LOGFILE=/home/gugu/workspace/webpidgin/Pidgin-Web/script/log.txt
PROCS=1
SOCKET=/tmp/pidgin.socket


# your application environment variables


if [ -f "/etc/sysconfig/"$prog ]; then
		. "/etc/sysconfig/"$prog
fi

start() {
    if [ -f $PID ]; then
        echo "already running..."
        return 1
    fi
# Start daemons.
    echo -n $"Starting Pidgin::Web: "
    echo -n "["`date +"%Y-%m-%d %H:%M:%S"`"] " >> ${LOGFILE}
			rm ${LOGFILE};
			cd ${EXECDIR}
			cd ../libpurple/example
			./start_backend
			cd ${EXECDIR}
			sleep 5
#			echo script/pidgin_web_fastcgi.pl -n ${PROCS} -l ${SOCKET} -p ${PID}  -e
			cd server
			    nohup ./simple.pl - &
			cd ${EXECDIR}
			nohup script/pidgin_web_fastcgi.pl -n ${PROCS} -l ${SOCKET} -p ${PID} -e &
    RETVAL=$?
    [ $RETVAL -eq 0 ] && success || failure $"$prog start"
    echo
    return $RETVAL
}
stop() {
        # Stop daemons.
    echo -n $"Shutting down Pidgin::Web: "
		echo -n "["`date +"%Y-%m-%d %H:%M:%S"`"] " >> ${LOGFILE}
    /bin/kill `cat $PID 2>/dev/null ` >/dev/null 2>&1 && (success; echo "Stoped" >> ${LOGFILE} ) || (failure $"$prog stop";echo "Stop failed" >> ${LOGFILE} )
    killall simple.pl
    killall start_backend
    killall lt-nullclient
    /bin/rm $PID >/dev/null 2>&1
    RETVAL=$?
    echo
    return $RETVAL
}
status() {
# show status
    if [ -f $PID ]; then
        echo "${prog} (pid `/bin/cat $PID`) is running..."
    else
        echo "${prog} is stopped"
    fi
    return $?
}
restart() {
    stop
#    sleep 5
    start
}
# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
	sleep 5
        start
        ;;
    status)
        status
        ;;
    *)
        echo $"Usage: $0 {start|stop|restart|status}"
        exit 1
esac
exit $?
