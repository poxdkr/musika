import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musika/screen/home_screen.dart';
import 'package:musika/screen/login_screen.dart';
import 'package:musika/screen/more_screen.dart';
import 'package:musika/screen/search_screen.dart';
import 'package:musika/screen/upload_screen.dart';
import 'package:musika/widget/bottom_bar.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;
String uid = "";
String username = "";


void main() async {
  //FlutterBinding 초기화
  WidgetsFlutterBinding.ensureInitialized();
  //FireBase초기화
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  void initState() {
    if(_auth.currentUser != null) {
      uid = _auth.currentUser!.uid;
      getUserInfo();
    }
    super.initState();
  }

  Future<void> getUserInfo() async {
    print('main uid : $uid');
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
    return MaterialApp(
      title: 'Ai_pict',
      theme: ThemeData(primaryColor: Colors.black, brightness: Brightness.dark),
      home :AnimatedSplashScreen(
          splashIconSize: 300,
          curve: Curves.bounceIn,
          backgroundColor: Colors.white,
        splash : Container(
          width : 300,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                color: Colors.redAccent.shade200.withOpacity(0.2),
                blurRadius: 1,
                offset: Offset(1,3),
              )]
          ),
          child : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('image/icon.png', width: 100, height: 120,),
              SizedBox(height:10),
              Text('Ai_Pict',
                style : TextStyle(
                    color : Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(
                      color: Colors.redAccent,
                      blurRadius: 2,
                      offset: Offset(0,1),
                    )]
                ),

              )
            ],
          ),
        ),
        splashTransition: SplashTransition.fadeTransition,
          nextScreen: StreamBuilder(
          //로그아웃이나 뒤로가기를 시도하여 이 페이지를 올 경우
          //FirebaseAuth.instance가 변화했는지를 체크하여 페이지를 이동시켜주기 위해 StreamBuilder를 사용
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot){
              if(snapshot.hasData){
                print('main _ username :: $username');
                return TabControl_pad();
              }else{
                return LoginScreen();
              }
            }
        ),
      ),
      //TabController()
    );
  }
}

Widget TabControl_pad(){

  List<Widget> tabs = [];
  List<Widget> tabViewList = [];
  if(_auth.currentUser!=null){
    print("auth 살아있음!!");
  }
  print('username :::::: $username');

  if(username == "admin" && _auth.currentUser!=null) {
    tabs = [
      Tab(
        icon: Icon(Icons.home),
      ),
      Tab(
        icon: Icon(Icons.search),
      ),
      Tab(
        icon: Icon(Icons.person),
      ),
      Tab(icon: Icon(Icons.settings),)
    ];
    tabViewList= [
      HomeScreen(),
      SearchScreen(),
      MoreScreen(),
      UploadScreen(),
    ];
  }else{
    tabs = [
      Tab(
        icon: Icon(Icons.home),
      ),
      Tab(
      icon: Icon(Icons.search),
      ),
      Tab(
      icon: Icon(Icons.person),
      )
    ];
    tabViewList= [
      HomeScreen(),
      SearchScreen(),
      MoreScreen(),
    ];
  }
    return DefaultTabController(
      length: tabs.length,
      animationDuration: Duration(milliseconds: 50),
      child: Scaffold(
        body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: tabViewList
        ),
        bottomNavigationBar: BottomBar(tabs : tabs),
      ),
    );
  }


