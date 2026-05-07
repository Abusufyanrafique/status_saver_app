
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/images/app_images.dart';

import '../../Local Database/LocalDatabase.dart';
import '../RecentStatus/StatusScreen.dart';
class HomeItem {
  final String title;
  final String icon;
  final Widget screen;

  HomeItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}

List<HomeItem> items = [
  HomeItem(
    title: "WhatsApp Status",
    icon: AllIcons.send,
    screen: StatusScreen()
  ),

  HomeItem(
    title: "WA Business Status", //  Naya Title
    icon: AllIcons.send, // Business ke liye bhi wahi icon ya koi aur use karein
    screen: const StatusScreen(isBusiness: true), //  Flag pass karein
  ),
  HomeItem(
      title: "Downloaded Status",
      icon: AllIcons.download,
      screen: SavedItemsScreen()
      // screen: DownloadStatus()
  ),

  // HomeItem(
  //   title: "WA Business Cleaner",
  //   icon: AllIcons.cleaner,
  //   screen: WABusinessCleaner()
  // ),
];

class HomeScreen extends StatelessWidget {
 HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backgroung_image),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
                 bottom: 0,
                left: 0,
                right: 0,
                child: Container(
              height: 400,
             // width: double.infinity,
             // color: Colors.black,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only( topRight: Radius.circular(40),
                    topLeft: Radius.circular(40)),
                gradient: AppColor1.backgroundGradientColor
              ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Status Saver App",

                          style: AppColor1().customTextStyleBold16(fontWeight: FontWeight(500))

                          ,),
                        SizedBox(height:getHeight(5),),
                        Text("Download & Keep Your Favorite Status Forever",
                          style: AppColor1().customTextStyle14(fontWeight: FontWeight(400))

                          ,),

                        Expanded(
                          child: GridView.builder(
                              itemCount: items.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 130,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,),
                              itemBuilder: (context, index) {
                                return ButtonContainer(
                                  items[index].title,
                                  items[index].icon,
                                      () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => items[index].screen,
                                      ),
                                    );
                                  },
                                );
                              }
                        ))
                      ],
                    ),
                  ),





            ),


            )
          ],
        )
      ),
    );
  }





 Widget ButtonContainer(
     String title,
     String icon,
     VoidCallback onTap,
     ) {
   return GestureDetector(
     onTap: onTap, //  sirf yeh use hoga
     child: Container(
       decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(6),
         boxShadow: [
           BoxShadow(
             blurRadius: 5,
             offset: Offset(0, 1),
             color: Colors.black.withOpacity(0.25),
           ),
         ],
         color: Colors.white,
       ),
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             SvgPicture.asset(icon),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Flexible(
                   child: Text(
                     title,
                     style: AppColor1()
                         .customTextStyle14(fontWeight: FontWeight.w600),
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
                 Icon(Icons.arrow_forward_ios),
               ],
             )
           ],
         ),
       ),
     ),
   );
 }
}

