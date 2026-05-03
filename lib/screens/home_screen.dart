import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../widgets/upload_panel.dart';
import '../widgets/quiz_view.dart';
import '../widgets/summary_view.dart';
import '../widgets/chat_view.dart';
import '../widgets/insights_view.dart';
import '../widgets/neural_background.dart';

enum DocBrainTab { ask, quiz, summary, insights }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DocBrainTab _activeTab = DocBrainTab.ask;
  bool _sidebarOpen = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: NeuralBackground()),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DocBrainTheme.bgDeep.withOpacity(0.92),
                    DocBrainTheme.bgDeep.withOpacity(0.85),
                    const Color(0xFF0A0F1E).withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _TopBar(
                isMobile: isMobile,
                onMenuTap: () => setState(() => _sidebarOpen = !_sidebarOpen),
              ),
              Expanded(
                child: isMobile
                    ? _MobileLayout(
                        activeTab: _activeTab,
                        onTabChange: (t) => setState(() => _activeTab = t),
                      )
                    : _DesktopLayout(
                        activeTab: _activeTab,
                        onTabChange: (t) => setState(() => _activeTab = t),
                        sidebarOpen: _sidebarOpen,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onMenuTap;

  const _TopBar({required this.isMobile, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: DocBrainTheme.bgCard.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: DocBrainTheme.neonCyan.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DocBrainTheme.neonCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: DocBrainTheme.neonCyan.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: DocBrainTheme.neonCyan.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: DocBrainTheme.neonCyan, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DOCBRAIN',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: DocBrainTheme.textPrimary,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    'AI Study Assistant',
                    style: TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 11,
                      color: DocBrainTheme.neonCyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
          const Spacer(),
          Row(
            children: [
              _StatusDot(color: DocBrainTheme.neonGreen, label: 'AI ONLINE'),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DocBrainTheme.bgCardLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: DocBrainTheme.borderGlow),
                  ),
                  child: Icon(
                    isMobile ? Icons.menu : Icons.view_sidebar_outlined,
                    color: DocBrainTheme.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  final Color color;
  final String label;
  const _StatusDot({required this.color, required this.label});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3 + _ctrl.value * 0.4),
                  blurRadius: 6 + _ctrl.value * 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          widget.label,
          style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 9,
              color: widget.color,
              letterSpacing: 1.5),
        ),
      ],
    );
  }
}

// ─── Desktop Layout ───────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final DocBrainTab activeTab;
  final Function(DocBrainTab) onTabChange;
  final bool sidebarOpen;

  const _DesktopLayout({
    required this.activeTab,
    required this.onTabChange,
    required this.sidebarOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Sidebar: always has its own independent scroll ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: sidebarOpen ? 340 : 0,
          child: sidebarOpen
              ? Container(
                  decoration: BoxDecoration(
                    color: DocBrainTheme.bgCard.withOpacity(0.8),
                    border: Border(
                        right: BorderSide(color: DocBrainTheme.borderGlow)),
                  ),
                  child: const SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: UploadPanel(),
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Right panel ──
        Expanded(
          child: Column(
            children: [
              _TabBar(activeTab: activeTab, onTabChange: onTabChange),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: DocBrainTheme.bgCard.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: DocBrainTheme.borderGlow),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _ContentArea(activeTab: activeTab),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Mobile Layout ────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final DocBrainTab activeTab;
  final Function(DocBrainTab) onTabChange;

  const _MobileLayout({required this.activeTab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabBar(activeTab: activeTab, onTabChange: onTabChange),
        Expanded(child: _ContentArea(activeTab: activeTab, isMobile: true)),
      ],
    );
  }
}

// ─── Content Area — THE KEY FIX ──────────────────────────────────────────────
//
//  ChatView  →  fills the box; it owns its internal ListView (messages) +
//               a pinned TextField at the bottom via Column + Expanded.
//               Do NOT wrap it in SingleChildScrollView or it breaks.
//
//  All other tabs  →  content can be arbitrarily long, so wrap with
//               SingleChildScrollView so the user can scroll down.
//
class _ContentArea extends StatelessWidget {
  final DocBrainTab activeTab;
  final bool isMobile;

  const _ContentArea({required this.activeTab, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    if (activeTab == DocBrainTab.ask) {
      // ChatView manages its own scroll + pinned input — give it the full space.
      return const ChatView();
    }

    // For every other tab, scroll the content freely.
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: switch (activeTab) {
        DocBrainTab.quiz => const QuizView(),
        DocBrainTab.summary => const SummaryView(),
        DocBrainTab.insights => const InsightsView(),
        DocBrainTab.ask => const SizedBox.shrink(), // unreachable
      },
    );
  }
}

// ─── Tab Bar ──────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final DocBrainTab activeTab;
  final Function(DocBrainTab) onTabChange;

  const _TabBar({required this.activeTab, required this.onTabChange});

  static const _tabs = [
    (
      DocBrainTab.ask,
      'ASK AI',
      Icons.chat_bubble_outline_rounded,
      DocBrainTheme.neonGreen
    ),
    (DocBrainTab.quiz, 'MCQs', Icons.quiz_rounded, DocBrainTheme.neonPink),
    (
      DocBrainTab.summary,
      'SUMMARY',
      Icons.auto_awesome_rounded,
      DocBrainTheme.neonCyan
    ),
    (
      DocBrainTab.insights,
      'INSIGHTS',
      Icons.lightbulb_outline_rounded,
      DocBrainTheme.neonOrange
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: DocBrainTheme.bgCard.withOpacity(0.6),
        border: Border(bottom: BorderSide(color: DocBrainTheme.borderGlow)),
      ),
      child: Row(
        children: [
          for (final (tab, label, icon, color) in _tabs) ...[
            _Tab(
              label: label,
              icon: icon,
              color: color,
              isActive: activeTab == tab,
              onTap: () => onTabChange(tab),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color.withOpacity(0.6) : Colors.transparent,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12)]
              : [],
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive ? color : DocBrainTheme.textSecondary,
                size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Exo 2',
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? color : DocBrainTheme.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
