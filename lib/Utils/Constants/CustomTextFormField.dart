

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'AllColors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.titleController,
    required this.title,
    required this.line,
    required this.hinttext,
    this.keyboardType,
    this.onChanged,
  this.inputFormatters,
  });

  final TextEditingController titleController;
  final String title;
  final int? line;
  final String hinttext;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 8,),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Background color of TextField
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25), // 25% opacity
                offset: Offset(0, 1), // x=0, y=1
                blurRadius: 4, // blur
                spreadRadius: 0, // spread
              ),
            ],
            borderRadius: BorderRadius.circular(8), // optional, rounded corners
          ),
          child: TextFormField(
            maxLines: line ?? 1,
            onChanged: onChanged,
            controller: titleController,
            keyboardType: keyboardType,
            decoration:  InputDecoration(
              hintText: hinttext,
              hintStyle: AppColor1().customTextStyleBold16(color: AppColor1.screenbackgroundColor),
              //fillColor: AppColors.white,

              filled: true,
              border: InputBorder.none,
              //border: OutlineInputBorder(),
            ),
          ),
        ),


      ],
    );
  }
}



class CustomIconTextField extends StatelessWidget {
  const CustomIconTextField({
    super.key,
    required this.titleController,
    required this.title,
    required this.line,
    required this.hinttext,
    required this.icon,
    
  });

  final TextEditingController titleController;
  final String title;
  final int? line;
  final String hinttext;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        TextFormField(
          maxLines: line ?? 1,
          controller: titleController,
          decoration:  InputDecoration(
            icon:Icon(icon),
            hintText: hinttext,
            hintStyle: AppColor1().customTextStyleBold16(color: AppColor1.screenbackgroundColor),
           // fillColor: AppColors.white,
            filled: true,
            border: InputBorder.none,
            //border: OutlineInputBorder(),
          ),
        ),


      ],
    );
  }
}