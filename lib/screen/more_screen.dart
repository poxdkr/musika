import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musika/main.dart';
import 'package:musika/screen/login_screen.dart';
import 'package:musika/widget/recently_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

String uid = "";
String email = "";
String? username="";


class MoreScreen extends StatefulWidget {

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {

  bool isUser = false;

  @override
  void initState() {
    if(_auth.currentUser != null) {
      uid = _auth.currentUser!.uid;
      email = _auth.currentUser!.email!;
      isUser = true;
      getUserInfo();
    }else{
      print(isUser);
      username = '';
      email = '';
    }

    super.initState();

  }

  Future<void> getUserInfo() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection('user').where('uid',isEqualTo: uid).get();
    List<DocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;
    // 문서 데이터와 문서 ID 출력 예제
    for (final DocumentSnapshot<Map<String, dynamic>> document in documents) {
      final Map<String, dynamic>? data = document.data();
      final String id = document.id;
      // 문서 데이터 출력
      if (data != null) {
        print('Document data: $data');
        setState(() {
          username = data['username'];
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding : EdgeInsets.only(top:10),
                child: CircleAvatar(radius: 100, backgroundImage: AssetImage('image/musika_icon.png'),),
              ),
              Container(
                padding : EdgeInsets.only(top:15,bottom: 10),
                child: Text(
                    username != "" ? '${username}' : '비회원',
                    style : TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
              Container(
                padding : EdgeInsets.all(10),
                width: 140,
                height: 5,
                color:Colors.redAccent,
              ),
              Container(
                  padding : EdgeInsets.all(10),
                  child : Text(
                    email != "" ? '${email}' : '',
                    style: TextStyle(fontSize: 12, color: Colors.white60),)
              ),
              Container(
                  padding : EdgeInsets.all(10),
                  child : TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () async {
                      await _auth.signOut();
                      Navigator.pushAndRemoveUntil(
                          context, MaterialPageRoute(builder: (context) => MyApp()), (route) => false
                      );
                    },
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit, color: Colors.white,),
                          SizedBox(width: 10,),
                          Text(
                              isUser ? '로그아웃' : '로그인',
                              style : TextStyle(color : Colors.white)
                          )
                        ],
                      ),
                    ),

                  )
              )
            ],
          )
      ),
    );
  }
}
