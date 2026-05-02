import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'views/onboarding_screen.dart';
import 'models/habit_model.dart';
import 'models/topic_model.dart';
import 'models/vault_file_model.dart';
import 'models/revision_attachment.dart'; // Import the new model
import 'viewmodels/topic_provider.dart';
import 'viewmodels/habit_provider.dart';
import 'adapters/color_adapter.dart';
import 'views/review_queue_screen.dart';
import 'views/review_screen.dart';
import 'views/medvault_screen.dart';
import 'package:myapp/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize our bulletproof pure-Dart database safely
  await Hive.initFlutter();

  // 2. Register Adapters
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(TopicAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(VaultFileAdapter());
  Hive.registerAdapter(RevisionAttachmentAdapter()); // Register the new adapter

  // 3. Open Boxes
  await Hive.openBox<Topic>('topicsBox');
  final habitsBox = await Hive.openBox<Habit>('habitsBox');
  await Hive.openBox<VaultFile>('vaultBox');
  await Hive.openBox<RevisionAttachment>('attachmentsBox'); // Open the new box
  await Hive.openBox<dynamic>('metaBox');
  // Add initial habits if the box is empty
  if (habitsBox.isEmpty) {
    habitsBox.putAll({
      '1': Habit(
          id: '1',
          title: 'Wake Up',
          streakCount: 12,
          isCompleted: false,
          colorHex: 0xFFFFB547),
      '2': Habit(
          id: '2',
          title: 'Study AM',
          streakCount: 8,
          isCompleted: false,
          colorHex: 0xFF00E5D0),
      '3': Habit(
          id: '3',
          title: 'Review',
          streakCount: 15,
          isCompleted: false,
          colorHex: 0xFF9B6DFF),
      '4': Habit(
          id: '4',
          title: 'Exercise',
          streakCount: 5,
          isCompleted: false,
          colorHex: 0xFF3DDE8B),
      '5': Habit(
          id: '5',
          title: 'Meditate',
          streakCount: 3,
          isCompleted: false,
          colorHex: 0xFFF48FB1),
    });
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 4. Wrap the beautiful new app in Riverpod's ProviderScope
  runApp(const ProviderScope(child: MedVaultApp()));
}

// ─── GLASSMORPHISM CARD ────────────────────────────────────────────────────────
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
    this.borderRadius = 20,
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
            border:
                border ?? Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── ROOT APP ──────────────────────────────────────────────────────────────────
class MedVaultApp extends StatelessWidget {
  const MedVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffold,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.teal,
          secondary: AppColors.purple,
          surface: AppColors.surface,
        ),
        fontFamily: 'Roboto',
      ),
      home: Hive.box<dynamic>('metaBox').get('onboarding_complete') == true
    ? const MainShell()
    : const OnboardingScreen(),
    );
  }
}

