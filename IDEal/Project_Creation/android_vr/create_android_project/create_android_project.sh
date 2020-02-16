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

mkdir AndroidVR_$1
cd AndroidVR_$1

mkdir -p src/$package_1/$package_2/$appName
mkdir -p src/org/Bibliotekum_Ultimatum/app
mkdir -p gvr
mkdir -p obj
mkdir -p bin
mkdir -p res
mkdir -p res/drawable
mkdir -p res/values


mkdir -p libs
mkdir -p lib


ln -s $project_creation_folder/../Link/Keystore .

cp -a $project_creation_folder/android_vr/libs/. libs/
cp -a $project_creation_folder/android_vr/BU/. src/org/Bibliotekum_Ultimatum/app/
cp -a $project_creation_folder/android_vr/gvr/. gvr/
cp -a $project_creation_folder/icon/. res/drawable/
cp -a $project_creation_folder/android_vr/res/. res/
cp -a $project_creation_folder/android_vr/build/. .


activityName="$appName"_Activity

echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<resources xmlns:xliff=\"urn:oasis:names:tc:xliff:document:1.2\">
    <string name=\"app_name\">$appName</string>

    <!-- Strings present in 'VR' activity -->
    <string name=\"title_activity_vr\"
            description=\"VR activity title. [CHAR_LIMIT=30]\">
            Hello Cardboard</string>
    <string name=\"no_permissions\"
            description=\"Text shown on Android Toast when permissions are not granted.
                         [CHAR_LIMIT=30]\">
            Permissions not granted</string>
    <string name=\"low_storage_error\"
            description=\"Text shown on Android Toast when detector dependencies can not be
                         downloaded due to low storage. [CHAR_LIMIT=70]\">
            Detector dependencies cannot be downloaded due to low device storage</string>

    <!-- Strings present in 'Settings' menu -->
    <string name=\"switch_viewer\"
            description=\"Short text shown on the settings menu to let the user switch viewer.
                         [CHAR_LIMIT=30]\">
            Switch Cardboard viewer</string>
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


echo "
package $package_1.$package_2.$appName;    
import android.opengl.GLES30;
import android.opengl.Matrix;
import android.os.Bundle;
import android.util.Log;
import com.google.vr.ndk.base.Properties;
import com.google.vr.ndk.base.Properties.PropertyType;
import com.google.vr.ndk.base.Value;
import com.google.vr.sdk.base.AndroidCompat;
import com.google.vr.sdk.base.Eye;
import com.google.vr.sdk.base.GvrActivity;
import com.google.vr.sdk.base.GvrView;
import com.google.vr.sdk.base.HeadTransform;
import com.google.vr.sdk.base.Viewport;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Random;
import javax.microedition.khronos.egl.EGLConfig;
import android.app.Activity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.InputDevice;

import org.Bibliotekum_Ultimatum.app.BU_Functions; 


public class $activityName extends GvrActivity implements GvrView.StereoRenderer {
  	private String appName = \"$appName\";
  	private String TAG = appName + \"_ActivityVR\";	
  	private Properties gvrProperties;
  	private Matrix projection;
  	private float[] front = new float[3];
  	private float[] up = new float[3];
  	private float[] right = new float[3];
  	private boolean cardboard_trigger = false;
  	private BU_Functions f = new BU_Functions();
	boolean controller_isPlugged = false;
	float controller_lX = 0.0f;
	float controller_lY = 0.0f;
	float controller_rX = 0.0f; 
	float controller_rY = 0.0f;
	float controller_triggerLeft = 0.0f; 
	float controller_triggerRight = 0.0f;
  	boolean controller_up = false;
	boolean controller_down = false;    
	boolean controller_left = false;  
	boolean controller_right = false;  
	boolean controller_start = false;           
	boolean controller_back = false;           
	boolean controller_leftShoulder = false;    
	boolean controller_rightShoulder = false;   
	boolean controller_A = false;  
	boolean controller_B = false;         
	boolean controller_X = false;         
	boolean controller_Y = false;


