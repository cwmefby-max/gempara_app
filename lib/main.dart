
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const GemparaApp());
}

class GemparaApp extends StatefulWidget {
  const GemparaApp({super.key});

  @override
  State<GemparaApp> createState() => _GemparaAppState();
}

class _GemparaAppState extends State<GemparaApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F3F7),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E272E),
        useMaterial3: true,
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

class _MainNavigatorState extends State<MainNavigator> {
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

  late PageController _infoPageController;
  late PageController _vehiclePageController;
  int _currentVirtualPage = 10000;
  Timer? _globalTimer;

  double distanceValue = 1.2;
  String city = "Pati, Jawa Tengah";

  @override
  void initState() {
    super.initState();
    _infoPageController = PageController(initialPage: _currentVirtualPage);
    _vehiclePageController = PageController(initialPage: _currentVirtualPage);

    _globalTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _currentVirtualPage++;
        if (_infoPageController.hasClients) {
          _infoPageController.animateToPage(_currentVirtualPage,
              duration: const Duration(milliseconds: 1200), curve: Curves.easeInOut);
        }
        if (_vehiclePageController.hasClients) {
          _vehiclePageController.animateToPage(_currentVirtualPage,
              duration: const Duration(milliseconds: 900), curve: Curves.easeInOut);
        }
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _globalTimer?.cancel();
    _infoPageController.dispose();
    _vehiclePageController.dispose();
    super.dispose();
  }

