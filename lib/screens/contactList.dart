import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat_app/Firebase/database.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> with WidgetsBindingObserver {
  dynamic listOfSnapshots;
  dynamic userMap;
  late dynamic id;

  Widget widgetDecision(
      requestArray, acceptedArray, uid, BuildContext context, index) {
    if (listOfSnapshots[index].get('requestSent').contains(userMap.get('id'))
        as bool) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ignore: deprecated_member_use
          FlatButton(
              onPressed: () {
                DatabaseServices(context).onAcceptRequest(
                    userMap.get('requestAccepted'),
                    listOfSnapshots[index].get('requestSent'),
                    listOfSnapshots[index].get('id'),
                    id);
              },
              minWidth: 50,
              child: Icon(Icons.check)),

          // ignore: deprecated_member_use
          FlatButton(
              onPressed: () {
                DatabaseServices(context).onDenyRequest(
                    userMap.get('requestAccepted'),
                    listOfSnapshots[index].get('id'),
                    id);
              },
              minWidth: 50,
              child: Icon(Icons.clear)),
        ],
      );
    } else if (userMap
            .get('requestAccepted')
            .contains(listOfSnapshots[index].get('id')) as bool ||
        listOfSnapshots[index].get('requestAccepted').contains(id) as bool) {
      print('Hi');
      return Column(
        children: [Icon(Icons.check), Text('Accepted')],
      );
    } else if (userMap
        .get('requestSent')
        .contains(listOfSnapshots[index].get('id')) as bool) {
      return Column(
        children: [Icon(Icons.send), Text('Request sent')],
      );
    }

    return TextButton(
        onPressed: () {
          DatabaseServices(context).onSendRequest(
              userMap.get('requestSent'), listOfSnapshots[index].get('id'), id);
        },
        child: Icon(Icons.add));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userMap.get('id') as String)
        .update({'status': "$status"});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //online
      setStatus("Online");
    } else {
      //offline
      setStatus("Offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    id = '';
    id = id.isEmpty as bool ? ModalRoute.of(context)!.settings.arguments : id;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
              child: Center(
            child: Text(
              'Co-passengers in your vicinity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )),
        ),
      ),
      body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listOfSnapshots = snapshot.data!.docs;
                  listOfSnapshots.forEach((element) {
                    if (element.get('id') == id) {
                      userMap = element;
                    }
                  });

                  listOfSnapshots.remove(userMap);

                  return ListView.builder(
                      itemCount: listOfSnapshots.length as int,
                      itemBuilder: (context, index) {
                        print(listOfSnapshots[index].get('blocked'));
                        print(userMap.get('requestSent'));
                        return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: ListTile(
                                leading: Icon(
                                  Icons.account_circle_outlined,
                                  size: 60,
                                ),
                                trailing: widgetDecision(
                                    listOfSnapshots[index].get('requestSent'),
                                    listOfSnapshots[index]
                                        .get('requestAccepted'),
                                    listOfSnapshots[index].get('id'),
                                    context,
                                    index),
                                title: Center(
                                  child: Text(
                                    listOfSnapshots[index].get('name')
                                        as String,
                                    style: TextStyle(fontSize: 17),
                                  ),
                                ),
                                subtitle: Center(
                                  child: Text(
                                    listOfSnapshots[index].get('aboutMe')
                                        as String,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                onTap: () async {
                                  if (listOfSnapshots[index]
                                          .get('requestAccepted')
                                          .contains(id) as bool ||
                                      userMap.get('requestAccepted').contains(
                                              listOfSnapshots[index].get('id'))
                                          as bool) {
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    List<dynamic> sortList = [
                                      pref.getString('id'),
                                      listOfSnapshots[index].id
                                    ];
                                    sortList.sort();
                                    dynamic finalString =
                                        sortList[0] + sortList[1];
                                    // ignore: unused_local_variable
                                    dynamic blockedByYou =
                                        pref.getString('blocked');
                                    Navigator.pushNamed(context, '/chatRoom',
                                        arguments: {
                                          'chatID': finalString,
                                          'id': pref.getString('id'),
                                          'peerID': listOfSnapshots[index].id,
                                          'name': listOfSnapshots[index]
                                              .get('name'),
                                          'blocked': listOfSnapshots[index]
                                              .get('blocked'),
                                          'blockedByYou':
                                              userMap.get('blocked'),
                                          'blockedStatus': userMap
                                              .get('blocked')
                                              .contains(listOfSnapshots[index]
                                                  .get('id')),
                                          'aboutMe': listOfSnapshots[index]
                                              .get('aboutMe')
                                        });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            'Please send a request to chat or wait for them to accept your request');
                                  }
                                },
                              ),
                            ));
                      });
                }
                return Center(child: CircularProgressIndicator());
              })),
    );
  }
}
