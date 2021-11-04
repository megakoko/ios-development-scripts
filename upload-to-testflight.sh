#!/bin/sh

# Created by Andrey Chukavin, 2021

SCRIPT_NAME=$(basename $0)
SCRIPT_DIR=$(dirname $0)

usage() {
	echo "Usage:"
	echo "\t./$SCRIPT_NAME [--project PROJECT_NAME] --scheme SCHEME_NAME"
	echo "\tHere's an output from \"xcodebuild -list\":"
	xcodebuild -list
}

PROJECT_NAME="$(ls -d *.xcodeproj)"
SCHEME_NAME=""

while test $# -gt 0
do
    case "$1" in
    --project)
		echo $2
		echo $PROJECT_NAME
        PROJECT_NAME=$2
        shift
        ;;
    --scheme)
        SCHEME_NAME=$2
        shift
        ;;
    esac
    shift
done

if [ "$PROJECT_NAME" = "" ]
then
	echo "Project name must be specified"
	echo
	usage	
	exit 1
fi


if [ "$SCHEME_NAME" = "" ]
then
	echo "Scheme name must be specified"
	echo
	usage	
	exit 1
fi

echo "Building project: \"$PROJECT_NAME\", scheme \"$SCHEME_NAME\"."
echo "Current branch: \"$(git branch --show-current)\""

XCODE_PATH=/Users/megakoko/Library/Developer/Xcode
ARCHIVE_DIR_PATH=$XCODE_PATH/Archives/$(date +%Y-%m-%d)
ARCHIVE_FILE_PATH="$ARCHIVE_DIR_PATH/${SCHEME_NAME} $(date "+%d.%m.%Y,_%H.%M").xcarchive"

echo
echo "Cleaning the project"
xcodebuild -quiet -project $PROJECT_NAME -scheme "$SCHEME_NAME" -configuration Release clean

echo
echo "Building the project"
xcodebuild -quiet -project $PROJECT_NAME -scheme "$SCHEME_NAME" -configuration Release archive -archivePath "$ARCHIVE_FILE_PATH"

echo
echo "Exporting the project"
xcodebuild -exportArchive -archivePath "$ARCHIVE_FILE_PATH" -exportOptionsPlist $SCRIPT_DIR/ExportOptions.plist -exportPath $XCODE_PATH/MY_DERIVED_DATA