  	@Override
  	protected void onCreate(Bundle savedInstanceState) {
    		f.initBU(this.getAssets(), appName);
    		super.onCreate(savedInstanceState);
    		initializeGvrView();
   	}


  	public void initializeGvrView() {
    		setContentView(R.layout.common_ui);

    		GvrView gvrView = (GvrView) findViewById(R.id.gvr_view);
    		gvrView.setEGLConfigChooser(8, 8, 8, 8, 16, 8);
    		gvrView.setEGLContextClientVersion(3);

    		gvrView.setRenderer(this);
    		gvrView.setTransitionViewEnabled(true);

    		// Enable Cardboard-trigger feedback with Daydream headsets. This is a simple way of supporting
    		// Daydream controller input for basic interactions using the existing Cardboard trigger API.
    		gvrView.enableCardboardTriggerEmulation();

    		if (gvrView.setAsyncReprojectionEnabled(true)) {
      			// Async reprojection decouples the app framerate from the display framerate,
      			// allowing immersive interaction even at the throttled clockrates set by
      			// sustained performance mode.
      			AndroidCompat.setSustainedPerformanceMode(this, true);
    		}

    		setGvrView(gvrView);
    		gvrProperties = gvrView.getGvrApi().getCurrentProperties();
  	}


  @Override
  public void onPause() {
    super.onPause();
  }

  @Override
  public void onResume() {
    super.onResume();
  }

  @Override
  public void onRendererShutdown() {
  }

  @Override
  public void onSurfaceChanged(int width, int height) {
  }


  @Override
  public void onSurfaceCreated(EGLConfig config) {
    GLES30.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    f.nativeOnSurfaceCreated();
  }

  @Override
  public void onNewFrame(HeadTransform headTransform) {
    headTransform.getRightVector(right, 0);
    headTransform.getUpVector(up, 0);
    headTransform.getForwardVector(front, 0);

	controller_isPlugged = countControllers() > 0;

    f.nativeOnUpdate(				cardboard_trigger,
						controller_isPlugged,
						controller_lX, controller_lY,
						controller_rX, controller_rY,
						controller_triggerLeft, controller_triggerRight,
						controller_up,
						controller_down,          
						controller_left,          
						controller_right,         
						controller_start,         
						controller_back,         
						controller_leftShoulder,  
						controller_rightShoulder, 
						controller_A,
						controller_B,       
						controller_X,       
						controller_Y);

   	cardboard_trigger = false;
  }

	public Integer countControllers() {
	    ArrayList<Integer> gameControllerDeviceIds = new ArrayList<Integer>();
	    int[] deviceIds = InputDevice.getDeviceIds();
	    for (int deviceId : deviceIds) {
		InputDevice dev = InputDevice.getDevice(deviceId);
		int sources = dev.getSources();

		// Verify that the device has gamepad buttons, control sticks, or both.
		if (((sources & InputDevice.SOURCE_GAMEPAD) == InputDevice.SOURCE_GAMEPAD)
		        || ((sources & InputDevice.SOURCE_JOYSTICK)
		        == InputDevice.SOURCE_JOYSTICK)) {
		    // This device is a game controller. Store its device ID.
		    if (!gameControllerDeviceIds.contains(deviceId)) {
		        gameControllerDeviceIds.add(deviceId);
		    }
		}
	    }
	    return gameControllerDeviceIds.size();
	}


  @Override
  public void onDrawEye(Eye eye) {
    GLES30.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);

