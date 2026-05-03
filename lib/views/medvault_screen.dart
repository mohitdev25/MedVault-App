import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:myapp/models/vault_file_model.dart';
import 'package:myapp/theme/app_colors.dart';
import 'package:myapp/viewmodels/vault_provider.dart';
import 'package:uuid/uuid.dart';
import 'search_overlay.dart';

class MedVaultScreen extends ConsumerStatefulWidget {
  const MedVaultScreen({super.key});

  @override
  ConsumerState<MedVaultScreen> createState() => _MedVaultScreenState();
}

class _MedVaultScreenState extends ConsumerState<MedVaultScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Medicine',
    'Surgery',
    'Pathology',
    'Pharmacology',
    'Anatomy',
    'General',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    final ext = file.extension?.toUpperCase() ?? 'FILE';
    final sizeInMB = (file.size / (1024 * 1024)).toStringAsFixed(1);

    final vaultFile = VaultFile(
      id: const Uuid().v4(),
      name: file.name,
      category: _selectedCategory == 'All' ? 'General' : _selectedCategory,
      size: '$sizeInMB MB',
      type: ext,
      filePath: file.path!,
      colorHex: AppColors.subjectColor(
        _selectedCategory == 'All' ? 'General' : _selectedCategory,
      ).toARGB32(),
    );

    ref.read(vaultProvider.notifier).addFile(vaultFile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.name} added to vault'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _openFile(VaultFile file) async {
    final exists = await File(file.filePath).exists();
    if (!exists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'File not found. It may have been moved or deleted.'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Remove',
              textColor: Colors.white,
              onPressed: () =>
                  ref.read(vaultProvider.notifier).deleteFile(file.id),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }
    await OpenFilex.open(file.filePath);
  }

  void _deleteFile(VaultFile file) {
    ref.read(vaultProvider.notifier).deleteFile(file.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${file.name} removed'),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalFilesCount = ref.watch(vaultProvider.select((v) => v.length));
    final filteredFiles = ref.watch(filteredVaultProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(totalFilesCount),
          SliverToBoxAdapter(child: _buildCategoryFilter()),
          filteredFiles.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _VaultFileCard(
                        file: filteredFiles[index],
                        onTap: () => _openFile(filteredFiles[index]),
                        onDelete: () => _deleteFile(filteredFiles[index]),
                      ),
                      childCount: filteredFiles.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text(
          'Add File',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(int totalFiles) {
    return SliverAppBar(
      backgroundColor: AppColors.scaffold,
      floating: true,
      pinned: false,
      elevation: 0,
      toolbarHeight: 120,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MedVault',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalFiles files stored',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // Android 16 Style Pill Search Bar
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) => const SearchOverlay(),
                  transitionsBuilder: (context, animation, _, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            },
            child: Hero(
              tag: 'search_bar',
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search your vault...',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            final selected = cat == _selectedCategory;
            final color =
                cat == 'All' ? AppColors.teal : AppColors.subjectColor(cat);
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withAlpha(40)
                      : AppColors.surface.withAlpha(150),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? color : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: selected ? color : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.amber.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.amber.withAlpha(60)),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              color: AppColors.amber,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Vault is empty',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your PDFs, images, and\ndocuments to study offline.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VaultFileCard extends StatelessWidget {
  final VaultFile file;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _VaultFileCard({
    required this.file,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(file.colorHex);

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showDeleteDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          file.type,
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Text(
                        file.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            file.category,
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          file.size,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove File?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '${file.name} will be removed from your vault.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
