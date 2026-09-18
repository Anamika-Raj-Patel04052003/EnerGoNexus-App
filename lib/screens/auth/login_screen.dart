import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/animated_ev_background.dart';
import '../home/home_screen.dart';
import '../driver/driver_main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // 0: Passenger, 1: Pilot/Captain, 2: Fleet Operator, 3: Supreme Admin
  int _selectedRoleIndex = 0;
  bool _isLoginMode = true; // true = Login, false = Register / Onboard

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _extraFieldController = TextEditingController();

  // Form State
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // 4 Industry Standard Enterprise Stakeholders
  final List<Map<String, dynamic>> _stakeholderRoles = [
    {
      'title': 'Passenger',
      'label': 'यात्री',
      'icon': LucideIcons.user,
      'color': const Color(0xFF00E5FF), // Electric Cyan
      'badge': 'COMMUTER',
      'desc': 'Book electric cabs, daily shuttle & share rides',
      'extraLabel': null,
      'extraHint': null,
    },
    {
      'title': 'Pilot / Captain',
      'label': 'चालक (Solo & Fleet)',
      'icon': LucideIcons.car,
      'color': const Color(0xFF10B981), // Emerald Green
      'badge': 'EV PILOT',
      'desc': 'Accept rides, OTP trip start & instant daily payouts',
      'extraLabel': 'Driving License / Vehicle RC Number',
      'extraHint': 'e.g. DL-0420230019284',
    },
    {
      'title': 'Fleet Operator',
      'label': 'फ्लीट ऑपरेटर',
      'icon': LucideIcons.building2,
      'color': const Color(0xFFF59E0B), // Amber Gold
      'badge': 'ENTERPRISE',
      'desc': 'Manage commercial EV fleet, corporate vault & shifts',
      'extraLabel': 'Enterprise / Agency GSTIN Number',
      'extraHint': 'e.g. 07AAAAA0000A1Z5 / Agency Name',
    },
    {
      'title': 'Supreme Admin',
      'label': 'प्लेटफॉर्म प्रशासन',
      'icon': LucideIcons.shieldCheck,
      'color': const Color(0xFF8B5CF6), // Royal Purple
      'badge': 'GOVERNANCE',
      'desc': 'Platform-wide dispatch, tariffs & security audits',
      'extraLabel': 'Security Master Passcode',
      'extraHint': 'Enter Master PIN',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _extraFieldController.dispose();
    super.dispose();
  }

  void _switchRole(int index) {
    setState(() {
      _selectedRoleIndex = index;
      _extraFieldController.clear();
    });
  }

  Future<void> _handleAuthentication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isLoginMode && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match! Please re-verify.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Save session in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final roleName = _stakeholderRoles[_selectedRoleIndex]['title'].toString().toLowerCase();
    await prefs.setString('auth_token', 'demo_energo_jwt_${DateTime.now().millisecondsSinceEpoch}');
    await prefs.setString('user_role', roleName);
    await prefs.setString('user_email', _emailPhoneController.text.trim());
    if (!_isLoginMode) {
      await prefs.setString('user_name', _nameController.text.trim());
    }

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final currentRole = _stakeholderRoles[_selectedRoleIndex];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle2, color: Colors.black, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isLoginMode
                    ? 'Login Successful: Welcome to ${currentRole['title']} Hub!'
                    : 'Registration Complete: Onboarded as ${currentRole['title']}!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
        backgroundColor: currentRole['color'],
        duration: const Duration(seconds: 2),
      ),
    );

    // Route to the appropriate dashboard
    Widget destination;
    if (_selectedRoleIndex == 0) {
      // Passenger Dashboard
      destination = const HomeScreen();
    } else {
      // Pilot / Fleet Operator / Supreme Admin Cockpit
      destination = const DriverMainNavigation();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeRole = _stakeholderRoles[_selectedRoleIndex];
    final Color roleAccentColor = activeRole['color'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: AnimatedEVBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top App Branding
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: roleAccentColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: roleAccentColor.withOpacity(0.4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: roleAccentColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              LucideIcons.zap,
                              color: roleAccentColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'EnerGo Nexus',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'INTELLIGENT EV MOBILITY & FLEET PLATFORM',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: roleAccentColor,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 1: Stakeholder Role Selector Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '1. SELECT YOUR PORTAL PROFILE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleAccentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            activeRole['badge'],
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: roleAccentColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.15,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _stakeholderRoles.length,
                      itemBuilder: (context, index) {
                        final role = _stakeholderRoles[index];
                        final isSelected = _selectedRoleIndex == index;
                        return InkWell(
                          onTap: () => _switchRole(index),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? role['color'].withOpacity(0.18) : const Color(0xFF131B2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? role['color'] : Colors.white12,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? role['color'].withOpacity(0.25) : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    role['icon'],
                                    color: isSelected ? role['color'] : Colors.white54,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        role['title'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? Colors.white : Colors.white70,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        role['label'],
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: isSelected ? role['color'] : Colors.white38,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Login vs Register Mode Toggle Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isLoginMode = true),
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isLoginMode ? roleAccentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Center(
                                  child: Text(
                                    'LOGIN (लॉगिन)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: _isLoginMode ? Colors.black : Colors.white70,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isLoginMode = false),
                              borderRadius: BorderRadius.circular(9),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isLoginMode ? roleAccentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Center(
                                  child: Text(
                                    'ONBOARD / REGISTER',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                      color: !_isLoginMode ? Colors.black : Colors.white70,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 3: Dynamic Form Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: roleAccentColor.withOpacity(0.35), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: roleAccentColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _isLoginMode ? LucideIcons.logIn : LucideIcons.userPlus,
                                  color: roleAccentColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isLoginMode
                                          ? '${activeRole['title']} Login'
                                          : 'Register as ${activeRole['title']}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: roleAccentColor,
                                      ),
                                    ),
                                    Text(
                                      activeRole['desc'],
                                      style: const TextStyle(fontSize: 11, color: Colors.white60),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Full Name (Only in Registration Mode)
                          if (!_isLoginMode) ...[
                            _buildInputLabel('Full Legal Name / पूरा नाम *'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              validator: (val) {
                                if (!_isLoginMode && (val == null || val.trim().isEmpty)) {
                                  return 'Please enter your full legal name';
                                }
                                return null;
                              },
                              decoration: _inputDecoration(
                                hint: 'e.g. Ramesh Chandra',
                                icon: LucideIcons.user,
                                accentColor: roleAccentColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Email or Mobile Number (Common)
                          _buildInputLabel('Official Email or Mobile Number *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailPhoneController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email or phone number';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(
                              hint: '+91 98765 43210 / user@energonexus.com',
                              icon: LucideIcons.mail,
                              accentColor: roleAccentColor,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Dynamic Role-Specific Field (License / GSTIN / Master Passcode)
                          if (activeRole['extraLabel'] != null && (!_isLoginMode || _selectedRoleIndex == 3)) ...[
                            _buildInputLabel('${activeRole['extraLabel']} *'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _extraFieldController,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please provide ${activeRole['extraLabel']}';
                                }
                                return null;
                              },
                              decoration: _inputDecoration(
                                hint: activeRole['extraHint'] ?? 'Enter detail',
                                icon: LucideIcons.badgeCheck,
                                accentColor: roleAccentColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Password Field
                          _buildInputLabel('Password / सुरक्षा पिन *'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            validator: (val) {
                              if (val == null || val.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              icon: LucideIcons.lock,
                              accentColor: roleAccentColor,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  color: Colors.white54,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Confirm Password (Only in Registration Mode)
                          if (!_isLoginMode) ...[
                            _buildInputLabel('Confirm Password / पासवर्ड दोहराएं *'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              validator: (val) {
                                if (!_isLoginMode && (val == null || val != _passwordController.text)) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              decoration: _inputDecoration(
                                hint: '••••••••',
                                icon: LucideIcons.checkCheck,
                                accentColor: roleAccentColor,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                    color: Colors.white54,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          const SizedBox(height: 8),

                          // Action Submit Button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuthentication,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: roleAccentColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isLoginMode
                                            ? 'CONTINUE TO ${activeRole['title'].toString().toUpperCase()}'
                                            : 'COMPLETE ${activeRole['title'].toString().toUpperCase()} ONBOARDING',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.5,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(LucideIcons.arrowRight, size: 16, color: Colors.black),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bottom Toggle Switch Text
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => _isLoginMode = !_isLoginMode);
                        },
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                            children: [
                              TextSpan(
                                text: _isLoginMode ? "New stakeholder / user? " : "Already registered? ",
                              ),
                              TextSpan(
                                text: _isLoginMode ? "Onboard & Register Here" : "Login to Portal",
                                style: TextStyle(color: roleAccentColor, fontWeight: FontWeight.bold),
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
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color accentColor,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.white54, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF0D1322),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}