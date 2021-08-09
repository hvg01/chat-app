import 'package:chat_app/Firebase/firebaseFunction.dart';
import 'package:chat_app/chat/chatRoom.dart';
import 'package:chat_app/screens/contactList.dart';
import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: FireBaseFunction())
    ],
    child:MaterialApp(
        initialRoute: '/login',
        routes:{
          '/home':(context)=>Contacts(),
          '/login':(context)=>LoginScreen(title: 'Air India'),
          '/chatRoom': (context)=>ChatRoom()
        }
    ))
  );
}

