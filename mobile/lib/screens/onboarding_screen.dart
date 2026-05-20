import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() =>
    _OnboardingScreenState();
}

class _OnboardingScreenState
  extends State<OnboardingScreen>
  with TickerProviderStateMixin {
  
  final PageController _pageController =
    PageController();
  int _currentPage = 0;
  late AnimationController _celebrationCtrl;
  bool _showConfetti = false;

  final List<Map<String, dynamic>> _pages = [
    {
      'emoji': '⚡',
      'title': 'InsightFlow AI',
      'subtitle': 'Pakistan ka pehla bilingual\nAutonomous Business AI Agent',
      'desc': 'Powered by Google Antigravity\n& Gemini AI | Team FireCoders',
      'color': const Color(0xFF00D4FF),
      'btnText': 'Next →',
    },
    {
      'emoji': '🤖',
      'title': '3 AI Agents',
      'subtitle': 'Gatekeeper → Analyst → Executor',
      'desc': 'Real-time agentic decision making\nwith live Pakistan data',
      'color': const Color(0xFF00E5A0),
      'btnText': 'Next →',
    },
    {
      'emoji': '🇵🇰',
      'title': 'Made for Pakistan',
      'subtitle': '5 Real Pakistan Scenarios',
      'desc': 'Supply Chain • Flood Warning\nLoad Shedding • Financial • Policy\nUrdu + English Support',
      'color': const Color(0xFFFFB800),
      'btnText': '🚀 Get Started',
    },
  ];

  @override
  void initState() {
    super.initState();
    _celebrationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    Future.delayed(const Duration(milliseconds: 300),
      () {
      setState(() => _showConfetti = true);
      Future.delayed(const Duration(seconds: 3), () {
        if(mounted) setState(
          () => _showConfetti = false);
      });
    });
  }

  @override
  void dispose() {
    _celebrationCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if(_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) {
              setState(() {
                _currentPage = i;
                _showConfetti = i == 0;
              });
              if(i == 0) {
                Future.delayed(
                  const Duration(seconds: 3), () {
                  if(mounted) setState(
                    () => _showConfetti = false);
                });
              }
            },
            itemCount: _pages.length,
            itemBuilder: (ctx, i) {
              final page = _pages[i];
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    32, 60, 32, 160),
                  child: Column(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: [
                      // Emoji Circle
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: page['color']
                            .withOpacity(0.1),
                          border: Border.all(
                            color: page['color']
                              .withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: page['color']
                                .withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            page['emoji'],
                            style: const TextStyle(
                              fontSize: 65),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        page['title'],
                        style: GoogleFonts.inter(
                          color: page['color'],
                          fontSize: 30,
                          fontWeight:
                            FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        page['subtitle'],
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE8F4FD),
                          fontSize: 17,
                          fontWeight:
                            FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      
                      // Desc
                      Text(
                        page['desc'],
                        style: GoogleFonts.inter(
                          color: const Color(0xFF7BA7C4),
                          fontSize: 13,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // Feature chips on last page
                      if(i == 2) ...[
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment:
                            WrapAlignment.center,
                          children: [
                            '🏭 Supply Chain',
                            '🌊 Flood Warning',
                            '⚡ Load Shedding',
                            '💰 Financial',
                            '📰 Policy News',
                          ].map((f) => Container(
                            padding: const EdgeInsets
                              .symmetric(
                              horizontal: 12,
                              vertical: 6),
                            decoration:
                              BoxDecoration(
                              color: const Color(0xFFFFB800)
                                .withOpacity(0.1),
                              borderRadius:
                                BorderRadius
                                .circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFFFFB800)
                                .withOpacity(0.3)),
                            ),
                            child: Text(f,
                              style:
                                GoogleFonts.inter(
                                color: const Color(
                                  0xFFFFB800),
                                fontSize: 12,
                                fontWeight:
                                  FontWeight.w500,
                              )),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          // Confetti
          if(_showConfetti)
            _buildConfetti(size),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  32, 16, 32, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment:
                        MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length, (i) =>
                        AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 300),
                          margin: const EdgeInsets
                            .symmetric(horizontal: 4),
                          width: _currentPage == i
                            ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                              ? _pages[_currentPage]
                                ['color']
                              : const Color(0xFF1E3A5F),
                            borderRadius:
                              BorderRadius
                              .circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Next Button
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets
                          .symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _pages[_currentPage]
                                ['color'],
                              const Color(0xFF0066CC),
                            ],
                          ),
                          borderRadius:
                            BorderRadius
                            .circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _pages[
                                _currentPage]
                                ['color']
                                .withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Text(
                          _pages[_currentPage]
                            ['btnText'],
                          textAlign:
                            TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                              FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Skip
                    if(_currentPage < _pages.length - 1)
                      GestureDetector(
                        onTap: _skip,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            color:
                              const Color(0xFF7BA7C4),
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti(Size size) {
    final colors = [
      const Color(0xFF00D4FF),
      const Color(0xFFFFB800),
      const Color(0xFFFF4757),
      const Color(0xFF00E5A0),
      const Color(0xFF9B59B6),
      Colors.white,
    ];
    
    final emojis = ['🎉','🎊','🎈',
      '🎉','🎊','🎈','🎉','🎊','🎈','🎉'];

    return IgnorePointer(
      child: Stack(
        children: [
          // Balloons
          ...emojis.asMap().entries.map((e) =>
            TweenAnimationBuilder<double>(
              key: ValueKey('b${e.key}'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 2500 + e.key * 200),
              builder: (ctx, val, _) => Positioned(
                left: (30.0 + e.key * 
                  (size.width - 60) / 
                  emojis.length),
                bottom: size.height * val - 60,
                child: Opacity(
                  opacity: val < 0.8 
                    ? 1.0 
                    : (1 - val) * 5,
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 28 + 
                        (e.key % 3) * 8.0),
                  ),
                ),
              ),
            ),
          ),

          // Confetti dots
          ...List.generate(40, (i) {
            final startX = 
              (i * 73.0) % size.width;
            return TweenAnimationBuilder<double>(
              key: ValueKey('c$i'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(
                milliseconds: 1800 + i * 40),
              builder: (ctx, val, _) => Positioned(
                left: startX + 
                  (val * 60 - 30) * 
                  (i % 2 == 0 ? 1 : -1),
                top: size.height * val,
                child: Opacity(
                  opacity: val < 0.7 
                    ? 1.0 
                    : (1 - val) * 3.3,
                  child: Container(
                    width: 7 + (i % 4) * 2.0,
                    height: 7 + (i % 4) * 2.0,
                    decoration: BoxDecoration(
                      color: colors[i % 6],
                      shape: i % 2 == 0
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                      borderRadius: i % 2 != 0
                        ? BorderRadius.circular(2)
                        : null,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
