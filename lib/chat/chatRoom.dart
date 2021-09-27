import 'package:chat_app/Firebase/database.dart';
import 'package:chat_app/chat/repliesRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  dynamic messages;
  TextEditingController textMessage = TextEditingController();
  dynamic data = {};
  late bool blockedStatus;
  Map<bool, Widget> widgetMap = {
    true: Icon(Icons.block),
    false: Icon(Icons.undo)
  };

  blockMechanism() async {
    data['blockedByYou'] = await DatabaseServices(context).onBlockOrUnblock(
        data['id'],
        data['peerID'],
        data['blockedByYou'],
        context,
        data['blockedStatus']);
    data['blockedStatus'] = !(data['blockedStatus'] as bool);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isEmpty as bool
        ? ModalRoute.of(context)!.settings.arguments
        : data;
    DatabaseServices(context).blocked(data['blockedStatus'] as bool);
    blockedStatus = DatabaseServices(context).getBlockedStatus as bool;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  child: Icon(Icons.account_circle_outlined),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        data['name'] as String,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(data['aboutMe'] + " | " as String),
                          StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc('${data['peerID']}')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      snapshot.data!.get('status') as String);
                                } else
                                  return Text("offline");
                              })
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                bool x = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                            'Are you sure you want to ${blockedStatus ? 'unblock' : 'block'} this conversation ?'),
                        content: Container(
                          width: 100,
                          height: 100,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                await blockMechanism();
                                Navigator.pop(context, !blockedStatus);
                              },
                              child: Text('Yes')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context, blockedStatus);
                              },
                              child: Text('No'))
                        ],
                      );
                    }) as bool;
                print(x);
                print(blockedStatus);
                DatabaseServices(context).getCurrentBlockedStatus(x);
                blockedStatus =
                    DatabaseServices(context).getBlockedStatus as bool;
                print(blockedStatus);
              },
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('id', isEqualTo: data['peerID'])
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data!.docs[0].get('blocked'));
                    data['blocked'] = snapshot.data!.docs[0].get('blocked');
                  }
                  return Icon(blockedStatus ? Icons.undo : Icons.block);
                },
              ))
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(data['chatID'] as String)
                    .collection(data['chatID'] as String)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  print(data);
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueGrey)));
                  } else {
                    messages = snapshot.data!.docs;
                    DatabaseServices(context).markRead(
                        data['peerID'] as String,
                        FirebaseFirestore.instance
                            .collection('messages')
                            .doc(data['chatID'] as String)
                            .collection(data['chatID'] as String));
                    return ListView.builder(
                      itemCount: messages.length as int,
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          child: Align(
                            alignment:
                                (messages[index].get('idFrom') == data['id']
                                    ? Alignment.topRight
                                    : Alignment.topLeft),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => RepliesRoom(
                                        messages[index],
                                        data['chatID'] as String,
                                        data['peerID'] as String,
                                        data['id'] as String,
                                        data['blockedStatus'] as bool)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: messages[index].get('idFrom') ==
                                          data['id']
                                      ? BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20))
                                      : BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                  border: Border.all(
                                      color: (messages[index].get('idFrom') ==
                                              data['id']
                                          ? Colors.black
                                          : Colors.green)),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          messages[index].get('content')
                                              as String,
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: (messages[index]
                                                          .get('idFrom') ==
                                                      data['id']
                                                  ? Colors.black
                                                  : Colors.green)),
                                        ),
                                      ),
                                    ),
                                    messages[index].get('idFrom') == data['id']
                                        ? Icon(
                                            Icons.done_all,
                                            size: 16,
                                            color:
                                                messages[index].get('read') ==
                                                        true
                                                    ? Colors.blue
                                                    : Colors.black,
                                          )
                                        : SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              )),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: textMessage,
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      print(data['blocked']);
                      if ('${data['blocked']}'.contains('${data['id']}')) {
                        Fluttertoast.showToast(
                            msg: "Messaging has been blocked");
                      } else if ('${data['blockedByYou']}'
                          .contains('${data['peerID']}')) {
                        Fluttertoast.showToast(
                            msg: "You have blocked this contact");
                      } else {
                        DatabaseServices(context).onSendMessage(
                            textMessage.text,
                            data['id'] as String,
                            data['peerID'] as String,
                            textMessage,
                            FirebaseFirestore.instance
                                .collection('messages')
                                .doc(data['chatID'] as String)
                                .collection(data['chatID'] as String));
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
