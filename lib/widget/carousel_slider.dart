import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:musika/model/paint_model.dart';
import 'package:musika/screen/detail_screen.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class CarouselImage extends StatefulWidget {

  final List<Paint> paints;

  CarouselImage({required this.paints});

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {

  List<Paint>? paints;
  List<Widget>? pSquares;
  List<Container> pSquares_1 = [];
  List<String>? codes;
  List<bool>? isAs;
  List<String>? cates;
  List<String>? hashtags;
  List<String>? p_files;
  List<String>? regdates;

  int _currentPage = 0;
  Paint? _currentPaint;

  @override
  void initState() {
    super.initState();
    paints = widget.paints;

    List<Widget> results = [];
    List<Container> results_11 = [];

      for (Paint p in paints!) {
        Container square = Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) {
                      return DetailScreen(paint: p);
                    },
                  )
              );
            },
            child: Container(
              child: Image.network(
                p.p_file,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null)
                    return child;
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.redAccent.withOpacity(0.5)),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        );
        results_11.add(square);
      }

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
      height: 500,
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
          /*CarouselSlider(
              items: pSquares,
              options: CarouselOptions(
                autoPlay: true,
                autoPlayAnimationDuration: Duration(seconds: 1),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPage = index;
                    _currentPaint = paints?[_currentPage];
                  });
                },
              )
          ),*/
          Flexible(
              child: CardSwiper(
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
