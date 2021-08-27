#!/bin/sh

# Created by Andrey Chukavin, 2021

MERGED_BRANCHES=$(git branch --merged | grep -v master | grep -v '^*')
if [[ "$MERGED_BRANCHES" = "" ]]
then
	echo "No branches to delete"
else
	git branch -d $MERGED_BRANCHES
fi
