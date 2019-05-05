package com.mengtnt.export_video_frame;
import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.os.AsyncTask;
import android.util.Log;

import java.nio.ByteBuffer;
import java.util.ArrayList;

interface Callback {
    void exportPath(ArrayList<String> list);
}

public final class ExportImageTask extends AsyncTask<Object,Void,ArrayList<String>> {

    private Callback callBack;

    void setCallBack(Callback callBack) {
        this.callBack = callBack;
    }

    @Override
    protected ArrayList<String> doInBackground(Object... objects) {
        String filePath = (String) objects[0];
        int number = (int)objects[1];
        if (number <= 0) {
            return null;
        }
        ArrayList result = new ArrayList(number);

        MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
        try {
            mediaMetadataRetriever.setDataSource(filePath);
            String METADATA_KEY_DURATION = mediaMetadataRetriever
                    .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
            int max = (int) Long.parseLong(METADATA_KEY_DURATION);
            int step = max / number;

            for ( int index = 0 ; index < max ; index = index+step ) {
                Bitmap bmpOriginal = mediaMetadataRetriever.getFrameAtTime(index * 1000, MediaMetadataRetriever.OPTION_CLOSEST);
                if (bmpOriginal == null) {
                    continue;
                }
                int bmpVideoHeight = bmpOriginal.getHeight();
                int bmpVideoWidth = bmpOriginal.getWidth();
                int byteCount = bmpVideoWidth * bmpVideoHeight * 4;
                ByteBuffer tmpByteBuffer = ByteBuffer.allocate(byteCount);
                bmpOriginal.copyPixelsToBuffer(tmpByteBuffer);
                Bitmap bitmap = Bitmap.createScaledBitmap(bmpOriginal, bmpVideoWidth, bmpVideoHeight, false);
                String key = String.format("%s%d", filePath, index);
                FileStorage.share().createFile(key,bitmap);
                result.add(FileStorage.share().filePath(key));
                Log.d("Media", "bmpVideoWidth:'" + bmpVideoWidth + "'  bmpVideoHeight:'" + bmpVideoHeight + "'" + key);
            }
        } catch (Exception e) {
            Log.e("Media read error",e.toString());
        }
        mediaMetadataRetriever.release();
        return result;
    }

    @Override
    protected void onPostExecute(ArrayList<String> strings) {
        super.onPostExecute(strings);
        this.callBack.exportPath(strings);
    }

}
