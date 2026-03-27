import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/habit_model.dart';

final habitProvider = NotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);

class HabitNotifier extends Notifier<List<Habit>> {
  Box<Habit> get _habitBox => Hive.box<Habit>('habitsBox');

  @override
  List<Habit> build() {
    _handleDailyReset();
    return _habitBox.values.toList();
  }

  void _handleDailyReset() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    // Use a special key in same box for metadata
    // We store it as a raw dynamic value
    final box = Hive.box<dynamic>('metaBox');
    final lastReset = box.get('__last_reset__') as String?;

    if (lastReset == todayKey) return; // Already reset today

    // New day detected
    for (final habit in _habitBox.values) {
      if (!habit.isCompleted) {
        // Missed yesterday — streak breaks
        habit.streakCount = 0;
      }
      habit.isCompleted = false;
      _habitBox.put(habit.id, habit);
    }

    box.put('__last_reset__', todayKey);
  }

  void toggleHabit(String id) {
    final habit = _habitBox.get(id);
    if (habit == null) return;

    habit.isCompleted = !habit.isCompleted;

    if (habit.isCompleted) {
      // Completing — increment streak
      habit.streakCount += 1;
    }
    // Uncompleting — streak stays, just toggle back
    // No decrement — user shouldn't be punished for fat fingers

    _habitBox.put(habit.id, habit);
    state = _habitBox.values.toList();
  }

  void addHabit(Habit habit) {
    _habitBox.put(habit.id, habit);
    state = _habitBox.values.toList();
  }

  void deleteHabit(String id) {
    _habitBox.delete(id);
    state = _habitBox.values.toList();
  }
}
