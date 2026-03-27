import 'package:flutter/material.dart';
import 'package:myapp/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:myapp/main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<AnimationController> _animationControllers;
  int _currentPage = 0;
  final TextEditingController _usernameController = TextEditingController();

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.psychology_rounded,
      'title': 'Study Smarter',
      'subtitle':
          'Master your subjects with scientifically proven spaced repetition. Remember more by studying at the perfect time.',
      'color': AppColors.teal,
    },
    {
      'icon': Icons.track_changes_rounded,
      'title': 'Build Habits',
      'subtitle':
          'Consistency is key. Track your daily study streaks and build unbreakable learning habits over time.',
      'color': AppColors.purple,
    },
    {
      'icon': Icons.lock_person_rounded,
      'title': 'Own Your Data',
      'subtitle':
          '100% offline and privacy-first. Your vault, your rules. What should we call you, Doctor?',
      'color': AppColors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationControllers = List.generate(
      _pages.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3000),
      ),
    );
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    _usernameController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _animationControllers[index].forward(from: 0.0);
  }

  void _getStarted() {
    final username = _usernameController.text.trim();
    final box = Hive.box<dynamic>('metaBox');
    box.put('username', username.isEmpty ? 'Doctor' : username);
    box.put('onboarding_complete', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainShell()),
    );
  }

  Widget _buildDot(int index) {
    final isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.teal
            : AppColors.textSecondary.withAlpha(76),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage(int index) {
    final page = _pages[index];
    final isLastPage = index == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page['icon'] as IconData,
            size: 100,
            color: page['color'] as Color,
          ),
          const SizedBox(height: 48),
          _StaggeredText(
            text: page['title'] as String,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            controller: _animationControllers[index],
          ),
          const SizedBox(height: 16),
          _StaggeredText(
            text: page['subtitle'] as String,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
            controller: _animationControllers[index],
          ),
          if (isLastPage) ...[
            const SizedBox(height: 48),
            Hero(
              tag: 'username_hero',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _usernameController,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 16),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle:
                        const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: AppColors.teal),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) => _buildPage(index),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                        _pages.length, (index) => _buildDot(index)),
                  ),
                  if (_currentPage == _pages.length - 1)
                    ElevatedButton(
                      onPressed: _getStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggeredText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final AnimationController controller;

  const _StaggeredText({
    required this.text,
    required this.style,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4.0,
      runSpacing: 4.0,
      children: List.generate(words.length, (index) {
        double start = (index * 80.0) / 3000.0;
        if (start >= 1.0) start = 0.99;
        double end = start + 0.1;
        if (end > 1.0) end = 1.0;

        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );

        return FadeTransition(
          opacity: animation,
          child: Text(words[index], style: style, textAlign: TextAlign.center),
        );
      }),
    );
  }
}
