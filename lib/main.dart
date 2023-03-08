import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Ai_pict/screen/home_screen.dart';
import 'package:Ai_pict/screen/login_screen.dart';
import 'package:Ai_pict/screen/more_screen.dart';
import 'package:Ai_pict/screen/search_screen.dart';
import 'package:Ai_pict/screen/upload_screen.dart';
import 'package:Ai_pict/widget/bottom_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

String uid = "";
String username = "";
String userToken="";

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  //파이어베이스 메시지 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Android 알림 채널 설정
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id', // id
    'channel_name', // name
    description: 'channel_description', // description
    importance: Importance.max, // importance
    playSound: true,
  );

  //설정한 채널을 널어서 NotificationPlugin 작성
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  print("Handling a background message: ${message.notification}");
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification!.body}');

    flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,

        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription:channel.description,
            importance: Importance.high,
            icon: '@mipmap/ic_launcher',

          ),
          /*iOS: const IOSNotificationDetails(
                badgeNumber: 1,
                subtitle: 'the subtitle',
                sound: 'slow_spring_board.aiff',
              )*/
        )
    );
  }
}

Future<String?> getUserToken() async {
  DateTime now = DateTime.now();
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  String nowTime = formatter.format(now);

  var fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: "BNZniSDCR04atJgpU2IzjfejWr6Ydwwd5ZXFabwpMtDz9djwdAcGyw_iM_hP3xHdcE2l6Do1KIfb9vdpP7TVGGw");
  //print('fcmToken :: $fcmToken');

  //이미 등록된 토큰인지 확인하기
  var userTokens = await FirebaseFirestore.instance.collection('tokens').where('token',isEqualTo: fcmToken).get();

  if (userTokens.docs.isNotEmpty) {
    print('해당 사용자 토큰이 존재합니다.');
  } else {
    print('해당 사용자 토큰이 존재하지 않습니다.');

    FirebaseFirestore.instance.collection('tokens').doc().set(
      { 'token' : fcmToken , 'regdate' : nowTime}
    );
    print('새로운 이용자의 토큰이 등록되었습니다.');
  }
  return fcmToken;
}

Future<void> main() async {
  //FlutterBinding 초기화
  WidgetsFlutterBinding.ensureInitialized();
  //FireBase초기화
  await Firebase.initializeApp();

  //파이어베이스 메시지 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Android 알림 채널 설정
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_id', // id
      'channel_name', // name
      description: 'channel_description', // description
      importance: Importance.high, // importance
      playSound: true,
  );

  //설정한 채널을 널어서 NotificationPlugin 작성
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  //백그라운드 처리
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.notification!.body}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification!.body}');

      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,

          NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription:channel.description,
                importance: Importance.high,
                icon: '@mipmap/ic_launcher',

              ),
              /*iOS: const IOSNotificationDetails(
                badgeNumber: 1,
                subtitle: 'the subtitle',
                sound: 'slow_spring_board.aiff',
              )*/
          )
      );
    }
  });

  //App 시작
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
    //유저의 토큰등록 여부를 판단후 없으면 등록
    super.initState();
    getUserToken();
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
      theme: ThemeData(primaryColor: Colors.black, brightness: Brightness.dark,fontFamily: 'NotoSans',),
      home :AnimatedSplashScreen(
          splashIconSize: 300,
          curve: Curves.bounceIn,
          backgroundColor: Colors.black.withOpacity(0.5),
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