// ─── MAIN SHELL (Bottom Nav) ───────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final _pages = [
    const DashboardScreen(),
    // This is a placeholder, it will be replaced by the actual review screen later
    const ReviewQueueScreen(),
    const MedVaultScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.today_rounded,
                label: 'Today',
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
                color: AppColors.teal,
              ),
              _NavItem(
                icon: Icons.psychology_alt_rounded,
                label: 'Review',
                selected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
                color: AppColors.purple,
              ),
              _NavItem(
                icon: Icons.folder_special_rounded,
                label: 'Vault',
                selected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
                color: AppColors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(38) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: selected ? color : AppColors.textSecondary, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1: DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnim =
        CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack);
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AddRevisionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(topicProvider);
    final habits = ref.watch(habitProvider);


    final todayTopics = ref.read(topicProvider.notifier).getDueTopics();
    final upcomingTopics = ref.read(topicProvider.notifier).getUpcomingTopics();

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      floatingActionButton: ScaleTransition(
        scale: _fabAnim,
        child: FloatingActionButton(
          onPressed: _showAddSheet,
          backgroundColor: AppColors.teal,
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
              child: _buildGreeting(todayTopics.length, topics.length)),
          SliverToBoxAdapter(child: _buildHabitStrip(habits)),
          SliverToBoxAdapter(child: _buildSegmentedControl()),
          SliverToBoxAdapter(
              child: _buildTopicList(todayTopics, upcomingTopics)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: false,
      backgroundColor: AppColors.scaffold,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.teal, AppColors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'MedVault',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
          onPressed: () {},
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.purple,
          child: Text('DR',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildGreeting(int dueTodayCount, int totalTopics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good morning, Doctor 👋',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'NEET PG · 47 days to go',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsRow(dueTodayCount, totalTopics),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int dueTodayCount, int totalTopics) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            bgColor: AppColors.teal.withAlpha(20),
            border: Border.all(color: AppColors.teal.withAlpha(51)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔥 15',
                    style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text('Day streak',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            bgColor: AppColors.purple.withAlpha(20),
            border: Border.all(color: AppColors.purple.withAlpha(51)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$dueTodayCount',
                    style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                const Text('Due today',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            bgColor: AppColors.amber.withAlpha(20),
            border: Border.all(color: AppColors.amber.withAlpha(51)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$totalTopics',
                    style: const TextStyle(
                        color: AppColors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                const Text('Total Topics',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitStrip(List<Habit> habits) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY HABITS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _HabitCard(habit: habits[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GlassCard(
        padding: const EdgeInsets.all(4),
        borderRadius: 16,
        bgColor: AppColors.surface.withAlpha(153),
        child: Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tabIndex == 0 ? AppColors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 14,
                        color: _tabIndex == 0
                            ? Colors.black
                            : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'To Revise Today',
                      style: TextStyle(
                        color: _tabIndex == 0
                            ? Colors.black
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tabIndex == 1 ? AppColors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14,
                        color: _tabIndex == 1
                            ? Colors.white
                            : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Upcoming',
                      style: TextStyle(
                        color: _tabIndex == 1
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildTopicList(List<Topic> todayTopics, List<Topic> upcomingTopics) {
    final topics = _tabIndex == 0 ? todayTopics : upcomingTopics;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: topics
            .map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TopicCard(topic: t),
                ))
            .toList(),
      ),
    );
  }
}

// ─── HABIT CARD ────────────────────────────────────────────────────────────────
class _HabitCard extends StatelessWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorHex);
    return GlassCard(
      width: 85,
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      bgColor: color.withAlpha(20),
      border: Border.all(color: color.withAlpha(64)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 6),
          Text(
            habit.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '🔥 ${habit.streakCount}',
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ─── TOPIC CARD ────────────────────────────────────────────────────────────────
class _TopicCard extends StatelessWidget {
  final Topic topic;
  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final isDueToday = topic.nextReviewDate.day == DateTime.now().day;
    final accent = isDueToday ? AppColors.red : AppColors.teal;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReviewScreen(topic: topic)),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        bgColor: AppColors.cardBg.withAlpha(179),
        border: Border.all(
          color:
              isDueToday ? AppColors.red.withAlpha(77) : AppColors.glassBorder,
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: accent,
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
                  const SizedBox(height: 2),
                  Text(
                    topic.markdownNote,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                    DateFormat.MMMd().format(topic.nextReviewDate),
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
}

// ─── ADD REVISION BOTTOM SHEET ─────────────────────────────────────────────────
class _AddRevisionSheet extends ConsumerStatefulWidget {
  const _AddRevisionSheet();

  @override
  ConsumerState<_AddRevisionSheet> createState() => _AddRevisionSheetState();
}

class _AddRevisionSheetState extends ConsumerState<_AddRevisionSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedSubject = 'General';
  String _selectedCycleType = 'default_4';

  final List<String> _subjects = [
    'Medicine',
    'Surgery',
    'Pathology',
    'Pharmacology',
    'Anatomy',
    'General'
  ];

  final Map<String, String> _cycleOptions = {
    'Default (1d, 5d, 14d, 28d)': 'default_4',
    'Short (3 Cycles)': 'short_3',
    'Long (5 Cycles)': 'long_5',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveRevision() {
    if (_titleController.text.isEmpty) return;

    ref.read(topicProvider.notifier).addTopic(
          title: _titleController.text,
          markdownNote: _notesController.text,
          subject: _selectedSubject,
          cycleType: _selectedCycleType,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xF01A1A22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: AppColors.glassBorder, width: 1),
                left: BorderSide(color: AppColors.glassBorder, width: 0.5),
                right: BorderSide(color: AppColors.glassBorder, width: 0.5),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'New Revision',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                _SheetField(
                    hint: 'Topic (e.g. Myocardial Infarction)',
                    controller: _titleController),
                const SizedBox(height: 12),
                _SheetField(
                    hint: 'Notes (optional)', controller: _notesController),
                const SizedBox(height: 20),
                _buildSubjectPicker(),
                const SizedBox(height: 20),
                _buildCyclePicker(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveRevision,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Revision',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSubjectPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('SUBJECT'),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _subjects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final subject = _subjects[i];
              final selected = subject == _selectedSubject;
              return ChoiceChip(
                label: Text(subject),
                selected: selected,
                onSelected: (bool isSelected) {
                  if (isSelected) {
                    setState(() {
                      _selectedSubject = subject;
                    });
                  }
                },
                backgroundColor: AppColors.glass,
                selectedColor: AppColors.teal,
                labelStyle: TextStyle(
                  color: selected ? Colors.black : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: selected ? AppColors.teal : AppColors.glassBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCyclePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CYCLE'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _cycleOptions.entries.map((entry) {
            final selected = entry.value == _selectedCycleType;
            return ChoiceChip(
              label: Text(entry.key),
              selected: selected,
              onSelected: (bool isSelected) {
                if (isSelected) {
                  setState(() {
                    _selectedCycleType = entry.value;
                  });
                }
              },
              backgroundColor: AppColors.glass,
              selectedColor: AppColors.purple,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                    color: selected ? AppColors.purple : AppColors.glassBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            );
          }).toList(),
        )
      ],
    );
  }
}

class _SheetField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  const _SheetField({required this.hint, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        filled: true,
        fillColor: AppColors.glass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

