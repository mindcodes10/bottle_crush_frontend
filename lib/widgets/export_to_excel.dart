import 'dart:io';
import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportToExcel {
  static Future<void> exportDataToExcel(
      BuildContext context, Future<Map<String, dynamic>?> Function() fetchBottleStats) async {
    debugPrint('Starting exportToExcel function...');
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Android Version: ${androidInfo.version.release}');

      if (androidInfo.version.release.compareTo('12') < 0) {
        if (await Permission.storage.request().isGranted) {
          await _performExport(context, fetchBottleStats);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied. Please enable it in settings.')),
          );
        }
      } else {
        await _performExport(context, fetchBottleStats);
      }
    } catch (e) {
      debugPrint('Error during export: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export Excel file.')),
      );
    }
  }

  static Future<void> _performExport(
      BuildContext context, Future<Map<String, dynamic>?> Function() fetchBottleStats) async {
    try {
      Map<String, dynamic>? bottleStats = await fetchBottleStats();
      if (bottleStats == null || bottleStats.isEmpty) {
        throw Exception("No data available for export.");
      }

      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];
      sheet.appendRow(['Date', 'Business Name', 'Machine Name', 'Bottle Count', 'Bottle Weight']);

      bottleStats.forEach((date, businesses) {
        businesses.forEach((businessName, machines) {
          if (machines.isNotEmpty) {
            for (var machine in machines) {
              sheet.appendRow([
                date,
                businessName,
                machine['machine_name'] ?? '',
                machine['total_bottles']?.toString() ?? '0',
                machine['total_weight']?.toString() ?? '0.0',
              ]);
            }
          } else {
            sheet.appendRow([date, businessName, 'No Machines', '0', '0.0']);
          }
        });
      });

      List<int>? encodedFile = excel.encode();
      if (encodedFile == null) {
        throw Exception("Error encoding Excel file.");
      }

      String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileName = 'BottleStats_$formattedDate.xlsx';

      await _saveFileToDownloads(fileName, encodedFile, context);
    } catch (e) {
      debugPrint('Error exporting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export Excel file.')),
      );
    }
  }

  static Future<void> _saveFileToDownloads(
      String fileName, List<int> encodedFile, BuildContext context) async {
    try {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      String filePath = '${downloadDir.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(encodedFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel file saved in "Downloads" folder')),
      );
    } catch (e) {
      debugPrint('Error while saving file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel file not saved.')),
      );
    }
  }
}
