#!/bin/bash
set -e

currentFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#https://gist.github.com/authmane512/a5ca42da6f506350392e6a3ee2c97a90#file-build-sh

. ../project.settings
. ../Compilers/compilers.settings

javaFolder="src/org/libsdl/app"
javaFolder3="src/org/Bibliotekum_Ultimatum/app"
javaFolder2=src/"$package_1"/"$package_2"/"$appName"
rjavaFolder=src/"$package_1"/"$package_2"/"$appName"

resFolder="res"
assetFolder="assets"
androidManifest="AndroidManifest.xml"

echo "Cleaning..."
mkdir -p $assetFolder

rm -rf obj/*
rm -rf $rjavaFolder/R.java
rm -rf lib
rm -rf ${assetFolder}/${appName}_resources

if [ "$1" == "clean" ]; then
	rm -rf libs
	mkdir libs

	echo "Compiling SDL..."
	$NDK NDK_APPLICATION_MK=jni/Application.mk APP_BUILD_SCRIPT=jni/SDL2/Android.mk

fi

ln -s libs lib
cp -a ../main/${appName}_resources $assetFolder/${appName}_resources

echo "Compiling C/C++ code..."

COMPILER="clang++ -static-libstdc++"
FLAGS="-fPIC -lGLESv3 -shared -lSDL2 -DBU_APP_NAME=\"${appName}\" -DBU_MOBILE -DBU_ANDROID -DBU_SDL -std=c++17"

if [ "$1" == "final" ]; then
	FLAGS="$FLAGS -O2"
fi

echo "   Used flags: $FLAGS"

LIB=$currentFolder/lib

$NDK_TOOLCHAINS/aarch64-linux-android21-$COMPILER -L/$LIB/arm64-v8a/ $FLAGS ../main/main.cpp -o lib/arm64-v8a/libmain.so
$NDK_TOOLCHAINS/armv7a-linux-androideabi21-$COMPILER -L/$LIB/armeabi-v7a/ $FLAGS ../main/main.cpp -o lib/armeabi-v7a/libmain.so
$NDK_TOOLCHAINS/i686-linux-android21-$COMPILER -L/$LIB/x86/ $FLAGS ../main/main.cpp -o lib/x86/libmain.so
$NDK_TOOLCHAINS/x86_64-linux-android21-$COMPILER -L/$LIB/x86_64/ $FLAGS ../main/main.cpp -o lib/x86_64/libmain.so

echo "Generating R.java file..."
$AAPT package -f -m -J src -M $androidManifest -S $resFolder -I $PLATFORM

echo "Compiling..."

$JAVAC -d obj -classpath src -bootclasspath $PLATFORM -source 1.7 -target 1.7 -cp jars/gvr.jar $javaFolder/* $javaFolder2/* $javaFolder3/*
$JAVAC -d obj -classpath src -bootclasspath $PLATFORM -source 1.7 -target 1.7 $rjavaFolder/R.java

echo "Translating to Dalvik bytecode..."
$DX --dex --output=classes.dex obj

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



mkdir -p ../Compiled/Android

cp -a bin/. ../Compiled/Android



