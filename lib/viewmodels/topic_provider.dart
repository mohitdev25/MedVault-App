import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/topic_model.dart';

final topicProvider =
    NotifierProvider<TopicNotifier, List<Topic>>(TopicNotifier.new);

class TopicNotifier extends Notifier<List<Topic>> {
  late Box<Topic> _topicBox;

  @override
  List<Topic> build() {
    _topicBox = Hive.box<Topic>('topicsBox');
    return _getSortedTopics();
  }

  /// Helper to get topics sorted by date (Overdue first)
  List<Topic> _getSortedTopics() {
    final topics = _topicBox.values.toList();
    // Sort by nextReviewDate ascending so oldest/overdue appear at the top
    topics.sort((a, b) => a.nextReviewDate.compareTo(b.nextReviewDate));
    return topics;
  }

  /// CRITICAL: Normalizes any DateTime to midnight (00:00:00)
  /// This ensures "Due Today" works from the start of the day.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void addTopic({
    required String title,
    required String markdownNote,
    required String subject,
    String cycleType = 'default_4',
  }) {
    // Using timestamp as a simple unique ID
    final String id = DateTime.now().millisecondsSinceEpoch.toString();

    // Initial review is always tomorrow at midnight
    final nextDate =
        _normalizeDate(DateTime.now().add(const Duration(days: 1)));

    final newTopic = Topic(
      id: id,
      title: title,
      markdownNote: markdownNote,
      nextReviewDate: nextDate,
      intervalDays: 1,
      subject: subject,
      cycleNotes: [],
      totalCycles: 4,
      completedCycles: 0,
      cycleType: cycleType,
    );

    _topicBox.put(id, newTopic);
    state = _getSortedTopics();
  }

  /// Logic for completing a review session
  void completeReview(String id, int gradeIndex, String? newNote) {
    final topic = _topicBox.get(id);
    if (topic == null) return;

    // SRS Intervals for 'default_4': [1, 5, 14, 28]
    final intervals = [1, 5, 14, 28];
    final int selectedInterval = intervals[gradeIndex];

    // Update mutable fields
    topic.completedCycles += 1;

    if (newNote != null && newNote.trim().isNotEmpty) {
      // Create a new list to ensure Hive detects the change if needed,
      // though manual put handles it.
      topic.cycleNotes.add(newNote.trim());
    }

    // Calculate next date and strip time
    topic.nextReviewDate =
        _normalizeDate(DateTime.now().add(Duration(days: selectedInterval)));
    topic.intervalDays = selectedInterval;

    _topicBox.put(id, topic);
    state = _getSortedTopics();
  }

  void deleteTopic(String id) {
    _topicBox.delete(id);
    state = _getSortedTopics();
  }
  
  void updateTopic(Topic topic) {
  _topicBox.put(topic.id, topic);
  state = _getSortedTopics();
}
  // --- Filtered Getters for UI ---

  /// Returns topics due today OR in the past (Overdue)
  List<Topic> getDueTopics() {
    final today = _normalizeDate(DateTime.now());
    // We include anything where normalized date is <= today midnight
    return state.where((t) {
      final normalizedTopicDate = _normalizeDate(t.nextReviewDate);
      return normalizedTopicDate
          .isBefore(today.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Returns topics due strictly after today
  List<Topic> getUpcomingTopics() {
    final today = _normalizeDate(DateTime.now());
    return state.where((t) {
      final normalizedTopicDate = _normalizeDate(t.nextReviewDate);
      return normalizedTopicDate.isAfter(today);
    }).toList();
  }
}
