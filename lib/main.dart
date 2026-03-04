import 'services/mqtt_service.dart'; // Pastikan nama file ini sesuai (tanpa 's' di service)
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light, 
        scaffoldBackgroundColor: const Color(0xFFF8F9FB), 
        useMaterial3: true
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, 
        scaffoldBackgroundColor: const Color(0xFF1E272E), 
        useMaterial3: true
      ),
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
  // --- INTEGRASI MQTT ---
  final MqttService mqttService = MqttService();
  String connectionStatus = "Connecting...";

  bool isIotVisible = true; 
  bool isLocked = true; 
  bool isRelayOn = false;
  bool isAlarmOn = false;
  bool isRouteActive = false;
  bool isStartActive = false;
  bool isSeatActive = false;
  bool isFuelActive = false;
  bool isFocusActive = false;
  bool isCompassActive = false;

  late AnimationController _scanController;
  late AnimationController _panelController;
  late Animation<Offset> _panelSlideAnimation;
  bool _showScanAnim = false;

  late PageController _infoPageController;
  late PageController _vehiclePageController;
  int _currentVirtualPage = 10000;
  Timer? _globalTimer;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi Koneksi MQTT saat aplikasi dibuka
    _initMqtt();

    _infoPageController = PageController(initialPage: _currentVirtualPage);
    _vehiclePageController = PageController(initialPage: _currentVirtualPage);
    _scanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _panelController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _panelSlideAnimation = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeOutCubic)
    );
    
    if (isIotVisible) _panelController.forward();

    _globalTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _currentVirtualPage++;
        _infoPageController.animateToPage(_currentVirtualPage, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        _vehiclePageController.animateToPage(_currentVirtualPage, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
        setState(() {});
      }
    });
  }

  // Fungsi memulai koneksi MQTT
  void _initMqtt() async {
    bool success = await mqttService.connect();
    setState(() {
      connectionStatus = success ? "Online" : "Offline";
    });
  }

  void _vibrateInstan() {
    HapticFeedback.lightImpact();
  }

  void _triggerScan() async {
    setState(() => _showScanAnim = true);
    await _scanController.forward();
    await _scanController.reverse();
    setState(() => _showScanAnim = false);
  }

  void _toggleIotPanel() {
    _vibrateInstan();
    if (isIotVisible) {
      _panelController.reverse().then((_) => setState(() => isIotVisible = false));
    } else {
      setState(() => isIotVisible = true);
      _panelController.forward();
    }
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _scanController.dispose();
    _panelController.dispose();
    _infoPageController.dispose();
    _vehiclePageController.dispose();
    mqttService.disconnect(); // Putuskan MQTT saat aplikasi ditutup
    super.dispose();
  }

  // --- UI HELPER BOX ---
  BoxDecoration neuBox({bool isPressed = false, double borderRadius = 20, bool isDisabled = false}) {
    bool isDark = widget.isDark;
    Color bg = isDark ? const Color(0xFF1E272E) : const Color(0xFFFDFDFD); 
    if (isDisabled) bg = bg.withAlpha(128);
    Color shadowDark = isDark ? Colors.black.withAlpha(102) : const Color(0xFFD1D9E6).withAlpha(128);

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: isDisabled ? [] : [
        BoxShadow(
          color: shadowDark, 
          offset: isPressed ? const Offset(2, 2) : const Offset(6, 6), 
          blurRadius: isPressed ? 4 : 12,
          spreadRadius: 1,
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
          Container(width: double.infinity, height: double.infinity, color: isDark ? const Color(0xFF151E24) : const Color(0xFFF0F2F5)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // --- HEADER ---
                  Container(
                    decoration: neuBox(),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SmartLock", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
                                const Text("Pati, Jawa Tengah", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildTopIcon(isAlarmOn ? Icons.notifications_active : Icons.notifications, isAlarmOn, () {
                                  _vibrateInstan();
                                  setState(() => isAlarmOn = true);
                                  mqttService.publishPesan('alarm', 'ON'); // KIRIM MQTT
                                  Future.delayed(const Duration(milliseconds: 800), () {
                                    setState(() => isAlarmOn = false);
                                    mqttService.publishPesan('alarm', 'OFF'); // KIRIM MQTT
                                  });
                                }),
                                const SizedBox(width: 10),
                                _buildTopIcon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round, false, widget.onThemeToggle),
                                const SizedBox(width: 10),
                                _buildTopIcon(Icons.videogame_asset_rounded, isIotVisible, _toggleIotPanel),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(color: isDark ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13)),
                        SizedBox(
                          height: 60,
                          child: PageView.builder(
                            controller: _infoPageController,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => index % 2 == 0 
                                ? Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat("SPEED", "0 km/h"), _buildStat("JARAK", "1.2 km"), _buildStat("ETA", "4 m"), _buildStat("SUHU", "32°")])
                                : Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat("BATTERY", "12.8V"), _buildStat("FUEL", "85%"), _buildStat("SIGNAL", connectionStatus), _buildStat("STATUS", "Aman")]),
                          ),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(activePageIndex == 0), const SizedBox(width: 6), _buildDot(activePageIndex == 1)]),
                      ],
                    ),
                  ),

                  // --- KONTROL UNIT ---
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          SlideTransition(
                            position: _panelSlideAnimation,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                                decoration: neuBox(borderRadius: 30),
                                child: Column(
                                  children: [
                                    Text("KONTROL UNIT", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: isDark ? Colors.white70 : Colors.black54)),
                                    const Spacer(),
                                    _buildStartButton(),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        // TOMBOL POWER (RELAY)
                                        Expanded(child: _buildVerticalGridBtn(isRelayOn ? "ON" : "OFF", Icons.power_settings_new_rounded, isRelayOn, () {
                                          if (!isLocked) {
                                            _vibrateInstan();
                                            setState(() => isRelayOn = !isRelayOn);
                                            mqttService.publishPesan('relay', isRelayOn ? 'ON' : 'OFF'); // KIRIM MQTT
                                            if (isRelayOn) _triggerScan();
                                          }
                                        }, isDisabled: isLocked)),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              _buildHoldBtn("SEAT", Icons.archive_rounded, isSeatActive, isLocked, (val) { 
                                                if(!isLocked) { 
                                                   if(val) _vibrateInstan(); 
                                                   setState(() => isSeatActive = val); 
                                                   mqttService.publishPesan('seat', val ? 'OPEN' : 'IDLE'); // KIRIM MQTT
                                                } 
                                              }),
                                              const SizedBox(height: 15),
                                              _buildHoldBtn("FUEL", Icons.local_gas_station_rounded, isFuelActive, isLocked, (val) { 
                                                if(!isLocked) { 
                                                   if(val) _vibrateInstan(); 
                                                   setState(() => isFuelActive = val); 
                                                   mqttService.publishPesan('fuel', val ? 'OPEN' : 'IDLE'); // KIRIM MQTT
                                                } 
                                              }),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        // TOMBOL LOCK
                                        Expanded(child: _buildVerticalGridBtn(isLocked ? "LOCKED" : "UNLOCK", isLocked ? Icons.lock_rounded : Icons.lock_open_rounded, isLocked, () {
                                          if(!isRelayOn) { 
                                            _vibrateInstan(); 
                                            setState(() => isLocked = !isLocked); 
                                            mqttService.publishPesan('lock', isLocked ? '1' : '0'); // KIRIM MQTT
                                          }
                                        }, isDisabled: isRelayOn)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGETS (Sama seperti kode Anda dengan tambahan logic) ---
  Widget _buildStartButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_showScanAnim)
          AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) => SizedBox(
                width: 175, height: 175,
                child: CustomPaint(painter: DottedCirclePainter(progress: _scanController.value)),
            ),
          ),
        GestureDetector(
          onTapDown: (_) { 
            if(isRelayOn) { 
              _vibrateInstan(); 
              setState(() => isStartActive = true); 
              mqttService.publishPesan('engine', 'START'); // KIRIM MQTT
            } 
          },
          onTapUp: (_) {
            setState(() => isStartActive = false);
            mqttService.publishPesan('engine', 'STOP'); // KIRIM MQTT
          },
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
      onTapDown: (_) { if(!isDisabled) onTap(); },
      child: Opacity(
        opacity: isDisabled ? 0.3 : 1.0,
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
        opacity: isDisabled ? 0.3 : 1.0,
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

  Widget _buildDot(bool active) => Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? Colors.blueAccent : Colors.grey.withAlpha(77)));
  Widget _buildStat(String label, String value) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: widget.isDark ? Colors.white : const Color(0xFF2C3E50))), Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold))]);
}

// ... Painter tetap sama seperti kode Anda ...
class DottedCirclePainter extends CustomPainter {
  final double progress;
  DottedCirclePainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.blueAccent.withAlpha(153)..style = PaintingStyle.fill;
    double radius = size.width / 2;
    int dotsCount = 45;
    double currentArc = 2 * math.pi * progress;
    for (int i = 0; i < dotsCount; i++) {
      double angle = (2 * math.pi / dotsCount) * i;
      if (angle <= currentArc) {
        double x = radius + radius * math.cos(angle - math.pi / 2);
        double y = radius + radius * math.sin(angle - math.pi / 2);
        canvas.drawCircle(Offset(x, y), 2.2, paint);
      }
    }
  }
  @override bool shouldRepaint(DottedCirclePainter oldDelegate) => oldDelegate.progress != progress;
}