#!/usr/bin/env bash

function usage {
	echo "Usage: $0 start|stop rails_env pidfile logfile"
	exit 1
}

# Starts Sidekiq.
# Assumes loading the user's bashrc is sufficient to get things going.
function start {
	set -x
	. ~/.bashrc

	cd $2 && exec bundle exec sidekiq -e $1 -P $3 >> $4 2>&1
}

# Sends TERM to the PID in the specified pidfile.
function stop {
	kill -TERM `cat $1`
}

# Seriously, you'd think this would be a built-in.
# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in#comment3818043_246128
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
APP_DIR=$SCRIPT_DIR/..

action=$1
env=$2
pidfile=$3
logfile=$4

if [ ! $action -a $env -a $pidfile -a $logfile ]; then
	usage
fi

case $action in
	start)
		start $env $APP_DIR $pidfile $logfile
		;;
	stop)
		stop $pidfile
		;;
	*)
		usage
		;;
esac
