import 'dart:typed_data';

import 'package:flutter/material.dart';

class MyGridItem extends StatefulWidget {
  final Future<Uint8List?> filePath;

  const MyGridItem(this.filePath);

  @override
  _MyGridItemState createState() => _MyGridItemState();
}

class _MyGridItemState extends State<MyGridItem> with AutomaticKeepAliveClientMixin {
 
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width,
      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:  FutureBuilder<Uint8List?>(
                          
                              future: widget.filePath,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Center(child: Text('Error loading image'));
                                }
                              },
                            ),
                        ));
  }

  @override
  bool get wantKeepAlive => true;
}
