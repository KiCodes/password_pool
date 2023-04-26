import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utils/constants.dart';

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  UniqueKey _bigCardKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    double maxWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (maxWidth >= 1024) {
            return Center(
              child: buildContainer(appState, isLandscape, 35.0, 400.0, 30.0, 30.0, 50.0),
            );
          } else if (maxWidth >= 768) {
            return Center(
              child: buildContainer(appState, isLandscape, 36.0, 400.0, 50.0, 40.0, 45.0),
            );
          } else if (maxWidth >= 480) {
            return Center(
              child: buildContainer(appState, isLandscape, 22.0, 250.0, 40.0, 10.0, 33.0),
            );
          }else if (maxWidth >= 250) {
            return Center(
              child: buildContainer(appState, isLandscape, 10.0, 100.0, 9.0, 10.0,22.0),
            );
          }
          else {
            return Center(
              child: buildContainer(appState, isLandscape, 10.0, 100.0, 14.0, 10.0,15.0),
            );
          }
        },
      ),
    );
  }

  SingleChildScrollView buildContainer(MyAppState appState, isLandscape, fontSize, imageSize, space, space2, title) {
    return SingleChildScrollView(
      child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: !appState.isDarkMode
                        ? [Colors.lightBlueAccent, Colors.blue]
                        : [Colors.black12, Colors.black45],
                  ),
                ),
                height: isLandscape ? null : MediaQuery.of(context).size.height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      !appState.isDarkMode
                          ? Image.asset(
                        'assets/images/default.e71d14e.png',
                        height: imageSize,
                        // Change the color here
                      )
                          : Image.asset(
                        'assets/images/2689199.png',
                        height: imageSize,
                        // Change the color here
                      ),
                      SizedBox(height: space),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(Texts.title,
                                style: TextStyle(
                                    fontSize: title,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(height: space,),
                            Text(Texts.subtitle,
                                style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                      SizedBox(height: space2),
                      BigCard(key: _bigCardKey, appState: appState),
                      SizedBox(height: space2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              appState.addToFavorites();
                            },
                            icon: Icon(
                              appState.isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: Text(
                              appState.isFavorited ? 'Unfavorite' : 'Favourite',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: fontSize),
                            ),
                          ),
                          SizedBox(width: space2),
                          ElevatedButton(
                            onPressed: () {
                              appState.getRandomCasing();
                              _bigCardKey = UniqueKey();
                            },
                            child: Text(
                              Texts.next,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: space2,),
                      Container(
                        height: space2,
                      )
                    ],
                  ),
                ),
              ),
    );
  }
}
