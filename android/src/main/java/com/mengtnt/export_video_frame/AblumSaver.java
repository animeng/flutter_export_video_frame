package com.mengtnt.export_video_frame;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.RectF;
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

    private String addWatermark(Bitmap source, Bitmap watermark, float ratio) {
        Canvas canvas;
        Paint paint;
        Bitmap bmp;
        Matrix matrix;
        RectF r;

        int width, height;
        float scale;

        width = source.getWidth();
        height = source.getHeight();

        // Create the new bitmap
        bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        paint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.DITHER_FLAG | Paint.FILTER_BITMAP_FLAG);

        // Copy the original bitmap into the new one
        canvas = new Canvas(bmp);
        canvas.drawBitmap(source, 0, 0, paint);

        // Scale the watermark to be approximately to the ratio given of the source image height
        scale = (float) (((float) height * ratio) / (float) watermark.getHeight());

        // Create the matrix
        matrix = new Matrix();
        matrix.postScale(scale, scale);

        // Determine the post-scaled size of the watermark
        r = new RectF(0, 0, watermark.getWidth(), watermark.getHeight());
        matrix.mapRect(r);

        // Move the watermark to the bottom right corner
        matrix.postTranslate(width - r.width(), height - r.height());

        // Draw the watermark
        canvas.drawBitmap(watermark, matrix, paint);
        String name = String.format("%d%.5f",System.currentTimeMillis(),Math.random());
        String key = MD5.getStr(name);
        FileStorage.share().createFile(key,bmp);
        return FileStorage.share().filePath(key);

    }

    void saveToAlbum(final String filePath, final Bitmap water, final Result result){

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
                    String resultPath = filePath;
                    if (water != null) {
                        BitmapFactory.Options bmOptions = new BitmapFactory.Options();
                        Bitmap source = BitmapFactory.decodeFile(filePath,bmOptions);

                        resultPath = addWatermark(source,water, (float)0.2);
                    }
                    String md5 = MD5.getStr(resultPath);
                    String fileName = md5 + ".jpg";
                    File file = new File(myDir, fileName);
                    if (file.exists()) {
                        result.success(true);
                        return;
                    }
                    try {
                        FileOutputStream out = new FileOutputStream(file);
                        in = new FileInputStream(resultPath);
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
