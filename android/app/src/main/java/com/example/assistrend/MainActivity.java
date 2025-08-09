package com.example.assistrend;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.assistrend/permissions";
    private static final int PERMISSIONS_REQUEST_CODE = 42;
    private MethodChannel.Result permissionResult;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("requestMediaPermissions")) {
                                requestMediaPermissions(result);
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }

    private void requestMediaPermissions(MethodChannel.Result result) {
        this.permissionResult = result;
        
        // Different permissions based on Android SDK version
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ (API 33+)
            String[] permissions = {
                    Manifest.permission.READ_MEDIA_IMAGES,
                    Manifest.permission.READ_MEDIA_VIDEO,
                    Manifest.permission.READ_MEDIA_AUDIO
            };
            requestPermissions(permissions);
        } else {
            // Android 12 and below
            String[] permissions = {
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
            };
            requestPermissions(permissions);
        }
    }

    private void requestPermissions(String[] permissions) {
        boolean shouldRequest = false;
        
        for (String permission : permissions) {
            if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
                shouldRequest = true;
                break;
            }
        }
        
        if (shouldRequest) {
            ActivityCompat.requestPermissions(this, permissions, PERMISSIONS_REQUEST_CODE);
        } else {
            if (permissionResult != null) {
                permissionResult.success(true);
                permissionResult = null;
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSIONS_REQUEST_CODE && permissionResult != null) {
            boolean allGranted = true;
            
            if (grantResults.length > 0) {
                for (int result : grantResults) {
                    if (result != PackageManager.PERMISSION_GRANTED) {
                        allGranted = false;
                        break;
                    }
                }
            } else {
                allGranted = false;
            }
            
            permissionResult.success(allGranted);
            permissionResult = null;
        } else {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }
}
