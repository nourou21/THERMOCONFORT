import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_application_2/inside%20app/paramettre.dart';
import 'package:google_fonts/google_fonts.dart';

class GraphPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool is_dark_mode = parametter.getDarkMode();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: is_dark_mode ? Colors.grey.shade900 : Colors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 1),
                          Expanded(
                            child: DefaultTextStyle(
                              style: GoogleFonts.indieFlower(
                                textStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 40,
                                ),
                              ),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'Graph page',
                                    speed: Duration(milliseconds: 200),
                                  ),
                                ],
                                totalRepeatCount: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
