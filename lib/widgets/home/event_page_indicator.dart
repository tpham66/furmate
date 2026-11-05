import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EventPageIndicator extends StatelessWidget {
  final PageController pageController;
  final int count;

  const EventPageIndicator({super.key,
    required this.pageController,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SmoothPageIndicator(
        controller: pageController,
        count: count,
        effect: WormEffect(
          activeDotColor: Colors.blue,
          dotColor: Colors.grey,
          dotHeight: 12,
          dotWidth: 12,
        ),
      ),
    );
  }
}
