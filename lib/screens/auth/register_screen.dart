import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
    setState(() => _loading = true);

    try {
      // 1️⃣ TẠO USER FIREBASE AUTH
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // 2️⃣ LƯU CUSTOMER VÀO FIRESTORE
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(uid)
          .set({
        'customerId': uid,
        'email': _emailCtrl.text.trim(),
        'fullName': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'preferences': [],
        'loyaltyPoints': 0,
        'createdAt': Timestamp.now(),
        'isActive': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );

      Navigator.pop(context); // quay lại Login
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Đăng ký thất bại')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Center(
        child: SizedBox(
          width: 480,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                const Icon(Icons.person_add,
                    size: 60, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'Tạo tài khoản',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _buildField(_nameCtrl, 'Họ và tên', Icons.person),
                _buildField(_emailCtrl, 'Email', Icons.email),
                _buildField(_passwordCtrl, 'Mật khẩu', Icons.lock,
                    obscure: true),
                _buildField(_phoneCtrl, 'Số điện thoại', Icons.phone),
                _buildField(_addressCtrl, 'Địa chỉ', Icons.home),

                const SizedBox(height: 24),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text('Đăng ký'),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
