#!/bin/bash

if [ $# -eq 0 ] ; then
    	echo "No arguments"
	exit 1
fi

currentFolder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
appName=$1
where=$2
project_creation_folder=$3


package_1=com
package_2=mantegral

mkdir -p $where
cd $where

mkdir Android_$1
cd Android_$1

mkdir -p src/$package_1/$package_2/$appName
mkdir -p src/org/libsdl/app
mkdir -p src/org/Bibliotekum_Ultimatum/app
mkdir -p obj
mkdir -p bin
mkdir -p res/layout
mkdir -p res/values
mkdir -p res/drawable

mkdir -p jni/SDL2

mkdir -p libs
mkdir -p lib


ln -s $project_creation_folder/../Link/Keystore .

cp -a $project_creation_folder/android/libs/. libs/
cp -a $project_creation_folder/android/java/. src/org/libsdl/app/
cp -a $project_creation_folder/android/BU/. src/org/Bibliotekum_Ultimatum/app/
cp -a $project_creation_folder/android/SDL2/. jni/SDL2/
cp -a $project_creation_folder/icon/. res/drawable/
cp -a $project_creation_folder/android/build/. .


activityName="$appName"_Activity
resName="$appName"_resources

echo "
package $package_1.$package_2.$appName;    
import org.libsdl.app.SDLActivity; 
import org.Bibliotekum_Ultimatum.app.BU_Functions; 

import android.content.res.AssetManager;
import android.os.Environment;
import android.util.Log;

import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.InputStream;

public class $activityName extends SDLActivity {

    String dataDir;
    BU_Functions funkce;


    @Override
    protected void onStart() {
        if (Environment.getExternalStorageState() == null)
            dataDir = Environment.getDataDirectory().getAbsolutePath();
        else
            dataDir = Environment.getExternalStorageDirectory().getAbsolutePath();
        copyFileOrDir(\"$resName\");
	
        funkce = new BU_Functions();
	funkce.setStoragePath(dataDir + \"/\");

        super.onStart();
    }



    /* https://gist.github.com/tylerchesley/6198074 */

    public void copyFileOrDir(String path) {
        AssetManager assetManager = this.getAssets();
        String assets[] = null;
        try {
            assets = assetManager.list(path);
            if (assets.length == 0) {
                copyFile(path);
            } else {
                String fullPath = dataDir + \"/\" + path;
                File dir = new File(fullPath);
                if (!dir.exists())
                    dir.mkdir();
                for (int i = 0; i < assets.length; ++i) {
                    copyFileOrDir(path + \"/\" + assets[i]);
                }
            }
        } catch (IOException ex) {
            Log.e(\"tag\", \"I/O Exception\", ex);
        }
    }

    private void copyFile(String filename) {
        AssetManager assetManager = this.getAssets();

        InputStream in = null;
        OutputStream out = null;
        try {
            in = assetManager.open(filename);
            String newFileName = dataDir + \"/\" + filename;

            File soubor = new File(newFileName);
            if(soubor.exists())
                return;

            out = new FileOutputStream(newFileName);

            byte[] buffer = new byte[1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            in = null;
            out.flush();
            out.close();
            out = null;
        } catch (Exception e) {
            Log.e(\"tag\", e.getMessage());
        }

    }

 }
" >> src/$package_1/$package_2/$appName/$activityName.java

echo "APP_ABI := armeabi-v7a arm64-v8a x86 x86_64
APP_PLATFORM=android-21
" >> jni/Application.mk

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<resources>
    <color name=\"colorPrimary\">#3F51B5</color>
    <color name=\"colorPrimaryDark\">#303F9F</color>
    <color name=\"colorAccent\">#FF4081</color>
</resources>
" >> res/values/colors.xml

echo "<resources>
    <style name=\"AppTheme\" parent=\"android:Theme.Holo.Light.DarkActionBar\">

    </style>

</resources>
" >> res/values/styles.xml


echo "<resources>
    <string name=\"app_name\">$appName</string>
</resources>
" >> res/values/strings.xml


echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>

<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"
	package=\"$package_1.$package_2.$appName\"
	android:versionCode=\"1\"
	android:versionName=\"1.0\"
	android:installLocation=\"auto\">
	<uses-sdk android:minSdkVersion=\"21\" />

	<!-- Tell the system this app requires OpenGL ES 3.1. -->
	<uses-feature android:glEsVersion=\"0x00030001\" android:required=\"true\" />


	<!-- Touchscreen support -->
	<uses-feature
	android:name=\"android.hardware.touchscreen\"
	android:required=\"false\" />

	<!-- Game controller support -->
	<uses-feature
	android:name=\"android.hardware.gamepad\"
	android:required=\"false\" />

	<!-- External mouse input events -->
	<uses-feature
	android:name=\"android.hardware.type.pc\"
	android:required=\"false\" />

	<!-- Allow writing to external storage -->
	<uses-permission android:name=\"android.permission.WRITE_EXTERNAL_STORAGE\" />
	<uses-permission android:name=\"android.permission.READ_EXTERNAL_STORAGE\" />
	<!-- Allow access to the vibrator -->
	<uses-permission android:name=\"android.permission.VIBRATE\" />

	<application android:label=\"@string/app_name\"
	android:icon=\"@drawable/icon\"
	android:allowBackup=\"true\"
	android:theme=\"@android:style/Theme.NoTitleBar.Fullscreen\"
	android:hardwareAccelerated=\"true\" >


	<activity android:name=\"$activityName\"
	    android:label=\"@string/app_name\"
	    android:alwaysRetainTaskState=\"true\"
	    android:launchMode=\"singleInstance\"
	    android:configChanges=\"orientation|uiMode|screenLayout|screenSize|smallestScreenSize|keyboard|keyboardHidden|navigation\"
            android:screenOrientation=\"landscape\"
	    >
	    <intent-filter>
		<action android:name=\"android.intent.action.MAIN\" />
		<category android:name=\"android.intent.category.LAUNCHER\" />
	    </intent-filter>
	</activity>
	</application>

</manifest>

" >> AndroidManifest.xml


