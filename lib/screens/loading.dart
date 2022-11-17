import 'package:flutter/material.dart';
import 'package:catalog/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ScreenLoading extends StatefulWidget {
  const ScreenLoading({Key? key}) : super(key: key);

  @override
  State<ScreenLoading> createState() => _ScreenLoadingState();
}

class _ScreenLoadingState extends State<ScreenLoading> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: const [
              /*Image.asset(
                "assets/logo.png",
                height: 300,
                width: 300,
              ),*/
              SizedBox(height: 15),
              Text(
                aplicationName,
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 42,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Organizando a facilidade.",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          LoadingAnimationWidget.stretchedDots(
            color: Colors.black,
            size: 50,
          ),
        ],
      ),
      );
  }
}
