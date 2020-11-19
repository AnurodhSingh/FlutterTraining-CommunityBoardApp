import 'package:community_board_app/utils/guid_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_board_app/constants/strings.dart';
import 'cutom_card.dart';

/// Board screen
class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenWidgetState createState() => _BoardScreenWidgetState();
}

/// Board screen widget state
class _BoardScreenWidgetState extends State<BoardScreen> {
  var firestoreDb = Firestore.instance.collection("board").orderBy('timestamp', descending: false).snapshots();
  TextEditingController nameInputController;
  TextEditingController titleInputController;
  TextEditingController descriptionInputController;
  GUIDUtils guidUtils;
  String userID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setGUID();
    nameInputController = TextEditingController();
    titleInputController = TextEditingController();
    descriptionInputController = TextEditingController();
  }

  setGUID() async {
    // Fetch guid from shared preference.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String guid = prefs.getString(GUID);

    // If guid is not present in the shared preference then 
    // create a new one and store it.
    if(guid == null)
    {
      var uuid = Uuid();
      guid = uuid.v4();
      await prefs.setString(GUID, guid);
    }
    GUIDUtils guidUtils = new GUIDUtils();
    guidUtils.setGuid(guid);
    userID = guidUtils.getGuid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community Board')),
      body: StreamBuilder(
          stream: firestoreDb,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, int index ) {
                  return(
                    CustomCard(snapshot: snapshot.data, index: index, userID: userID)
                  );
                });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog(context);
        },
        child: Icon(FontAwesomeIcons.pen),
      ),
    );
  }

  _showDialog(BuildContext context) async {
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
                  clearInputFields();
                  Navigator.pop(context);
                },
                child: Text('Cancel')),
            FlatButton(
                onPressed: () {
                  if (nameInputController.text.isNotEmpty &&
                      titleInputController.text.isNotEmpty &&
                      descriptionInputController.text.isNotEmpty) {
                    saveDataToFirestore(
                        nameInputController.text,
                        titleInputController.text,
                        descriptionInputController.text);
                  }
                },
                child: Text('Save'))
          ],
        ));
  }

  void clearInputFields() {
    nameInputController.clear();
    titleInputController.clear();
    descriptionInputController.clear();
  }

  void saveDataToFirestore(String name, String title, String description) {
    Firestore.instance.collection("board").add({
      "id": userID,
      "name": name,
      "title": title,
      "description": description,
      "timestamp": new DateTime.now()
    }).then((response) {
      print(response.documentID);
      clearInputFields();
      Navigator.pop(context);
    }).catchError((error){
      print(error);
    });
  }
}
