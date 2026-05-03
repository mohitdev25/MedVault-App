import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/vault_file_model.dart';

class VaultNotifier extends Notifier<List<VaultFile>> {
  final _vaultBox = Hive.box<VaultFile>('vaultBox');

  @override
  List<VaultFile> build() {
    return _vaultBox.values.toList();
  }

  void addFile(VaultFile file) {
    _vaultBox.put(file.id, file);
    state = _vaultBox.values.toList();
  }

  void deleteFile(String id) {
    _vaultBox.delete(id);
    state = _vaultBox.values.toList();
  }
}

final vaultProvider = NotifierProvider<VaultNotifier, List<VaultFile>>(() {
  return VaultNotifier();
});

final filteredVaultProvider = Provider.family<List<VaultFile>, String>((ref, category) {
  final files = ref.watch(vaultProvider);
  if (category == 'All') {
    return files;
  }
  return files.where((f) => f.category == category).toList();
});

final searchVaultProvider = Provider.autoDispose.family<List<VaultFile>, String>((ref, query) {
  if (query.isEmpty) return [];
  final files = ref.watch(vaultProvider);
  final lowerQuery = query.toLowerCase();
  return files.where((f) => f.name.toLowerCase().contains(lowerQuery)).toList();
});
