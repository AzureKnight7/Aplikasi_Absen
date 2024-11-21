import 'package:flutter/material.dart';

class QTextfieldClockin extends StatefulWidget {
  final String title;
  final String hint;
  final double? height;
  final double? width;
  final TextEditingController controller;
  final bool isUseIcon;
  final IconData? icon;
  const QTextfieldClockin({
    super.key,
    required this.title,
    required this.hint,
    this.height,
    this.width,
    required this.controller,
    required this.isUseIcon,
    this.icon,
  });

  @override
  State<QTextfieldClockin> createState() => _QTextfieldAuthState();
}

class _QTextfieldAuthState extends State<QTextfieldClockin> {
  bool? hide;
  @override
  void initState() {
    hide = widget.isUseIcon ? true : false;
    super.initState();
  }

  void changeHide() {
    hide = !hide!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: MediaQuery.of(context).size.width / 1.7,
      child: TextField(
        controller: widget.controller,
        obscureText: hide!,
        decoration: InputDecoration(
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            filled: true,
            hintText: widget.hint,
            hintStyle: TextStyle(color: Color(0xff5D5D65)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blue)),
            suffixIcon: widget.isUseIcon
                ? InkWell(
                    onTap: () => changeHide(),
                    child: Container(
                      margin: const EdgeInsets.only(
                        right: 20.0,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 24.0,
                      ),
                    ),
                  )
                : null),
      ),
    );
  }
}
