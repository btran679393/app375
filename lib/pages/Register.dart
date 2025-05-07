import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _error = '';
  String _success = '';

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = "Passwords do not match.";
        _success = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
      _success = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5274/api/Auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _success = "Registration successful! You can now log in.";
          _usernameController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        setState(() {
          _error = "Registration failed (${response.statusCode}): ${utf8.decode(response.bodyBytes)}";
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Register", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "BTAnime Registration",
              style: TextStyle(color: Colors.white, fontSize: 26),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red)),
            if (_success.isNotEmpty)
              Text(_success, style: const TextStyle(color: Colors.greenAccent)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
