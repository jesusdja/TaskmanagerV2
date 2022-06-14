import 'package:flutter/material.dart';

class DropdownGeneric extends StatelessWidget {

  final void Function(String?)? onChanged;
  final void Function()? onTap;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final TextStyle? textStyle;
  final double iconSize;
  final Widget? icon;
  final Color borderColor;
  final double sizeH;
  final FocusNode? focusNode;
  final double radius;
  final Color backColor;
  final double itemHeight;

  DropdownGeneric({
    this.value,
    this.onChanged,
    required this.items,
    this.textStyle,
    this.iconSize = 35,
    this.icon,
    this.borderColor = Colors.grey,
    this.sizeH = 20,
    this.focusNode,
    this.onTap,
    this.radius = 5.0,
    this.backColor = Colors.white,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: sizeH * 0.045,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: backColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: new Border.all(
          width: 1.0,
          color: borderColor,
        ),
      ),
      padding: EdgeInsets.only(left: 15),
      child: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton<String>(
          onTap: onTap,
          focusNode: focusNode,
          isExpanded: true,
          itemHeight: itemHeight,
          value: value,
          iconEnabledColor: Colors.grey,
          style: textStyle,
          underline: Container(color: Colors.transparent),
          onChanged: onChanged,
          items: items,
        ),
      ),
    );
  }
}
