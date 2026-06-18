import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/home_bloc/home_bloc.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../views/sos/sos_listener.dart';
import '../../views/sos/sos_button.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(HomeUserLoaded()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is HomeJoinRequestSent) {
          context.read<HomeBloc>().add(HomeUserLoaded());
        }
      },
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return const Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is HomeUserActive) return _NormalHome(user: state.user);
        if (state is HomeUserPending)
          return _JoinRequestScreen(isPending: true);
        if (state is HomeUserRemoved)
          return _JoinRequestScreen(isPending: false);
        return const Scaffold(
          backgroundColor: AppColors.surface,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      },
    );
  }
}

//  Normal Home

class _NormalHome extends StatelessWidget {
  final UserModel user;
  const _NormalHome({required this.user});

  @override
  Widget build(BuildContext context) {
    return SosListener(
      currentUser: user,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context),
                _GreetingCard(user: user),
                const SizedBox(height: 20),
                _QuickStats(user: user),
                const SizedBox(height: 28),
                _SectionHeader(label: 'Quick Access'),
                const SizedBox(height: 14),
                _NavGrid(user: user),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          // app logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),

              boxShadow: AppColors.cardShadow,
            ),
            child: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          Spacer(),
          FutureBuilder<String?>(
            future: FirestoreService.getFlatName(user.flatId),
            builder: (context, snap) {
              return Text(
                snap.data ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              );
            },
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile');
              // ignore: use_build_context_synchronously
              context.read<HomeBloc>().add(HomeUserLoaded());
            },
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadow,
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final UserModel user;
  const _GreetingCard({required this.user});

  String get _greeting {
    final h = DateTime.now().hour;
    final m = DateTime.now().minute;
    if (h >= 5 && h < 12) return 'Good Morning';
    if (h >= 12 && h < 16) return 'Good Noon';
    if (h == 16 || (h == 18 && m <= 30) || h == 17) return 'Good Afternoon';
    if ((h == 18 && m > 30) || h == 19 || (h == 20 && m < 30))
      return 'Good Evening';
    return 'Good Night';
  }

  IconData get _greetingIconData {
    final h = DateTime.now().hour;
    final m = DateTime.now().minute;
    if (h >= 5 && h < 12) return Icons.wb_sunny_rounded;
    if (h >= 12 && h < 16) return Icons.wb_cloudy_rounded;
    if (h == 16 || h == 17 || (h == 18 && m <= 30))
      return Icons.wb_twilight_rounded;
    if ((h == 18 && m > 30) || h == 19 || (h == 20 && m < 30))
      return Icons.location_city_rounded;
    return Icons.nightlight_round;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,

        borderRadius: BorderRadius.circular(20),

        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _greetingIconData,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _greeting,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (user.isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 12, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final UserModel user;
  const _QuickStats({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Today',
              value: DateFormat('dd MMM').format(DateTime.now()),
              icon: Icons.calendar_today_rounded,
              color: AppColors.info,
              bgColor: AppColors.info.withValues(alpha: 0.08),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StreamBuilder(
              stream: FirestoreService.getMembers(user.flatId),
              builder: (context, snap) {
                final count = snap.data?.length ?? 0;
                return _StatCard(
                  label: 'Members',
                  value: '$count',
                  icon: Icons.people_rounded,
                  color: AppColors.success,
                  bgColor: AppColors.success.withValues(alpha: 0.08),
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: StreamBuilder(
              stream: FirestoreService.getTasks(user.flatId),
              builder: (context, snap) {
                final tasks = snap.data ?? [];

                final myPending = tasks
                    .where(
                      (t) =>
                          t.assignedTo.contains(user.uid) &&
                          !t.completedBy.contains(user.uid),
                    )
                    .length;
                return _StatCard(
                  label: 'Pending',
                  value: '$myPending',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.warning,
                  bgColor: AppColors.warning.withValues(alpha: 0.08),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),

        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavGrid extends StatelessWidget {
  final UserModel user;
  const _NavGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.restaurant_rounded,
        label: 'Meals',
        route: '/meal',
        color: Colors.white,
      ),
      _NavItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Expenses',
        route: '/expense',
        color: Colors.white,
      ),
      _NavItem(
        icon: Icons.task_alt_rounded,
        label: 'Tasks',
        route: '/task',
        color: Colors.white,
      ),
      _NavItem(
        icon: Icons.chat_bubble_rounded,
        label: 'Chat',
        route: '/chat-list',
        color: Colors.white,
      ),
      _NavItem(
        icon: Icons.people_rounded,
        label: 'Members',
        route: '/profile',
        color: Colors.white,
      ),
      _NavItem(
        icon: Icons.campaign_rounded,
        label: 'Notices',
        route: '/notice-list',
        color: Colors.white,
      ),
      _NavItem(
        icon: Icons.shopping_cart_rounded,
        label: 'Bazar',
        route: '/bazar-list',
        color: Colors.white,
      ),
      _NavItem(
        icon: Icons.history_rounded,
        label: 'Activity',
        route: '/activity',
        color: Colors.white,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
        children: [
          ...items.map((item) => _NavTile(item: item)),
          SosButton(currentUser: user),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  const _NavTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),

          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(item.icon, color: item.color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Join Request Screen

class _JoinRequestScreen extends StatefulWidget {
  final bool isPending;
  const _JoinRequestScreen({required this.isPending});

  @override
  State<_JoinRequestScreen> createState() => _JoinRequestScreenState();
}

class _JoinRequestScreenState extends State<_JoinRequestScreen> {
  final _flatCodeCtrl = TextEditingController();

  @override
  void dispose() {
    _flatCodeCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _flatCodeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Flat Code দাও')));
      return;
    }
    context.read<HomeBloc>().add(HomeJoinRequestSubmitted(code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Row(
            children: [
              const SizedBox(width: 23),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bachelor Flat',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.black),
              tooltip: 'Sign out',
              onPressed: () async {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
            const SizedBox(width: 7),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: widget.isPending
                ? _buildWaitingView()
                : _buildJoinView(context),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.secondaryFaint,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            size: 48,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Waiting for Approval',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'তোমার join request পাঠানো হয়েছে।\nAdmin approve করলে সব access পাবে।',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // status card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.secondaryFaint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Request pending review...',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinView(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final loading = state is HomeLoading;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryFaint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'কোনো Flat-এ নেই',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Flat Code দিয়ে join request পাঠাও।',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // field label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Flat Code',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _flatCodeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'যেমন: FLAT-A3X9',
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.vpn_key_outlined,
                    size: 20,
                    color: AppColors.textHint,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Join Request পাঠাও',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
