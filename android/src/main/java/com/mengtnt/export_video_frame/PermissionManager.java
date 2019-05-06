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

import android.content.pm.PackageManager;
import android.app.Activity;
import android.Manifest;
import androidx.core.app.ActivityCompat;

final class PermissionManager {
    static final int REQUEST_EXTERNAL_STORAGE_PERMISSION = 1000;

    private Activity activity;
    private String[] grantName;

    private static PermissionManager instance = new PermissionManager();

    PermissionManager() {
        String[] name = new String[] {Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE};
        this.grantName = name;
    }

    static PermissionManager current() {
        return instance;
    }

    void setActivity(Activity activity) {
        this.activity = activity;
    }

    boolean isPermissionGranted() {
        Boolean isRead = ActivityCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED;
        Boolean isWrite = ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED;
        return isRead && isWrite;
    }

    void askForPermission() {
        ActivityCompat.requestPermissions(activity,grantName, REQUEST_EXTERNAL_STORAGE_PERMISSION);
    }

}
