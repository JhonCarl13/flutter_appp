import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentFormPage extends StatefulWidget {
  final String? documentId;
  final Map<String, dynamic>? initialData;
  const StudentFormPage({super.key, this.documentId, this.initialData});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _name;
  late final TextEditingController _course;
  late final TextEditingController _year;
  late final TextEditingController _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? {};
    _number = TextEditingController(text: d['studentNumber'] ?? '');
    _name = TextEditingController(text: d['fullName'] ?? '');
    _course = TextEditingController(text: d['course'] ?? '');
    _year = TextEditingController(text: d['yearLevel'] ?? '');
    _email = TextEditingController(text: d['email'] ?? '');
  }

  @override
  void dispose() {
    for (final c in [_number, _name, _course, _year, _email]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final collection = FirebaseFirestore.instance.collection('users').doc(uid).collection('students');
    final data = {
      'studentNumber': _number.text.trim(),
      'fullName': _name.text.trim(),
      'course': _course.text.trim(),
      'yearLevel': _year.text.trim(),
      'email': _email.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      if (widget.documentId == null) {
        await collection.add({...data, 'createdAt': FieldValue.serverTimestamp()});
      } else {
        await collection.doc(widget.documentId).update(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool email = false}) {
    const deepGreen = Color(0xFF0C5132);
    const surfaceColor = Color(0xFFF8F9FA);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: deepGreen, width: 1.8),
          ),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return '$label is required';
          if (email && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email';
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const deepGreen = Color(0xFF0C5132);
    const surfaceColor = Color(0xFFF8F9FA);
    final isEditing = widget.documentId != null;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Student Record' : 'Add New Student',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isEditing ? Icons.edit_note_rounded : Icons.person_add_rounded,
                              color: deepGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEditing ? 'Update Student Details' : 'Student Information',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1D1E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isEditing ? 'Modify the fields below' : 'Fill in the student details',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _field(_number, 'Student Number', Icons.badge_outlined),
                      _field(_name, 'Full Name', Icons.person_outline),
                      _field(_course, 'Course', Icons.school_outlined),
                      _field(_year, 'Year Level', Icons.calendar_today_outlined),
                      _field(_email, 'Email Address', Icons.email_outlined, email: true),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: deepGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  isEditing ? 'Update Changes' : 'Save Student',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
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
      ),
    );
  }
}