import 'package:chat_app/Firebase/firebaseFunction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatabaseServices {
  BuildContext context;
  DatabaseServices(this.context);

  onSendMessage(String content, String id, String peerId,
      TextEditingController textEditingController, CollectionReference messageCollection) {
    Provider.of<FireBaseFunction>(context, listen: false)
        .sendMessage(content, id, peerId, textEditingController, messageCollection);
  }

  onBlockOrUnblock(
      uid, peerID, array, BuildContext context, blockedStatus) async {
    return Provider.of<FireBaseFunction>(context, listen: false)
        .blockOrUnblock(uid, peerID, array, context, blockedStatus);
  }

  onSendRequest(requestArray, peerID, uid) {
    Provider.of<FireBaseFunction>(context, listen: false)
        .sendRequest(requestArray, peerID, uid);
  }

  onAcceptRequest(acceptArray, requestArray, peerID, uid) {
    Provider.of<FireBaseFunction>(context, listen: false)
        .acceptRequest(acceptArray, requestArray, peerID, uid);
  }

  onDenyRequest(requestArray, peerID, uid) {
    Provider.of<FireBaseFunction>(context, listen: false)
        .denyRequest(requestArray, peerID, uid);
  }

  markRead(String peerID, CollectionReference messageCollection) {
    Provider.of<FireBaseFunction>(context, listen: false)
        .markRead(peerID, messageCollection);
  }

  blocked(bool blockedStatus) {
    Provider.of<FireBaseFunction>(context).blocked = blockedStatus;
  }

  get getBlockedStatus {
    return Provider.of<FireBaseFunction>(context).blocked;
  }

  getCurrentBlockedStatus(bool status) {
    Provider.of<FireBaseFunction>(context, listen: false)
        .getCurrentBlockedStatus(status);
  }
}
