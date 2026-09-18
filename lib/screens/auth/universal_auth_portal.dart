import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../home/home_screen.dart';
import '../driver/driver_main_navigation.dart';

class UniversalAuthPortal extends StatefulWidget {
  const UniversalAuthPortal({super.key});

  @override
  State<UniversalAuthPortal> createState() => _UniversalAuthPortalState();
}

class _UniversalAuthPortalState extends State<UniversalAuthPortal> {
  int _selectedRoleIndex = 0; // 0: Passenger, 1: Pilot/Captain, 2: Fleet Operator, 3: Supreme Admin
  bool _isLoginMode = true; // true: Login, false: Register

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _extraController = TextEditingController(); 
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Passenger',
      'label': 'यात्री',
      'icon': LucideIcons.user,
      'color': const Color(0xFF00E5FF),
      'desc': 'Book electric cabs, daily shuttle & share rides',
      'extraLabel': null,
    },
    {
      'title': 'Pilot / Captain',
      'label': 'चालक (Solo & Fleet)',
      'icon': LucideIcons.car,
      'color': const Color(0xFF10B981),
      'desc': 'Accept rides, OTP trip start & daily bank payouts',
      'extraLabel': 'Driving License / Vehicle RC',
    },
    {
      'title': 'Fleet Operator',
      'label': 'फ्लीट ऑपरेटर / पार्टनर',
      'icon': LucideIcons.building2,
      'color': const Color(0xFFF59E0B),
      'desc': 'Manage commercial EV fleet, corporate vault & driver shifts',
      'extraLabel': 'Enterprise / Agency Name',
    },
    {
      'title': 'Supreme Admin',
      'label': 'प्लेटफॉर्म प्रशासन',
      'icon': LucideIcons.shieldCheck,
      'color': const Color(0xFF8B5CF6),
      'desc': 'Platform-wide dispatch, tariffs & audit controls',
      'extraLabel': 'Security Master Passcode',
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  void _handleAuthSubmit() async {
    final emailPhone = _emailPhoneController.text.trim();
    final password = _passwordController.text.trim();

    if (emailPhone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required credentials!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);

    if (!mounted) return;

    final currentRole = _roles[_selectedRoleIndex]['title'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome to $currentRole Workspace!'),
        backgroundColor: _roles[_selectedRoleIndex]['color'],
      ),
    );

    // Target Screen Navigation
    Widget targetScreen;
    if (_selectedRoleIndex == 0) {
      // Passenger Home Screen
      targetScreen = const HomeScreen();
    } else {
      // Pilot / Fleet Operator / Admin Navigation
      targetScreen = const DriverMainNavigation();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeRole = _roles[_selectedRoleIndex];
    final Color roleColor = activeRole['color'];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Branding
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.zap, color: roleColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EnerGo Nexus',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'ENTERPRISE MOBILITY ECOSYSTEM',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Role Selector Grid
              const Text(
                '1. SELECT STAKEHOLDER PROFILE / प्रोफाइल चुनें:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = _selectedRoleIndex == index;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRoleIndex = index;
                        _extraController.clear();
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
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
                          Icon(role['icon'], color: isSelected ? role['color'] : Colors.white54, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  role['title'],
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

              // Login vs Register Toggle Switch
              Container(
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLoginMode ? roleColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              'PORTAL LOGIN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _isLoginMode ? Colors.black : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _isLoginMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLoginMode ? roleColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              'ONBOARD / REGISTER',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: !_isLoginMode ? Colors.black : Colors.white60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: roleColor.withOpacity(0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isLoginMode
                          ? '${activeRole['title']} Access'
                          : 'Onboard New ${activeRole['title']}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: roleColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeRole['desc'],
                      style: const TextStyle(fontSize: 12, color: Colors.white60),
                    ),
                    const SizedBox(height: 18),

                    // Register Only Field: Full Name
                    if (!_isLoginMode) ...[
                      _buildTextField(
                        controller: _nameController,
                        label: _selectedRoleIndex == 2 ? 'Authorized Person Name' : 'Full Name / पूरा नाम',
                        icon: LucideIcons.user,
                        hint: 'e.g. Ramesh Kumar',
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Email or Phone
                    _buildTextField(
                      controller: _emailPhoneController,
                      label: 'Official Email or Mobile Number',
                      icon: LucideIcons.phone,
                      hint: '+91 98765 43210 / contact@domain.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Role Specific Field
                    if (activeRole['extraLabel'] != null && (!_isLoginMode || _selectedRoleIndex == 3)) ...[
                      _buildTextField(
                        controller: _extraController,
                        label: activeRole['extraLabel'],
                        icon: LucideIcons.badgeCheck,
                        hint: 'Enter ${activeRole['extraLabel']}',
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password / Security PIN',
                      icon: LucideIcons.lock,
                      hint: '••••••••',
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 22),

                    // Submit Action Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleAuthSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: roleColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                            )
                          : Text(
                              _isLoginMode
                                  ? 'PROCEED TO ${activeRole['title'].toString().toUpperCase()} DASHBOARD'
                                  : 'COMPLETE ${activeRole['title'].toString().toUpperCase()} ONBOARDING',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mode Toggle Footer
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
                          text: _isLoginMode
                              ? "New partner / user? "
                              : "Already registered? ",
                        ),
                        TextSpan(
                          text: _isLoginMode ? 'Onboard & Register' : 'Login Here',
                          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white54, size: 18),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.white54,
                      size: 18,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF0D1322),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}