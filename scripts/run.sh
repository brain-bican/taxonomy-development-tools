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

IMAGE=${IMAGE:-taxonomy-development-tools}
TDT_DEBUG=${TDT_DEBUG:-no}

TIMECMD=
if [ x$TDT_DEBUG = xyes ]; then
    # If you wish to change the format string, take care of using
    # non-breaking spaces (U+00A0) instead of normal spaces, to
    # prevent the shell from tokenizing the format string.
    TIMECMD="/usr/bin/time -f ### DEBUG STATS ###\nElapsed time: %E\nPeak memory: %M kb"
fi

GITHUB_USER=$(git config user.name)
GITHUB_EMAIL=$(git config user.email)

mkdir -p "$HOME/tdt_datasets"

docker run -v "$PWD:/work" -v "$HOME/tdt_datasets:/tdt_datasets" -w /work --rm -ti -p 3000:3000 -p 8000:8000 -p 3001:3001 -e "GITHUB_AUTH_TOKEN=$GH_TOKEN" --env "GITHUB_USER=$GITHUB_USER" --env "GITHUB_EMAIL=$GITHUB_EMAIL" ghcr.io/brain-bican/$IMAGE $TIMECMD "$@"