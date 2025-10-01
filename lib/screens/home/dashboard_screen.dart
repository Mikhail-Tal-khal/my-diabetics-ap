// lib/screens/home/dashboard_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_diabeticapp/providers/streak_provider.dart';
import 'package:my_diabeticapp/screens/detection/diabetes_detection_screen.dart';
import 'package:my_diabeticapp/screens/home/widgets/action_card.dart';
import 'package:my_diabeticapp/providers/user_auth_provider.dart';
import 'package:my_diabeticapp/screens/home/widgets/article_card.dart';
import 'package:my_diabeticapp/screens/home/widgets/health_metrics_card.dart';
import 'package:my_diabeticapp/screens/home/widgets/history_card.dart';
import 'package:my_diabeticapp/screens/home/widgets/section_header.dart';
import 'package:my_diabeticapp/screens/settings/setting_screen.dart';
import 'package:my_diabeticapp/test_results_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onSettingsTap;

  const DashboardScreen({super.key, required this.onSettingsTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showFAB = true;
  bool _hasCheckedInToday = false;
  DateTime? _lastOpenedDate; // Track locally instead of in StreakProvider

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    _checkDailyStreak();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _showFAB) {
        setState(() => _showFAB = false);
      } else if (_scrollController.offset <= 100 && !_showFAB) {
        setState(() => _showFAB = true);
      }
    });
  }

  void _checkDailyStreak() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final streakProvider = Provider.of<StreakProvider>(context, listen: false);
      
      // Check if we've already recorded today's usage
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // For demo purposes, we'll use a simple approach
      // In a real app, you'd want to persist this date
      if (_lastOpenedDate == null || _lastOpenedDate!.isBefore(today)) {
        // New day - increment streak
        streakProvider.incrementStreak();
        _lastOpenedDate = now;
        
        setState(() {
          _hasCheckedInToday = true;
        });
        
        _showStreakCelebration(context);
      } else {
        // Already recorded today
        setState(() {
          _hasCheckedInToday = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StreakProvider>(
      builder: (context, streakProvider, _) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              if (context.mounted) {
                context.read<TestResultsProvider>().setState(() {});
              }
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, streakProvider),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HealthMetricsCard(),
                            const SizedBox(height: 24),
                            _buildDailyCheckSection(context, streakProvider),
                            const SizedBox(height: 24),
                            const TestResultsSection(),
                            const SizedBox(height: 24),
                            const ActionGrid(),
                            const SizedBox(height: 24),
                            const ArticlesList(),
                            const SizedBox(height: 24),
                            _buildQuickStats(context),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: AnimatedScale(
            scale: _showFAB ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiabetesDetectionScreen(),
                    ),
                  ),
                  customBorder: const CircleBorder(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Test',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, StreakProvider streakProvider) {
    final user = Provider.of<UserAuthProvider>(context).currentUser;
    final theme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 240,
      floating: false,
      pinned: true,
      backgroundColor: theme.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primary,
                theme.primary.withOpacity(0.8),
                theme.primary.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row with avatar and actions
                  Row(
                    children: [
                      // User Avatar with better styling
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            backgroundImage: user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null,
                            child: user?.photoUrl == null
                                ? Text(
                                    _getInitials(user?.name ?? 'User'),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Notification Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined, size: 26),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Settings Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 26),
                          color: Colors.white,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Greeting with time-based message and emoji
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getGreetingSubtitle(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Streak indicator with improved styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orange.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${streakProvider.currentStreak}-day streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (streakProvider.currentStreak > 0)
                          Icon(
                            Icons.celebration_rounded,
                            color: Colors.yellow.shade300,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get time-based greeting with emoji
  String _getGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return '🌅 Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return '☀️ Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return '🌆 Good Evening';
    } else {
      return '🌙 Good Night';
    }
  }

  // Helper method to get greeting subtitle
  String _getGreetingSubtitle() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Ready to start your day?';
    } else if (hour >= 12 && hour < 17) {
      return 'How\'s your day going?';
    } else if (hour >= 17 && hour < 21) {
      return 'Hope you had a great day!';
    } else {
      return 'Time to rest and recharge';
    }
  }

  // Helper method to get user initials from name
  String _getInitials(String name) {
    List<String> names = name.trim().split(' ');
    if (names.isEmpty) return 'U';
    
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }

  Widget _buildDailyCheckSection(
    BuildContext context,
    StreakProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Daily Check-in',
          onSeeAll: () => _showStreakDetails(context, provider),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade50,
                Colors.purple.shade50,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _hasCheckedInToday ? Colors.green.shade100 : Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _hasCheckedInToday ? Icons.check_circle_rounded : Icons.local_fire_department_rounded,
                color: _hasCheckedInToday ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
            title: Text(
              _hasCheckedInToday ? 'Daily check-in complete!' : 'Welcome back!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              _hasCheckedInToday 
                  ? 'Your ${provider.currentStreak}-day streak is active!'
                  : 'Using the app today will maintain your streak',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            trailing: _hasCheckedInToday
                ? Icon(Icons.verified_rounded, color: Colors.green.shade700)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Your Progress', onSeeAll: () {}),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.calendar_today_rounded,
                title: 'Tests',
                value: '12',
                subtitle: 'This month',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.trending_up_rounded,
                title: 'Avg Sugar',
                value: '120',
                subtitle: 'mg/dL',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showStreakDetails(BuildContext context, StreakProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange.shade700,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.currentStreak} Day Streak!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep using the app daily to maintain your streak',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showStreakCelebration(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Daily streak updated! Keep using the app daily! 🔥',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class TestResultsSection extends StatelessWidget {
  const TestResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestResultsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.results.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recent Test Results',
              onSeeAll: () => _navigateToHistory(context),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.results.length.clamp(0, 5),
                itemBuilder: (context, index) {
                  final result = provider.results[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: 12,
                      left: index == 0 ? 4 : 0,
                    ),
                    child: Hero(
                      tag: 'result_${result.id}',
                      child: HistoryCard(
                        result: result as dynamic,
                        onTap: () => _showResultDetails(context, result),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recent Test Results', onSeeAll: null),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Test Results Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take your first scan to start monitoring',
            style: TextStyle(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DiabetesDetectionScreen(),
              ),
            ),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Take First Scan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    // Show a message since we're using bottom navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Use the History tab in bottom navigation'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showResultDetails(BuildContext context, dynamic result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Test Result Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  context,
                  'Date',
                  DateFormat('MMM dd, yyyy').format(result.timestamp),
                  Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Blood Sugar',
                  '${result.sugarLevel} mg/dL',
                  Icons.bloodtype_rounded,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  'Status',
                  result.isNormal ? 'Normal' : 'High',
                  result.isNormal ? Icons.check_circle : Icons.warning,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quick Actions', onSeeAll: () {}),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            ActionCard(
              icon: Icons.camera_alt_rounded,
              title: 'New Scan',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiabetesDetectionScreen(),
                ),
              ),
            ),
            ActionCard(
              icon: Icons.history_rounded,
              title: 'View History',
              color: Colors.purple,
              onTap: () => _navigateToHistory(context),
            ),
            ActionCard(
              icon: Icons.article_rounded,
              title: 'Health Tips',
              color: Colors.orange,
              onTap: () => _showComingSoon(context),
            ),
            ActionCard(
              icon: Icons.local_hospital_rounded,
              title: 'Doctors',
              color: Colors.red,
              onTap: () => _navigateToDoctors(context),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToHistory(BuildContext context) {
    // Show a message since we're using bottom navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Use the History tab in bottom navigation'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _navigateToDoctors(BuildContext context) {
    // Show a message since we're using bottom navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Use the Doctor tab in bottom navigation'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Health tips coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ArticlesList extends StatelessWidget {
  const ArticlesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Health Articles', onSeeAll: () {}),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              ArticleCard(
                title: 'Managing Diabetes Naturally',
                imageAsset: 'assets/images/healthy_food.jpeg',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              ArticleCard(
                title: 'Exercise Benefits',
                imageAsset: 'assets/images/exercise.jpeg',
                onTap: () {},
              ),
              const SizedBox(width: 12),
              ArticleCard(
                title: 'Blood Sugar Monitoring',
                imageAsset: 'assets/images/blood_sugar.jpeg',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}