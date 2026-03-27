import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/models/topic_model.dart';
import 'package:myapp/theme/app_colors.dart';
import 'package:myapp/viewmodels/topic_provider.dart';
import 'package:myapp/views/review_screen.dart';
import 'package:intl/intl.dart';

class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dueTopics = topics.where((t) {
      final due = DateTime(
        t.nextReviewDate.year,
        t.nextReviewDate.month,
        t.nextReviewDate.day,
      );
      return due.isBefore(today) || due.isAtSameMomentAs(today);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(dueTopics.length),
          dueTopics.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ReviewQueueCard(topic: dueTopics[index]),
                      ),
                      childCount: dueTopics.length,
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar:
          dueTopics.isNotEmpty ? _buildStartButton(context, dueTopics) : null,
    );
  }

  SliverAppBar _buildAppBar(int count) {
    return SliverAppBar(
      backgroundColor: AppColors.scaffold,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Queue',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '$count topics due',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
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
              color: AppColors.teal.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.teal.withAlpha(60)),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.teal,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'All caught up!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No topics due today.\nKeep up the streak! 🔥',
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

  Widget _buildStartButton(BuildContext context, List<Topic> dueTopics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewScreen(topic: dueTopics.first),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.play_arrow_rounded,
              color: Colors.black, size: 22),
          label: const Text(
            'Start Review Session',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewQueueCard extends ConsumerWidget {
  final Topic topic;
  const _ReviewQueueCard({required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectColor = AppColors.subjectColor(topic.subject);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      topic.nextReviewDate.year,
      topic.nextReviewDate.month,
      topic.nextReviewDate.day,
    );
    final isOverdue = due.isBefore(today);
    final accent = isOverdue ? AppColors.red : AppColors.teal;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(topic: topic),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg.withAlpha(179),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isOverdue ? AppColors.red.withAlpha(77) : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: subjectColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: subjectColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: subjectColor.withAlpha(60)),
                        ),
                        child: Text(
                          topic.subject.toUpperCase(),
                          style: TextStyle(
                            color: subjectColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildCycleDots(),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withAlpha(77)),
                  ),
                  child: Text(
                    isOverdue
                        ? 'Overdue'
                        : DateFormat.MMMd().format(topic.nextReviewDate),
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleDots() {
    return Row(
      children: List.generate(topic.totalCycles, (i) {
        final filled = i < topic.completedCycles;
        final color = AppColors.subjectColor(topic.subject);
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : color.withAlpha(40),
          ),
        );
      }),
    );
  }
}
