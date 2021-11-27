import 'package:flutter/material.dart';
import 'package:salon_creator/common/color.dart';
import 'package:salon_creator/firebase/database.dart';
import 'package:salon_creator/screens/lesson_edit_screen.dart';
import 'package:salon_creator/widgets/custom_dialog.dart';

class LessonInfo {
  final String salonId;
  final String lessonId;
  LessonInfo({this.salonId, this.lessonId});
}

class LessonCard extends StatefulWidget {
  const LessonCard(
      {Key key,
      this.title,
      this.imageUrl,
      this.salonId,
      this.lessonId,
      this.isPublished,
      this.context})
      : super(key: key);
  final String title;
  final String imageUrl;
  final String salonId;
  final String lessonId;
  final bool isPublished;
  final BuildContext context;

  @override
  _LessonCardState createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard> {
  final dbHandler = DbHandler();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 180),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              widget.imageUrl != ""
                  ? Container(
                      height: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(widget.imageUrl),
                        ),
                      ),
                    )
                  : Container(height: 120, color: Colors.grey.shade400),
              Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonEditScreen(
                          lessonInfo: LessonInfo(
                              salonId: widget.salonId,
                              lessonId: widget.lessonId),
                        ),
                      ),
                    );
                    // Navigator.of(context).pushNamed(
                    //   '/lesson/edit',
                    //   arguments: LessonInfo(
                    //       salonId: widget.salonId, lessonId: widget.lessonId),
                    // );
                  },
                  icon: Icon(Icons.edit, color: Colors.white),
                ),
              )
            ],
          ),
          Container(
            color: widget.isPublished ? primaryColor : Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text(
                    widget.title != null ? widget.title : "未設定",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    showCustomDialog(
                      context: context,
                      title: Text("本当に削除しますか？"),
                      content: "選択されたレッスンが削除されます",
                      leftButtonText: "削除する",
                      rightButtonText: "取り消し",
                      leftFunction: () async {
                        Navigator.of(context).pop(widget.context);
                        await dbHandler.deleteLesson(
                            widget.lessonId, widget.salonId);
                      },
                      rightFunction: () {
                        Navigator.of(context).pop(widget.context);
                      },
                    );
                  },
                  child: Icon(Icons.delete, color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
