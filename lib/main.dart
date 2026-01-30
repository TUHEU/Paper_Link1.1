import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_helper;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper.instance.database;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PaperLinkApp());
}

class PaperLinkApp extends StatefulWidget {
  const PaperLinkApp({super.key});

  @override
  State<PaperLinkApp> createState() => _PaperLinkAppState();
}

class _PaperLinkAppState extends State<PaperLinkApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Link',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A11CB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          backgroundColor: Color(0xFF6A11CB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A11CB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 0,
          backgroundColor: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: ThemeSwitcher(
        onThemeChanged: toggleTheme,
        child: const SplashScreen(),
      ),
    );
  }
}

class ThemeSwitcher extends InheritedWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode currentTheme;

  const ThemeSwitcher({
    super.key,
    required this.onThemeChanged,
    required super.child,
    this.currentTheme = ThemeMode.light,
  });

  static ThemeSwitcher? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>();
  }

  @override
  bool updateShouldNotify(ThemeSwitcher oldWidget) {
    return oldWidget.currentTheme != currentTheme;
  }
}

// 🔥 SPLASH SCREEN
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Navigate to WelcomePage after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A11CB),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 80,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Paper Link',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Educational Portal & Attendance System',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: _animationController.value,
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Welcome Screen with Single Login Option
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A11CB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.brightness_6,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          final themeSwitcher = ThemeSwitcher.of(context);
                          if (themeSwitcher != null) {
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            themeSwitcher.onThemeChanged(!isDark);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 40,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Paper Link',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black38,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Educational Portal & Attendance System',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign in to continue',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 30),

                    // Single Login Button
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UniversalLoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.login,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap to sign in',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.white70,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Smart Role Detection',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Automatically detects your role based on admin registration',
                            style: TextStyle(
                              color: Colors.white30,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Universal Login Screen - No Permission Requests
class UniversalLoginScreen extends StatefulWidget {
  const UniversalLoginScreen({super.key});

  @override
  State<UniversalLoginScreen> createState() => _UniversalLoginScreenState();
}

class _UniversalLoginScreenState extends State<UniversalLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Auto-enable permissions for all users
    _autoEnablePermissions();
  }

  Future<void> _autoEnablePermissions() async {
    try {
      // Auto-enable location permission
      final locationStatus = await Permission.location.status;
      if (!locationStatus.isGranted) {
        await Permission.location.request();
      }

      // Auto-enable camera permission
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        await Permission.camera.request();
      }

      // Update database for all users with auto-enabled permissions
      final db = await DatabaseHelper.instance.database;
      await db.execute(
        'UPDATE users SET locationPermission = 1, cameraPermission = 1',
      );
    } catch (e) {
      print('Auto-enable permissions error: $e');
    }
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Special admin login
      if (email == 'nadaljunior999@gmail.com' && password == 'Fahdil@1') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'currentUser',
          json.encode({
            'id': 'admin001',
            'email': 'nadaljunior999@gmail.com',
            'firstName': 'Fahdil',
            'lastName': 'Admin',
            'role': 'admin',
            'gpsEnabled': 1,
            'messagingEnabled': 1,
            'locationPermission': 1,
            'cameraPermission': 1,
          }),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(role: 'admin'),
          ),
          (route) => false,
        );
        return;
      }

      final user = await DatabaseHelper.instance.getUserByEmail(email);

      if (user == null || user['password'] != password) {
        setState(() {
          _errorMessage = 'Invalid email or password';
          _isLoading = false;
        });
        return;
      }

      // Auto-enable permissions for this user if not already enabled
      if (user['locationPermission'] != 1 || user['cameraPermission'] != 1) {
        await DatabaseHelper.instance.updateUserPermissions(
          user['id'],
          locationPermission: true,
          cameraPermission: true,
        );
        user['locationPermission'] = 1;
        user['cameraPermission'] = 1;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'currentUser',
        json.encode({
          ...user,
          'gpsEnabled': user['gpsEnabled'] == 1,
          'messagingEnabled': user['messagingEnabled'] == 1,
          'locationPermission': 1,
          'cameraPermission': 1,
        }),
      );

      // Navigate directly to dashboard based on user role
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(role: user['role']),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2D1B69)]
                        : [const Color(0xFF2575FC), const Color(0xFF6A11CB)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.brightness_6,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () {
                            final themeSwitcher = ThemeSwitcher.of(context);
                            if (themeSwitcher != null) {
                              themeSwitcher.onThemeChanged(!isDark);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Icon(
                      Icons.school,
                      size: 80,
                      color: isDark ? Colors.white : Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Paper Link Portal',
                      style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Colors.white70 : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Auto-enabled permissions indicator
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Permissions Auto-Enabled',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            hintText: 'username@paperlink.edu',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: isDark ? Colors.white70 : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_errorMessage != null) const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A11CB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.security,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Smart Login System',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Auto-detects your role from admin registration\n'
                              '• Permissions automatically enabled\n'
                              '• Direct dashboard access',
                              style: TextStyle(
                                color: Colors.white30,
                                fontSize: 11,
                              ),
                            ),
                          ],
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
    );
  }
}

// 🔥 NEW: AI Service Class for Question Generation
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final String _apiKey = 'sk-6ed0aa304660497da3684efa240d8ded';
  final String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  Future<String> generateQuestions({
    required String topic,
    required String subject,
    required String difficulty,
    required int numberOfQuestions,
    required String questionType,
  }) async {
    try {
      final prompt = _buildPrompt(
        topic: topic,
        subject: subject,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
        questionType: questionType,
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert educational assistant specialized in creating high-quality assessment questions.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Service Error: $e');
    }
  }

  Future<String> generatePaperFeedback({
    required String paperTitle,
    required String paperContent,
    required String subject,
  }) async {
    try {
      final prompt =
          '''
Analyze this paper and provide constructive feedback:

Paper Title: $paperTitle
Subject: $subject
Content: $paperContent

Please provide:
1. Overall assessment
2. Strengths
3. Areas for improvement
4. Specific suggestions
5. Grade recommendation (A-F)
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert academic reviewer providing detailed feedback on student papers.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Feedback Error: $e');
    }
  }

  Future<String> answerQuestion({
    required String question,
    required String subject,
    required String context,
  }) async {
    try {
      final prompt =
          '''
Please answer this question:

Subject: $subject
Question: $question
Context: $context

Provide a detailed, accurate answer suitable for educational purposes.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an expert tutor providing clear, educational answers to student questions.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.5,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to answer question: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('AI Answer Error: $e');
    }
  }

  String _buildPrompt({
    required String topic,
    required String subject,
    required String difficulty,
    required int numberOfQuestions,
    required String questionType,
  }) {
    return '''
Generate $numberOfQuestions $difficulty-level $questionType questions about "$topic" for $subject.

Format each question as follows:
1. Question text
2. Multiple choice options (A, B, C, D) if applicable
3. Correct answer
4. Brief explanation

Make the questions educational, clear, and aligned with standard curriculum for $subject.

Topic: $topic
Subject: $subject
Difficulty: $difficulty
Question Type: $questionType
Number of Questions: $numberOfQuestions

Please format the response clearly with numbered questions.
''';
  }
}

