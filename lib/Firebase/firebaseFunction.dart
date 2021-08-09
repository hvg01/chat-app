import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireBaseFunction extends ChangeNotifier{
  late bool blocked;

  get getBlockedStatus{
    return blocked;
  }
  static onSendMessage(String content,String id, String peerId , TextEditingController textEditingController, String groupChatId) {

    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,

          },
        );
      });

    }
  }

  onBlockOrUnblock(id,array,BuildContext context,blockedStatus) async{
    if(blockedStatus){
      array.remove(id);
    }
    else{
      array.add(id);
    }

    FirebaseFirestore.instance.collection('users').doc(id).update({'blocked': array});
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('blocked', json.encode(array));
    return array;
  }

  getCurrentBlockedStatus(bool status){
    blocked=status;
    notifyListeners();
  }
}