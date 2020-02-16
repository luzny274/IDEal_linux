
package com.mantegral.Example_3D;    
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

public class Example_3D_Activity extends SDLActivity {

    String dataDir;
    BU_Functions funkce;


    @Override
    protected void onStart() {
        if (Environment.getExternalStorageState() == null)
            dataDir = Environment.getDataDirectory().getAbsolutePath();
        else
            dataDir = Environment.getExternalStorageDirectory().getAbsolutePath();
        copyFileOrDir("Example_3D_resources");
	
        funkce = new BU_Functions();
	funkce.setStoragePath(dataDir + "/");

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
                String fullPath = dataDir + "/" + path;
                File dir = new File(fullPath);
                if (!dir.exists())
                    dir.mkdir();
                for (int i = 0; i < assets.length; ++i) {
                    copyFileOrDir(path + "/" + assets[i]);
                }
            }
        } catch (IOException ex) {
            Log.e("tag", "I/O Exception", ex);
        }
    }

    private void copyFile(String filename) {
        AssetManager assetManager = this.getAssets();

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

