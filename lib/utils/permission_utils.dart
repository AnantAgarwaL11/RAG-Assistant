// lib/utils/permission_utils.dart
//import 'package:permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    try {
      PermissionStatus status = await Permission.storage.status;

      if (status.isDenied) {
        status = await Permission.storage.request();
      }

      return status.isGranted;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request manage external storage permission (Android 11+)
  static Future<bool> requestManageExternalStoragePermission() async {
    try {
      PermissionStatus status = await Permission.manageExternalStorage.status;

      if (status.isDenied) {
        status = await Permission.manageExternalStorage.request();
      }

      return status.isGranted;
    } catch (e) {
      print('Error requesting manage external storage permission: $e');
      return false;
    }
  }

  /// Check if all required permissions are granted
  static Future<bool> hasAllRequiredPermissions() async {
    bool storageGranted = await Permission.storage.isGranted;
    return storageGranted;
  }

  /// Request all required permissions at once
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.storage,
    ].request();
  }

  /// Show permission dialog with explanation
  static Future<bool> showPermissionDialog(BuildContext context, String permission) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
          'This app needs $permission permission to function properly. '
              'Please grant the permission in the next dialog.',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Continue'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Show settings dialog when permission is permanently denied
  static void showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Denied'),
        content: Text(
          'Storage permission is required to access files. '
              'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Open Settings'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  /// Check and request storage permission with UI feedback
  static Future<bool> checkAndRequestStoragePermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      bool shouldRequest = await showPermissionDialog(context, 'Storage');
      if (shouldRequest) {
        status = await Permission.storage.request();
        return status.isGranted;
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      showSettingsDialog(context);
      return false;
    }

    return false;
  }
}