  BoxDecoration neuBox(BuildContext context, {bool isPressed = false, double borderRadius = 20}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg = isDark ? const Color(0xFF1E272E) : const Color(0xFFF0F3F7);
    Color shadowDark = isDark 
        ? Colors.black.withOpacity(0.8) 
        : const Color(0xFF9EA7B3).withOpacity(0.5);

    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: shadowDark, 
          offset: isPressed ? const Offset(2, 2) : const Offset(6, 6), 
          blurRadius: isPressed ? 4 : 12,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = widget.isDark;
    String statusKeamanan = distanceValue > 1.0 ? "Siaga" : "Aman";
    int activePageIndex = _currentVirtualPage % 2;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity, height: double.infinity,
            color: isDark ? const Color(0xFF151E24) : const Color(0xFFE5E9F0),
            child: Center(child: Opacity(opacity: 0.05, child: Icon(Icons.map_rounded, size: 200, color: isDark ? Colors.white : Colors.black))),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // --- NAVIGASI UTAMA ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: neuBox(context),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("SmartLock by Mefby", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : const Color(0xFF2C3E50))),
                                Text(city, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Row(
                              children: [
                                _buildTopIcon(isAlarmOn ? Icons.notifications_active : Icons.notifications, isAlarmOn, () => setState(() => isAlarmOn = !isAlarmOn)),
                                const SizedBox(width: 10),
                                _buildTopIcon(isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round, false, widget.onThemeToggle),
                                const SizedBox(width: 10),
                                _buildTopIcon(Icons.videogame_asset_rounded, isIotVisible, () => setState(() => isIotVisible = !isIotVisible)),
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
                            itemBuilder: (context, index) {
                              int realIndex = index % 2;
                              return (realIndex == 0) 
                                ? Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat("SPEED", "0 km/h"), _buildStat("JARAK", "$distanceValue km"), _buildStat("ETA", "4 m"), _buildStat("SUHU", "32°")])
                                : Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildStat("BATTERY", "12.8V"), _buildStat("FUEL", "85%"), _buildStat("SIGNAL", "Online"), _buildStat("STATUS", statusKeamanan)]);
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: activePageIndex == 0 ? Colors.blueAccent : Colors.grey.withOpacity(0.3))),
                            const SizedBox(width: 6),
                            Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: activePageIndex == 1 ? Colors.blueAccent : Colors.grey.withOpacity(0.3))),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (isIotVisible)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: neuBox(context, borderRadius: 30),
                        child: Column(
                          children: [
                            Text("KONTROL UNIT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2, color: isDark ? Colors.white : Colors.black87)),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 15,
                              child: PageView.builder(
                                controller: _vehiclePageController,
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  int realIndex = index % 2;
                                  return Center(child: Text(realIndex == 0 ? "Aerox 155 VVA" : "W 3601 QY", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)));
                                },
                              ),
                            ),
                            const Spacer(),
                            
                            // TOMBOL START ENGINE (Logika Hold)
                            GestureDetector(
                              onTapDown: (_) => setState(() => isStartActive = true),
                              onTapUp: (_) => setState(() => isStartActive = false),
                              onTapCancel: () => setState(() => isStartActive = false),
                              child: Container(
                                width: 150, height: 150,
                                decoration: neuBox(context, isPressed: isStartActive, borderRadius: 80),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bolt_rounded, color: isStartActive ? Colors.greenAccent : (isDark ? Colors.white : Colors.black54), size: 65),
                                    const Text("START ENGINE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildGridBtn(isRelayOn ? "ON" : "OFF", Icons.power_settings_new_rounded, isActive: isRelayOn, onTap: () => setState(() => isRelayOn = !isRelayOn)),
                                // JOK & TANGKI (Logika Hold)
                                _buildHoldBtn("JOK", Icons.archive_rounded, isJokActive, (val) => setState(() => isJokActive = val)),
                                _buildHoldBtn("TANGKI", Icons.local_gas_station_rounded, isTangkiActive, (val) => setState(() => isTangkiActive = val)),
                                _buildGridBtn(isLocked ? "LOCKED" : "UNLOCK", isLocked ? Icons.lock_rounded : Icons.lock_open_rounded, isActive: isLocked, onTap: () => setState(() => isLocked = !isLocked)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (!isIotVisible)
            Positioned(
              bottom: 30, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFloatBtn(Icons.my_location_rounded, () {
                    setState(() => isFocusActive = true);
                    Future.delayed(const Duration(milliseconds: 200), () => setState(() => isFocusActive = false));
                  }, isActive: isFocusActive),
                  const SizedBox(width: 25),
                  _buildFloatBtn(Icons.map_rounded, () => setState(() => isRouteActive = !isRouteActive), isActive: isRouteActive),
                  const SizedBox(width: 25),
                  _buildFloatBtn(Icons.explore_rounded, () {
                    setState(() => isCompassActive = true);
                    Future.delayed(const Duration(milliseconds: 200), () => setState(() => isCompassActive = false));
                  }, isActive: isCompassActive),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: neuBox(context, isPressed: active, borderRadius: 12),
        child: Icon(icon, size: 20, color: active ? const Color(0xFFFF7675) : (widget.isDark ? Colors.white : const Color(0xFF2C3E50))),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: widget.isDark ? Colors.white : const Color(0xFF2C3E50))),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Tombol Grid Biasa (ON/OFF & LOCK)
  Widget _buildGridBtn(String label, IconData icon, {required bool isActive, required VoidCallback onTap}) {
    bool isDark = widget.isDark;
    Color activeColor = (label == "ON" || label == "LOCKED") ? const Color(0xFFFF7675) : Colors.orangeAccent;
    
    // Perbaikan warna teks: Tetap gelap di mode terang walaupun aktif
    Color textColor = isActive 
        ? (isDark ? Colors.white : const Color(0xFF2C3E50)) 
        : (isDark ? Colors.white70 : Colors.black54);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75, height: 85,
        decoration: neuBox(context, isPressed: isActive, borderRadius: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: isActive ? activeColor : (isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  // Widget Baru Khusus Hold (Jok & Tangki)
  Widget _buildHoldBtn(String label, IconData icon, bool isActive, Function(bool) onChanged) {
    bool isDark = widget.isDark;
    Color textColor = isActive 
        ? (isDark ? Colors.white : const Color(0xFF2C3E50)) 
        : (isDark ? Colors.white70 : Colors.black54);

    return GestureDetector(
      onTapDown: (_) => onChanged(true),
      onTapUp: (_) => onChanged(false),
      onTapCancel: () => onChanged(false),
      child: Container(
        width: 75, height: 85,
        decoration: neuBox(context, isPressed: isActive, borderRadius: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: isActive ? Colors.orangeAccent : (isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatBtn(IconData icon, VoidCallback onTap, {bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60, height: 60,
        decoration: neuBox(context, isPressed: isActive, borderRadius: 30),
        child: Icon(icon, size: 24, color: isActive ? Colors.blueAccent : (widget.isDark ? Colors.white : const Color(0xFF2C3E50))),
      ),
    );
  }
}
