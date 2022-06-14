import 'package:flutter/material.dart';

class TextFieldGeneral extends StatelessWidget {
  final String? placeHolder;
  final IconData? icon;
  final bool obscure;
  final int? maxLines;
  final Color borderColor;
  final TextEditingController? textEditingController;
  final bool autoCorrect;
  final void Function(String)? onChanged;
  final TextInputType textInputType;
  final bool autoValidate;
  final String? initialValue;
  final double sizeH;
  final double sizeW;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final void Function(String)? onFieldSubmitted;
  final double sizeHeight;
  final TextAlign textAlign;
  final TextStyle labelStyle;
  final List<BoxShadow>? boxShadow;
  final double sizeBorder;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enable;
  final EdgeInsetsGeometry padding;
  final TextCapitalization textCapitalization;
  final String hintText;
  final Color colorBack;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final BoxConstraints? constraints;
  final bool activeInputBorder;
  final double radius;

  TextFieldGeneral({
    required this.sizeH,
    required this.sizeW,
    this.initialValue = '',
    this.placeHolder,
    this.icon,
    this.borderColor = Colors.grey,
    this.textEditingController,
    this.onChanged,
    this.textInputType = TextInputType.name,
    this.autoCorrect = false,
    this.obscure = false,
    this.autoValidate = false,
    this.maxLines = 1,
    this.focusNode,
    this.onTap,
    this.onFieldSubmitted,
    this.sizeHeight = 0,
    this.textAlign = TextAlign.left,
    this.labelStyle = const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
    this.boxShadow,
    this.sizeBorder = 1.5,
    this.suffixIcon,
    this.prefixIcon,
    this.enable = true,
    this.padding = const EdgeInsets.only(left: 5),
    this.textCapitalization = TextCapitalization.sentences,
    this.hintText = '',
    this.colorBack = Colors.white,
    this.autofocus = false,
    this.textInputAction,
    this.constraints,
    this.activeInputBorder = true,
    this.radius = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: constraints != null ? null : sizeHeight == 0 ? (sizeH * 0.06) : sizeHeight,
      padding: padding,
      constraints: constraints,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: colorBack,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: new Border.all(
          width: sizeBorder,
          color: borderColor,
        ),
        boxShadow: boxShadow,
      ),
      child: TextFormField(
        onFieldSubmitted: onFieldSubmitted,
        onTap: onTap,
        style: labelStyle,
        textAlign: textAlign,
        initialValue: initialValue,
        maxLines: maxLines,
        obscureText: obscure,
        enabled: enable,
        controller: textEditingController,
        onChanged: onChanged,
        autocorrect: autoCorrect,
        keyboardType: textInputType,
        focusNode: focusNode,
        textCapitalization: textCapitalization,
        autofocus: autofocus,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorBack,
          focusedBorder: !activeInputBorder ? null : OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            borderSide: BorderSide(
              width: 0.0,
              color: Colors.transparent,
            ),
          ),
          enabledBorder: !activeInputBorder ? null : OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius)),
            borderSide: BorderSide(
              width: 0.0,
              color: Colors.transparent,
            ),
          ),
          suffixIcon: suffixIcon,
          labelText: placeHolder,
          labelStyle: labelStyle,
          errorStyle: labelStyle,
          hintText: hintText,
          hintStyle: labelStyle,
          prefixIcon: prefixIcon,
          contentPadding: !activeInputBorder ? null : EdgeInsets.symmetric(horizontal: sizeW * 0.01, vertical: sizeH * 0.001)
        ),
      ),
    );
  }
}
