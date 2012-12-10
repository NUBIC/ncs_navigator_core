#!/usr/bin/env bash

function usage {
	echo "Usage: $0 start|stop|restart rails_env pidfile logfile concurrency_level"
	exit 1
}

# Starts Sidekiq.
# Assumes loading the user's bashrc is sufficient to get things going.
function start {
	. ~/.bashrc

	cd $2 && exec bundle exec sidekiq -e $1 -c $5 -P $3 >> $4 2>&1
}

# Sends TERM to the PID in the specified pidfile.
function stop {
	kill -TERM `cat $1`
}

# Waits for the PID in the specified pidfile to not exist.
# Assumes that the user running this script has permissions to send signal 0 to
# the process.
function wait_for_stop {
	pid=`cat $1`

	while kill -0 $pid; do
		sleep 1
	done
}

# Sends TERM, removes the pidfile, starts up Sidekiq again.
function restart {
	stop $3
	wait_for_stop $3
	start $1 $2 $3 $4 $5
}

# Seriously, you'd think this would be a built-in.
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in#comment3818043_246128
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
APP_DIR=$SCRIPT_DIR/..

action=$1
env=$2
pidfile=$3
logfile=$4
concurrency=$5

if [ ! $concurrency ]; then
	concurrency=10
fi

if [ ! $action -a $env -a $pidfile -a $logfile ]; then
	usage
fi

case $action in
	start)
		start $env $APP_DIR $pidfile $logfile $concurrency
		;;
	stop)
		stop $pidfile
		;;
	restart)
		restart $env $APP_DIR $pidfile $logfile $concurrency
		;;
	*)
		usage
		;;
esac
