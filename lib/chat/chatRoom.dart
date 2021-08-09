import 'package:chat_app/Firebase/firebaseFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'chatClass.dart';
class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  dynamic messages;
  TextEditingController textMessage = TextEditingController();
  dynamic data={};
  late bool blockedStatus;

  blockMechanism(){
    data['blockedByYou']=Provider.of<FireBaseFunction>(context,listen: false).onBlockOrUnblock(data['peerID'], data['blocked'],context,blockedStatus);

  }

  @override
  Widget build(BuildContext context) {
    data=data.isEmpty?ModalRoute.of(context)!.settings.arguments:data;
    blockedStatus=data['blockedStatus'];
    print(data);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child:  Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black,),
                ),
                SizedBox(width: 2,),
                CircleAvatar(
                  child: Icon(Icons.account_circle_outlined),
                  maxRadius: 20,
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(data['name'],style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                      SizedBox(height: 5,),
                      Text(data['aboutMe'])

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          FlatButton(
              onPressed: ()async{

                bool x= await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Are you sure you want to block this conversation ?'),
                        content: Container(
                          width: 100,
                          height: 100,
                        ),
                        
                        actions: [
                          FlatButton(
                              onPressed: (){

                                blockMechanism();
                                Navigator.pop(context,!blockedStatus);


                              }, 
                              child: Text('Yes')
                          ),
                          FlatButton(
                              onPressed: (){
                                Navigator.pop(context,blockedStatus);
                              },
                              child: Text('No'))
                        ],



                      );
                    });
                print(blockedStatus);
                Provider.of<FireBaseFunction>(context,listen: false).getCurrentBlockedStatus(x);
                blockedStatus=Provider.of<FireBaseFunction>(context,listen: false).getBlockedStatus;
                print(blockedStatus);

              },
              child: blockedStatus==true?Icon(Icons.undo):Icon(Icons.block)
          )
        ],
      ),

      body: Stack(
    children: <Widget>[
      Flexible(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .doc(data['chatID'])
                .collection(data['chatID'])
                .orderBy('timestamp', descending: false)
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
                        alignment: (messages[index].get('idFrom') == data['id']?Alignment.topRight:Alignment.topLeft),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: (messages[index].get('idFrom')== data['id']?Colors.black:Colors.green)! ),

                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(messages[index].get('content'), style: TextStyle(
                              fontSize: 15,
                            color: (messages[index].get('idFrom')== data['id']?Colors.black:Colors.green)!
                          ),),
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
                if(data['blocked'].contains(data['id'])){
                  Fluttertoast.showToast(msg: "You have been blocked by this contact");
                }

                else if(data['blockedByYou'].contains(data['peerID'])){
                  Fluttertoast.showToast(msg: "You have blocked this contact");
                }

                else{
                  FireBaseFunction.onSendMessage(textMessage.text, data['id'] , data['peerID'], textMessage, data['chatID']);
                }



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
