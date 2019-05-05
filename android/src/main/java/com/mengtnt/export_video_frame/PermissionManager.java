package com.mengtnt.export_video_frame;

import android.content.pm.PackageManager;
import android.app.Activity;
import android.Manifest;
import androidx.core.app.ActivityCompat;

public final class PermissionManager {
    static final int REQUEST_EXTERNAL_STORAGE_PERMISSION = 1000;

    private Activity activity;
    private String[] grantName;

    private static PermissionManager instance = new PermissionManager();

    public PermissionManager() {
        String[] name = new String[] {Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE};
        this.grantName = name;
    }

    public static PermissionManager current() {
        return instance;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public boolean isPermissionGranted() {
        Boolean isRead = ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED;
        Boolean isWrite = ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED;
        return isRead && isWrite;
    }

    public void askForPermission() {
        ActivityCompat.requestPermissions(activity,grantName, REQUEST_EXTERNAL_STORAGE_PERMISSION);
    }

}
