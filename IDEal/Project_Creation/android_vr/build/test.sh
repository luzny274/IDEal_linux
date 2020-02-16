#!/bin/bash

. ../project.settings
. ../Compilers/compilers.settings

echo "Launching..."
$ADB install -r bin/$appName.apk
$ADB shell am start -n $package_1.$package_2.$appName/."$appName"_Activity
