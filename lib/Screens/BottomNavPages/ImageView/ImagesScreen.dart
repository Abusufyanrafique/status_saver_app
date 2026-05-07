import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/bloc/status/status_bloc.dart';
import 'package:status_saver/bloc/status/status_event.dart';
import 'package:status_saver/bloc/status/status_state.dart';
import 'ImageView.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {

  @override
  void initState() {
    super.initState();

    //  Replace 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatusBloc>().add(LoadStatusEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColor1.screenbackgroundColor,

      body: BlocBuilder<StatusBloc, StatusState>(
        builder: (context, state) {

          //  Loading
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          //  WhatsApp not found
          if (!state.isWhatsappAvailable) {
            return const Center(child: Text("WhatsApp not available"));
          }

          //  No images
          if (state.images.isEmpty) {
            return const Center(child: Text("No Images Available"));
          }

          //  Show Grid
          return Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              itemCount: state.images.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: getHeight(175),
                crossAxisSpacing: 15,
                mainAxisSpacing: 18,
              ),
              itemBuilder: (context, index) {
                final data = state.images[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => ImageView(imagePath: data.path),
                      ),
                    );
                  },
                  child: Container(
                    height: getHeight(175),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(data.path)),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                          color: const Color(0xff000000).withOpacity(0.25),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}