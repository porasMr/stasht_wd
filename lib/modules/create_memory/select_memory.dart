import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stasht/modules/create_memory/model/memory_item.dart';
import 'package:stasht/utils/app_colors.dart';
import 'package:stasht/utils/assets_images.dart';
import 'package:stasht/utils/constants.dart';

// ignore: must_be_immutable
class SelectMemoryScreen extends StatefulWidget {
  SelectMemoryScreen({super.key, required this.memoryItem});

  List<MemoryItem> memoryItem = [];

  @override
  State<SelectMemoryScreen> createState() => _SelectMemoryScreenState();
}

class _SelectMemoryScreenState extends State<SelectMemoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        systemNavigationBarColor: Colors.white,
      ),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: const IgnorePointer(),
          leadingWidth: 0,
          title: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close)),
              const SizedBox(
                width: 10,
              ),
              Text(
                "Select a Memory",
                style: appTextStyle(
                    fz: 22,
                    height: 28 / 22,
                    fm: robotoRegular,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 1,
              color: AppColors.primaryColor.withOpacity(0.3),
              width: MediaQuery.of(context).size.width,
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return Container(
                    height: 1,
                    color: AppColors.primaryColor.withOpacity(0.1),
                    width: MediaQuery.of(context).size.width,
                  );
                },
                itemCount: widget.memoryItem.length,
                itemBuilder: (context, index) {
                  final memory = widget.memoryItem[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, memory);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.only(right: 0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.skeltonBorderColor),
                              borderRadius: BorderRadius.circular(10),
                              image: memory.imageUrl == ''
                                  ? const DecorationImage(
                                      image: AssetImage(
                                        "assets/images/placeHolder.png",
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : memory.imageUrl != ''
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            memory.imageUrl,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                              color:
                                  memory.imageUrl != '' ? null : Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            memory.title,
                            style: appTextStyle(
                              fm: robotoBold,
                              fz: 14,
                              fw: FontWeight.w500,
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
