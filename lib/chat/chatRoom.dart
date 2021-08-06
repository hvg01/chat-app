import 'package:chat_app/Firebase/firebaseFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'chatClass.dart';
class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  dynamic messages=[Chat(content: 'Hello',id: 1,type: 'receiver'),Chat(content: 'Hi',id: 2,type: 'sender')];
  TextEditingController textMessage = TextEditingController();
  dynamic data={};
  @override
  Widget build(BuildContext context) {
    data=data.isEmpty?ModalRoute.of(context)!.settings.arguments:data;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        centerTitle: true,
      ),
      body: Stack(
    children: <Widget>[
      Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .doc(data['chatID'])
                .collection(data['chatID'])
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey)));
              }
              else{
                messages=snapshot.data!.docs;
                return  ListView.builder(
                  itemCount: messages.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10,bottom: 10),
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index){
                    return Container(
                      padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
                      child: Align(
                        alignment: (messages[index].type == "receiver"?Alignment.topLeft:Alignment.topRight),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: (messages[index].type  == "receiver"?Colors.grey.shade200:Colors.blue[200]),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(messages[index].content, style: TextStyle(fontSize: 15),),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          )
      ),

    Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: EdgeInsets.only(left: 10,bottom: 10,top: 10),
        height: 60,
        width: double.infinity,
        color: Colors.white,
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: (){
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.add, color: Colors.white, size: 20, ),
              ),
            ),
            SizedBox(width: 15,),
            Expanded(
              child: TextField(
                controller: textMessage,
                decoration: InputDecoration(
                    hintText: "Write message...",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none
                ),
              ),
            ),
            SizedBox(width: 15,),
            FloatingActionButton(
              onPressed: () async{

                FireBaseFunction.onSendMessage(textMessage.text, data['id'] , data['peerID'], textMessage, data['chatID']);

              },
              child: Icon(Icons.send,color: Colors.white,size: 18,),
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
