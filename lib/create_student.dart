import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateStudent extends StatefulWidget {
  const CreateStudent({super.key});

  @override
  State<CreateStudent> createState() => _CreateStudentState();
}

class _CreateStudentState extends State<CreateStudent> {
  final TextEditingController _studentNoController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  // Define the green theme color
  final Color primaryGreen = const Color(0xFF0F8A17);

  @override
  void dispose() {
    _studentNoController.dispose();
    _fullNameController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> saveStudent() async {
    final studentNo = _studentNoController.text.trim();
    final fullName = _fullNameController.text.trim();
    final course = _courseController.text.trim();

    if (studentNo.isEmpty || fullName.isEmpty || course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Save student details to Firestore
    await FirebaseFirestore.instance.collection('students').add({
      'student_no': studentNo,
      'name': fullName,
      'course': course,
      'createdAt': FieldValue.serverTimestamp(),
    });

    _studentNoController.clear();
    _fullNameController.clear();
    _courseController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Student added successfully!'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: primaryGreen, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Create Student",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner inside card
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            color: primaryGreen,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Student Information",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Enter the details below to register a new student",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Color(0xFFF1F5F9), height: 1),
                    ),

                    // Student No. Field
                    _buildCustomTextField(
                      controller: _studentNoController,
                      labelText: "Student Number",
                      hintText: "e.g., 2026-0001",
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Full Name Field
                    _buildCustomTextField(
                      controller: _fullNameController,
                      labelText: "Full Name",
                      hintText: "e.g., Juan Dela Cruz",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Course Field
                    _buildCustomTextField(
                      controller: _courseController,
                      labelText: "Course / Program",
                      hintText: "e.g., BS Information Technology",
                      icon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: saveStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Save Student Record",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
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
}