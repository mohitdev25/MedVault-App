import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/models/topic_model.dart';
import 'package:myapp/models/habit_model.dart';
import 'package:myapp/models/vault_file_model.dart';

class BackupService {
  static Future<void> autoBackup() async {
    try {
      final topicsBox = Hive.box<Topic>('topicsBox');
      final habitsBox = Hive.box<Habit>('habitsBox');
      final vaultBox = Hive.box<VaultFile>('vaultBox');

      final List<Map<String, dynamic>> topicsList =
          topicsBox.values.map((topic) {
        return {
          'id': topic.id,
          'title': topic.title,
          'markdownNote': topic.markdownNote,
          'nextReviewDate': topic.nextReviewDate.millisecondsSinceEpoch,
          'intervalDays': topic.intervalDays,
          'subject': topic.subject,
          'cycleNotes': topic.cycleNotes,
          'totalCycles': topic.totalCycles,
          'completedCycles': topic.completedCycles,
          'cycleType': topic.cycleType,
        };
      }).toList();

      final List<Map<String, dynamic>> habitsList =
          habitsBox.values.map((habit) {
        return {
          'id': habit.id,
          'title': habit.title,
          'streakCount': habit.streakCount,
          'isCompleted': habit.isCompleted,
          'colorHex': habit.colorHex,
        };
      }).toList();

      final List<Map<String, dynamic>> vaultsList =
          vaultBox.values.map((vault) {
        return {
          'id': vault.id,
          'name': vault.name,
          'category': vault.category,
          'size': vault.size,
          'type': vault.type,
          'filePath': vault.filePath,
          'colorHex': vault.colorHex,
        };
      }).toList();

      final Map<String, dynamic> backupData = {
        'backup_timestamp': DateTime.now().toIso8601String(),
        'topics': topicsList,
        'habits': habitsList,
        'vaults': vaultsList,
      };

      final String jsonString = jsonEncode(backupData);

      final Directory directory = await getApplicationDocumentsDirectory();
      final File backupFile =
          File('${directory.path}/rethink_backup.json');

      await backupFile.writeAsString(jsonString);
    } catch (e, stackTrace) {
      developer.log(
        'AutoBackup failed',
        error: e,
        stackTrace: stackTrace,
        name: 'BackupService',
      );
    }
  }
}