// 🔥 NEW: AI Questions Table in Database
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('paperlink.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = path_helper.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Updated version
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table with GPS and messaging settings
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        role TEXT NOT NULL,
        profileImage BLOB,
        createdAt TEXT NOT NULL,
        gpsEnabled INTEGER DEFAULT 0,
        messagingEnabled INTEGER DEFAULT 0,
        locationPermission INTEGER DEFAULT 0,
        cameraPermission INTEGER DEFAULT 0
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId TEXT NOT NULL,
        studentName TEXT NOT NULL,
        studentEmail TEXT NOT NULL,
        classroomId TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        verifiedByGPS INTEGER NOT NULL,
        photoPath TEXT,
        FOREIGN KEY (studentId) REFERENCES users (id)
      )
    ''');

    // Classrooms table
    await db.execute('''
      CREATE TABLE classrooms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        radius REAL NOT NULL
      )
    ''');

    // Papers table (PaperLink feature)
    await db.execute('''
      CREATE TABLE papers (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        studentId TEXT NOT NULL,
        studentName TEXT NOT NULL,
        subject TEXT NOT NULL,
        date TEXT NOT NULL,
        fileSize TEXT,
        status TEXT NOT NULL,
        fileType TEXT,
        fileExtension TEXT,
        abstract TEXT,
        uploadedBy TEXT,
        isPublic INTEGER DEFAULT 0,
        hasFile INTEGER DEFAULT 0,
        grade TEXT,
        feedback TEXT,
        rejectionReason TEXT,
        reviewedDate TEXT,
        fileContent BLOB
      )
    ''');

    // Messages table (PaperLink feature)
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        senderName TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0
      )
    ''');

    // 🔥 NEW: AI Generated Questions table
    await db.execute('''
      CREATE TABLE ai_questions (
        id TEXT PRIMARY KEY,
        topic TEXT NOT NULL,
        subject TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        questionType TEXT NOT NULL,
        numberOfQuestions INTEGER NOT NULL,
        generatedContent TEXT NOT NULL,
        generatedBy TEXT NOT NULL,
        generatedAt TEXT NOT NULL,
        isSaved INTEGER DEFAULT 0,
        FOREIGN KEY (generatedBy) REFERENCES users (id)
      )
    ''');

    // 🔥 NEW: Saved Questions for Users
    await db.execute('''
      CREATE TABLE saved_questions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        questionId TEXT NOT NULL,
        savedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (questionId) REFERENCES ai_questions (id)
      )
    ''');

    // Insert default classrooms
    await db.insert('classrooms', {
      'id': 'room_101',
      'name': 'Classroom 101',
      'latitude': 4.0511,
      'longitude': 9.7679,
      'radius': 50.0,
    });

    await db.insert('classrooms', {
      'id': 'room_102',
      'name': 'Classroom 102',
      'latitude': 4.0512,
      'longitude': 9.7678,
      'radius': 50.0,
    });

    await db.insert('classrooms', {
      'id': 'lab_201',
      'name': 'Computer Lab 201',
      'latitude': 4.0513,
      'longitude': 9.7677,
      'radius': 50.0,
    });

    // Insert admin user with new credentials
    await db.insert('users', {
      'id': 'admin001',
      'email': 'nadaljunior999@gmail.com',
      'password': 'Fahdil@1',
      'firstName': 'Fahdil',
      'lastName': 'Admin',
      'role': 'admin',
      'createdAt': DateTime.now().toString(),
      'gpsEnabled': 1,
      'messagingEnabled': 1,
      'locationPermission': 1,
      'cameraPermission': 1,
    });

    // Insert sample users with all permissions enabled
    await db.insert('users', {
      'id': 'student001',
      'email': 'john@paperlink.edu',
      'password': 'john123',
      'firstName': 'John',
      'lastName': 'Doe',
      'role': 'student',
      'createdAt': DateTime.now().toString(),
      'gpsEnabled': 1,
      'messagingEnabled': 1,
      'locationPermission': 1,
      'cameraPermission': 1,
    });

    await db.insert('users', {
      'id': 'teacher001',
      'email': 'jane@paperlink.edu',
      'password': 'jane123',
      'firstName': 'Jane',
      'lastName': 'Smith',
      'role': 'teacher',
      'createdAt': DateTime.now().toString(),
      'gpsEnabled': 1,
      'messagingEnabled': 1,
      'locationPermission': 1,
      'cameraPermission': 1,
    });

    // Insert sample papers with file content
    final samplePDF = await _getSamplePDF();
    await db.insert('papers', {
      'id': '1',
      'title': 'Introduction to Machine Learning',
      'studentId': 'student001',
      'studentName': 'John Doe',
      'subject': 'Computer Science',
      'date': '2024-01-15',
      'fileSize': '12MB',
      'status': 'approved',
      'fileType': 'PDF',
      'fileExtension': '.pdf',
      'abstract':
          'This paper explores the fundamentals of machine learning algorithms.',
      'uploadedBy': 'student',
      'isPublic': 1,
      'hasFile': 1,
      'grade': 'A',
      'feedback': 'Excellent research work',
      'fileContent': samplePDF,
    });

    final sampleImage = await _getSampleImage();
    await db.insert('papers', {
      'id': '2',
      'title': 'Quantum Physics Research',
      'studentId': 'student001',
      'studentName': 'John Doe',
      'subject': 'Physics',
      'date': '2024-01-10',
      'fileSize': '8MB',
      'status': 'approved',
      'fileType': 'IMAGE',
      'fileExtension': '.jpg',
      'abstract': 'Research on quantum mechanics principles.',
      'uploadedBy': 'student',
      'isPublic': 1,
      'hasFile': 1,
      'grade': 'A+',
      'feedback': 'Outstanding research',
      'fileContent': sampleImage,
    });
  }

  Future<Uint8List> _getSamplePDF() async {
    // Create a simple PDF content for demonstration
    final pdfContent = '''
%PDF-1.4
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj
2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj
3 0 obj
<<
/Type /Page
/Parent 2 0 R
/Resources <<
/Font <<
/F1 4 0 R
>>
>>
/MediaBox [0 0 612 792]
/Contents 5 0 R
>>
endobj
4 0 obj
<<
/Type /Font
/Subtype /Type1
/BaseFont /Helvetica
>>
endobj
5 0 obj
<<
/Length 44
>>
stream
BT
/F1 24 Tf
100 700 Td
(Introduction to Machine Learning) Tj
ET
endstream
endobj
xref
0 6
0000000000 65535 f 
0000000010 00000 n 
0000000053 00000 n 
0000000102 00000 n 
0000000218 00000 n 
0000000262 00000 n 
trailer
<<
/Size 6
/Root 1 0 R
>>
startxref
360
%%EOF
''';
    return Uint8List.fromList(pdfContent.codeUnits);
  }

  Future<Uint8List> _getSampleImage() async {
    // Create a simple image for demonstration
    final imageData = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    );
    return imageData;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for GPS and messaging settings
      await db.execute(
        'ALTER TABLE users ADD COLUMN gpsEnabled INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN messagingEnabled INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN locationPermission INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE users ADD COLUMN cameraPermission INTEGER DEFAULT 0',
      );

      // Update existing users with all permissions enabled
      await db.execute(
        'UPDATE users SET gpsEnabled = 1, messagingEnabled = 1, locationPermission = 1, cameraPermission = 1',
      );
    }

    if (oldVersion < 3) {
      // Add fileContent column to papers table
      await db.execute('ALTER TABLE papers ADD COLUMN fileContent BLOB');
    }

    if (oldVersion < 4) {
      // Add AI questions tables
      await db.execute('''
        CREATE TABLE ai_questions (
          id TEXT PRIMARY KEY,
          topic TEXT NOT NULL,
          subject TEXT NOT NULL,
          difficulty TEXT NOT NULL,
          questionType TEXT NOT NULL,
          numberOfQuestions INTEGER NOT NULL,
          generatedContent TEXT NOT NULL,
          generatedBy TEXT NOT NULL,
          generatedAt TEXT NOT NULL,
          isSaved INTEGER DEFAULT 0,
          FOREIGN KEY (generatedBy) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE saved_questions (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          questionId TEXT NOT NULL,
          savedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id),
          FOREIGN KEY (questionId) REFERENCES ai_questions (id)
        )
      ''');
    }
  }

  // User methods
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    return await db.query('users', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await instance.database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deleteUser(String userId) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'id = ? AND role != ?',
      whereArgs: [userId, 'admin'],
    );
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> updateUserPermissions(
    String userId, {
    bool? gpsEnabled,
    bool? messagingEnabled,
    bool? locationPermission,
    bool? cameraPermission,
  }) async {
    final db = await instance.database;
    final updates = <String, dynamic>{};

    if (gpsEnabled != null) updates['gpsEnabled'] = gpsEnabled ? 1 : 0;
    if (messagingEnabled != null)
      updates['messagingEnabled'] = messagingEnabled ? 1 : 0;
    if (locationPermission != null)
      updates['locationPermission'] = locationPermission ? 1 : 0;
    if (cameraPermission != null)
      updates['cameraPermission'] = cameraPermission ? 1 : 0;

    if (updates.isEmpty) return 0;

    return await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Attendance methods
  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await instance.database;
    return await db.insert('attendance', attendance);
  }

  Future<List<Map<String, dynamic>>> getAllAttendance() async {
    final db = await instance.database;
    return await db.query('attendance', orderBy: 'timestamp DESC');
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(
    String studentId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'attendance',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'timestamp DESC',
    );
  }

  // Classroom methods
  Future<List<Map<String, dynamic>>> getAllClassrooms() async {
    final db = await instance.database;
    return await db.query('classrooms');
  }

  Future<int> insertClassroom(Map<String, dynamic> classroom) async {
    final db = await instance.database;
    return await db.insert('classrooms', classroom);
  }

  Future<int> updateUserProfileImage(
    String userId,
    Uint8List? imageBytes,
  ) async {
    final db = await instance.database;
    return await db.update(
      'users',
      {'profileImage': imageBytes},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Uint8List?> getUserProfileImage(String userId) async {
    final db = await instance.database;
    final results = await db.query(
      'users',
      columns: ['profileImage'],
      where: 'id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty
        ? results.first['profileImage'] as Uint8List?
        : null;
  }

  // Paper methods (PaperLink features)
  Future<int> insertPaper(Map<String, dynamic> paper) async {
    final db = await instance.database;
    return await db.insert('papers', paper);
  }

  Future<List<Map<String, dynamic>>> getAllPapers() async {
    final db = await instance.database;
    return await db.query('papers', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getPendingPapers() async {
    final db = await instance.database;
    return await db.query(
      'papers',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getApprovedPapers() async {
    final db = await instance.database;
    return await db.query(
      'papers',
      where: 'status = ?',
      whereArgs: ['approved'],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPublicPapers() async {
    final db = await instance.database;
    return await db.query(
      'papers',
      where: 'isPublic = ?',
      whereArgs: [1],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserPapers(String userId) async {
    final db = await instance.database;
    return await db.query(
      'papers',
      where: 'studentId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<int> updatePaper(Map<String, dynamic> paper) async {
    final db = await instance.database;
    return await db.update(
      'papers',
      paper,
      where: 'id = ?',
      whereArgs: [paper['id']],
    );
  }

  Future<int> deletePaper(String paperId) async {
    final db = await instance.database;
    return await db.delete('papers', where: 'id = ?', whereArgs: [paperId]);
  }

  Future<Uint8List?> getPaperContent(String paperId) async {
    final db = await instance.database;
    final results = await db.query(
      'papers',
      columns: ['fileContent'],
      where: 'id = ?',
      whereArgs: [paperId],
    );
    return results.isNotEmpty
        ? results.first['fileContent'] as Uint8List?
        : null;
  }

  // Message methods (PaperLink features)
  Future<int> insertMessage(Map<String, dynamic> message) async {
    final db = await instance.database;
    return await db.insert('messages', message);
  }

  Future<List<Map<String, dynamic>>> getMessagesBetween(
    String user1Id,
    String user2Id,
  ) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT * FROM messages 
      WHERE (senderId = ? AND receiverId = ?) 
         OR (senderId = ? AND receiverId = ?)
      ORDER BY timestamp DESC
    ''',
      [user1Id, user2Id, user2Id, user1Id],
    );
  }

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final db = await instance.database;
    final conversations = await db.rawQuery(
      '''
      SELECT DISTINCT 
        CASE 
          WHEN senderId = ? THEN receiverId 
          ELSE senderId 
        END as otherUserId,
        CASE 
          WHEN senderId = ? THEN (SELECT firstName || ' ' || lastName FROM users WHERE id = receiverId)
          ELSE (SELECT firstName || ' ' || lastName FROM users WHERE id = senderId)
        END as otherUserName,
        MAX(timestamp) as lastTimestamp
      FROM messages 
      WHERE senderId = ? OR receiverId = ?
      GROUP BY otherUserId
      ORDER BY lastTimestamp DESC
    ''',
      [userId, userId, userId, userId],
    );
    return conversations;
  }

  Future<int> markMessagesAsRead(String userId, String otherUserId) async {
    final db = await instance.database;
    return await db.update(
      'messages',
      {'isRead': 1},
      where: 'senderId = ? AND receiverId = ? AND isRead = ?',
      whereArgs: [otherUserId, userId, 0],
    );
  }

  Future<int> getUnreadMessageCount(String userId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM messages 
      WHERE receiverId = ? AND isRead = ?
    ''',
      [userId, 0],
    );
    return result.first['count'] as int;
  }

  // 🔥 NEW: AI Question Methods
  Future<int> insertAIQuestion(Map<String, dynamic> question) async {
    final db = await instance.database;
    return await db.insert('ai_questions', question);
  }

  Future<List<Map<String, dynamic>>> getAIQuestionsByUser(String userId) async {
    final db = await instance.database;
    return await db.query(
      'ai_questions',
      where: 'generatedBy = ?',
      whereArgs: [userId],
      orderBy: 'generatedAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllAIQuestions() async {
    final db = await instance.database;
    return await db.query('ai_questions', orderBy: 'generatedAt DESC');
  }

  Future<List<Map<String, dynamic>>> getSavedAIQuestions(String userId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT aq.* FROM ai_questions aq
      INNER JOIN saved_questions sq ON aq.id = sq.questionId
      WHERE sq.userId = ?
      ORDER BY sq.savedAt DESC
    ''',
      [userId],
    );
  }

  Future<int> saveQuestionForUser(String userId, String questionId) async {
    final db = await instance.database;
    return await db.insert('saved_questions', {
      'id': 'saved_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'questionId': questionId,
      'savedAt': DateTime.now().toString(),
    });
  }

  Future<int> unsaveQuestionForUser(String userId, String questionId) async {
    final db = await instance.database;
    return await db.delete(
      'saved_questions',
      where: 'userId = ? AND questionId = ?',
      whereArgs: [userId, questionId],
    );
  }

  Future<bool> isQuestionSaved(String userId, String questionId) async {
    final db = await instance.database;
    final results = await db.query(
      'saved_questions',
      where: 'userId = ? AND questionId = ?',
      whereArgs: [userId, questionId],
    );
    return results.isNotEmpty;
  }

  Future<int> deleteAIQuestion(String questionId) async {
    final db = await instance.database;
    // First delete from saved_questions
    await db.delete(
      'saved_questions',
      where: 'questionId = ?',
      whereArgs: [questionId],
    );
    // Then delete from ai_questions
    return await db.delete(
      'ai_questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
  }
}

// Location Service Class
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.location.request();
      return result.isGranted;
    }
  }

  Future<Position> getCurrentLocation() async {
    final hasPermission = await checkLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<bool> isInClassroom(String classroomId, Position userPosition) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final results = await db.query(
        'classrooms',
        where: 'id = ?',
        whereArgs: [classroomId],
      );

      if (results.isEmpty) return false;

      final classroom = results.first;
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        classroom['latitude'] as double,
        classroom['longitude'] as double,
      );

      return distance <= (classroom['radius'] as double);
    } catch (e) {
      print('Location error: $e');
      return false;
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Location unavailable';
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}

// Camera Service Class
class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  Future<void> initializeCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return photo != null ? File(photo.path) : null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  Future<File?> pickPhotoFromGallery() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return photo != null ? File(photo.path) : null;
    } catch (e) {
      print('Error picking photo: $e');
      return null;
    }
  }

  Future<Uint8List?> compressAndConvertPhoto(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return Uint8List.fromList(bytes);
    } catch (e) {
      print('Error processing photo: $e');
      return null;
    }
  }

  void dispose() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized =>
      _cameraController?.value.isInitialized ?? false;
}

// Paper Viewer Screen
class PaperViewerScreen extends StatelessWidget {
  final Map<String, dynamic> paper;
  final Uint8List? fileContent;

  const PaperViewerScreen({super.key, required this.paper, this.fileContent});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPDF = paper['fileType'] == 'PDF';
    final isImage = paper['fileType'] == 'IMAGE';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color(0xFF6A11CB),
        title: Text(
          paper['title'],
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: fileContent == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 60,
                    color: isDark ? Colors.white : Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No file content available',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )
          : isPDF
          ? _buildPDFViewer(context, fileContent!, paper)
          : isImage
          ? _buildImageViewer(context, fileContent!, isDark)
          : _buildTextPreview(context, paper, isDark),
    );
  }

  Widget _buildPDFViewer(
    BuildContext context,
    Uint8List fileContent,
    Map<String, dynamic> paper,
  ) {
    try {
      final pdfController = PdfController(
        document: PdfDocument.openData(fileContent),
      );
      return PdfView(controller: pdfController, scrollDirection: Axis.vertical);
    } catch (e) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Error loading PDF',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              'Preview available in text format',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImageViewer(
    BuildContext context,
    Uint8List fileContent,
    bool isDark,
  ) {
    return PhotoView(
      imageProvider: MemoryImage(fileContent),
      backgroundDecoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
      ),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2.0,
    );
  }

  Widget _buildTextPreview(
    BuildContext context,
    Map<String, dynamic> paper,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            paper['title'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'By: ${paper['studentName']}',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Subject: ${paper['subject']}',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Date: ${paper['date']}',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Abstract:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  paper['abstract'] ?? 'No abstract available',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (paper['grade'] != null) ...[
            Text(
              'Grade: ${paper['grade']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (paper['feedback'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green.withOpacity(0.1)
                    : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.green : Colors.green.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green : Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    paper['feedback'],
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.green : Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Paper Data Manager (Updated with file viewing)
class PaperDataManager {
  static final PaperDataManager _instance = PaperDataManager._internal();

  factory PaperDataManager() {
    return _instance;
  }

  PaperDataManager._internal();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> addPaper(
    Map<String, dynamic> paper, {
    File? file,
    String? fileType,
  }) async {
    if (file != null) {
      final bytes = await file.readAsBytes();
      paper['fileContent'] = bytes;
    }
    await dbHelper.insertPaper(paper);
  }

  Future<void> updatePaperStatus(
    String paperId,
    String status, {
    String? grade,
    String? feedback,
  }) async {
    final paper = await _getPaperById(paperId);
    if (paper != null) {
      paper['status'] = status;
      if (grade != null) paper['grade'] = grade;
      if (feedback != null) paper['feedback'] = feedback;
      if (status == 'approved') paper['isPublic'] = 1;
      await dbHelper.updatePaper(paper);
    }
  }

  Future<Map<String, dynamic>?> _getPaperById(String paperId) async {
    final papers = await dbHelper.getAllPapers();
    return papers.firstWhere(
      (paper) => paper['id'] == paperId,
      orElse: () => {},
    );
  }

  Future<void> removePaper(String paperId) async {
    await dbHelper.deletePaper(paperId);
  }

  Future<Uint8List?> getPaperContent(String paperId) async {
    return await dbHelper.getPaperContent(paperId);
  }

  Future<List<Map<String, dynamic>>> getPendingPapers() async {
    return await dbHelper.getPendingPapers();
  }

  Future<List<Map<String, dynamic>>> getApprovedPapers() async {
    return await dbHelper.getApprovedPapers();
  }

  Future<List<Map<String, dynamic>>> getPublicPapers() async {
    return await dbHelper.getPublicPapers();
  }

  Future<List<Map<String, dynamic>>> getUserPapers(String userId) async {
    return await dbHelper.getUserPapers(userId);
  }

  Future<void> viewPaper(
    BuildContext context,
    Map<String, dynamic> paper,
  ) async {
    final content = await getPaperContent(paper['id']);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PaperViewerScreen(paper: paper, fileContent: content),
      ),
    );
  }
}

// 🔥 NEW: AI Questions Manager
class AIQuestionManager {
  static final AIQuestionManager _instance = AIQuestionManager._internal();
  factory AIQuestionManager() => _instance;
  AIQuestionManager._internal();

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final AIService aiService = AIService();

  Future<Map<String, dynamic>> generateQuestions({
    required String topic,
    required String subject,
    required String difficulty,
    required int numberOfQuestions,
    required String questionType,
    required String generatedBy,
  }) async {
    try {
      // Generate questions using AI
      final generatedContent = await aiService.generateQuestions(
        topic: topic,
        subject: subject,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
        questionType: questionType,
      );

      // Save to database
      final questionId = 'aiq_${DateTime.now().millisecondsSinceEpoch}';
      final questionData = {
        'id': questionId,
        'topic': topic,
        'subject': subject,
        'difficulty': difficulty,
        'questionType': questionType,
        'numberOfQuestions': numberOfQuestions,
        'generatedContent': generatedContent,
        'generatedBy': generatedBy,
        'generatedAt': DateTime.now().toString(),
        'isSaved': 0,
      };

      await dbHelper.insertAIQuestion(questionData);

      return {
        'success': true,
        'id': questionId,
        'content': generatedContent,
        'message': 'Questions generated successfully!',
      };
    } catch (e) {
      return {'success': false, 'error': 'Failed to generate questions: $e'};
    }
  }

  Future<String> generatePaperFeedback({
    required String paperTitle,
    required String paperContent,
    required String subject,
  }) async {
    try {
      return await aiService.generatePaperFeedback(
        paperTitle: paperTitle,
        paperContent: paperContent,
        subject: subject,
      );
    } catch (e) {
      return 'Unable to generate AI feedback at this time. Error: $e';
    }
  }

  Future<String> answerQuestion({
    required String question,
    required String subject,
    required String context,
  }) async {
    try {
      return await aiService.answerQuestion(
        question: question,
        subject: subject,
        context: context,
      );
    } catch (e) {
      return 'Unable to answer question at this time. Error: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getUserQuestions(String userId) async {
    return await dbHelper.getAIQuestionsByUser(userId);
  }

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    return await dbHelper.getAllAIQuestions();
  }

  Future<List<Map<String, dynamic>>> getSavedQuestions(String userId) async {
    return await dbHelper.getSavedAIQuestions(userId);
  }

  Future<bool> saveQuestion(String userId, String questionId) async {
    try {
      await dbHelper.saveQuestionForUser(userId, questionId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unsaveQuestion(String userId, String questionId) async {
    try {
      await dbHelper.unsaveQuestionForUser(userId, questionId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isQuestionSaved(String userId, String questionId) async {
    return await dbHelper.isQuestionSaved(userId, questionId);
  }

  Future<bool> deleteQuestion(String questionId) async {
    try {
      await dbHelper.deleteAIQuestion(questionId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Dashboard Screen - Combined features (Updated with theme toggle)
class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _currentUser;
  Position? _currentLocation;
  String _currentAddress = 'Getting location...';
  bool _isTracking = false;
  Uint8List? _profileImage;
  int _unreadMessages = 0;
  int _pendingPapers = 0;
  int _savedQuestions = 0;

  final LocationService _locationService = LocationService();
  final CameraService _cameraService = CameraService();
  final PaperDataManager _paperManager = PaperDataManager();
  final AIQuestionManager _aiQuestionManager = AIQuestionManager();
  StreamSubscription<Position>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _getCurrentLocation();
    _loadProfileImage();
    _loadUnreadMessages();
    _loadPendingPapers();
    _loadSavedQuestionsCount();
    _cameraService.initializeCamera();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      setState(() {
        _currentUser = Map<String, dynamic>.from(json.decode(userJson));
      });
    }
  }

  Future<void> _loadProfileImage() async {
    if (_currentUser != null) {
      try {
        final image = await DatabaseHelper.instance.getUserProfileImage(
          _currentUser!['id'],
        );
        setState(() {
          _profileImage = image;
        });
      } catch (e) {
        print('Error loading profile image: $e');
      }
    }
  }

  Future<void> _loadUnreadMessages() async {
    if (_currentUser != null) {
      final count = await DatabaseHelper.instance.getUnreadMessageCount(
        _currentUser!['id'],
      );
      setState(() {
        _unreadMessages = count;
      });
    }
  }

  Future<void> _loadPendingPapers() async {
    if (widget.role == 'admin') {
      final papers = await _paperManager.getPendingPapers();
      setState(() {
        _pendingPapers = papers.length;
      });
    }
  }

  Future<void> _loadSavedQuestionsCount() async {
    if (_currentUser != null) {
      final savedQuestions = await _aiQuestionManager.getSavedQuestions(
        _currentUser!['id'],
      );
      setState(() {
        _savedQuestions = savedQuestions.length;
      });
    }
  }

  Future<void> _updateProfileImage() async {
    final File? photo = await _cameraService.takePhoto();
    if (photo != null && _currentUser != null) {
      final compressedImage = await _cameraService.compressAndConvertPhoto(
        photo,
      );
      if (compressedImage != null) {
        await DatabaseHelper.instance.updateUserProfileImage(
          _currentUser!['id'],
          compressedImage,
        );
        setState(() {
          _profileImage = compressedImage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF4CAF50),
            content: Text('Profile photo updated successfully!'),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentLocation = position;
        _currentAddress = address;
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Unable to get location: $e';
      });
    }
  }

  void _startLocationTracking() {
    _locationSubscription = _locationService.getLocationStream().listen(
      (position) {
        setState(() {
          _currentLocation = position;
        });
      },
      onError: (error) {
        print('Location tracking error: $error');
      },
    );

    setState(() {
      _isTracking = true;
    });
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    setState(() {
      _isTracking = false;
    });
  }

  Future<void> _markAttendanceWithPhoto(String classroomId) async {
    if (_currentUser == null || _currentLocation == null) return;

    try {
      final isInClassroom = await _locationService.isInClassroom(
        classroomId,
        _currentLocation!,
      );
      if (!isInClassroom) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFF44336),
            content: Text('You are not in the classroom area'),
          ),
        );
        return;
      }

      final File? photo = await _cameraService.takePhoto();
      if (photo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFF44336),
            content: Text('Please take a photo to mark attendance'),
          ),
        );
        return;
      }

      await DatabaseHelper.instance.insertAttendance({
        'studentId': _currentUser!['id'],
        'studentName':
            '${_currentUser!['firstName']} ${_currentUser!['lastName']}',
        'studentEmail': _currentUser!['email'],
        'classroomId': classroomId,
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'timestamp': DateTime.now().toString(),
        'verifiedByGPS': isInClassroom ? 1 : 0,
        'photoPath': photo.path,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF4CAF50),
          content: Text('Attendance marked successfully with photo!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFF44336),
          content: Text('Error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gpsEnabled = _currentUser?['gpsEnabled'] == 1;
    final messagingEnabled = _currentUser?['messagingEnabled'] == 1;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2D1B69)]
                        : [const Color(0xFF2575FC), const Color(0xFF6A11CB)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.logout,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('currentUser');
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WelcomeScreen(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                        const Spacer(),
                        Text(
                          '${widget.role[0].toUpperCase()}${widget.role.substring(1)} Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chat,
                                color: isDark ? Colors.white : Colors.white,
                              ),
                              onPressed: messagingEnabled
                                  ? _openMessages
                                  : null,
                              tooltip: 'Messages',
                            ),
                            if (_unreadMessages > 0 && messagingEnabled)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    _unreadMessages.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            if (!messagingEnabled)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: const Icon(
                                    Icons.block,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.brightness_6,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () {
                            final themeSwitcher = ThemeSwitcher.of(context);
                            if (themeSwitcher != null) {
                              themeSwitcher.onThemeChanged(!isDark);
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: _updateProfileImage,
                          tooltip: 'Update profile photo',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Profile Image
                    GestureDetector(
                      onTap: _updateProfileImage,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: widget.role == 'admin'
                            ? const Color(0xFFF44336)
                            : widget.role == 'teacher'
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF4CAF50),
                        backgroundImage: _profileImage != null
                            ? MemoryImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Icon(
                                widget.role == 'admin'
                                    ? Icons.admin_panel_settings
                                    : widget.role == 'teacher'
                                    ? Icons.school
                                    : Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 15),
                    Text(
                      'Welcome, ${_currentUser?['firstName'] ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currentUser?['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // User Status Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.gps_fixed,
                                size: 14,
                                color: Colors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'GPS Enabled',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.green,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Camera Enabled',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (widget.role == 'admin'
                                    ? const Color(0xFFF44336)
                                    : widget.role == 'teacher'
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFF4CAF50))
                                .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: widget.role == 'admin'
                              ? const Color(0xFFF44336)
                              : widget.role == 'teacher'
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF4CAF50),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.role == 'admin'
                              ? const Color(0xFFF44336)
                              : widget.role == 'teacher'
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.role != 'admin' && gpsEnabled)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gps_fixed,
                            color: _currentLocation != null
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentLocation != null
                                      ? 'Location Active'
                                      : 'Location Inactive',
                                  style: TextStyle(
                                    color: _currentLocation != null
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFF44336),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _currentAddress,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isTracking ? Icons.stop : Icons.play_arrow,
                              color: _isTracking
                                  ? const Color(0xFFF44336)
                                  : const Color(0xFF4CAF50),
                            ),
                            onPressed: () {
                              if (_isTracking) {
                                _stopLocationTracking();
                              } else {
                                _startLocationTracking();
                              }
                            },
                            tooltip: _isTracking
                                ? 'Stop Tracking'
                                : 'Start Tracking',
                          ),
                        ],
                      ),
                      if (_currentLocation != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLocationInfo(
                              'Lat',
                              _currentLocation!.latitude.toStringAsFixed(6),
                              isDark,
                            ),
                            _buildLocationInfo(
                              'Lng',
                              _currentLocation!.longitude.toStringAsFixed(6),
                              isDark,
                            ),
                            _buildLocationInfo(
                              'Accuracy',
                              '${_currentLocation!.accuracy.toStringAsFixed(2)}m',
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

              if (widget.role != 'admin' && !gpsEnabled)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_off, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GPS Disabled',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Contact admin to enable GPS tracking',
                              style: TextStyle(
                                color: Colors.red.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select an option below',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 25),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.2,
                      children: _getDashboardActions(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _getDashboardActions(bool isDark) {
    final gpsEnabled = _currentUser?['gpsEnabled'] == 1;
    final messagingEnabled = _currentUser?['messagingEnabled'] == 1;

    if (widget.role == 'admin') {
      return [
        _buildDashboardCard(
          icon: Icons.people,
          title: 'Manage Users',
          subtitle: 'View all users',
          color: const Color(0xFFF44336),
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserManagementScreen(),
            ),
          ),
        ),
        _buildDashboardCard(
          icon: Icons.person_add,
          title: 'Add User',
          subtitle: 'Create new user',
          color: const Color(0xFF4CAF50),
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterUserScreen()),
          ),
        ),
        _buildDashboardCard(
          icon: Icons.pending_actions,
          title: 'Pending Papers',
          subtitle: 'Review submissions',
          color: const Color(0xFFFF9800),
          isDark: isDark,
          count: _pendingPapers,
          onTap: () => _showPendingPapersScreen(),
        ),
        _buildDashboardCard(
          icon: Icons.library_books,
          title: 'Papers',
          subtitle: 'View all papers',
          color: const Color(0xFF2196F3),
          isDark: isDark,
          onTap: () => _showPapersManagement(),
        ),
        _buildDashboardCard(
          icon: Icons.upload,
          title: 'Upload',
          subtitle: 'Share resources',
          color: const Color(0xFF4CAF50),
          isDark: isDark,
          onTap: () => _showUploadPaperDialog(),
        ),
        _buildDashboardCard(
          icon: Icons.analytics,
          title: 'Analytics',
          subtitle: 'View statistics',
          color: const Color(0xFF9C27B0),
          isDark: isDark,
          onTap: _showAnalytics,
        ),
        _buildDashboardCard(
          icon: Icons.auto_awesome,
          title: 'AI Questions',
          subtitle: 'Generate questions',
          color: const Color(0xFF00BCD4),
          isDark: isDark,
          onTap: _showAIQuestionGenerator,
        ),
        _buildDashboardCard(
          icon: Icons.question_answer,
          title: 'My AI Questions',
          subtitle: 'View generated',
          color: const Color(0xFF673AB7),
          isDark: isDark,
          onTap: _showMyAIQuestions,
        ),
      ];
    } else if (widget.role == 'teacher') {
      return [
        _buildDashboardCard(
          icon: Icons.list_alt,
          title: 'Attendance',
          subtitle: 'View records',
          color: const Color(0xFF4CAF50),
          isDark: isDark,
          onTap: () => _showAttendanceRecords(),
        ),
        _buildDashboardCard(
          icon: Icons.library_books,
          title: 'Papers',
          subtitle: 'View submissions',
          color: const Color(0xFF2196F3),
          isDark: isDark,
          onTap: () => _showPapersForViewing(),
        ),
        _buildDashboardCard(
          icon: Icons.class_,
          title: 'Classrooms',
          subtitle: 'View locations',
          color: const Color(0xFF9C27B0),
          isDark: isDark,
          onTap: () => _showClassroomsDialog(),
        ),
        _buildDashboardCard(
          icon: Icons.location_on,
          title: 'Location',
          subtitle: 'View GPS data',
          color: gpsEnabled ? const Color(0xFFF44336) : Colors.grey,
          isDark: isDark,
          onTap: gpsEnabled ? _showLocationDetails : null,
        ),
        _buildDashboardCard(
          icon: Icons.photo_camera,
          title: 'Camera',
          subtitle: 'Take photo',
          color: const Color(0xFFFF9800),
          isDark: isDark,
          onTap: _updateProfileImage,
        ),
        _buildDashboardCard(
          icon: Icons.chat,
          title: 'Messages',
          subtitle: 'Communicate',
          color: messagingEnabled ? const Color(0xFF00BCD4) : Colors.grey,
          isDark: isDark,
          count: messagingEnabled ? _unreadMessages : 0,
          onTap: messagingEnabled ? _openMessages : null,
        ),
        _buildDashboardCard(
          icon: Icons.auto_awesome,
          title: 'AI Questions',
          subtitle: 'Generate questions',
          color: const Color(0xFF00BCD4),
          isDark: isDark,
          onTap: _showAIQuestionGenerator,
        ),
        _buildDashboardCard(
          icon: Icons.bookmark,
          title: 'Saved Questions',
          subtitle: 'View saved',
          color: const Color(0xFF673AB7),
          isDark: isDark,
          count: _savedQuestions,
          onTap: _showSavedAIQuestions,
        ),
      ];
    } else {
      return [
        _buildDashboardCard(
          icon: Icons.camera_alt,
          title: 'Mark Attendance',
          subtitle: 'Take photo to mark',
          color: gpsEnabled ? const Color(0xFF4CAF50) : Colors.grey,
          isDark: isDark,
          onTap: gpsEnabled ? _showClassroomSelection : null,
        ),
        _buildDashboardCard(
          icon: Icons.upload_file,
          title: 'Submit Paper',
          subtitle: 'Upload document',
          color: const Color(0xFF2196F3),
          isDark: isDark,
          onTap: () => _showStudentUploadDialog(),
        ),
        _buildDashboardCard(
          icon: Icons.library_books,
          title: 'My Papers',
          subtitle: 'View submissions',
          color: const Color(0xFF9C27B0),
          isDark: isDark,
          onTap: () => _showMyPapers(),
        ),
        _buildDashboardCard(
          icon: Icons.assignment,
          title: 'Attendance',
          subtitle: 'My records',
          color: const Color(0xFFFF9800),
          isDark: isDark,
          onTap: _showMyAttendance,
        ),
        _buildDashboardCard(
          icon: Icons.public,
          title: 'Public Papers',
          subtitle: 'Browse resources',
          color: const Color(0xFF00BCD4),
          isDark: isDark,
          onTap: () => _showPublicPapers(),
        ),
        _buildDashboardCard(
          icon: Icons.chat,
          title: 'Messages',
          subtitle: 'Communicate',
          color: messagingEnabled ? const Color(0xFFF44336) : Colors.grey,
          isDark: isDark,
          count: messagingEnabled ? _unreadMessages : 0,
          onTap: messagingEnabled ? _openMessages : null,
        ),
        _buildDashboardCard(
          icon: Icons.auto_awesome,
          title: 'Ask AI',
          subtitle: 'Get answers',
          color: const Color(0xFF00BCD4),
          isDark: isDark,
          onTap: _showAIAssistant,
        ),
        _buildDashboardCard(
          icon: Icons.bookmark,
          title: 'Saved Questions',
          subtitle: 'Study material',
          color: const Color(0xFF673AB7),
          isDark: isDark,
          count: _savedQuestions,
          onTap: _showSavedAIQuestions,
        ),
      ];
    }
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    int? count,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(15),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isDisabled)
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.lock, size: 16, color: Colors.grey),
                    ),
                ],
              ),
              if (count != null && count > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPapersForViewing() async {
    final papers = await _paperManager.getPublicPapers();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Available Papers',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: papers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No papers available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    final paper = papers[index];
                    return ListTile(
                      leading: Icon(
                        paper['fileType'] == 'PDF'
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: const Color(0xFF4CAF50),
                      ),
                      title: Text(
                        paper['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'By: ${paper['studentName']} - ${paper['subject']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white70,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _paperManager.viewPaper(context, paper);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => UploadPaperDialog(
        userId: _currentUser!['id'],
        userName: '${_currentUser!['firstName']} ${_currentUser!['lastName']}',
        isAdmin: false,
      ),
    ).then((_) {
      // Refresh pending papers count after dialog closes
      _loadPendingPapers();
    });
  }

  void _showUploadPaperDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => UploadPaperDialog(
        userId: _currentUser!['id'],
        userName: '${_currentUser!['firstName']} ${_currentUser!['lastName']}',
        isAdmin: true,
      ),
    ).then((_) {
      // Refresh pending papers count after dialog closes
      _loadPendingPapers();
    });
  }

  void _openMessages() async {
    if (_currentUser == null) return;

    final conversations = await DatabaseHelper.instance.getConversations(
      _currentUser!['id'],
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: conversations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF4CAF50),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        conv['otherUserName'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Last activity',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white70,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _openChat(conv['otherUserId'], conv['otherUserName']);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(String otherUserId, String otherUserName) async {
    if (_currentUser == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUserId: _currentUser!['id'],
          currentUserName:
              '${_currentUser!['firstName']} ${_currentUser!['lastName']}',
          otherUserId: otherUserId,
          otherUserName: otherUserName,
        ),
      ),
    ).then((_) {
      // Refresh unread message count when returning from chat
      _loadUnreadMessages();
    });
  }

  void _showPendingPapersScreen() async {
    final papers = await _paperManager.getPendingPapers();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Pending Papers',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: papers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No pending papers',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    final paper = papers[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.description,
                        color: Color(0xFF4CAF50),
                      ),
                      title: Text(
                        paper['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'By: ${paper['studentName']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _acceptPaper(paper['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectPaper(paper['id']),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_red_eye,
                              color: Colors.blue,
                            ),
                            onPressed: () => _viewPaperDetails(paper),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _viewPaperDetails(Map<String, dynamic> paper) async {
    Navigator.pop(context);
    await _paperManager.viewPaper(context, paper);
  }

  Future<void> _acceptPaper(String paperId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        title: const Text(
          'Accept Paper',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter grade and feedback:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: 'Grade (A, B, C, etc)',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                // Store grade
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: 'Feedback',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              onChanged: (value) {
                // Store feedback
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _paperManager.updatePaperStatus(
                paperId,
                'approved',
                grade: 'A',
                feedback: 'Good work!',
              );
              setState(() {
                _pendingPapers--;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF4CAF50),
                  content: Text('Paper accepted successfully!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('ACCEPT'),
          ),
        ],
      ),
    );
  }

  void _rejectPaper(String paperId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        title: const Text(
          'Reject Paper',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Reason for rejection:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                labelText: 'Reason',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _paperManager.updatePaperStatus(paperId, 'rejected');
              setState(() {
                _pendingPapers--;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFFF44336),
                  content: Text('Paper rejected'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text('REJECT'),
          ),
        ],
      ),
    );
  }

  void _showPapersManagement() async {
    final papers = await DatabaseHelper.instance.getAllPapers();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('All Papers', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: papers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No papers available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    final paper = papers[index];
                    return ListTile(
                      leading: Icon(
                        paper['status'] == 'approved'
                            ? Icons.check_circle
                            : Icons.pending,
                        color: paper['status'] == 'approved'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: Text(
                        paper['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${paper['studentName']} - ${paper['status']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.blue,
                        ),
                        onPressed: () => _viewPaperDetails(paper),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPublicPapers() async {
    final papers = await _paperManager.getPublicPapers();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Public Papers',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: papers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No public papers available',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    final paper = papers[index];
                    return ListTile(
                      leading: Icon(
                        paper['fileType'] == 'PDF'
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: const Color(0xFF4CAF50),
                      ),
                      title: Text(
                        paper['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'By: ${paper['studentName']} - Grade: ${paper['grade'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.blue,
                        ),
                        onPressed: () => _viewPaperDetails(paper),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMyPapers() async {
    if (_currentUser == null) return;
    final papers = await _paperManager.getUserPapers(_currentUser!['id']);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('My Papers', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: papers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'You have no papers yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    final paper = papers[index];
                    return ListTile(
                      leading: Icon(
                        paper['status'] == 'approved'
                            ? Icons.check_circle
                            : Icons.pending,
                        color: paper['status'] == 'approved'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: Text(
                        paper['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${paper['subject']} - ${paper['status']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye,
                          color: Colors.blue,
                        ),
                        onPressed: () => _viewPaperDetails(paper),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClassroomSelection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select Classroom',
          style: TextStyle(color: Colors.white),
        ),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseHelper.instance.getAllClassrooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No classrooms found',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final classroom = snapshot.data![index];
                  return ListTile(
                    leading: const Icon(Icons.class_, color: Color(0xFF4CAF50)),
                    title: Text(
                      classroom['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${classroom['latitude']}, ${classroom['longitude']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white70,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _markAttendanceWithPhoto(classroom['id']);
                    },
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationDetails() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFF44336),
          content: Text('Unable to get location'),
        ),
      );
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Location Details',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationDetailRow(
                'Latitude',
                _currentLocation!.latitude.toStringAsFixed(6),
                isDark,
              ),
              _buildLocationDetailRow(
                'Longitude',
                _currentLocation!.longitude.toStringAsFixed(6),
                isDark,
              ),
              _buildLocationDetailRow(
                'Accuracy',
                '${_currentLocation!.accuracy.toStringAsFixed(2)} meters',
                isDark,
              ),
              const SizedBox(height: 15),
              const Text(
                'Address:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                _currentAddress,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMyAttendance() async {
    if (_currentUser == null) return;

    final attendance = await DatabaseHelper.instance.getStudentAttendance(
      _currentUser!['id'],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'My Attendance',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: attendance.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 60,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No attendance records found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: attendance.length,
                  itemBuilder: (context, index) {
                    final record = attendance[index];
                    final date = DateTime.parse(record['timestamp']);

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          record['verifiedByGPS'] == 1
                              ? Icons.check_circle
                              : Icons.error,
                          color: record['verifiedByGPS'] == 1
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336),
                        ),
                        title: Text(
                          record['classroomId'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${date.toString().split(' ')[0]}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Time: ${date.toString().split(' ')[1].split('.')[0]}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'GPS Verified: ${record['verifiedByGPS'] == 1 ? 'Yes' : 'No'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAttendanceRecords() async {
    final attendance = await DatabaseHelper.instance.getAllAttendance();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Attendance Records',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: attendance.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 60,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No attendance records found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: attendance.length,
                  itemBuilder: (context, index) {
                    final record = attendance[index];
                    final date = DateTime.parse(record['timestamp']);

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Color(0xFF4CAF50),
                        ),
                        title: Text(
                          record['studentName'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Class: ${record['classroomId']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Date: ${date.toString().split(' ')[0]} ${date.toString().split(' ')[1].split('.')[0]}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'GPS: ${record['verifiedByGPS'] == 1 ? 'Verified' : 'Not Verified'}',
                              style: TextStyle(
                                color: record['verifiedByGPS'] == 1
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFF44336),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showClassroomsDialog() async {
    final classrooms = await DatabaseHelper.instance.getAllClassrooms();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Classrooms', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: classrooms.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No classrooms found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: classrooms.length,
                  itemBuilder: (context, index) {
                    final classroom = classrooms[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.class_,
                          color: Color(0xFF4CAF50),
                        ),
                        title: Text(
                          classroom['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coordinates: ${classroom['latitude']}, ${classroom['longitude']}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Radius: ${classroom['radius']} meters',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() async {
    final users = await DatabaseHelper.instance.getAllUsers();
    final attendance = await DatabaseHelper.instance.getAllAttendance();
    final papers = await DatabaseHelper.instance.getAllPapers();
    final classrooms = await DatabaseHelper.instance.getAllClassrooms();
    final aiQuestions = await DatabaseHelper.instance.getAllAIQuestions();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gpsEnabledUsers = users
        .where((user) => user['gpsEnabled'] == 1)
        .length;

    final messagingEnabledUsers = users
        .where((user) => user['messagingEnabled'] == 1)
        .length;

    final gpsVerified = attendance
        .where((record) => record['verifiedByGPS'] == 1)
        .length;

    final approvedPapers = papers
        .where((paper) => paper['status'] == 'approved')
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'System Analytics',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAnalyticsItem('Total Users', users.length.toString()),
                _buildAnalyticsItem(
                  'GPS Enabled Users',
                  gpsEnabledUsers.toString(),
                ),
                _buildAnalyticsItem(
                  'Messaging Enabled Users',
                  messagingEnabledUsers.toString(),
                ),
                _buildAnalyticsItem(
                  'Total Attendance',
                  attendance.length.toString(),
                ),
                _buildAnalyticsItem('Total Papers', papers.length.toString()),
                _buildAnalyticsItem('Classrooms', classrooms.length.toString()),
                _buildAnalyticsItem('GPS Verified', gpsVerified.toString()),
                _buildAnalyticsItem(
                  'Approved Papers',
                  approvedPapers.toString(),
                ),
                _buildAnalyticsItem(
                  'Pending Papers',
                  _pendingPapers.toString(),
                ),
                _buildAnalyticsItem(
                  'AI Questions Generated',
                  aiQuestions.length.toString(),
                ),
                _buildAnalyticsItem(
                  'Saved Questions',
                  _savedQuestions.toString(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'System Status: Active\nDatabase: Connected\nLocation: GPS Enabled\nPaper System: Operational\nMessaging: Enabled\nAI System: Active',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: AI Question Generator Dialog
  void _showAIQuestionGenerator() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AIQuestionGeneratorDialog(
        userId: _currentUser?['id'] ?? '',
        userName:
            '${_currentUser?['firstName'] ?? ''} ${_currentUser?['lastName'] ?? ''}',
        role: widget.role,
      ),
    ).then((_) {
      _loadSavedQuestionsCount();
    });
  }

  // 🔥 NEW: Show My AI Questions
  void _showMyAIQuestions() async {
    if (_currentUser == null) return;

    final questions = await _aiQuestionManager.getUserQuestions(
      _currentUser!['id'],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'My AI Questions',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: questions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No AI questions generated yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF00BCD4),
                        ),
                        title: Text(
                          '${question['topic']} (${question['difficulty']})',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${question['subject']} • ${question['questionType']} • ${question['numberOfQuestions']} questions',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.role == 'admin')
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteAIQuestion(question['id']),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.blue,
                              ),
                              onPressed: () => _viewAIQuestion(question),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: Show Saved AI Questions
  void _showSavedAIQuestions() async {
    if (_currentUser == null) return;

    final questions = await _aiQuestionManager.getSavedQuestions(
      _currentUser!['id'],
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Saved Questions',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: questions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark, size: 60, color: Colors.white70),
                      SizedBox(height: 10),
                      Text(
                        'No saved questions yet',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];

                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.bookmark,
                          color: Colors.yellow,
                        ),
                        title: Text(
                          '${question['topic']} (${question['difficulty']})',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${question['subject']} • ${question['questionType']} • ${question['numberOfQuestions']} questions',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark_remove,
                                color: Colors.red,
                              ),
                              onPressed: () => _unsaveQuestion(question['id']),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_red_eye,
                                color: Colors.blue,
                              ),
                              onPressed: () => _viewAIQuestion(question),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: View AI Question Details
  void _viewAIQuestion(Map<String, dynamic> question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'AI Generated Questions',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Topic: ${question['topic']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Subject: ${question['subject']} • Difficulty: ${question['difficulty']}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Type: ${question['questionType']} • Questions: ${question['numberOfQuestions']}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    question['generatedContent'],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                if (_currentUser != null)
                  FutureBuilder<bool>(
                    future: _aiQuestionManager.isQuestionSaved(
                      _currentUser!['id'],
                      question['id'],
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final isSaved = snapshot.data!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Close'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (isSaved) {
                                  _unsaveQuestion(question['id']);
                                } else {
                                  _saveQuestion(question['id']);
                                }
                              },
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark_remove
                                    : Icons.bookmark_add,
                              ),
                              label: Text(isSaved ? 'Unsave' : 'Save'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSaved
                                    ? Colors.red
                                    : const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 NEW: Delete AI Question
  void _deleteAIQuestion(String questionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        title: const Text(
          'Delete Question',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this AI generated question?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _aiQuestionManager.deleteQuestion(questionId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF4CAF50),
            content: Text('Question deleted successfully'),
          ),
        );
        _showMyAIQuestions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFF44336),
            content: Text('Failed to delete question'),
          ),
        );
      }
    }
  }

  // 🔥 NEW: Save Question
  void _saveQuestion(String questionId) async {
    if (_currentUser == null) return;

    final success = await _aiQuestionManager.saveQuestion(
      _currentUser!['id'],
      questionId,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF4CAF50),
          content: Text('Question saved successfully'),
        ),
      );
      setState(() {
        _savedQuestions++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFF44336),
          content: Text('Failed to save question'),
        ),
      );
    }
  }

  // 🔥 NEW: Unsave Question
  void _unsaveQuestion(String questionId) async {
    if (_currentUser == null) return;

    final success = await _aiQuestionManager.unsaveQuestion(
      _currentUser!['id'],
      questionId,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF4CAF50),
          content: Text('Question unsaved successfully'),
        ),
      );
      setState(() {
        _savedQuestions = _savedQuestions > 0 ? _savedQuestions - 1 : 0;
      });
      _showSavedAIQuestions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFF44336),
          content: Text('Failed to unsave question'),
        ),
      );
    }
  }

  // 🔥 NEW: AI Assistant Dialog
  void _showAIAssistant() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AIAssistantDialog(
        userId: _currentUser?['id'] ?? '',
        userName:
            '${_currentUser?['firstName'] ?? ''} ${_currentUser?['lastName'] ?? ''}',
      ),
    );
  }
}

// 🔥 NEW: AI Question Generator Dialog
class AIQuestionGeneratorDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final String role;

  const AIQuestionGeneratorDialog({
    super.key,
    required this.userId,
    required this.userName,
    required this.role,
  });

  @override
  State<AIQuestionGeneratorDialog> createState() =>
      _AIQuestionGeneratorDialogState();
}

class _AIQuestionGeneratorDialogState extends State<AIQuestionGeneratorDialog> {
  final TextEditingController _topicController = TextEditingController();
  final AIQuestionManager _aiManager = AIQuestionManager();

  String _selectedSubject = 'Computer Science';
  String _selectedDifficulty = 'Easy';
  String _selectedQuestionType = 'Multiple Choice';
  int _selectedNumberOfQuestions = 5;
  bool _isGenerating = false;
  String? _errorMessage;
  String? _generatedContent;

  final List<String> _subjects = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Economics',
    'History',
    'English',
    'Geography',
  ];

  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> _questionTypes = [
    'Multiple Choice',
    'True/False',
    'Short Answer',
    'Essay',
  ];
  final List<int> _numberOfQuestions = [3, 5, 10, 15];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark
          ? const Color(0xFF2D1B69)
          : const Color(0xFF2575FC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '🤖 AI Question Generator',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isGenerating)
              Column(
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Generating questions with AI...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              )
            else if (_generatedContent != null)
              _buildGeneratedContent(isDark)
            else
              _buildGeneratorForm(isDark),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: _buildActions(isDark),
    );
  }

  Widget _buildGeneratorForm(bool isDark) {
    return Column(
      children: [
        TextField(
          controller: _topicController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Topic',
            labelStyle: const TextStyle(color: Colors.white70),
            hintText: 'e.g., Machine Learning, Calculus, Quantum Physics',
            hintStyle: const TextStyle(color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white70),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white70),
            ),
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _selectedSubject,
          items: _subjects.map((subject) {
            return DropdownMenuItem(
              value: subject,
              child: Text(subject, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedSubject = value!),
          decoration: InputDecoration(
            labelText: 'Subject',
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white70),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white70),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: isDark ? const Color(0xFF2D1B69) : Colors.white,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                items: _difficulties.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(
                      difficulty,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedDifficulty = value!),
                decoration: InputDecoration(
                  labelText: 'Difficulty',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: isDark ? const Color(0xFF2D1B69) : Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedQuestionType,
                items: _questionTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedQuestionType = value!),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white70),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: isDark ? const Color(0xFF2D1B69) : Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<int>(
          value: _selectedNumberOfQuestions,
          items: _numberOfQuestions.map((number) {
            return DropdownMenuItem(
              value: number,
              child: Text(
                '$number questions',
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (value) =>
              setState(() => _selectedNumberOfQuestions = value!),
          decoration: InputDecoration(
            labelText: 'Number of Questions',
            labelStyle: const TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white70),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white70),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: isDark ? const Color(0xFF2D1B69) : Colors.white,
        ),
      ],
    );
  }

  Widget _buildGeneratedContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Text(
              _generatedContent!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green),
          ),
          child: const Text(
            '✅ Questions generated successfully!\nYou can save these for future reference.',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(bool isDark) {
    if (_isGenerating) {
      return [
        TextButton(
          onPressed: null,
          child: const Text(
            'GENERATING...',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ];
    } else if (_generatedContent != null) {
      return [
        TextButton(
          onPressed: () {
            setState(() {
              _generatedContent = null;
              _errorMessage = null;
            });
          },
          child: const Text(
            'GENERATE MORE',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
          ),
          child: const Text('DONE'),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _generateQuestions,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4),
          ),
          child: const Text('GENERATE'),
        ),
      ];
    }
  }

  Future<void> _generateQuestions() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a topic';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    final result = await _aiManager.generateQuestions(
      topic: topic,
      subject: _selectedSubject,
      difficulty: _selectedDifficulty,
      numberOfQuestions: _selectedNumberOfQuestions,
      questionType: _selectedQuestionType,
      generatedBy: widget.userId,
    );

    setState(() {
      _isGenerating = false;
    });

    if (result['success'] == true) {
      setState(() {
        _generatedContent = result['content'];
      });
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }
}

// 🔥 NEW: AI Assistant Dialog
class AIAssistantDialog extends StatefulWidget {
  final String userId;
  final String userName;

  const AIAssistantDialog({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AIAssistantDialog> createState() => _AIAssistantDialogState();
}

class _AIAssistantDialogState extends State<AIAssistantDialog> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController(
    text: 'General',
  );
  final TextEditingController _contextController = TextEditingController();
  final AIQuestionManager _aiManager = AIQuestionManager();

  bool _isProcessing = false;
  String? _errorMessage;
  String? _answer;
  final List<Map<String, dynamic>> _chatHistory = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark
          ? const Color(0xFF2D1B69)
          : const Color(0xFF2575FC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '🤖 AI Study Assistant',
        style: TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: _chatHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 60,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ask me anything!\nI can help with homework, explanations,\nand study questions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      itemCount: _chatHistory.length,
                      itemBuilder: (context, index) {
                        final message = _chatHistory[index];
                        final isUser = message['role'] == 'user';

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF4CAF50)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: !isUser
                                  ? Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  const Text(
                                    'AI Assistant:',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  message['content'],
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              ),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            if (_answer != null && !_isProcessing)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  '✅ Answer generated!',
                  style: TextStyle(color: Colors.green),
                ),
              ),

            TextField(
              controller: _questionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Your Question',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'e.g., Explain photosynthesis, Solve 2x + 5 = 15',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _askQuestion,
                ),
              ),
              onSubmitted: (_) => _askQuestion(),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subjectController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _contextController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Context (optional)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE', style: TextStyle(color: Colors.white70)),
        ),
        if (_chatHistory.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                _chatHistory.clear();
                _answer = null;
                _errorMessage = null;
              });
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.white70)),
          ),
      ],
    );
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a question';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _answer = null;
      _chatHistory.insert(0, {'role': 'user', 'content': question});
    });

    _questionController.clear();

    try {
      final answer = await _aiManager.answerQuestion(
        question: question,
        subject: _subjectController.text.trim(),
        context: _contextController.text.trim(),
      );

      setState(() {
        _isProcessing = false;
        _answer = answer;
        _chatHistory.insert(0, {'role': 'assistant', 'content': answer});
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Failed to get answer: $e';
      });
    }
  }
}

// IMPROVED: Upload Paper Dialog with better state management
class UploadPaperDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final bool isAdmin;

  const UploadPaperDialog({
    super.key,
    required this.userId,
    required this.userName,
    required this.isAdmin,
  });

  @override
  State<UploadPaperDialog> createState() => _UploadPaperDialogState();
}

class _UploadPaperDialogState extends State<UploadPaperDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  String? _selectedFileType;
  String? _selectedFileExtension;
  String? _selectedSubject = 'Computer Science';
  final bool _isLoading = false;
  bool _isUploading = false;

  // Keep track of upload state
  static bool _isCurrentlyUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _isCurrentlyUploading = false;
    super.dispose();
  }

  Future<void> _pickFile() async {
    if (_isUploading || _isCurrentlyUploading) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _selectedFile = File(file.path!);
            _selectedFileExtension = file.extension;
            _selectedFileType = _getFileTypeFromExtension(
              _selectedFileExtension,
            );
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick file: $e'),
          backgroundColor: const Color(0xFFF44336),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isUploading || _isCurrentlyUploading) return;

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _selectedFileExtension = 'jpg';
        _selectedFileType = 'IMAGE';
      });
    }
  }

  String _getFileTypeFromExtension(String? extension) {
    if (extension == null) return 'FILE';
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'IMAGE';
      default:
        return 'FILE';
    }
  }

  Future<void> _uploadPaper() async {
    if (_isUploading || _isCurrentlyUploading) return;
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _isCurrentlyUploading = true;
    });

    try {
      final paperData = {
        'id': '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}',
        'title': _titleController.text,
        'studentId': widget.userId,
        'studentName': widget.userName,
        'subject': _selectedSubject!,
        'date': DateTime.now().toString().split(' ')[0],
        'fileSize': '${_selectedFile!.lengthSync() ~/ 1024}KB',
        'status': widget.isAdmin ? 'approved' : 'pending',
        'fileType': _selectedFileType ?? 'FILE',
        'fileExtension': _selectedFileExtension != null
            ? '.$_selectedFileExtension'
            : '.file',
        'abstract': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : 'Paper submitted by ${widget.isAdmin ? 'admin' : 'student'}',
        'uploadedBy': widget.isAdmin ? 'admin' : 'student',
        'isPublic': widget.isAdmin ? 1 : 0,
        'hasFile': 1,
      };

      if (widget.isAdmin) {
        paperData['grade'] = 'A';
        paperData['feedback'] = 'Uploaded by admin';
      }

      final paperManager = PaperDataManager();
      await paperManager.addPaper(
        paperData,
        file: _selectedFile,
        fileType: _selectedFileType,
      );

      if (!widget.isAdmin) {
        // Send notification message to admin
        await DatabaseHelper.instance.insertMessage({
          'id': 'MSG${DateTime.now().millisecondsSinceEpoch}',
          'senderId': widget.userId,
          'senderName': widget.userName,
          'receiverId': 'admin001',
          'text':
              '📄 New paper submitted: "${_titleController.text}" for review.',
          'timestamp': DateTime.now().toString(),
          'isRead': 0,
        });
      }

      // Reset form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedFile = null;
        _selectedFileType = null;
        _selectedFileExtension = null;
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isAdmin
                ? '✅ Paper uploaded and published publicly!'
                : '📤 Paper submitted for review!',
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFF44336),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _isCurrentlyUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        return !_isUploading;
      },
      child: AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF2D1B69)
            : const Color(0xFF2575FC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          widget.isAdmin
              ? '📤 Upload Paper as Admin'
              : '📝 Submit Paper for Review',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isUploading)
                Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Uploading your paper...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              else ...[
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  items: const [
                    DropdownMenuItem(
                      value: 'Computer Science',
                      child: Text(
                        'Computer Science',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Mathematics',
                      child: Text(
                        'Mathematics',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Physics',
                      child: Text(
                        'Physics',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Chemistry',
                      child: Text(
                        'Chemistry',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Economics',
                      child: Text(
                        'Economics',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedSubject = value),
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: isDark
                      ? const Color(0xFF2D1B69)
                      : Colors.white,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Paper Title',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description/Abstract',
                    labelStyle: const TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedFile == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: Colors.white70,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No file selected',
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                'Supports: PDF, JPG, PNG',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: _selectedFileType == 'IMAGE'
                                  ? Image.file(
                                      _selectedFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.insert_drive_file,
                                        size: 60,
                                        color: Colors.white70,
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                _selectedFile!.path.split('/').last,
                                style: const TextStyle(color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFile,
                      icon: const Icon(Icons.insert_drive_file),
                      label: const Text('Browse'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ElevatedButton(
            onPressed: _isUploading ? null : _uploadPaper,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isUploading
                  ? Colors.grey
                  : const Color(0xFF4CAF50),
            ),
            child: _isUploading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.isAdmin ? 'UPLOAD' : 'SUBMIT'),
          ),
        ],
      ),
    );
  }
}

// Chat Screen
class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markMessagesAsRead();
  }

  Future<void> _loadMessages() async {
    final messages = await DatabaseHelper.instance.getMessagesBetween(
      widget.currentUserId,
      widget.otherUserId,
    );
    setState(() {
      _messages.addAll(messages);
      _isLoading = false;
    });
  }

  Future<void> _markMessagesAsRead() async {
    await DatabaseHelper.instance.markMessagesAsRead(
      widget.currentUserId,
      widget.otherUserId,
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'id': 'MSG${DateTime.now().millisecondsSinceEpoch}',
      'senderId': widget.currentUserId,
      'senderName': widget.currentUserName,
      'receiverId': widget.otherUserId,
      'text': text,
      'timestamp': DateTime.now().toString(),
      'isRead': 0,
    };

    await DatabaseHelper.instance.insertMessage(newMessage);

    setState(() {
      _messages.insert(0, newMessage);
    });

    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent!'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFF6A11CB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUserName,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Online',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6, color: Colors.white),
            onPressed: () {
              final themeSwitcher = ThemeSwitcher.of(context);
              if (themeSwitcher != null) {
                themeSwitcher.onThemeChanged(!isDark);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat,
                          size: 60,
                          color: isDark ? Colors.white70 : Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Start a conversation!',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['senderId'] == widget.currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF4CAF50)
                                : isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: !isMe
                                ? Border.all(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                  )
                                : null,
                            boxShadow: !isMe && !isDark
                                ? [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(
                                  message['senderName'],
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                message['text'],
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(message['timestamp']),
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white70
                                      : (isDark ? Colors.white54 : Colors.grey),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF4CAF50),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
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

// User Management Screen
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await DatabaseHelper.instance.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleGPS(String userId, bool currentStatus) async {
    await DatabaseHelper.instance.updateUserPermissions(
      userId,
      gpsEnabled: !currentStatus,
    );
    await _loadUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: !currentStatus
            ? const Color(0xFF4CAF50)
            : const Color(0xFFF44336),
        content: Text(!currentStatus ? 'GPS Enabled' : 'GPS Disabled'),
      ),
    );
  }

  Future<void> _toggleMessaging(String userId, bool currentStatus) async {
    await DatabaseHelper.instance.updateUserPermissions(
      userId,
      messagingEnabled: !currentStatus,
    );
    await _loadUsers();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: !currentStatus
            ? const Color(0xFF4CAF50)
            : const Color(0xFFF44336),
        content: Text(
          !currentStatus ? 'Messaging Enabled' : 'Messaging Disabled',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2D1B69)]
                        : [const Color(0xFF2575FC), const Color(0xFF6A11CB)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'User Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: _loadUsers,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.person_add,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterUserScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Icon(Icons.people, size: 60, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text(
                      'Manage System Users',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          final gpsEnabled = user['gpsEnabled'] == 1;
                          final messagingEnabled =
                              user['messagingEnabled'] == 1;
                          final isAdmin = user['role'] == 'admin';

                          return Card(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: user['role'] == 'admin'
                                    ? const Color(0xFFF44336)
                                    : user['role'] == 'teacher'
                                    ? const Color(0xFF2196F3)
                                    : const Color(0xFF4CAF50),
                                child: Text(
                                  user['firstName'][0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                '${user['firstName']} ${user['lastName']}',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user['email']} - ${user['role']}',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: isAdmin
                                            ? null
                                            : () => _toggleGPS(
                                                user['id'],
                                                gpsEnabled,
                                              ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: gpsEnabled
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: gpsEnabled
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.gps_fixed,
                                                size: 12,
                                                color: gpsEnabled
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'GPS',
                                                style: TextStyle(
                                                  color: gpsEnabled
                                                      ? Colors.green
                                                      : Colors.red,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: isAdmin
                                            ? null
                                            : () => _toggleMessaging(
                                                user['id'],
                                                messagingEnabled,
                                              ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: messagingEnabled
                                                ? Colors.blue.withOpacity(0.2)
                                                : Colors.red.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: messagingEnabled
                                                  ? Colors.blue
                                                  : Colors.red,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.chat,
                                                size: 12,
                                                color: messagingEnabled
                                                    ? Colors.blue
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Messages',
                                                style: TextStyle(
                                                  color: messagingEnabled
                                                      ? Colors.blue
                                                      : Colors.red,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: user['role'] != 'admin'
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Color(0xFFF44336),
                                      ),
                                      onPressed: () => _deleteUser(user['id']),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteUser(String userId) async {
    await DatabaseHelper.instance.deleteUser(userId);
    setState(() {
      _users.removeWhere((user) => user['id'] == userId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF4CAF50),
        content: Text('User deleted successfully'),
      ),
    );
  }
}

// Register User Screen
class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'student';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Default permissions based on role
  bool _enableGPS = true;
  bool _enableMessaging = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2D1B69)]
                        : [const Color(0xFF2575FC), const Color(0xFF6A11CB)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          'Register New User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.brightness_6,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                          onPressed: () {
                            final themeSwitcher = ThemeSwitcher.of(context);
                            if (themeSwitcher != null) {
                              themeSwitcher.onThemeChanged(!isDark);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Icon(Icons.person_add, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'Add New User to System',
                      style: TextStyle(fontSize: 20, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextFormField(
                          controller: _firstNameController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextFormField(
                          controller: _lastNameController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            hintText: 'username@paperlink.edu',
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: isDark ? Colors.white70 : Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Role',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildRoleOption(
                                  'Student',
                                  'student',
                                  const Color(0xFF4CAF50),
                                  isDark,
                                ),
                                const SizedBox(width: 10),
                                _buildRoleOption(
                                  'Teacher',
                                  'teacher',
                                  const Color(0xFF2196F3),
                                  isDark,
                                ),
                                const SizedBox(width: 10),
                                _buildRoleOption(
                                  'Admin',
                                  'admin',
                                  const Color(0xFFF44336),
                                  isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Permission Settings
                      if (_selectedRole != 'admin')
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Enable Features',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 10),

                              // GPS Toggle
                              Row(
                                children: [
                                  Icon(
                                    Icons.gps_fixed,
                                    color: _enableGPS
                                        ? Colors.green
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'GPS Location Tracking',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Switch(
                                    value: _enableGPS,
                                    onChanged: _selectedRole == 'student'
                                        ? (value) =>
                                              setState(() => _enableGPS = value)
                                        : null,
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                              if (_selectedRole != 'student')
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 34,
                                    top: 4,
                                  ),
                                  child: Text(
                                    'Only students require GPS for attendance',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.6)
                                          : Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 15),

                              // Messaging Toggle
                              Row(
                                children: [
                                  Icon(
                                    Icons.chat,
                                    color: _enableMessaging
                                        ? Colors.blue
                                        : (isDark
                                              ? Colors.white70
                                              : Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Messaging System',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Switch(
                                    value: _enableMessaging,
                                    onChanged: (value) => setState(
                                      () => _enableMessaging = value,
                                    ),
                                    activeColor: Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_successMessage != null)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (_errorMessage != null || _successMessage != null)
                        const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'REGISTER USER',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'User Registration Guidelines',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• All users must have valid email\n'
                              '• Students get GPS enabled automatically\n'
                              '• Teachers get messaging enabled\n'
                              '• Admins have all features enabled\n'
                              '• Students need GPS for attendance tracking',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
    );
  }

  Widget _buildRoleOption(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    final isSelected = _selectedRole == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = value;
            // Set default permissions based on role
            if (value == 'student') {
              _enableGPS = true;
              _enableMessaging = true;
            } else if (value == 'teacher') {
              _enableGPS = false;
              _enableMessaging = true;
            } else if (value == 'admin') {
              _enableGPS = true;
              _enableMessaging = true;
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                value == 'student'
                    ? Icons.person
                    : value == 'teacher'
                    ? Icons.school
                    : Icons.admin_panel_settings,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white70 : Colors.grey),
                size: 24,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? color
                      : (isDark ? Colors.white70 : Colors.grey),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final existingUser = await DatabaseHelper.instance.getUserByEmail(email);

      if (existingUser != null) {
        setState(() {
          _errorMessage = 'Email already exists';
          _isLoading = false;
        });
        return;
      }

      // Set permissions based on role
      final gpsEnabled =
          _selectedRole == 'admin' ||
          (_selectedRole == 'student' && _enableGPS);
      final messagingEnabled = _selectedRole == 'admin' || _enableMessaging;

      final newUser = {
        'id': '${_selectedRole}_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'password': _passwordController.text,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'role': _selectedRole,
        'createdAt': DateTime.now().toString(),
        'gpsEnabled': gpsEnabled ? 1 : 0,
        'messagingEnabled': messagingEnabled ? 1 : 0,
        'locationPermission': 1, // Auto-enabled
        'cameraPermission': 1, // Auto-enabled
      };

      await DatabaseHelper.instance.insertUser(newUser);

      setState(() {
        _successMessage =
            'User registered successfully!\n'
            'GPS: ${gpsEnabled ? 'Enabled' : 'Disabled'}\n'
            'Messaging: ${messagingEnabled ? 'Enabled' : 'Disabled'}';
        _isLoading = false;
      });

      // Clear form
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
