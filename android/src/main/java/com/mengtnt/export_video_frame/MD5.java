package com.mengtnt.export_video_frame;
import java.math.BigInteger;
import java.security.MessageDigest;
import android.util.Log;

public class MD5 {

    public static String getStr(String str) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(str.getBytes());
            return new BigInteger(1, md.digest()).toString(16);
        } catch (Exception e) {
            Log.e("MD5 Error",e.toString());
        }
        return "";
    }
}
