import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'athlete_account_creation_screen.dart';

class AthleteJoinScreen extends StatefulWidget {
  const AthleteJoinScreen({super.key});

  @override
  State<AthleteJoinScreen> createState() => _AthleteJoinScreenState();
}

class _AthleteJoinScreenState extends State<AthleteJoinScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _error;
  bool _isValidCode = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to controllers
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        _checkCodeValidity();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _checkCodeValidity() {
    final code = _getCode();
    setState(() {
      _isValidCode = code.length == 6;
    });
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyCode() async {
    final code = _getCode();
    if (code.length != 6) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, accept any 6-character code
    // In real app, this would validate against backend
    if (code.length == 6) {
      setState(() {
        _isLoading = false;
      });

      // Show success animation
      _showSuccessAnimation();

      // Navigate to account creation after animation
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AthleteAccountCreationScreen(inviteCode: code),
            ),
          );
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _error = 'CODE NOT RECOGNIZED. CHECK WITH YOUR COACH.';
      });
      _shakeBoxes();
    }
  }

  void _showSuccessAnimation() {
    // This would show a checkmark animation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFFD4A017)),
            SizedBox(width: 8),
            Text('Code verified successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shakeBoxes() {
    // Animate boxes to shake on error
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].clear();
    }
    _focusNodes[0].requestFocus();
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text(
              'ENTER YOUR ACCESS CODE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Your coach sent you a 6-character code.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            // OTP input boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  height: 55,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLength: 1,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(1),
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _error != null
                              ? Colors.red
                              : const Color(0xFFD4A017),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _error != null
                              ? Colors.red
                              : Colors.white30,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFD4A017),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1a1a1a),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidCode && !_isLoading ? _verifyCode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValidCode
                      ? const Color(0xFFD4A017)
                      : Colors.grey,
                  foregroundColor: _isValidCode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'VERIFY CODE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to request code screen or show dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact your coach for an access code.'),
                  ),
                );
              },
              child: const Text(
                'REQUEST A CODE',
                style: TextStyle(
                  color: Color(0xFFD4A017),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}