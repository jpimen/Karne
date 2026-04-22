// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../../models/index.dart';
import '../index.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  static const Color _gold = Color(0xFFD4A017);
  static const Color _dark = Color(0xFF111111);
  static const Color _card = Color(0xFF1C1C1E);
  static const Color _cardBorder = Color(0xFF2C2C2E);

  late AnimationController _heroCtrl;
  late Animation<double> _heroAnim;

  List<TrainingProgram> _programs = [];
  Map<String, dynamic> _dashData = {};
  bool _loading = true;
  int _selectedNav = 0;

  final List<String> _quotes = [
    '"The only bad workout is the one that didn\'t happen."',
    '"Strength does not come from the body. It comes from the will of the soul."',
    '"The pain you feel today will be the strength you feel tomorrow."',
    '"Every rep is a deposit into your future self."',
    '"Don\'t limit your challenges. Challenge your limits."',
  ];

  late String _todayQuote;

  @override
  void initState() {
    super.initState();
    _todayQuote = _quotes[DateTime.now().day % _quotes.length];

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _heroAnim = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroCtrl.forward();

    _loadData();
  }

  void _showGetLinkDialog() {
    const appLink = 'https://thelaboratory.app/join';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.link_rounded, color: _gold, size: 20),
            SizedBox(width: 8),
            Text('GET LINK', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share this link to invite others:', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gold.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(appLink, style: TextStyle(color: _gold, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Link copied to clipboard!'),
                          backgroundColor: _gold,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: const Icon(Icons.copy_rounded, color: _gold, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white38, letterSpacing: 1)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('SHARE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    final api = context.read<AppProvider>().apiService;
    try {
      final programs = await api.getPrograms();
      final dash = await api.getDashboard().catchError((_) => <String, dynamic>{});
      if (mounted) {
        setState(() {
          _programs = programs;
          _dashData = dash;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AppProvider>().userName ?? 'Athlete';
    return Scaffold(
      backgroundColor: _dark,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _gold))
          : FadeTransition(
              opacity: _heroAnim,
              child: _buildBody(userName),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(String userName) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(userName),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _motivationCard(),
              const SizedBox(height: 20),
              _sectionTitle('YOUR STATS'),
              const SizedBox(height: 12),
              _statsRow(),
              const SizedBox(height: 20),
              _sectionTitle('ACTIVE PROGRAM'),
              const SizedBox(height: 12),
              _activeProgramCard(),
              const SizedBox(height: 20),
              _sectionTitle('STRENGTH METRICS'),
              const SizedBox(height: 12),
              _strengthMetrics(),
              const SizedBox(height: 20),
              _sectionTitle('MUSCLE GROUP FOCUS'),
              const SizedBox(height: 12),
              _muscleGroupGrid(),
              const SizedBox(height: 20),
              _sectionTitle('TRAINING INFO'),
              const SizedBox(height: 12),
              _trainingInfoCards(),
            ]),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(String userName) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: _dark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1200), _dark],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good ${_greeting()},',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                  Text(userName.toUpperCase(),
                      style: TextStyle(
                          color: _gold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ],
              ),
              const Spacer(),
              _avatarWidget(userName),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: TextButton.icon(
            onPressed: _showGetLinkDialog,
            icon: const Icon(Icons.link_rounded, size: 16, color: Colors.black),
            label: const Text(
              'GET LINK',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: _gold,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _avatarWidget(String name) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [_gold, Color(0xFFB8860B)]),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Center(
        child: Text(name[0].toUpperCase(),
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _motivationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2a1f00), Color(0xFF1a1500)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.08), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.bolt, color: _gold, size: 18),
            SizedBox(width: 6),
            Text('DAILY MOTIVATION',
                style: TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ]),
          SizedBox(height: 12),
          Text(_todayQuote,
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic, height: 1.5)),
          SizedBox(height: 8),
          Text('Let\'s crush today!',
              style: TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _statsRow() {
    final totalPrograms = _programs.length;
    final totalWeeks = _programs.fold<int>(0, (sum, p) => sum + p.weekTotal);
    final currentWeek = _programs.isNotEmpty ? _programs.first.weekCurrent : 0;

    return Row(
      children: [
        Expanded(child: _statCard('PROGRAMS', '$totalPrograms', Icons.layers_outlined, _gold)),
        SizedBox(width: 10),
        Expanded(child: _statCard('TOTAL WEEKS', '$totalWeeks', Icons.calendar_month_outlined, Color(0xFF4FC3F7))),
        SizedBox(width: 10),
        Expanded(child: _statCard('CURRENT WEEK', '$currentWeek', Icons.trending_up, Color(0xFF81C784))),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _activeProgramCard() {
    if (_programs.isEmpty) {
      return _emptyCard('No active program. Create one to get started!', Icons.add_circle_outline);
    }
    final p = _programs.first;
    final progress = p.weekTotal > 0 ? p.weekCurrent / p.weekTotal : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(p.name,
                  style: TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ),
            _typeBadge(p.programType),
          ]),
          SizedBox(height: 14),
          Row(children: [
            Text('Week ${p.weekCurrent}',
                style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
            Text(' of ${p.weekTotal}',
                style: TextStyle(color: Colors.white54)),
          ]),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Color(0xFF2C2C2E),
              valueColor: AlwaysStoppedAnimation<Color>(_gold),
              minHeight: 8,
            ),
          ),
          SizedBox(height: 10),
          Row(children: [
            Icon(Icons.fitness_center, size: 14, color: Colors.white38),
            SizedBox(width: 4),
            Text('${p.days.length} training days/week',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProgramListScreen())),
              child: Text('VIEW →',
                  style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    final colors = {
      'hypertrophy': Color(0xFF7B61FF),
      'strength': Color(0xFFFF6B6B),
      'powerlifting': Color(0xFFFF9500),
    };
    final c = colors[type.toLowerCase()] ?? _gold;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(type.toUpperCase(),
          style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _strengthMetrics() {
    final metrics = [
      {'lift': 'SQUAT', 'weight': '—', 'icon': Icons.airline_seat_legroom_extra},
      {'lift': 'BENCH', 'weight': '—', 'icon': Icons.fitness_center},
      {'lift': 'DEADLIFT', 'weight': '—', 'icon': Icons.arrow_upward},
      {'lift': 'OHP', 'weight': '—', 'icon': Icons.expand_less},
    ];

    // Try to pull from dash data if available
    final lifts = _dashData['lifts'] as Map<String, dynamic>?;
    if (lifts != null) {
      for (var m in metrics) {
        final key = (m['lift'] as String).toLowerCase();
        if (lifts.containsKey(key)) m['weight'] = '${lifts[key]} kg';
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2),
      itemCount: metrics.length,
      itemBuilder: (_, i) {
        final m = metrics[i];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(m['icon'] as IconData, color: _gold, size: 22),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(m['weight'] as String,
                      style: TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(m['lift'] as String,
                      style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.2)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _muscleGroupGrid() {
    final groups = [
      {'name': 'CHEST', 'icon': '💪', 'color': Color(0xFFFF6B6B)},
      {'name': 'BACK', 'icon': '🔙', 'color': Color(0xFF4FC3F7)},
      {'name': 'LEGS', 'icon': '🦵', 'color': Color(0xFF81C784)},
      {'name': 'SHOULDERS', 'icon': '🏋️', 'color': Color(0xFFFFB74D)},
      {'name': 'ARMS', 'icon': '💯', 'color': Color(0xFFCE93D8)},
      {'name': 'CORE', 'icon': '⚡', 'color': _gold},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final g = groups[i];
        final color = g['color'] as Color;
        return Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(g['icon'] as String, style: TextStyle(fontSize: 22)),
              SizedBox(height: 4),
              Text(g['name'] as String,
                  style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        );
      },
    );
  }

  Widget _trainingInfoCards() {
    final tips = [
      {
        'title': 'Progressive Overload',
        'body': 'Increase weight or reps each session to stimulate muscle growth.',
        'icon': Icons.trending_up,
        'color': Color(0xFF81C784),
      },
      {
        'title': 'Rest & Recovery',
        'body': 'Muscles grow during rest. Aim for 7–9 hours of sleep per night.',
        'icon': Icons.bedtime_outlined,
        'color': Color(0xFF7B61FF),
      },
      {
        'title': 'RPE Training',
        'body': 'Rate of Perceived Exertion helps gauge effort. Leave 1–3 reps in reserve.',
        'icon': Icons.speed,
        'color': Color(0xFFFF9500),
      },
      {
        'title': 'Nutrition Matters',
        'body': 'Hit your protein goals. Aim for 1.6–2.2g of protein per kg of bodyweight.',
        'icon': Icons.restaurant_outlined,
        'color': Color(0xFF4FC3F7),
      },
    ];

    return Column(
      children: tips.map((t) {
        final color = t['color'] as Color;
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(t['icon'] as IconData, color: color, size: 22),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t['title'] as String,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(height: 3),
                    Text(t['body'] as String,
                        style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyCard(String msg, IconData icon) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(children: [
        Icon(icon, color: Colors.white24, size: 40),
        SizedBox(height: 12),
        Text(msg, style: TextStyle(color: Colors.white38, fontSize: 13), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(children: [
      Container(width: 3, height: 16, color: _gold, margin: EdgeInsets.only(right: 8)),
      Text(title,
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
    ]);
  }

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
      {'icon': Icons.layers_outlined, 'label': 'Programs'},
      {'icon': Icons.bar_chart_outlined, 'label': 'Stats'},
      {'icon': Icons.person_outline, 'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF161616),
        border: Border(top: BorderSide(color: _cardBorder)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == _selectedNav;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedNav = i);
                    if (i == 1) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ProgramListScreen()));
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData,
                          color: active ? _gold : Colors.white38,
                          size: 22),
                      SizedBox(height: 3),
                      Text(item['label'] as String,
                          style: TextStyle(
                              color: active ? _gold : Colors.white38,
                              fontSize: 10,
                              fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}


