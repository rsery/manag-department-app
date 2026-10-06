import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class AppUpdateInfo {
  final int versionCode;

  final String versionName;

  final String releaseNotes;

  final bool forceUpdate;

  final String storagePath;

  final String apkUrl;

  const AppUpdateInfo({
    required this.versionCode,
    required this.versionName,
    required this.releaseNotes,
    required this.forceUpdate,
    required this.storagePath,
    required this.apkUrl,
  });

  factory AppUpdateInfo.fromMap(Map<String, dynamic> data) {
    return AppUpdateInfo(
      versionCode: _parseInt(data['versionCode']),
      versionName: (data['versionName'] ?? '').toString().trim(),
      releaseNotes: (data['releaseNotes'] ?? '').toString().trim(),
      forceUpdate: data['forceUpdate'] == true,
      storagePath: (data['storagePath'] ?? '').toString().trim(),
      apkUrl: (data['apkUrl'] ?? '').toString().trim(),
    );
  }

static int _parseInt(dynamic value) {
if (value is int) {
return value;
}

if (value is num) {
  return value.toInt();
}

return int.tryParse(value?.toString() ?? '') ?? 0;

}
}

class AppUpdateService {
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseStorage _storage = FirebaseStorage.instance;

bool _dialogShown = false;

Future<AppUpdateInfo?> checkForUpdate() async {
try {
final packageInfo = await PackageInfo.fromPlatform();

  final currentBuildNumber =
      int.tryParse(packageInfo.buildNumber.trim()) ?? 0;

  final snapshot = await _firestore
      .collection('app_config')
      .doc('android')
      .get();

  if (!snapshot.exists) {
    return null;
  }

  final data = snapshot.data();

  if (data == null) {
    return null;
  }

  final updateInfo = AppUpdateInfo.fromMap(data);

  if (updateInfo.versionCode <= currentBuildNumber) {
    return null;
  }

  if (updateInfo.storagePath.isEmpty) {
    return null;
  }

  return updateInfo;
} catch (e) {
  debugPrint('App update check failed: $e');
  return null;
}

}

Future<void> checkAndShowUpdateDialog(BuildContext context) async {
if (_dialogShown) {
return;
}

final updateInfo = await checkForUpdate();

if (updateInfo == null) {
  return;
}

if (!context.mounted) {
  return;
}

_dialogShown = true;

await showDialog<void>(
  context: context,
  barrierDismissible: !updateInfo.forceUpdate,
  builder: (dialogContext) {
    return PopScope(
      canPop: !updateInfo.forceUpdate,
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.system_update_rounded),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'يتوفر تحديث جديد',
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإصدار الجديد: ${updateInfo.versionName}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (updateInfo.releaseNotes.isNotEmpty) ...[
                const Text(
                  'ملاحظات التحديث:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(updateInfo.releaseNotes),
              ],
              if (updateInfo.forceUpdate) ...[
                const SizedBox(height: 14),
                const Text(
                  'هذا التحديث إجباري ويجب تثبيته للمتابعة.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!updateInfo.forceUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('لاحقًا'),
            ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              await _downloadAndInstall(
                context,
                updateInfo,
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  },
);

_dialogShown = false;

}

Future<void> _downloadAndInstall(
BuildContext context,
AppUpdateInfo updateInfo,
) async {
if (!context.mounted) {
return;
}

final progressNotifier = ValueNotifier<double?>(null);

showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (dialogContext) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text(
          'جاري تنزيل التحديث',
          textDirection: TextDirection.rtl,
        ),
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: ValueListenableBuilder<double?>(
            valueListenable: progressNotifier,
            builder: (context, progress, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 12),
                  Text(
                    progress == null
                        ? 'جاري تنزيل ملف التحديث...'
                        : 'تم تنزيل ${(progress * 100).toStringAsFixed(0)}%',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  },
);

try {
  final directory = await getApplicationSupportDirectory();

  final apkFile = File(
    '${directory.path}/app_update_${updateInfo.versionCode}.apk',
  );

  if (await apkFile.exists()) {
    await apkFile.delete();
  }

  final reference = _storage.ref(updateInfo.storagePath);

  final downloadTask = reference.writeToFile(apkFile);

  downloadTask.snapshotEvents.listen(
    (snapshot) {
      final total = snapshot.totalBytes;

      if (total <= 0) {
        progressNotifier.value = null;
        return;
      }

      progressNotifier.value =
          snapshot.bytesTransferred / total;
    },
  );

  await downloadTask;

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  progressNotifier.dispose();

  final result = await OpenFile.open(
    apkFile.path,
    type: 'application/vnd.android.package-archive',
  );

  if (result.type != ResultType.done) {
    if (!context.mounted) {
      return;
    }

    await _showInstallError(
      context,
      result.message,
    );
  }
} catch (e) {
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  progressNotifier.dispose();

  if (!context.mounted) {
    return;
  }

  await _showInstallError(
    context,
    'تعذر تنزيل أو فتح ملف التحديث.\n\n$e',
  );
}

}

Future<void> _showInstallError(
BuildContext context,
String message,
) async {
if (!context.mounted) {
return;
}

await showDialog<void>(
  context: context,
  builder: (dialogContext) {
    return AlertDialog(
      title: const Text(
        'تعذر تثبيت التحديث',
        textDirection: TextDirection.rtl,
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(message),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
          },
          child: const Text('حسنًا'),
        ),
      ],
    );
  },
);

}
}