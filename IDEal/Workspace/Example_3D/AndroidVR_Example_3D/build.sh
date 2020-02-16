#!/bin/bash
set -e

currentFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#https://gist.github.com/authmane512/a5ca42da6f506350392e6a3ee2c97a90#file-build-sh

. ../project.settings
. ../Compilers/compilers.settings

javaFolder3="src/org/Bibliotekum_Ultimatum/app"
javaFolder2=src/"$package_1"/"$package_2"/"$appName"
rjavaFolder=src/"$package_1"/"$package_2"/"$appName"

rjavaFolder2=src/com/google/vr/cardboard/

resFolder="res"
assetFolder="assets"
androidManifest="AndroidManifest.xml"

echo "Cleaning..."
mkdir -p $assetFolder

rm -rf obj/*
rm -rf $rjavaFolder/R.java
rm -rf lib
rm -rf ${assetFolder}/${appName}_resources

ln -s libs lib
cp -a ../main/${appName}_resources $assetFolder/${appName}_resources

#cp -a classes/protobuf.meta obj/

echo "Compiling C/C++ code..."

COMPILER="clang++ -static-libstdc++"
FLAGS="-fPIC -shared -lGLESv3 -DBU_APP_NAME=\"${appName}\" -DBU_MOBILE -DBU_ANDROID -DBU_VR -std=c++17"

if [ "$1" == "final" ]; then
	FLAGS="$FLAGS -O2"
fi
echo "   Used flags: $FLAGS"

LIB=$currentFolder/lib

$NDK_TOOLCHAINS/i686-linux-android21-$COMPILER -L/$LIB/x86/ $FLAGS ../main/main.cpp -o lib/x86/libmain.so
$NDK_TOOLCHAINS/aarch64-linux-android21-$COMPILER -L/$LIB/arm64-v8a/ $FLAGS ../main/main.cpp -o lib/arm64-v8a/libmain.so
$NDK_TOOLCHAINS/armv7a-linux-androideabi21-$COMPILER -L/$LIB/armeabi-v7a/ $FLAGS ../main/main.cpp -o lib/armeabi-v7a/libmain.so

echo "Generating R.java files..."
$AAPT package -f -m -J src -M $androidManifest -S $resFolder -I $PLATFORM

$AAPT package -f -m -J src -M gvr/AndroidManifest.xml -S $resFolder -I $PLATFORM

echo "Compiling..."

$JAVAC -d obj -classpath src -bootclasspath $PLATFORM -source 1.8 -target 1.8 -cp gvr/gvr.jar $javaFolder2/* $javaFolder3/*

$JAVAC -d obj -classpath src -bootclasspath $PLATFORM -source 1.8 -target 1.8 $rjavaFolder/R.java
$JAVAC -d obj -classpath src -bootclasspath $PLATFORM -source 1.8 -target 1.8 $rjavaFolder2/R.java

echo "Translating to Dalvik bytecode..."
$DX --dex --output=classes.dex obj gvr/gvr.jar
# jars/classes.jar

echo "Making APK..."
$AAPT package -f -m -F bin/$appName.apk -M $androidManifest -S $resFolder -I $PLATFORM -A $assetFolder

for d in lib/* ; do
	for f in $d/* ; do					
		$AAPT add -v bin/$appName.apk $f
	done
done

$AAPT add bin/$appName.apk classes.dex

echo "Aligning and signing APK..."

echo 123456 | $APKSIGNER sign --ks Keystore/key.jks bin/$appName.apk
$ZIPALIGN -f 4 bin/$appName.apk bin/$appName-release.apk



mkdir -p ../Compiled/AndroidVR

cp -a bin/. ../Compiled/AndroidVR




