import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) return const SizedBox.shrink();
        final user = authState.user;

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 28),

                  // User card
                  _buildUserCard(context, user),

                  const SizedBox(height: 24),

                  // Stats
                  _buildStatsCard(context),

                  const SizedBox(height: 24),

                  // Settings section
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsCard(context, user),

                  const SizedBox(height: 24),

                  // About section
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAboutCard(context),

                  const SizedBox(height: 32),

                  // Sign out button
                  _buildSignOutButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.8),
            AppTheme.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: ClipOval(
              child: user.photoUrl != null
                  ? CachedNetworkImage(
                imageUrl: user.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => _buildInitialsAvatar(user),
                errorWidget: (_, __, ___) => _buildInitialsAvatar(user),
              )
                  : _buildInitialsAvatar(user),
            ),
          ),
          const SizedBox(width: 16),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '⚡ TaskFlow Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.1, duration: 400.ms)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildInitialsAvatar(UserModel user) {
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Center(
        child: Text(
          user.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        int total = 0, completed = 0, active = 0;

        if (state is TaskLoaded) {
          total = state.totalCount;
          completed = state.completedCount;
          active = state.activeCount;
        } else if (state is TaskOperationSuccess) {
          total = state.loadedState.totalCount;
          completed = state.loadedState.completedCount;
          active = state.loadedState.activeCount;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Task Statistics',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatItem(context, total.toString(), 'Total',
                      AppTheme.primary, Icons.list_alt_rounded),
                  _buildDivider(),
                  _buildStatItem(context, active.toString(), 'Active',
                      AppTheme.warning, Icons.pending_actions_rounded),
                  _buildDivider(),
                  _buildStatItem(context, completed.toString(), 'Done',
                      AppTheme.success, Icons.check_circle_outline_rounded),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label,
      Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              )),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 60,
      color: AppTheme.divider,
    );
  }

  Widget _buildSettingsCard(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.person_outline,
            label: 'Display Name',
            value: user.name,
            onTap: () => _showEditNameDialog(context, user.name),
          ),
          const Divider(color: AppTheme.divider, height: 1),
          _buildSettingTile(
            context,
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
            onTap: null,
          ),
          const Divider(color: AppTheme.divider, height: 1),
          _buildSettingTile(
            context,
            icon: Icons.lock_reset_outlined,
            label: 'Change Password',
            value: 'Send reset email',
            onTap: () {
              context
                  .read<AuthBloc>()
                  .add(AuthPasswordResetRequested(user.email));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Password reset email sent!'),
                    backgroundColor: AppTheme.success),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildAboutCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.info_outline,
            label: 'App Version',
            value: '1.0.0',
            onTap: null,
          ),
          const Divider(color: AppTheme.divider, height: 1),
          _buildSettingTile(
            context,
            icon: Icons.code,
            label: 'Built with',
            value: 'Flutter + Firebase + BLoC',
            onTap: null,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildSettingTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textHint,
          )),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppTheme.textHint)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showSignOutDialog(context),
        icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
        label: const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.error),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthSignOutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Note: Update name via auth service
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Name updated!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}