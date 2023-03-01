import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Ai_pict/model/paint_model.dart';
import 'package:Ai_pict/widget/carousel_slider.dart';
import 'package:Ai_pict/widget/recently_slider.dart';


FirebaseFirestore firestore = FirebaseFirestore.instance;


class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }


  List<Paint_m> paints = [];

  Widget _fetchData(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('paint')
                                        .orderBy('regdate', descending: true)
                                        .limit(20)
                                        .snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          print('loading.......');
          return LinearProgressIndicator();
        }else{
          return _buildBody(context,snapshot.data!.docs);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, List<DocumentSnapshot> snapshot){
    List<Paint_m> paints = snapshot.map((m)=> Paint_m.fromSnapshot(m)).toList();
    return SingleChildScrollView(
      child: Column(
          children: [
            TopBar(),
            CarouselImage(paints: paints),
            SizedBox(height:10),
            RecentlySlider(paints: paints)
          ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _fetchData(context);
  }
}

//TopBar 위젯 (고정)
Widget TopBar(){
  return  Container(
      padding: EdgeInsets.only(top:60, left: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('image/icon.png'),
          ),
          Container(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Ai pict',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows:  [Shadow(
                    color: Colors.white60,
                    offset: Offset(0,1),
                    blurRadius: 5,
                  )]
              ),
            ),
          )
        ],
      ),
    );
}