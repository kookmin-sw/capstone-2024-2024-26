import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.0),
              child: Container(
                child: LoadingAnimationWidget.inkDrop(
                  color: const Color(0xFF004F9E),
                  size: 70.0,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            const Text(
              '잠시만 기다려주세요...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 0.13,
              ),
            )
          ],
        ),
      ),
    );
  }
}
