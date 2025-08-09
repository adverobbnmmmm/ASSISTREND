@echo off

set PHOTO_MANAGER_PATH=C:\Users\jenjo\AppData\Local\Pub\Cache\hosted\pub.dev\photo_manager-2.8.2\android\build.gradle
set PATCH_PATH=c:\Users\jenjo\Desktop\R\Assistrend\ASSISTREND-jefin-real\android\photo_manager_build.gradle.patch

echo Applying patch to photo_manager...
copy /Y "%PATCH_PATH%" "%PHOTO_MANAGER_PATH%" 
if %ERRORLEVEL% EQU 0 (
    echo Patch applied successfully!
) else (
    echo Failed to apply patch. Please check paths and permissions.
)

pause
