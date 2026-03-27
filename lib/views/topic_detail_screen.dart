import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/models/topic_model.dart';
import 'package:myapp/viewmodels/topic_provider.dart';
import 'package:myapp/theme/app_colors.dart';
import 'package:intl/intl.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final Topic topic;
  const TopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          if (_tabController.index != 0 && _isEditing) {
            _isEditing = false;
          }
        });
      }
    });
    _noteController = TextEditingController(text: widget.topic.markdownNote);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Topic?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${widget.topic.title}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ref.read(topicProvider.notifier).deleteTopic(widget.topic.id);
      Navigator.pop(context);
    }
  }

  void _toggleEdit(Topic currentTopic) {
    if (_isEditing) {
      final updatedTopic = currentTopic.copyWith(
        markdownNote: _noteController.text.trim(),
        cycleNotes: List<String>.from(currentTopic.cycleNotes),
      );
      ref.read(topicProvider.notifier).updateTopic(updatedTopic);
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(topicProvider);
    final topic = topics.firstWhere(
      (t) => t.id == widget.topic.id,
      orElse: () => widget.topic,
    );

    final subjectColor = AppColors.subjectColor(topic.subject);

    return GestureDetector(
      onLongPress: _confirmDelete,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          backgroundColor: AppColors.scaffold,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  topic.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: subjectColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: subjectColor.withAlpha(128)),
                ),
                child: Text(
                  topic.subject,
                  style: TextStyle(
                    color: subjectColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (_tabController.index == 0)
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  color: AppColors.teal,
                ),
                onPressed: () => _toggleEdit(topic),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.textSecondary),
              onPressed: _confirmDelete,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.teal,
            labelColor: AppColors.teal,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Notes'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNotesTab(topic),
            _buildHistoryTab(topic),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTab(Topic topic) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: _isEditing
            ? TextField(
                controller: _noteController,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 16, height: 1.5),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Enter your notes here...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  topic.markdownNote.isEmpty
                      ? 'No notes added yet.'
                      : topic.markdownNote,
                  style: TextStyle(
                    color: topic.markdownNote.isEmpty
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHistoryTab(Topic topic) {
    final double progress = topic.totalCycles > 0
        ? (topic.completedCycles / topic.totalCycles).clamp(0.0, 1.0)
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Cycle Progress Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cycle Progress',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${topic.completedCycles} Completed',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${topic.totalCycles} Total',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.glassBorder,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.teal),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Schedule Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today_rounded,
                        color: AppColors.teal, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Next Review',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, yyyy').format(topic.nextReviewDate),
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.update_rounded,
                        color: AppColors.purple, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Interval',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        '${topic.intervalDays} Days',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Cycle Notes
        if (topic.cycleNotes.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12, top: 8),
            child: Text(
              'Cycle Notes',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
          ...List.generate(topic.cycleNotes.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                          color: AppColors.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      topic.cycleNotes[index],
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
