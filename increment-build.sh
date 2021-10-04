#!/bin/sh

# Created by Andrey Chukavin, 2021

echo "Current branch: \"$(git branch --show-current)\""

STAGED_CHANGES=$(git diff --cached --numstat | wc -l | tr -d ' ')

if [ "$STAGED_CHANGES" != "0" ]; then
	echo Changes staged, skipping
    exit
fi

OLD_MARKETING_VERSION=$(xcrun agvtool mvers -terse1)
read -p "Enter new marketing version [$OLD_MARKETING_VERSION]: " NEW_MARKETING_VERSION
NEW_MARKETING_VERSION="${NEW_MARKETING_VERSION:-$OLD_MARKETING_VERSION}"

OLD_BUILD_NUMBER=$(xcrun agvtool vers -terse)
DEFAULT_NEW_BUILD_NUMBER=$(echo "$OLD_BUILD_NUMBER + 1" | bc)
read -p "Enter new build number [$DEFAULT_NEW_BUILD_NUMBER]: " NEW_BUILD_NUMBER
NEW_BUILD_NUMBER="${NEW_BUILD_NUMBER:-$DEFAULT_NEW_BUILD_NUMBER}"


if [ $OLD_MARKETING_VERSION = $NEW_MARKETING_VERSION -a $OLD_BUILD_NUMBER = $NEW_BUILD_NUMBER ];  then 
	echo "Nothing changed, skipping"
	exit
fi


OLD_FULL_VERSION="$OLD_MARKETING_VERSION ($OLD_BUILD_NUMBER)"

NEW_FULL_VERSION="$NEW_MARKETING_VERSION ($NEW_BUILD_NUMBER)"
NEW_FULL_VERSION_TAG="${NEW_MARKETING_VERSION}_($NEW_BUILD_NUMBER)"

echo ""

echo "Old version: $OLD_FULL_VERSION"
echo "New version: $NEW_FULL_VERSION"
echo ""

echo "Are you sure you want to change?"
echo ""

echo "Press [Ctrl+C] to abort. [Enter] to continue."
read DECISION

echo "OK"

xcrun agvtool new-marketing-version $NEW_MARKETING_VERSION
xcrun agvtool new-version -all $NEW_BUILD_NUMBER 

MODIFIED_VERSION_FILES=$(git status --short | egrep "^ M.+(plist|pbxproj)" --color=never | sed 's/ M //g')

git add '*.xcodeproj/*.pbxproj' '*/Info.plist'
git commit -m "Version $NEW_FULL_VERSION"
git tag -a "v$NEW_FULL_VERSION_TAG" -m "Version $NEW_FULL_VERSION"

echo "Don't forget to push!"
