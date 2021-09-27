import 'package:chat_app/Firebase/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RepliesRoom extends StatefulWidget {
  final message;
  final String chatID;
  final String peerID;
  final String id;
  final bool blocked;
  
  
  RepliesRoom(this.message, this.chatID, this.peerID, this.id, this.blocked);

  @override
  _RepliesRoomState createState() => _RepliesRoomState();
}

class _RepliesRoomState extends State<RepliesRoom> {

  dynamic messages;
  TextEditingController textMessage = TextEditingController();
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(color: Colors.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Replies for",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12
                ),
              
            ),
            Text(
              widget.message.get('content') as String,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: [
              Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(widget.chatID)
                    .collection(widget.chatID)
                    .doc(widget.message.get('timestamp') as String)
                    .collection('replies')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blueGrey)));
                  } else {
                    messages = snapshot.data!.docs;
                    DatabaseServices(context).markRead(
                        widget.peerID,
                        FirebaseFirestore.instance
                            .collection('messages')
                            .doc(widget.chatID)
                            .collection(widget.chatID)
                            .doc(widget.message.get('timestamp') as String)
                            .collection('replies'));
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
                                (messages[index].get('idFrom') == widget.id
                                    ? Alignment.topRight
                                    : Alignment.topLeft),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    messages[index].get('idFrom') == widget.id
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
                                            widget.id
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
                                                    widget.id
                                                ? Colors.black
                                                : Colors.green)),
                                      ),
                                    ),
                                  ),
                                  messages[index].get('idFrom') == widget.id
                                      ? Icon(
                                          Icons.done_all,
                                          size: 16,
                                          color: messages[index].get('read') ==
                                                  true
                                              ? Colors.blue
                                              : Colors.black,
                                        )
                                      : SizedBox()
                                ],
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
                      if (widget.blocked){
                        Fluttertoast.showToast(
                            msg: "You have been blocked by this contact");
                      }
                      else{
                        DatabaseServices(context).onSendMessage(
                          textMessage.text,
                          widget.id,
                          widget.peerID,
                          textMessage,
                          FirebaseFirestore.instance
                              .collection('messages')
                              .doc(widget.chatID)
                              .collection(widget.chatID)
                              .doc(widget.message.get('timestamp') as String)
                              .collection('replies'));
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
