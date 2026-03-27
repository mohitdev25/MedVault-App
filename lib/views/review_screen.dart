import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/models/topic_model.dart';
import 'package:myapp/viewmodels/topic_provider.dart';
import 'package:myapp/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? bgColor;
  final Border? border;
  final double? width;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.bgColor,
    this.border,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor ?? AppColors.glass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ReviewScreen extends ConsumerStatefulWidget {
  final Topic topic;
  const ReviewScreen({super.key, required this.topic});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _isRevealed = false;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _gradeReview(int intervalIndex) {
    final newNote = _notesController.text.trim();
    ref.read(topicProvider.notifier).completeReview(
      widget.topic.id,
      intervalIndex,
      newNote.isEmpty ? null : newNote,
    );

    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Next review in ${[1, 5, 14, 28][intervalIndex]} days',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.teal,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = AppColors.subjectColor(widget.topic.subject);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cycle ${widget.topic.completedCycles + 1} of ${widget.topic.totalCycles}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isRevealed
            ? _buildBackCard(subjectColor)
            : _buildFrontCard(subjectColor),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: _isRevealed
            ? _buildGradingButtons()
            : _buildRevealButton(),
      ),
    );
  }

  Widget _buildFrontCard(Color subjectColor) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubjectChip(subjectColor),
          const SizedBox(height: 20),
          Text(
            widget.topic.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          if (widget.topic.cycleNotes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: AppColors.glassBorder),
            const SizedBox(height: 12),
            const Text(
              'LAST NOTE',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.topic.cycleNotes.last,
              style: TextStyle(
                color: AppColors.textSecondary.withAlpha(180),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded,
                    color: AppColors.textSecondary.withAlpha(120),
                    size: 16),
                const SizedBox(width: 6),
                Text(
                  'Tap to reveal notes',
                  style: TextStyle(
                    color: AppColors.textSecondary.withAlpha(120),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(Color subjectColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubjectChip(subjectColor),
              const SizedBox(height: 12),
              Text(
                widget.topic.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('DAY 1 NOTES'),
        const SizedBox(height: 8),
        GlassCard(
          child: Text(
            widget.topic.markdownNote.isEmpty
                ? 'No notes added.'
                : widget.topic.markdownNote,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
        if (widget.topic.cycleNotes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('PREVIOUS CYCLE NOTES'),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.topic.cycleNotes
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Cycle ${e.key + 1}: ${e.value}',
                          style: TextStyle(
                            color: AppColors.textSecondary.withAlpha(178),
                            fontSize: 14,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildSectionHeader('ADD CYCLE NOTE'),
        const SizedBox(height: 8),
        GlassCard(
          child: TextField(
            controller: _notesController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Add shorthand notes for this cycle...',
              hintStyle: TextStyle(
                  color: AppColors.textSecondary.withAlpha(150)),
              border: InputBorder.none,
            ),
            maxLines: 3,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildRevealButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() => _isRevealed = true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Reveal Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGradingButtons() {
    return Row(
      children: [
        _GradeButton(
            label: 'AGAIN',
            interval: '+1d',
            color: AppColors.red,
            onTap: () => _gradeReview(0)),
        const SizedBox(width: 8),
        _GradeButton(
            label: 'HARD',
            interval: '+5d',
            color: AppColors.amber,
            onTap: () => _gradeReview(1)),
        const SizedBox(width: 8),
        _GradeButton(
            label: 'GOOD',
            interval: '+14d',
            color: AppColors.teal,
            onTap: () => _gradeReview(2)),
        const SizedBox(width: 8),
        _GradeButton(
            label: 'EASY',
            interval: '+28d',
            color: AppColors.green,
            onTap: () => _gradeReview(3)),
      ],
    );
  }

  Widget _buildSubjectChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        widget.topic.subject.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _GradeButton extends StatelessWidget {
  final String label;
  final String interval;
  final Color color;
  final VoidCallback onTap;

  const _GradeButton({
    required this.label,
    required this.interval,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color.withAlpha(38),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                interval,
                style: TextStyle(
                  color: color.withAlpha(180),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
