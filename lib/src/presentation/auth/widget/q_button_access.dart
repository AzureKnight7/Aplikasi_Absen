import 'package:flutter/material.dart';

class QButtonAcccess extends StatelessWidget {
  final String title;
  final String head;
  final Function onPress;
  const QButtonAcccess({
    super.key,
    required this.title,
    required this.head,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
              text: "Dont have account?",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Color(0xff5D5D65)),
              children: [
                TextSpan(
                  text: " Please contact HR",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xff5D5D65)),
                )
              ]),
        ),
        const SizedBox(
          width: 5.0,
        ),
        InkWell(
          onTap: () => onPress(),
          child: Text(
            head,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.blue,
            ),
          ),
        )
      ],
    );
  }
}
