import 'package:chat_app/chat/chatRoom.dart';
import 'package:chat_app/screens/contactList.dart';
import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/login',
    routes:{
      '/home':(context)=>Contacts(),
      '/login':(context)=>LoginScreen(title: 'Air India'),
      '/chatRoom': (context)=>ChatRoom()
    }
  ));
}

