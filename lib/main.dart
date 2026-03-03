import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const GemparaApp());
}

class GemparaApp extends StatefulWidget {
  const GemparaApp({super.key});

  @override
  State<GemparaApp> createState() => _GemparaAppStage();
}

class _GemparaAppStage extends State<GemparaApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: isDarkMode ? const Color(0xFF1E272E) : const Color(0xFFF0F3F7),
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(brightness: Brightness.light, scaffoldBackgroundColor: const Color(0xFFF0F3F7), useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF1E272E), useMaterial3: true),
      home: MainNavigator(onThemeToggle: toggleTheme, isDark: isDarkMode),
    );
  }
}

class MainNavigator extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  const MainNavigator({super.key, required this.onThemeToggle, required this.isDark});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> with TickerProviderStateMixin {
  bool isIotVisible = true; 
  bool isLocked = false;
  bool isRelayOn = false;
  bool isAlarmOn = false;
  bool isRouteActive = false;
  bool isStartActive = false;
  bool isJokActive = false;
  bool isTangkiActive = false;
  bool isFocusActive = false;
  bool isCompassActive = false;

  late AnimationController _scanController;
  bool _showScanAnim = false;

  late PageController _infoPageController;
  late PageController _vehiclePageController;
  int _currentVirtualPage = 10000;
  Timer? _globalTimer;

