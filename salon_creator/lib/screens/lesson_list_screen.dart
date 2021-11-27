import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/models/creator_model.dart';
import 'package:salon_creator/widgets/lesson_card.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({Key key, this.creator}) : super(key: key);
  final CreatorModel creator;

  @override
  _LessonListScreenState createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  List<Widget> lessons = [];
  final dbHanlder = DbHandler();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(DbHandler.salonsCollection)
          .doc(widget.creator.salonId)
          .collection(DbHandler.lessonsCollection)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }
        return Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: LessonCard(
                  isPublished: data['isPublish'],
                  lessonId: document.id,
                  salonId: widget.creator.salonId,
                  title: data['name'],
                  imageUrl:
                      data['thumbnailUrl'] != null ? data['thumbnailUrl'] : "",
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
