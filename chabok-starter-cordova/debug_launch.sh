#!/usr/bin/env bash

echo "\n ␡ ␡ Start removing com.chabokpush.cordova "

cordova plugin remove com.chabokpush.cordova

echo "\n✅✅ Removed com.chabokpush.cordova plugin\n"

echo "\n➕➕ Adding ChabokPush plugin\n"

cordova plugin add ../ChabokPush

echo "\n✅✅ Added ChabokPush plugin\n"

echo "\n👟👟\n\nRunning Application.\n"
cordova emulate ios --target="iPhone-6s, 12.2"
