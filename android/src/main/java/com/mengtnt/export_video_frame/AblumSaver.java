package com.mengtnt.export_video_frame;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.InputStream;

import io.flutter.plugin.common.MethodChannel.Result;

class AblumSaver {

    private String albumName;
    private Context current;

    private static AblumSaver instance = new AblumSaver();

    static AblumSaver share() {
        return instance;
    }

    public void setAlbumName(String albumName) {
        this.albumName = albumName;
    }

    public void setCurrent(Context current) {
        this.current = current;
    }

    void saveToAlbum(final String filePath, final Result result){

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    InputStream in;
                    String root = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).toString()+ "/"+albumName;
                    File myDir = new File(root);
                    if (!myDir.exists()) {
                        myDir.mkdirs();
                    }
                    String md5 = MD5.getStr(filePath);
                    String fileName = md5 + ".jpg";
                    File file = new File(myDir, fileName);
                    if (file.exists()) {
                        result.success(true);
                        return;
                    }
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
                        // Broadcast to system pictures
                        Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
                        Uri uri = Uri.fromFile(file);
                        intent.setData(uri);
                        current.sendBroadcast(intent);
                        result.success(true);
                    } catch (Exception e) {
                        e.printStackTrace();
                        result.success(false);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    result.success(false);
                }
            }
        }).start();
    }

}
