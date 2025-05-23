import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notif_firebase/pages/home.dart';
import 'package:notif_firebase/services/firestore.dart';
import 'package:notif_firebase/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController textController = TextEditingController();

  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: TextField(controller: textController),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (docID == null) {
                    firestoreService.addNote(textController.text);
                    // Show notification for new note
                    await NotificationService.createNotification(
                      id: DateTime.now().millisecondsSinceEpoch.remainder(
                        100000,
                      ),
                      title: 'Note Added',
                      body: 'Your note has been added!',
                    );
                  } else {
                    firestoreService.updateNote(docID, textController.text);
                  }

                  textController.clear();
                  Navigator.pop(context);
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          openNoteBox(docID: docID);
                          await NotificationService.createNotification(
                            id: DateTime.now().millisecondsSinceEpoch.remainder(
                              100000,
                            ),
                            title: 'Edit Note',
                            body: 'You are editing a note.',
                          );
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () async {
                          firestoreService.deleteNote(docID);
                          await NotificationService.createNotification(
                            id: DateTime.now().millisecondsSinceEpoch.remainder(
                              100000,
                            ),
                            title: 'Note Deleted',
                            body: 'A note has been deleted.',
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text("No notes found");
          }
        },
      ),
    );
  }
}
