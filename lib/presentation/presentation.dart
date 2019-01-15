import 'package:flutter/material.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/main.dart';

const double imagePadding = 6;

initSlides() => [
      Slide(
        title: loc.getText(loc.appName),
        text: " ",
        textImageRatio: 2 / 3,
        image: 'assets/icon.png',
        textColor: Colors.white,
        topColor: Colors.blue,
        imageDescription: "",
      ),
      Slide(
        title: loc.getText(loc.aboutCollector),
        text: loc.getText(loc.aboutCollectorText),
        image: "assets/kollKep.jpg",
        textColor: Colors.white,
        topColor: Colors.teal,
        imageDescription: loc.getText(loc.aboutCollectorImageDescription),
        textImageRatio: 3 / 5,
      ),
      Slide(
        title: loc.getText(loc.collectorControlling),
        text: loc.getText(loc.collectorControllingText),
        image: "assets/nodemcu.jpg",
        textColor: Colors.black87,
        topColor: Colors.yellow,
        imageDescription: loc.getText(loc.collectorControllingImageDescription),
        textImageRatio: 3 / 5,
      ),
      Slide(
        title: loc.getText(loc.theApplication),
        text: loc.getText(loc.theApplicationText),
        image: "assets/icon.png",
        textColor: Colors.white,
        topColor: Colors.indigo,
        imageDescription: " ",
        popOnTap: true,
      ),
    ];

class PresentationPage extends StatefulWidget {
  @override
  PresentationPageState createState() {
    return new PresentationPageState();
  }
}

class PresentationPageState extends State<PresentationPage>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  List<Widget> slides;

  @override
  void initState() {
    setLandscapeOrientation();
    hideSystemOverlay();
    super.initState();
    slides = initSlides();
    _controller = TabController(length: slides.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          showSystemOverlay();
          setPortraitOrientation();
          return true;
        },
        child: TabBarView(
          controller: _controller,
          children: slides,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class Slide extends StatelessWidget {
  final String title, text, image, imageDescription;
  final Color topColor, textColor;
  final bool hasImage, popOnTap;
  final double textImageRatio;

  const Slide({
    Key key,
    @required this.title,
    @required this.text,
    this.image,
    this.textColor,
    this.textImageRatio = 2 / 3,
    @required this.topColor,
    this.imageDescription,
    this.popOnTap = false,
  })  : assert(textImageRatio != null
            ? (textImageRatio < 1 && textImageRatio > 0)
            : true),
        hasImage = image != null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Material(
      type: MaterialType.canvas,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            elevation: 4,
            color: this.topColor,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 24, right: 24, bottom: 20),
              child: Text(
                title,
                style: theme.display1.copyWith(color: this.textColor),
              ),
            ),
          ),
          hasImage
              ? Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: width * textImageRatio,
                        child: _buildText(theme),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(imagePadding),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (popOnTap) {
                                    showSystemOverlay();
                                    setPortraitOrientation();
                                    Navigator.pop(context);
                                  }
                                },
                                child: Container(
                                  width: width * (1 - textImageRatio) -
                                      2 * imagePadding,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: AssetImage(image),
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.bottomCenter,
                                  )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                imageDescription,
                                style: theme.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : _buildText(theme),
        ],
      ),
    );
  }

  _buildText(TextTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: theme.headline.copyWith(fontSize: 20),
        textAlign: TextAlign.start,
      ),
    );
  }
}
