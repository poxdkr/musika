import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:Ai_pict/model/paint_model.dart';
import 'package:Ai_pict/screen/detail_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class CarouselImage extends StatefulWidget {

  final List<Paint_m> paints;

  CarouselImage({required this.paints});

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {

  List<Paint_m>? paints;
  List<Widget>? pSquares;
  List<Container> pSquares_1 = [];
  List<String>? codes;
  List<bool>? isAs;
  List<String>? cates;
  List<String>? hashtags;
  List<String>? p_files;
  List<String>? regdates;

  int _currentPage = 0;
  Paint_m? _currentPaint;

  @override
  void initState() {
    super.initState();
    paints = widget.paints;
    List<Paint_m> pList = paints!;
    List<Widget> results = [];
    List<Container> results_11 = [];

    int index = 0;
      for (var i =0; i<paints!.length; i++) {
        Container square = Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.white60
            )
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) {
                      return DetailScreen(pindex : i, paint: paints![i], paints: pList!,);
                    },
                  )
              );
            },
            child: Container(
              child:  CachedNetworkImage( // Image.network
                imageUrl: paints![i].p_file,
                placeholder: (context, url) => const LinearProgressIndicator(color: Colors.redAccent,),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fadeOutDuration: const Duration(seconds: 1),
                fadeInDuration: const Duration(seconds: 2),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
        results_11.add(square);
        index++;
      }

      results_11 = results_11.reversed.toList();


      pSquares_1 = results_11;
      codes = paints?.map((m) => m.code).toList();
      isAs = paints?.map((m) => m.isA).toList();
      cates = paints?.map((m) => m.cate).toList();
      hashtags = paints?.map((m) => m.hashtag).toList();
      p_files = paints?.map((m) => m.p_file).toList();
      regdates = paints?.map((m) => m.regdate).toList();
      _currentPaint = paints?[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.7,
      child : Column(
        children: [
          Container(
            padding: EdgeInsets.only(top:20),
          ),
          Container(
            padding: EdgeInsets.only(bottom : 10),
            child : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department),
                Text('Release', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),)
              ],
            )
          ),
          Flexible(
              child: CardSwiper(
                isVerticalSwipingEnabled: false,
                cards: pSquares_1,
              )
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 3),
            child: Column(
              children: [
                Text(
                  '${_currentPaint!.cate} / ${_currentPaint!.hashtag}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color : Colors.white60,
                      fontSize: 11
                  ),
                ),
              ],
            ),
          ),

        ],
      )
    );
  }
}
