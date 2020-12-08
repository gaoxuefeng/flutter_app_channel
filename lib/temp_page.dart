import 'package:flutter/material.dart';

/**
 * Created by Gao Xuefeng
 * on 12/8/20
 */
class TempPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTapDown: (detail) {
              print("点击${DateTime.now().toIso8601String()}");
            },
            // onTapUp: () {
            //   print("点击${DateTime.now().toIso8601String()}");
            // },
            child: Container(
              width: 100,
              height: 100,
              color: Colors.green,
            ),
          )
        ],
      ),
    );
  }
}
