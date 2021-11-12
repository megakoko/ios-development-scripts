#!/bin/sh
DEVICES=$(xcrun simctl list devices booted | grep Booted --color=none | egrep -o '\([-0-9A-Z]+\)' | sed 's/[()]//g')
for DEVICE in $DEVICES
do
	xcrun simctl status_bar "$DEVICE"  override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4
done

