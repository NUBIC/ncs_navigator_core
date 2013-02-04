set -x
MYDIR="$( cd "$( dirname "$0" )" && pwd )"
cd $MYDIR/..
find . -iname *.rb | xargs egrep -nHR '\.first|\.last' | cut -d ':' -f1-2 > $MYDIR/fl_audit_new.taskpaper
find . -iname *.rb | xargs egrep -nHR '(Time.now|Date.today)' | cut -d ':' -f1-2 > $MYDIR/today_now_audit_new.taskpaper
