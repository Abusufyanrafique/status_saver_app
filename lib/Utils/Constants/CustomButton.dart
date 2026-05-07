
import 'package:flutter/material.dart';
import 'AllColors.dart';
// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
   VoidCallback ontap;
  final String title;

  CustomButton({
    super.key,
    required this.ontap,
    required this.title,
  });

  bool _loading = false;



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: InkWell(
        onTap: ontap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
           color: AppColor1.primaryColor
           // gradient: AppColors.UploadbackgroundGradientColor,
          ),
          child: Center(
            child: _loading
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              title,
              style: AppColor1()
                  .customTextStyleBold16(color: AppColor1.textColor),
            ),
          ),
        ),
      ),
    );
  }
}

