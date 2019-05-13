package com.mengtnt.export_video_frame;

import android.os.Environment;
import io.flutter.plugin.common.MethodChannel.Result;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.InputStream;

class AblumSaver {

    private String albumName;

    AblumSaver(String albumName) {
        this.albumName = albumName;
    }

    void saveToAlbum(final String filePath, final Result result){
        new Thread(new Runnable() {
            public void run() {
                try {
                    InputStream in;
                    String root = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString()+ "/"+albumName;
                    File myDir = new File(root);
                    myDir.mkdirs();
                    String fileName = System.currentTimeMillis() + ".jpg";
                    File file = new File(myDir, fileName);
                    if (file.exists()) file.delete();
                    try {
                        FileOutputStream out = new FileOutputStream(file);
                        in = new FileInputStream(filePath);
                        byte[] buffer = new byte[1024];
                        int read;
                        while ((read = in.read(buffer)) != -1) {
                            out.write(buffer, 0, read);
                        }
                        in.close();
                        // write the output file
                        out.flush();
                        out.close();
                        result.success(true);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

}
