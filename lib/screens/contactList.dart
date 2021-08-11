import 'dart:convert';

import 'package:chat_app/Firebase/firebaseFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  dynamic listOfSnapshots;
  dynamic userMap;
  late dynamic id;

  Widget widgetDecision(requestArray,acceptedArray,uid,BuildContext context,index){
    if(requestArray.contains(uid)){
      print('Hello');
      return  Row(
        children: [
          FlatButton(
              onPressed: (){
                Provider.of<FireBaseFunction>(context,listen: false).acceptRequest(userMap.get('requestAccepted'), listOfSnapshots[index].get('id'),id);

              },
              child: Icon(Icons.check)
          ),
          FlatButton(
              onPressed: (){
                Provider.of<FireBaseFunction>(context,listen: false).denyRequest(userMap.get('requestAccepted'), listOfSnapshots[index].get('id'),id);
              },
              child: Icon(Icons.clear)
          )

        ],
      );
    }

    else if(acceptedArray.contains(uid)){
      print('Hi');
      return Icon(Icons.check);
    }

    else if(userMap.get('requestSent').contains(listOfSnapshots[index].get('id'))){
      print('Yola');
      return Icon(Icons.send);
    }

    print('Waddup');

    return FlatButton(
      onPressed: (){
        Provider.of<FireBaseFunction>(context,listen: false).sendRequest(userMap.get('requestSent'),listOfSnapshots[index].get('id'),id);
      },
      child: Icon(Icons.add)
    );

  }
  @override
  Widget build(BuildContext context) {
    id='';
    id=id.isEmpty?ModalRoute.of(context)!.settings.arguments:id;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(

              child: Center(
                child: Text(
                    'Co-passengers in your vicinity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ) ,
              )

          ),
        ),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){

              if(snapshot.hasData){
                listOfSnapshots=snapshot.data!.docs;
                listOfSnapshots.forEach((element){
                  if(element.get('id')==id){
                    userMap=element;
                  }
                });

                listOfSnapshots.remove(userMap);

                return ListView.builder(
                    itemCount:listOfSnapshots.length,
                    itemBuilder: (context,index){
                      print(listOfSnapshots[index].get('blocked'));
                      print(userMap.get('requestSent'));
                      return Card(
                        shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                        ) ,
                        child:Padding(
                          padding: EdgeInsets.all(20),
                          child: ListTile(
                            leading: Icon(
                              Icons.account_circle_outlined,
                              size: 60,
                            ),
                            trailing: widgetDecision(listOfSnapshots[index].get('requestSent'), listOfSnapshots[index].get('requestAccepted'), listOfSnapshots[index].get('id'), context,index),
                            title: Center(
                              child: Text(
                                listOfSnapshots[index].get('name'),
                                style: TextStyle(
                                    fontSize: 25
                                ),
                              ),
                            ),
                            subtitle:  Center(
                              child: Text(
                                listOfSnapshots[index].get('aboutMe'),
                                style: TextStyle(
                                    fontSize: 15
                                ),
                              ),
                            ),
                            onTap: () async{
                              if(listOfSnapshots[index].get('requestAccepted').contains(id)){
                                SharedPreferences pref = await SharedPreferences.getInstance();
                                List<dynamic> sortList= [pref.getString('id'),listOfSnapshots[index].id];
                                sortList.sort();
                                dynamic finalString=sortList[0]+sortList[1];
                                dynamic blockedByYou= pref.getString('blocked');
                                Navigator.pushNamed(context, '/chatRoom',arguments: {
                                  'chatID':finalString,
                                  'id':pref.getString('id'),
                                  'peerID': listOfSnapshots[index].id,
                                  'name':listOfSnapshots[index].get('name'),
                                  'blocked':listOfSnapshots[index].get('blocked'),
                                  'blockedByYou': json.decode(blockedByYou),
                                  'blockedStatus':json.decode(blockedByYou).contains(listOfSnapshots[index].id),
                                  'aboutMe': listOfSnapshots[index].get('aboutMe')
                                });
                              }

                              else{
                                Fluttertoast.showToast(msg: 'Please send a request to chat or wait for them to accept your request');
                              }




                            },

                          ) ,
                        )
                      );

                    }
                );

              }

              return Center(child:CircularProgressIndicator());

            }
        )
      ),
    );
  }
}
