import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  dynamic listOfSnapshots;
  late dynamic id;

  idTest(identity){
    if(identity==id){
      return false;
    }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    id='';
    id=id.isEmpty?ModalRoute.of(context)!.settings.arguments:id;
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
                listOfSnapshots=snapshot.data!.docs;
                listOfSnapshots.remove(listOfSnapshots.where((element)=>element.get('id')==id?true:false));
                return ListView.builder(
                    itemCount:listOfSnapshots.length,
                    itemBuilder: (context,index){
                      return Card(
                        shape:RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                        ) ,
                        child: ListTile(
                          title: Center(
                            child: Text(
                                listOfSnapshots[index].get('name'),
                              style: TextStyle(
                                fontSize: 20
                              ),
                            ),
                          ),
                          subtitle:  Center(
                            child: Text(
                              listOfSnapshots[index].get('aboutMe'),
                              style: TextStyle(
                                  fontSize: 10
                              ),
                            ),
                          ),
                          onTap: () async{
                            SharedPreferences pref = await SharedPreferences.getInstance();
                            List<dynamic> sortList= [pref.getString('id'),listOfSnapshots[index].id];
                            sortList.sort();
                            dynamic finalString=sortList[0]+sortList[1];
                            Navigator.pushNamed(context, '/chatRoom',arguments: {
                              'chatID':finalString,
                              'id':pref.getString('id'),
                              'peerID': listOfSnapshots[index].id
                            });
                          },

                        ) ,
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
