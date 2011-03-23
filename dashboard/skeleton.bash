## skeleton.bash
# 
# Creates an application skeleton from the provided
# Titanium application.
#
# Usage:
# skeleton "My App"
#
set -e

APP=$1
if [ ! -d "$APP" ]; then
    echo "ERROR: could not find app directory: \"$APP\"" >&2
    exit 1
fi

# titanium could be local or system install
# linux
if [ -d ~/.titanium ]; then
    TITANIUM=~/.titanium
elif [ -d /opt/titanium ]; then
    TITANIUM=/opt/titanium
# osx (appdata always in home dir, sdk may be in /Library)
elif [ -d /Library/Application\ Support/Titanium ]; then
    TITANIUM=/Library/Application\ Support/Titanium
elif [ -d ~/Library/Application\ Support/Titanium ]; then
    TITANIUM=~/Library/Application\ Support/Titanium
else
    echo "ERROR: could not find titanium." >&2
    exit 1
fi

# assume OS is first directory in sdk
OS=$(ls -d1 "$TITANIUM"/sdk/*/ | sed 's/ /\\ /g' | xargs basename)

# extract runtime version from manifest
RUNTIME=$(grep -m 1 runtime "$APP"/manifest | sed 's/runtime:\(.*\)/\1/')

if [ ! -d "$TITANIUM/sdk/$OS/$RUNTIME" ]; then
    echo "ERROR: could not find \"$TITANIUM/sdk/$OS/$RUNTIME\"." >&2
    exit 1
fi

# create a place for the skeleton
DIR=dashboard-"$RUNTIME-$OS"
rm -rf "$DIR"
mkdir "$DIR"

# run the tibuild.py packager
python "$TITANIUM/sdk/$OS/$RUNTIME"/tibuild.py -s "$TITANIUM" -a "$TITANIUM/sdk/$OS/$RUNTIME" -v -n -d "$DIR" -t bundle "$APP"

# strip out contents of resources dir
if [ $OS = "osx" ]; then
    APPDIR="$DIR"/$(basename "$APP").app
    RESDIR="$APPDIR"/Contents/Resources
    # don't remove English.lproj or others
    ls -d "$RESDIR"/* | grep -v .lproj | sed 's/ /\\ /g' | xargs rm -rf
else
    APPDIR="$DIR/$APP"
    RESDIR="$APPDIR"/Resources
    rm -rf "$RESDIR"/*
fi

# zip up skeleton and clean up
ZIP="$DIR".zip
rm -f "$ZIP"
zip -r "$ZIP" "$APPDIR"
rm -rf $DIR

echo Application skeleton archived in \"$ZIP\".
