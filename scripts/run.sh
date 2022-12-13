#!/bin/sh
# Wrapper script for docker.
#
# This is used primarily for wrapping the GNU Make workflow.
# Instead of typing "make TARGET", type "./run.sh make TARGET".
# This will run the make workflow within a docker container.
#
# The assumption is that you are working in the project root folder;
# we therefore map the whole repo (../..) to a docker volume.
#
# See README-editors.md for more details.

IMAGE=${IMAGE:-tdt}
TDT_DEBUG=${TDT_DEBUG:-no}

TIMECMD=
if [ x$TDT_DEBUG = xyes ]; then
    # If you wish to change the format string, take care of using
    # non-breaking spaces (U+00A0) instead of normal spaces, to
    # prevent the shell from tokenizing the format string.
    TIMECMD="/usr/bin/time -f ### DEBUG STATS ###\nElapsed time: %E\nPeak memory: %M kb"
fi

docker run --user "$(id -u):$(id -g)" -v $PWD:/work -w /work --rm -ti -p 5004:5555 brain-bican/$IMAGE $TIMECMD "$@"