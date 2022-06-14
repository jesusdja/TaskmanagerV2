import 'package:flutter/material.dart';
import 'package:tra_s4c/config/s4c_colors.dart';
import 'package:tra_s4c/config/s4c_style.dart';

// ignore: must_be_immutable
class ButtonGeneral extends StatelessWidget {
  final String? title;
  final VoidCallback? onPressed;
  final double? radius;
  final double height;
  final double width;
  final double textSize;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool bold;
  final EdgeInsets margin;
  final EdgeInsets titlePadding;
  Widget icon;
  final TextStyle? textStyle;
  final int? maxLines;
  final bool isBoxShadow;
  final Color colorBoxShadow;
  final double spreadRadiusBoxShadow;
  final double blurRadiusBoxShadow;
  final Offset offsetBoxShadow;
  final bool loadButton;
  final Color colorCircular;
  final double widthBorder;
  final Alignment alignmentText;
  final TextAlign textAlign;

  ButtonGeneral({
    @required this.title,
    @required this.onPressed,
    this.radius = 5,
    this.bold = false,
    required this.icon,
    this.height = 10,
    this.width = 30,
    this.textSize = 16.0,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.black,
    this.margin = const EdgeInsets.all(0.0),
    this.titlePadding = const EdgeInsets.all(0.0),
    this.textStyle,
    this.maxLines,
    this.isBoxShadow = false,
    this.colorBoxShadow = Colors.grey,
    this.spreadRadiusBoxShadow = 1,
    this.blurRadiusBoxShadow = 15,
    this.offsetBoxShadow = const Offset(0,0),
    this.loadButton = false,
    this.colorCircular = Colors.white,
    this.widthBorder = 1.5,
    this.alignmentText = Alignment.center,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleLocal = textStyle ?? S4CStyles().stylePrimary();
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 0),
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: widthBorder,
          style: BorderStyle.solid,
        ),
        boxShadow:  [
          isBoxShadow ? BoxShadow(
            color: colorBoxShadow,
            spreadRadius: spreadRadiusBoxShadow,
            blurRadius: blurRadiusBoxShadow,
            offset: offsetBoxShadow,
          ) : BoxShadow(),
        ]
      ),
      child:
      loadButton ?
      Center(
        child: Container(
          height: height * 0.6,width: height * 0.6,
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colorCircular))
        ),
      )
          :
      Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: S4CColors().primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(radius ?? 0),
          onTap: onPressed,
          child: Align(
            alignment: alignmentText,
            child: Padding(
              padding: titlePadding,
              child:  Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title ?? '',
                      maxLines: maxLines,
                      style: textStyleLocal,
                      textAlign: textAlign,
                    ),
                  ),
                  icon
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
