import 'package:battle_bro_00/common/theme_style.dart';
import 'package:flutter/material.dart';

Widget InkButton(
    {
      Function()? onTap,
      Widget? child,
      double? height,
      Color? bgColor,
      EdgeInsets? contentPadding,
      EdgeInsets? margin,
      EdgeInsets? padding
    }) {
  return Container(
      margin: margin,
      padding: padding,
      child: MaterialButton(
        height: height,
        minWidth: 30.0,
        padding: contentPadding ?? EdgeInsets.zero,
        color: bgColor ?? SECONDARY_50,
        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),
        onPressed: () {
          if (onTap != null) onTap();
        },
        highlightColor: Colors.white,
        child: child,
      )
  );
}