	/*if(eye.getType() == Eye.Type.LEFT)
    		GLES30.glClearColor(1.0f, 0.0f, 1.0f, 0.0f);

	if(eye.getType() == Eye.Type.RIGHT)
    		GLES30.glClearColor(0.0f, 1.0f, 0.0f, 0.0f);*/
    GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT | GLES30.GL_DEPTH_BUFFER_BIT);
    int typ = 0;
    if(eye.getType() == Eye.Type.LEFT)
	typ = -1;
    else if(eye.getType() == Eye.Type.RIGHT)
	typ = 1;

    
    f.nativeOnDrawEye(	front[0], front[1], front[2], 
			up[0], up[1], up[2], 
			right[0], right[1], right[2], 
			eye.getPerspective(f.nativeGetZNear(), f.nativeGetZFar()), typ);

  }

  @Override
  public void onFinishFrame(Viewport viewport) {}


  @Override
  public void onCardboardTrigger() {
	cardboard_trigger = true;
  }

    @Override
    public boolean onGenericMotionEvent(MotionEvent event){
	boolean handled = false;

	if(((event.getSource() & InputDevice.SOURCE_GAMEPAD)
	        == InputDevice.SOURCE_GAMEPAD) || ((event.getSource() & InputDevice.SOURCE_JOYSTICK)
	        == InputDevice.SOURCE_JOYSTICK))
	{
		controller_lX = event.getAxisValue(MotionEvent.AXIS_X);
		controller_lY = -event.getAxisValue(MotionEvent.AXIS_Y);
		controller_rX = event.getAxisValue(MotionEvent.AXIS_Z);
		controller_rY = event.getAxisValue(MotionEvent.AXIS_RZ);
		controller_triggerLeft =  event.getAxisValue(MotionEvent.AXIS_LTRIGGER);
		controller_triggerRight = event.getAxisValue(MotionEvent.AXIS_RTRIGGER);
		handled = true;
	}
	if(handled)
		return true;

	return super.onGenericMotionEvent(event);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
	boolean handled = false;

	if (((event.getSource() & InputDevice.SOURCE_GAMEPAD)
	        == InputDevice.SOURCE_GAMEPAD) || ((event.getSource() & InputDevice.SOURCE_DPAD) == InputDevice.SOURCE_DPAD)) {
	    if (event.getRepeatCount() == 0) {
	        switch (keyCode) {
	            case KeyEvent.KEYCODE_DPAD_LEFT:
			controller_left = true;
			handled = true;
			break;

	            case KeyEvent.KEYCODE_DPAD_RIGHT:
			controller_right = true;
			handled = true;
			break;

	            case KeyEvent.KEYCODE_DPAD_UP:
			controller_up = true;
			handled = true;
			break;

	            case KeyEvent.KEYCODE_DPAD_DOWN:
			controller_down = true;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_A:
			controller_A = true;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_B:
			controller_B = true;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_X:
			controller_X = true;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_Y:
			controller_Y = true;
			handled = true;
			break;



		    case KeyEvent.KEYCODE_BUTTON_START:
			controller_start = true;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BACK:
			controller_Y = true;
			handled = true;
			break;


		    case KeyEvent.KEYCODE_BUTTON_L1:
			controller_leftShoulder = true;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_R1:
			controller_rightShoulder = true;
			handled = true;
			break;
	        }
	    }
	    if (handled) {
	        return true;
	    }
	}

	return super.onKeyDown(keyCode, event);
    }


    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
	boolean handled = false;

	if ((event.getSource() & InputDevice.SOURCE_GAMEPAD)
	        == InputDevice.SOURCE_GAMEPAD) {
	    if (event.getRepeatCount() == 0) {
	        switch (keyCode) {
	            case KeyEvent.KEYCODE_DPAD_LEFT:
			controller_left = false;
			handled = true;
			break;

	            case KeyEvent.KEYCODE_DPAD_RIGHT:
			controller_right = false;
			handled = true;
			break;

	            case KeyEvent.KEYCODE_DPAD_UP:
			controller_up = false;
			handled = true;
			break;

	            case KeyEvent.KEYCODE_DPAD_DOWN:
			controller_down = false;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_A:
			controller_A = false;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_B:
			controller_B = false;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_X:
			controller_X = false;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_Y:
			controller_Y = false;
			handled = true;
			break;


		    case KeyEvent.KEYCODE_BUTTON_START:
			controller_start = false;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BACK:
			controller_Y = false;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_L1:
			controller_leftShoulder = false;
			handled = true;
			break;

		    case KeyEvent.KEYCODE_BUTTON_R1:
			controller_rightShoulder = false;
			handled = true;
			break;
	        }
	    }
	    if (handled) {
	        return true;
	    }
	}

	return super.onKeyUp(keyCode, event);
    }

}" >> src/$package_1/$package_2/$appName/$activityName.java

