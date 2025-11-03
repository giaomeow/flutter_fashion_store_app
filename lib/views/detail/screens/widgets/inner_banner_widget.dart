import 'package:flutter/material.dart';

class InnerBannerWidget extends StatelessWidget {
  final String image;
  const InnerBannerWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return // Banner danh mục
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 2048 / 683,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
