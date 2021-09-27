import 'package:chat_app/Firebase/firebaseFunction.dart';
import 'package:chat_app/chat/chatRoom.dart';
import 'package:chat_app/screens/contactList.dart';
import 'package:chat_app/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ignore: unused_local_variable
  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider.value(value: FireBaseFunction())],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: {
            '/home': (context) => Contacts(),
            '/login': (context) => LoginScreen(title: 'Air India'),
            '/chatRoom': (context) => ChatRoom()
          })));
}
