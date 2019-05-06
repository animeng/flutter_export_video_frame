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
import android.graphics.Bitmap;
import android.media.MediaMetadataRetriever;
import android.os.AsyncTask;
import android.util.Log;

import java.nio.ByteBuffer;
import java.util.ArrayList;

interface Callback {
    void exportPath(ArrayList<String> list);
}

final class ExportImageTask extends AsyncTask<Object,Void,ArrayList<String>> {

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
