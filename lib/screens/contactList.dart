import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        centerTitle: true,
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasData){
                print(snapshot.data!.docs);
                return ListView.builder(
                    itemCount:snapshot.data!.docs.length ,
                    itemBuilder: (context,index){
                      return ListTile(
                        title: Text(snapshot.data!.docs[index].get('name')),
                        onTap: () async{
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          List<dynamic> sortList= [pref.getString('id'),snapshot.data?.docs[index].id];
                          sortList.sort();
                          dynamic finalString=sortList[0]+sortList[1];
                          Navigator.pushNamed(context, '/chatRoom',arguments: {
                            'chatID':finalString,
                            'id':pref.getString('id'),
                            'peerID': snapshot.data?.docs[index].id
                          });
                        },

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
