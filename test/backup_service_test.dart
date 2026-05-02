import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/Services/backup_service.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
  });

  test('autoBackup handles exceptions gracefully', () async {
    // Hive is not initialized, so autoBackup should throw an error internally,
    // but the catch block should handle it.

    // We expect it NOT to throw an exception because it's caught.
    try {
      await BackupService.autoBackup();
      // If it reaches here, it didn't throw.
    } catch (e) {
      fail('autoBackup should not throw an exception: $e');
    }
  });
}
