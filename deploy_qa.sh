#!/usr/bin/env bash

SECHEME_NAME="TakoQA"
PRODUCT_NAME="TakoQA"
PROJECT_DIR=$(pwd)
BUILD_DIR="build"
INFOPLIST_FILE="Info.plist"
CONFIGURATION="Release"
EFFECTIVE_PLATFORM_NAME="-iphoneos"
OUTPUT_DIR=$PROJECT_DIR/$BUILD_DIR/$CONFIGURATION$EFFECTIVE_PLATFORM_NAME
ARCHIVE_PATH=$OUTPUT_DIR/$SECHEME_NAME.xcarchive
APP_APTH=$ARCHIVE_PATH/Products/Applications/$PRODUCT_NAME.app
INFO_PLIST=$APP_APTH/Info.plist
IPA_APTH=$OUTPUT_DIR/$SECHEME_NAME.ipa

xcodebuild clean
rm -f $IPA_APTH

xcodebuild -scheme $SECHEME_NAME -archivePath $ARCHIVE_PATH archive

# Auto-increment Build & Version Numbers
buildNumber=`cat build/nextBuildNumber`
echo "Current Build Number: $buildNumber"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFO_PLIST"
buildNumber=$(($buildNumber + 1))
echo $buildNumber > build/nextBuildNumber

xcrun -sdk iphoneos PackageApplication -v $APP_APTH -o $IPA_APTH

curl -F "uploadfile=@$IPA_APTH" -F "uploadkey=7gbebth9q97rd4wk" -F "sign=true" -F "lan=true" -F "sync=true" http://10.20.102.177:8888/upload