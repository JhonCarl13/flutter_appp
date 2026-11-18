import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'create_student.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final students = FirebaseFirestore.instance.collection('students');

  String getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // Opens a pre-filled bottom sheet or dialog to edit the student record
  void _showEditStudentDialog(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final studentNoController = TextEditingController(text: data['student_no'] ?? '');
    final nameController = TextEditingController(text: data['name'] ?? '');
    final courseController = TextEditingController(text: data['course'] ?? '');
    const primaryColor = Color(0xFF0C5132);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Student Record',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D1E),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: studentNoController,
                decoration: InputDecoration(
                  labelText: 'Student Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: courseController,
                decoration: InputDecoration(
                  labelText: 'Course / Program',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty || courseController.text.trim().isEmpty) return;
                    
                    await students.doc(document.id).update({
                      'student_no': studentNoController.text.trim(),
                      'name': nameController.text.trim(),
                      'course': courseController.text.trim(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0C5132);
    const surfaceColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          "Student Management",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateStudent()),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 22),
              tooltip: 'Add Student',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: students.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  final documents = snapshot.data?.docs ?? [];

                  if (documents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No student records yet.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      final data = document.data() as Map<String, dynamic>;

                      final studentno = data["student_no"] ?? '';
                      final name = data["name"] ?? '';
                      final course = data['course'] ?? '';

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 14),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFFE8F5E9),
                                    child: Text(
                                      getInitials(name),
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1D1E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.badge_outlined,
                                              size: 15,
                                              color: Colors.grey.shade500,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                studentno,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Edit Button - now opens pre-filled edit panel
                                  IconButton(
                                    onPressed: () => _showEditStudentDialog(context, document),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: Colors.blue.shade600,
                                      size: 22,
                                    ),
                                    tooltip: 'Edit Record',
                                  ),
                                  // Delete Button
                                  IconButton(
                                    onPressed: () async {
                                      await students.doc(document.id).delete();
                                    },
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.red.shade400,
                                      size: 22,
                                    ),
                                    tooltip: 'Delete Record',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.school_outlined,
                                      size: 15,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        course,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}