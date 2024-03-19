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

datasets_dir="$HOME/tdt_datasets"

# read project config to get datasets folder
project_config_file=$(find $PWD -regex ".*\(_project_config\.yaml\)"); echo "$project_config_file"
if [ -e "$project_config_file" ]
then
    directory_config=$(grep -A0 'datasets_folder:' $project_config_file | tail -n1)
    echo "directory_config: $directory_config"
    # if the directory_config is not a commented out line
    if [ -n "${directory_config%%#*}" ]
    then
        conf_dir=${directory_config//*datasets_folder:/}
        echo "conf_dir: $conf_dir"
        # if value not empty
        if [ -n "$conf_dir" ]
        then
            # strip spaces
            datasets_dir=${conf_dir//[[:blank:]]/}
        fi
    fi
fi

echo "datasets_dir: $datasets_dir"
mkdir -p "$datasets_dir"

docker run -v "$PWD:/work" -v "$datasets_dir:/tdt_datasets" -w /work --rm -ti -p 3000:3000 -p 8000:8000 -e "GITHUB_AUTH_TOKEN=$GH_TOKEN" --env "GITHUB_USER=$GITHUB_USER" --env "GITHUB_EMAIL=$GITHUB_EMAIL" ghcr.io/brain-bican/$IMAGE $TIMECMD "$@"