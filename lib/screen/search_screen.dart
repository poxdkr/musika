
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:musika/model/paint_model.dart';
import 'package:musika/screen/detail_screen.dart';

String sst = "regdate"; //기본 정렬 등록일자 내림순
bool isDesc = true;

class SearchScreen extends StatefulWidget {

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController _controller = TextEditingController();

  FocusNode focusNode = FocusNode();
  String _searchText = "";

  _SearchScreenState(){
    _controller.addListener(() {
      _searchText = _controller.text;
    }
    );
  }

  Widget _buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('paint')
                                        .orderBy(sst, descending: isDesc)
                                        .limit(200)
                                        .snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        }else{
          return _buildList(context, snapshot.data!.docs);
        }
      } ,
    );
  }


  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    List<DocumentSnapshot> searchResult = [];
    for(DocumentSnapshot d in snapshot){
      if(d.data().toString().toLowerCase().contains(_searchText)){
        searchResult.add(d);
      }
    }

    return Expanded(
        child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1 / 1.5,
            padding: EdgeInsets.all(5),
            children: searchResult
                .map((data) => _buildListItem(context ,data))
                .toList()
        )
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data){
    final paint = Paint.fromSnapshot(data);
    return InkWell(
      child: Container(
        padding : EdgeInsets.all(3),
        child: Image.network(
          paint.p_file,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent.withOpacity(0.5)),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
      onTap: (){
        Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) {
                return DetailScreen(paint: paint);
              },
            )
        );
      },
    );
  }
  //build 함수
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(padding:EdgeInsets.all(30)),
          //검색창 일체
          Container(
            color : Colors.black,
            padding : EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: Row(
              children: [
                //검색창
                Expanded(
                    flex : 6,
                    child: TextField(
                      onChanged: (text){
                        setState(() {
                          _searchText = text;
                        });
                      },
                      focusNode: focusNode,
                      style : TextStyle(
                        fontSize: 15,
                      ),
                      //autofocus: true,
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white12,
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white60,
                          size: 20,
                        ),
                        // (x) 버튼
                        suffixIcon: focusNode.hasFocus
                            ? IconButton(
                          icon: Icon(Icons.cancel, size: 20, color: Colors.white60,),
                          onPressed: (){
                            setState( (){
                              _controller.clear();
                              _searchText = "";
                            }
                            );
                          },
                        )
                            : Container(),
                        hintText: '검색',
                        //border Style
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius:  BorderRadius.all(Radius.circular(10)),
                        ),
                        enabledBorder:OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius:  BorderRadius.all(Radius.circular(10)),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius:  BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    )
                ),
                //취소 버튼
                focusNode.hasFocus
                    ? Expanded(
                    child: TextButton(
                        child: Text('취소',style:TextStyle(color:Colors.white60)),
                        onPressed: (){
                          setState(() {
                            _controller.clear();
                            _searchText = "";
                          });
                        }
                    )
                )
                    : Expanded(child: Container(), flex : 0),
              ],
            ),
          ),
          //Sorted Box
          Container(
            padding : EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(width : 10),
                  ElevatedButton(
                      onPressed: (){
                        setState(() {
                          sst = "regdate";
                          isDesc = true;
                        });
                      },
                      child: Text('등록일 ▽', style: TextStyle(color: Colors.white),),
                      style: TextButton.styleFrom(
                          primary: Colors.redAccent.shade400,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.white,
                          elevation: 1)
                  ),
                  SizedBox(width : 10),
                  ElevatedButton(
                      onPressed: (){
                        setState(() {
                          sst = "like_cnt";
                          isDesc = true;
                        });
                      },
                      child: Text('좋아요 ▽', style: TextStyle(color: Colors.white),),
                      style: TextButton.styleFrom(
                          primary: Colors.redAccent.shade400,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.white,
                          elevation: 1)
                  ),
                  SizedBox(width : 10),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          sst = "code";
                          Random random =  Random();
                          isDesc = random.nextBool();
                        });
                      },
                      child: Icon(Icons.shuffle, color : Colors.white),
                      style: TextButton.styleFrom(
                          primary: Colors.redAccent.shade400,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.white,
                          elevation: 1)
                  ),
                ],
              ),
          ),
          _buildBody(context),
        ],
      ),
    );
  }
}