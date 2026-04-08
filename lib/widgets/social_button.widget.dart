import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../cl_theme.dart';



class SocialButton extends StatefulWidget {
  const SocialButton({super.key, required this.name, required this.svgName});

  final String name;
  final String svgName;

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: CLTheme.of(context).secondaryText.withValues(alpha: 0.2),
            child: SvgPicture.asset(widget.svgName, height: 18, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
          ),
          SizedBox(height: 5),
          Text(widget.name, style: CLTheme.of(context).smallText.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
