/** 
MIT License

Copyright (c) 2019 mengtnt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
package com.mengtnt.export_video_frame;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Environment;
import android.util.Log;

public class FileStorage {

    private String directoryName;
    private Context context;
    private boolean external;

    private static FileStorage instance = new FileStorage();
    public static FileStorage share() {
        return instance;
    }

    public FileStorage() {
        this.external = false;
        this.directoryName = "ExportImage";
    }

    public void setContext(Context context) {
        this.context = context;
    }

    public void createFile(String key, Bitmap bitmapImage) {
        FileOutputStream fileOutputStream = null;
        try {
            File file = getFile(fileName(key));
            if (file.exists()) {
                return;
            }
            fileOutputStream = new FileOutputStream(file);
            bitmapImage.compress(Bitmap.CompressFormat.PNG, 100, fileOutputStream);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (fileOutputStream != null) {
                    fileOutputStream.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public boolean removeFile(String key) {
        File file = getFile(fileName(key));
        return file.delete();
    }

    public String filePath(String key) {
        File file = getFile(fileName(key));
        return file.getAbsolutePath();
    }

    private String fileName(String key) {
        return  MD5.getStr(key);
    }

    private File getFile(String fileName) {
        File directory;
        if(external){
            directory = getAlbumStorageDir(directoryName);
        }
        else {
            directory = context.getDir(directoryName, Context.MODE_PRIVATE);
        }
        if(!directory.exists() && !directory.mkdirs()){
            Log.e("FileStorage","Error creating directory " + directory);
        }

        return new File(directory, fileName);
    }

    private File getAlbumStorageDir(String albumName) {
        return new File(Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES), albumName);
    }

    public static boolean isExternalStorageWritable() {
        String state = Environment.getExternalStorageState();
        return Environment.MEDIA_MOUNTED.equals(state);
    }

    public static boolean isExternalStorageReadable() {
        String state = Environment.getExternalStorageState();
        return Environment.MEDIA_MOUNTED.equals(state) ||
                Environment.MEDIA_MOUNTED_READ_ONLY.equals(state);
    }

    public Bitmap load(String key) {
        FileInputStream inputStream = null;
        try {
            inputStream = new FileInputStream(getFile(fileName(key)));
            return BitmapFactory.decodeStream(inputStream);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (inputStream != null) {
                    inputStream.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return null;
    }
}
