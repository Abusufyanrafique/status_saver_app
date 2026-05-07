
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SizeConfig.dart';

class AppColor1{
  static const Color screenbackgroundColor = Color(0xFFE3EAF2);
  static const Color textColor = Color(0xff000000);
  static const Color subtextcolor = Color(0xff7C7777);
  static const Color primaryColor = Color(0xff56C8C8);


  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF0C8015);
  static const Color warningColor = Color(0xFFDB930B);

  static const backgroundGradientColor = LinearGradient(
    begin: Alignment.topCenter,

    end: Alignment.bottomCenter,
    colors: [
      Color(0xffE3EAF2),
      Color(0xffC9D6FF),
      Color(0xffA1C4FD)

    ],
    stops: [0.08, 0.4,1.0], // ascending order
  );

  static const backgroundGradientTextColor = LinearGradient(


      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
      //  AppColors.gradTextColor,
       Color(0xFF5B5CFF),
        Color(0xFF9B5CFF),
       //AppColors.primaryColor,
         Color(0xFFA057FF),
      ],
    );

  TextStyle customTextStyleRegular8({
    Color color = subtextcolor,
    FontWeight fontWeight = FontWeight.w400,
  })
  {
    return GoogleFonts.poppins(
      letterSpacing: 0,
        color: color,
        fontSize: 8,
        fontWeight: fontWeight,
        height: 1,
    );

  }
  TextStyle customTextStyleRegular10({
    Color color = subtextcolor,
    FontWeight fontWeight = FontWeight.w400,
  })
  {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(10),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyleBold10({
    Color color =textColor,
    FontWeight fontWeight = FontWeight.w700,
  })
  {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(10),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyle11({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(11),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyle12({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(12),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyle14({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(14),
      fontWeight: fontWeight,
      height: 1,

    );
  }
  TextStyle customTextStyle15({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(15),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyleBold16({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(16),
      fontWeight: fontWeight,
      height: 1,
    );
  }

  TextStyle customTextStyle18({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(18),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyle20Regular({
    Color color =textColor,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(20),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyle20({
    Color color =textColor,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(20),
      fontWeight: fontWeight,
      height: 1,
    );
  }


  TextStyle customTextStyle21({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(21),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyle24({
    Color color =textColor,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(24),
      fontWeight: fontWeight,
      height: 1,
    );
  }

  TextStyle customTextStyle27({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(27),
      fontWeight: fontWeight,
      height: 1,
    );
  }

  TextStyle customTextStyle30Regular({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w300,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(30),
      fontWeight: fontWeight,
      height: 1,
    );
  }
  TextStyle customTextStyle32({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(32),
      fontWeight: fontWeight,
      height: 1,
    );
  }

  TextStyle customTextStyle36({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.poppins(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(36),
      fontWeight: fontWeight,
      height: 1,
    );
  }

  TextStyle customTextStyleCairo14({
    Color color = textColor,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.cairo(
      letterSpacing: 0,
      color: color,
      fontSize: getFont(14),
      fontWeight: fontWeight,
      height: 1,
    );
  }


}






class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}


