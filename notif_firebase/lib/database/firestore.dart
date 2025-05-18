import 'package:flutter/material.dart';
import 'package:notif_firebase/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notif_firebase/pages/home_page.dart';

Future<void> addNote(String note) {
  return notes.add({'note': note, 'timestamp': Timestamp.now()});
}

Stream<QuerySnapshot> getNotesStream() {
  return notes.orderBy('timestamp', descending: true).snapshots();
}

Future<void> updateNote(String docID, String newNote) {
  return notes.doc(docID).update({
    'note': newNote,
    'timestamp': Timestamp.now(),
  });
}

Future<void> deleteNote(String docID) {
  return notes.doc(docID).delete();
}
