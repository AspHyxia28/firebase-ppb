import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notif_firebase/database/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void openNoteBox({String? docID, String? existingText}) {
    textController.text = existingText ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(docID == null ? 'Add Note' : 'Update Note'),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final text = textController.text.trim();
                    Navigator.pop(context);

                    if (docID == null) {
                      firestoreService.addNote(text);
                    } else {
                      firestoreService.updateNote(docID, text);
                    }
                    textController.clear();
                  }
                },
                child: Text(docID == null ? 'Add' : 'Update'),
              ),
            ],
          ),
    ).then((_) {
      textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
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
                        icon: const Icon(Icons.settings),
                        onPressed:
                            () => openNoteBox(
                              docID: docID,
                              existingText: noteText,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => firestoreService.deleteNote(docID),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading notes'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
