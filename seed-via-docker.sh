#!/bin/sh

set -e

TDT_IMAGE=${TDT_IMAGE:-taxonomy-development-tools}
TDT_TAG=${TDT_TAG:-latest}
TDT_GITNAME=${TDT_GITNAME:-$(git config --get user.name)}
TDT_GITEMAIL=${TDT_GITEMAIL:-$(git config --get user.email)}

docker run -v $PWD:/work -w /work --rm ghcr.io/brain-bican/$TDT_IMAGE:$TDT_TAG /tools/tdt.py seed --gitname "$TDT_GITNAME" --gitemail "$TDT_GITEMAIL" "$@"