  @override
  void initState() {
    super.initState();
    _infoPageController = PageController(initialPage: _currentVirtualPage);
    _vehiclePageController = PageController(initialPage: _currentVirtualPage);

    // Animasi scan dibuat lebih cepat (dari 1500ms ke 800ms)
    _scanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _globalTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _currentVirtualPage++;
        _infoPageController.animateToPage(_currentVirtualPage, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        _vehiclePageController.animateToPage(_currentVirtualPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        setState(() {});
      }
    });
  }

  // Fungsi getar instan
  void _vibrateInstan() {
    HapticFeedback.lightImpact(); // Light impact lebih responsif untuk klik cepat
  }

  void _triggerScan() async {
    setState(() => _showScanAnim = true);
    await _scanController.forward();
    await _scanController.reverse();
    setState(() => _showScanAnim = false);
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _scanController.dispose();
    _infoPageController.dispose();
    _vehiclePageController.dispose();
    super.dispose();
  }

  BoxDecoration neuBox({bool isPressed = false, double borderRadius = 20, bool isDisabled = false}) {
    bool isDark = widget.isDark;
    Color bg = isDark ? const Color(0xFF1E272E) : const Color(0xFFF0F3F7);
    if (isDisabled) bg = bg.withOpacity(0.5);
    
    Color shadowDark = isDark 
        ? Colors.black.withOpacity(0.35) 
        : const Color(0xFF9EA7B3).withOpacity(0.25);

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isDisabled ? [] : [
        BoxShadow(
          color: shadowDark, 
          offset: isPressed ? const Offset(2, 2) : const Offset(5, 5), 
          blurRadius: isPressed ? 4 : 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = widget.isDark;
    int activePageIndex = _currentVirtualPage % 2;

    return Scaffold(
      body: Stack(
        children: [
          Container(width: double.infinity, height: double.infinity, color: isDark ? const Color(0xFF151E24) : const Color(0xFFE5E9F0)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // --- HEADER ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: neuBox(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SmartLock by Mefby", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
                                const Text("Pati, Jawa Tengah", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildTopIcon(isAlarmOn ? Icons.notifications_active : Icons.notifications, isAlarmOn, () {
                                  // Tanpa Getar sesuai instruksi
                                  setState(() => isAlarmOn = true);
                                  Future.delayed(const Duration(milliseconds: 500), () => setState(() => isAlarmOn = false));
                                }),
                                const SizedBox(width: 10),
                                _buildTopIcon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round, false, widget.onThemeToggle),
                                const SizedBox(width: 10),
                                _buildTopIcon(Icons.videogame_asset_rounded, isIotVisible, () {
                                  setState(() => isIotVisible = !isIotVisible);
                                }),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                        SizedBox(
                          height: 60,
                          child: PageView.builder(
                            controller: _infoPageController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => index % 2 == 0 
                                ? Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat("SPEED", "0 km/h"), _buildStat("JARAK", "1.2 km"), _buildStat("ETA", "4 m"), _buildStat("SUHU", "32°")])
                                : Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat("BATTERY", "12.8V"), _buildStat("FUEL", "85%"), _buildStat("SIGNAL", "Online"), _buildStat("STATUS", "Aman")]),
                          ),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(activePageIndex == 0), const SizedBox(width: 6), _buildDot(activePageIndex == 1)]),
                      ],
                    ),
                  ),

                  // --- KONTROL UNIT (FULL PANJANG) ---
                  Expanded(
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                            decoration: neuBox(borderRadius: 30),
                            child: Column(
                              children: [
                                // Ukuran teks diperkecil
                                Text("KONTROL UNIT", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: isDark ? Colors.white70 : Colors.black54)),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 15,
                                  child: PageView.builder(
                                    controller: _vehiclePageController,
                                    scrollDirection: Axis.vertical,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) => Center(child: Text(index % 2 == 0 ? "Aerox 155 VVA" : "W 3601 QY", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                                const Spacer(),
                                _buildStartButton(),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(child: _buildVerticalGridBtn(isRelayOn ? "ON" : "OFF", Icons.power_settings_new_rounded, isRelayOn, () {
                                      _vibrateInstan(); // Getar Instan
                                      setState(() => isRelayOn = !isRelayOn);
                                      if (isRelayOn) _triggerScan();
                                    })),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          _buildHoldBtn("JOK", Icons.archive_rounded, isJokActive, isRelayOn, (val) { 
                                            if(!isRelayOn) { 
                                              if(val) _vibrateInstan(); // Getar Instan saat mulai tekan
                                              setState(() => isJokActive = val); 
                                            } 
                                          }),
                                          const SizedBox(height: 15),
                                          _buildHoldBtn("TANGKI", Icons.local_gas_station_rounded, isTangkiActive, isRelayOn, (val) { 
                                            if(!isRelayOn) { 
                                              if(val) _vibrateInstan(); // Getar Instan saat mulai tekan
                                              setState(() => isTangkiActive = val); 
                                            } 
                                          }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(child: _buildVerticalGridBtn(isLocked ? "LOCKED" : "UNLOCK", isLocked ? Icons.lock_rounded : Icons.lock_open_rounded, isLocked, () {
                                      if(!isRelayOn) { 
                                        _vibrateInstan(); // Getar Instan
                                        setState(() => isLocked = !isLocked); 
                                      }
                                    }, isDisabled: isRelayOn)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      crossFadeState: isIotVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!isIotVisible)
            Positioned(
              bottom: 40, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFloatBtn(Icons.my_location_rounded, () { setState(() => isFocusActive = true); Future.delayed(const Duration(milliseconds: 200), () => setState(() => isFocusActive = false)); }, isActive: isFocusActive),
                  const SizedBox(width: 25),
                  _buildFloatBtn(Icons.map_rounded, () { setState(() => isRouteActive = !isRouteActive); }, isActive: isRouteActive),
                  const SizedBox(width: 25),
                  _buildFloatBtn(Icons.explore_rounded, () { setState(() => isCompassActive = true); Future.delayed(const Duration(milliseconds: 200), () => setState(() => isCompassActive = false)); }, isActive: isCompassActive),
                ],
              ),
            )
        ],
      ),
    );
  }

  // --- WIDGETS ---
  Widget _buildStartButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_showScanAnim)
          AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              return SizedBox(
                width: 170, height: 170,
                child: CustomPaint(painter: DottedCirclePainter(progress: _scanController.value)),
              );
            },
          ),
        GestureDetector(
          onTapDown: (_) { 
            if(isRelayOn) { 
              _vibrateInstan(); // Getar Instan
              setState(() => isStartActive = true); 
            } 
          },
          onTapUp: (_) => setState(() => isStartActive = false),
          onTapCancel: () => setState(() => isStartActive = false),
          child: Opacity(
            opacity: isRelayOn ? 1.0 : 0.4,
            child: Container(
              width: 140, height: 140,
              decoration: neuBox(isPressed: isStartActive, borderRadius: 80, isDisabled: !isRelayOn),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: isStartActive ? Colors.greenAccent : (widget.isDark ? Colors.white : Colors.black54), size: 60),
                  const Text("START ENGINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalGridBtn(String label, IconData icon, bool isActive, VoidCallback onTap, {bool isDisabled = false}) {
    return GestureDetector(
      onTapDown: (_) { if(!isDisabled) onTap(); }, // Menggunakan TapDown agar getar & feedback visual instan
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          height: 125,
          decoration: neuBox(isPressed: isActive, borderRadius: 20, isDisabled: isDisabled),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: isActive ? const Color(0xFFFF7675) : (widget.isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 10),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF2C3E50))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHoldBtn(String label, IconData icon, bool isActive, bool isDisabled, Function(bool) onChanged) {
    return GestureDetector(
      onTapDown: (_) => onChanged(true),
      onTapUp: (_) => onChanged(false),
      onTapCancel: () => onChanged(false),
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          height: 55, width: double.infinity,
          decoration: neuBox(isPressed: isActive, borderRadius: 15, isDisabled: isDisabled),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isActive ? Colors.orangeAccent : (widget.isDark ? Colors.white70 : Colors.black54)),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.isDark ? Colors.white : const Color(0xFF2C3E50))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(width: 42, height: 42, decoration: neuBox(isPressed: active, borderRadius: 12), child: Icon(icon, size: 20, color: active ? const Color(0xFFFF7675) : (widget.isDark ? Colors.white : const Color(0xFF2C3E50)))),
  );

  Widget _buildDot(bool active) => Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? Colors.blueAccent : Colors.grey.withOpacity(0.3)));
  Widget _buildStat(String label, String value) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: widget.isDark ? Colors.white : const Color(0xFF2C3E50))), Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold))]);
  Widget _buildFloatBtn(IconData icon, VoidCallback onTap, {required bool isActive}) => GestureDetector(onTap: onTap, child: Container(width: 60, height: 60, decoration: neuBox(isPressed: isActive, borderRadius: 30), child: Icon(icon, size: 24, color: isActive ? Colors.blueAccent : (widget.isDark ? Colors.white : const Color(0xFF2C3E50)))));
}

class DottedCirclePainter extends CustomPainter {
  final double progress;
  DottedCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double radius = size.width / 2;
    int dotsCount = 40;
    double currentArc = 2 * math.pi * progress;

    for (int i = 0; i < dotsCount; i++) {
      double angle = (2 * math.pi / dotsCount) * i;
      if (angle <= currentArc) {
        double x = radius + radius * math.cos(angle - math.pi / 2);
        double y = radius + radius * math.sin(angle - math.pi / 2);
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DottedCirclePainter oldDelegate) => oldDelegate.progress != progress;
}
