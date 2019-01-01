import 'package:flutter/material.dart';
import 'package:hokollektor/main.dart';

const imagePadding = 6.0;

const slides = [
  Slide(
    title: "Collector App",
    text: " ",
    textImageRatio: 2 / 3,
    image: 'assets/icon.png',
    textColor: Colors.white,
    topColor: Colors.blue,
    imageDescription: "",
  ),
  Slide(
    title: "A kollektorról",
    text: "Péter tanár úr 2017 tavaszán készítette el a kollektort\n\n"
        "Mi kaptuk a lehetőséget, hogy vezérlést készítsünk hozzá.",
    image: "assets/kollKep.jpg",
    textColor: Colors.white,
    topColor: Colors.teal,
    imageDescription: "A tanár úr és a kollektor",
    textImageRatio: 3 / 5,
  ),
  Slide(
    title: "A vezérlés",
    text:
        "Beszereltünk egy Node MCU-t és hőszenzorokat, amivel valós időben mérjük a hőmérsékletet, és vezéreljük a kollektort.",
    image: "assets/nodemcu.jpg",
    textColor: Colors.black87,
    topColor: Colors.yellow,
    imageDescription: " ",
  ),
  Slide(
    title: "Az App",
    text:
        "Azt akartuk, hogy bárhol hozzáférhessünk a kollektorhoz, ezért készült ez az applikáció.",
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

  @override
  void initState() {
    setLandscapeOrientation();
    hideSystemOverlay();
    super.initState();
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
            elevation: 4.0,
            color: this.topColor,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 20.0, left: 24.0, right: 24.0, bottom: 20.0),
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
                                  )),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
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
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        style: theme.headline.copyWith(fontSize: 20.0),
        textAlign: TextAlign.start,
      ),
    );
  }
}