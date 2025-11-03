import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReusableTextWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final VoidCallback? onSubtitlePressed;

  const ReusableTextWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.onSubtitlePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style:
              titleStyle ??
              GoogleFonts.quicksand(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        TextButton(
          onPressed: onSubtitlePressed,
          child: Text(
            subtitle,
            style:
                subtitleStyle ??
                GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }
}
