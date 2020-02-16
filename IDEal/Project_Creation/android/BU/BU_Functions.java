package org.Bibliotekum_Ultimatum.app;

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

    public native void setStoragePath(String path);

 }

