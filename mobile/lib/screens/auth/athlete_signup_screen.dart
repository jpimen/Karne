import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/index.dart';
import '../index.dart';

class AthleteSignupScreen extends StatefulWidget {
  const AthleteSignupScreen({super.key});

  @override
  State<AthleteSignupScreen> createState() => _AthleteSignupScreenState();
}

class _AthleteSignupScreenState extends State<AthleteSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;
  String? _error;
  String _passwordStrength = '';
  double _passwordStrengthValue = 0.0;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.length < 6) {
        _passwordStrength = 'Weak';
        _passwordStrengthValue = 0.3;
      } else if (password.length < 8) {
        _passwordStrength = 'Fair';
        _passwordStrengthValue = 0.6;
      } else if (RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
        _passwordStrength = 'Strong';
        _passwordStrengthValue = 1.0;
      } else {
        _passwordStrength = 'Good';
        _passwordStrengthValue = 0.8;
      }
    });
  }

  Future<void> _signup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _error = 'Please fill in all required fields';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = 'Passwords do not match';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.apiService.register(
        _nameController.text, // Using name as username for now
        _emailController.text,
        _passwordController.text,
        role: 'client',
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AthleteLoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SIGN UP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Logo
            const Text(
              'THE LABORATORY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 2,
              color: const Color(0xFFD4A017),
            ),
            const SizedBox(height: 40),
            // Profile photo
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1a1a1a),
                  border: Border.all(
                    color: const Color(0xFFD4A017),
                    width: 2,
                  ),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFD4A017),
                        size: 40,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to add photo (optional)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 40),
            // Name field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'FULL NAME',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4A017)),
                ),
                filled: true,
                fillColor: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 20),
            // Email field
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'EMAIL ADDRESS',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4A017)),
                ),
                filled: true,
                fillColor: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 20),
            // Password field
            TextField(
              controller: _passwordController,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              onChanged: _checkPasswordStrength,
              decoration: const InputDecoration(
                labelText: 'CREATE PASSWORD',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4A017)),
                ),
                filled: true,
                fillColor: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 8),
            // Password strength indicator
            if (_passwordController.text.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _passwordStrengthValue,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _passwordStrengthValue < 0.6
                            ? Colors.red
                            : _passwordStrengthValue < 0.8
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _passwordStrength,
                    style: TextStyle(
                      color: _passwordStrengthValue < 0.6
                          ? Colors.red
                          : _passwordStrengthValue < 0.8
                              ? Colors.orange
                              : Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Confirm password field
            TextField(
              controller: _confirmPasswordController,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'CONFIRM PASSWORD',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD4A017)),
                ),
                filled: true,
                fillColor: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A017),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Already have account
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AthleteLoginScreen()),
                );
              },
              child: const Text(
                'ALREADY HAVE AN ACCOUNT? LOGIN',
                style: TextStyle(
                  color: Color(0xFFD4A017),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Join with invite code
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AthleteJoinScreen()),
                );
              },
              child: const Text(
                'JOIN WITH INVITE CODE',
                style: TextStyle(
                  color: Color(0xFFD4A017),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

