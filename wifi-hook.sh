#!/usr/bin/env bash

IFACE="$1"
ACTION="$2"

wg-down
if [ "$ACTION" = "up" ] && [ "$CONNECTION_ID" != "HJHOME" ]; then
	wg-up
fi

