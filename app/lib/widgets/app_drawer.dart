import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/input_screen.dart';
import '../screens/tracker_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 24,
      shadowColor: Colors.black,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Color(0xFF333333), width: 1),
          ),
        ),
        child: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FakeNews Killer',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'AI Fact Checker',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF8E8E8E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ─────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Color(0xFF2A2A2A), height: 1),
            ),
            const SizedBox(height: 16),

            // ── Navigation Items ────────────────────────────────────
            _DrawerNavItem(
              icon: Icons.search,
              label: 'Fact Check',
              isActive: currentRoute == 'home',
              onTap: () {
                Navigator.of(context).pop();
                if (currentRoute != 'home') {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const InputScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            _DrawerNavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Misinformation Tracker',
              isActive: currentRoute == 'tracker',
              onTap: () {
                Navigator.of(context).pop();
                if (currentRoute != 'tracker') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TrackerScreen()),
                  );
                }
              },
            ),

            const Spacer(),

            // ── Bottom Divider ──────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Color(0xFF2A2A2A), height: 1),
            ),
            const SizedBox(height: 8),

            // ── Settings ────────────────────────────────────────────
            _DrawerNavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              isActive: false,
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Coming soon',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF1C1C1C),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isActive
                  ? const Color(0xFF2A2A2A)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? Colors.white
                      : const Color(0xFF8E8E8E),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF8E8E8E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
