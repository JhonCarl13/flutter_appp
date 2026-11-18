import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'student_form_page.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final collection = FirebaseFirestore.instance.collection('users').doc(uid).collection('students');
    const deepGreen = Color(0xFF0C5132);
    const surfaceColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: const Text(
          'Student Records',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: deepGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentFormPage())),
        icon: const Icon(Icons.add_rounded), 
        label: const Text('Add Student', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collection.orderBy('fullName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Unable to load students.', style: TextStyle(color: Colors.redAccent)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: deepGreen));
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.folder_open_rounded, size: 48, color: deepGreen),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No student records yet.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1D1E)),
                  ),
                  const SizedBox(height: 4),
                  Text('Tap "Add Student" below to create one.', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final fullName = data['fullName'] ?? 'No Name';
              final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'S';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE8F5E9),
                    foregroundColor: deepGreen,
                    child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(
                    fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A1D1E)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'No: ${data['studentNumber'] ?? 'N/A'} • ${data['course'] ?? ''} (${data['yearLevel'] ?? ''})\n${data['email'] ?? ''}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (action) async {
                      if (action == 'edit') {
                        if (!context.mounted) return;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => StudentFormPage(documentId: doc.id, initialData: data)));
                      } else if (action == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Delete student?'),
                            content: Text('Delete $fullName? This cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.pop(dialogContext, true), 
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          try {
                            await collection.doc(doc.id).delete();
                          } catch (e) {
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [Icon(Icons.edit_outlined, size: 18, color: Colors.blue), SizedBox(width: 10), Text('Edit')]),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 10), Text('Delete')]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}