import 'package:flutter/material.dart';

import '../../utils/global_classes/color_manager.dart';
import '../../utils/global_variable.dart';

class CustomElevatedButton extends StatelessWidget {
  Function? onPressed;
  String? text;
  double? textFontSize;
  Color? textColor;
  double boarderRadius;

  double buttonHeight;
  Color backgroundColor;
  double buttonWidth;
  double buttonBorderWidth;
  Color buttonBorderColor;
  double horizontalPadding;

   CustomElevatedButton({
     super.key,
     required this.onPressed,
     required this.text,
     this.textFontSize = 14.0,
     this.textColor = Colors.black,
     this.boarderRadius = 5,
     this.buttonHeight = allElevatedButtonHeight,
     this.backgroundColor = ColorManager.teal600,
     this.buttonWidth = 80,
     this.buttonBorderWidth = boarderWidthVariable,
     this.buttonBorderColor = boarderColorVariable,
     this.horizontalPadding = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
          onPressed:  onPressed != null ? () => onPressed!() : null,
        style: ElevatedButton.styleFrom(
          padding:  EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
          minimumSize: Size(buttonWidth, 20),
          elevation: 0,
          fixedSize: Size.fromHeight(buttonHeight),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(boarderRadius),
          ),
          side: BorderSide(
            width: buttonBorderWidth,
            color: buttonBorderColor,
          ),
        ),
          child:Text(text!, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: textFontSize!, color: textColor),),
      ),
    );
  }
}
