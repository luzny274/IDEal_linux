package org.Bibliotekum_Ultimatum.app;

import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.InputStream;
import android.content.res.AssetManager;
import android.os.Environment;
import android.util.Log;

import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.InputStream;


public class BU_Functions {    
  public BU_Functions(){}

  static {
        System.loadLibrary("main");
  }

  private String dataDir;

  public native void setStoragePath(String path);

  public native void nativeOnDestroy();//

  public native void nativeOnSurfaceCreated();//

  public native void nativeOnUpdate(	boolean cardboard_trigger,
					boolean isPlugged,
					float lX, float lY,
					float rX, float rY,
					float triggerLeft, float triggerRight,
					boolean up,
					boolean down,          
					boolean left,          
					boolean right,         
					boolean start,         
					boolean back,         
					boolean leftShoulder,  
					boolean rightShoulder, 
					boolean A,
					boolean B,       
					boolean X,       
					boolean Y);

  public native void nativeOnDrawEye(	float frontX, float frontY, float frontZ, 
					float upX, float upY, float upZ, 
					float rightX, float rightY, float rightZ,
					float[] perspective, int type);//

  public native float nativeGetZNear();//

  public native float nativeGetZFar();//


  public void initBU(AssetManager assetManager, String appName){
  	
        if (Environment.getExternalStorageState() == null)
            dataDir = Environment.getDataDirectory().getAbsolutePath();
        else
            dataDir = Environment.getExternalStorageDirectory().getAbsolutePath();
        copyFileOrDir(appName + "_resources", assetManager);
	
        setStoragePath(dataDir + "/");

  }


    /* https://gist.github.com/tylerchesley/6198074 */

    public void copyFileOrDir(String path, AssetManager assetManager) {
        String assets[] = null;
        try {
            assets = assetManager.list(path);
            if (assets.length == 0) {
                copyFile(path, assetManager);
            } else {
                String fullPath = dataDir + "/" + path;
                File dir = new File(fullPath);
                if (!dir.exists())
                    dir.mkdir();
                for (int i = 0; i < assets.length; ++i) {
                    copyFileOrDir(path + "/" + assets[i], assetManager);
                }
            }
        } catch (IOException ex) {
            Log.e("tag", "I/O Exception", ex);
        }
    }

    private void copyFile(String filename, AssetManager assetManager) {

        InputStream in = null;
        OutputStream out = null;
        try {
            in = assetManager.open(filename);
            String newFileName = dataDir + "/" + filename;

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
            Log.e("tag", e.getMessage());
        }

    }



 }

