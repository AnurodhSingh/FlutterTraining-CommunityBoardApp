import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// CustomCard
class CustomCard extends StatelessWidget {
  final QuerySnapshot snapshot;
  final index;
  final userID;

  const CustomCard({Key key, this.snapshot, this.index, this.userID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var timeToDate = new DateTime.fromMillisecondsSinceEpoch(
        snapshot.documents[index].data['timestamp'].seconds * 1000);
    var dateFormat =
        new DateFormat("h:mm a,\t\t\t\t\td/MM/y ").format(timeToDate);
    var docId = snapshot.documents[index].documentID;

    return (Column(
      children: [
        Container(
          child: Card(
              elevation: 9,
              child: Column(
                children: [
                  ListTile(
                    title: Text(snapshot.documents[index].data['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.0,
                          ),
                          child: Text(
                              snapshot.documents[index].data['description']),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 5.0,
                          ),
                          child: Text(dateFormat),
                        ),
                      ],
                    ),
                    leading: CircleAvatar(
                        radius: 34,
                        child: Text(snapshot.documents[index].data['name']
                            .toString()[0])),
                    contentPadding: EdgeInsets.only(bottom: 5),
                  ),
                  showOptions(context, docId, userID),
                ],
              )),
        )
      ],
    ));
  }


  Widget showOptions(BuildContext context, String docId, String userID) {
    if (userID != null && userID == snapshot.documents[index].data['id']) {
      return (Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
              icon: Icon(
                FontAwesomeIcons.edit,
                size: 16,
              ),
              onPressed: () {
                _showDialog(
                    context,
                    snapshot.documents[index].data['name'],
                    snapshot.documents[index].data['title'],
                    snapshot.documents[index].data['description'],
                    docId);
              }),
          IconButton(
              icon: Icon(
                FontAwesomeIcons.trash,
                size: 16,
              ),
              onPressed: () {
                onDeletePost(docId);
              })
        ],
      ));
    }
    return (
      Container()
    );
  }

  void _showDialog(BuildContext context, String name, String title,
      String description, String docId) async {
    TextEditingController nameInputController = TextEditingController();
    TextEditingController titleInputController = TextEditingController();
    TextEditingController descriptionInputController = TextEditingController();
    nameInputController.text = name;
    titleInputController.text = title;
    descriptionInputController.text = description;
    await showDialog(
        context: context,
        child: AlertDialog(
          contentPadding: EdgeInsets.all(10),
          content: Column(children: [
            Text('Please fill out the form.'),
            Expanded(
                child: TextField(
              autofocus: true,
              autocorrect: true,
              decoration: InputDecoration(labelText: "Your Name"),
              controller: nameInputController,
            )),
            Expanded(
                child: TextField(
              autofocus: true,
              autocorrect: true,
              decoration: InputDecoration(labelText: "Title"),
              controller: titleInputController,
            )),
            Expanded(
                child: TextField(
              autofocus: true,
              autocorrect: true,
              decoration: InputDecoration(labelText: "Description"),
              controller: descriptionInputController,
            ))
          ]),
          actions: [
            FlatButton(
                onPressed: () {
                  onEditPost(
                          docId,
                          nameInputController.text,
                          titleInputController.text,
                          descriptionInputController.text)
                      .then((res) {
                    nameInputController.clear();
                    titleInputController.clear();
                    descriptionInputController.clear();
                    Navigator.pop(context);
                  });
                },
                child: Text('Update')),
          ],
        ));
  }

  Future onEditPost(
      String docId, String name, String title, String description) async {
    return Firestore.instance.collection("board").document(docId).updateData({
      "name": name,
      "title": title,
      "description": description,
    });
  }

  onDeletePost(String docId) async {
    await Firestore.instance.collection("board").document(docId).delete();
  }
}
