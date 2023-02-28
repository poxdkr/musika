import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;
String uid = "";
String username = "";

class BottomBar extends StatefulWidget {

  final List<Widget> tabs;

  BottomBar({required this.tabs});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {

  Future<void> getUserInfo() async {

    if(_auth.currentUser != null) {
      print('_auth.currentUser가 null이 아님???');
      uid = _auth.currentUser!.uid;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection(
        'user').where('uid', isEqualTo: uid).get();
    List<DocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;
    // 문서 데이터와 문서 ID 출력 예제
    for (final DocumentSnapshot<Map<String, dynamic>> document in documents) {
      final Map<String, dynamic>? data = document.data();
      final String id = document.id;
      // 문서 데이터 출력
      if (data != null) {
        print('Document data: $data');
        username = data['username'];
      }else{
          username = 'none';
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: TabBar(
              indicatorColor: Colors.white60,
              tabs:widget.tabs
              ,
            ),
          ),
        ),
      );
  }
}
