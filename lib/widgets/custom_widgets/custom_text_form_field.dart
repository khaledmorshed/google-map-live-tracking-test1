
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/global_classes/color_manager.dart';
import '../../utils/global_variable.dart';

class CustomTextFormField extends StatelessWidget {
  IconData? suffixIcon;
  IconData? prefixIcon;
  bool isCurrentPasswordField;
  bool isPasswordField;
  bool isConfirmPasswordField;
  String? hintText;
  IconData? icon;
  bool isPassword;
  Color? hintColor;
  double? hintTextSize;
  Color? textColor;
  TextInputType? textInputType;
  Function? onChanged;
  Function? validation;
  Function? onTap;
  Function? onFieldSubmit;
  TextEditingController? controller;
  bool? isReadOnly;
  EdgeInsets? padding;
  double? height;
  double? fontSize;
  String? errorText;
  double? outLineBoarder;
  Color? fillColor;
  bool? isContentPadding;
  double contentPaddingVertical;
  double contentPaddingHorizontal;
  double? iconPadding;
  String? prefixIconString;
  String? suffixIconString;
  bool? isFilled;
  FontWeight? fontWeight;
  Color? iconColor;
  bool? isErrorValidation;
  String? labelText;
  bool? isOutlineBoarder;
  bool? isDigitOnly;
  int ? maxLength;
  FocusNode? focusNode;
  bool? isAutovalidateMode = false;
  Color? enabledBoarderColor;
  Color? focusBoarderColor;
  bool onlyShowingBoarderError;
  bool enabled;
  bool isPhoneNumber;
  bool isLabelShowAlways;

  // String? check = "check";

  CustomTextFormField({
    super.key,
    this.suffixIcon,
    this.prefixIcon,
    this.hintText,
    this.icon,
    this.isPassword = false,
    this.textInputType = TextInputType.text,
    this.controller,
    this.hintColor,
    this.textColor = Colors.black,
    this.onChanged,
    this.onTap,
    this.isReadOnly = false,
    this.padding,
    this.height = 0,
    this.fontSize = 14,
    this.errorText = "please insert valid input 10",
    this.isOutlineBoarder = true,
    this.validation,
    //this.fillColor = ColorManager.homeBg,
    this.fillColor = ColorManager.whiteOnly,
    this.outLineBoarder,
    this.iconPadding,
    this.prefixIconString,
    this.suffixIconString,
    this.isFilled = true,
    this.fontWeight = FontWeight.w400,
    this.hintTextSize = 16,
    this.iconColor = Colors.grey,
    this.isErrorValidation = true,
    this.labelText,
    this.isDigitOnly = false,
    this.maxLength = 10000000,
    this.contentPaddingHorizontal = allTextFormFieldHorizontalPadding,
    this.contentPaddingVertical = allTextFormFieldVerticalPadding,
    this.isContentPadding = false,
    this.focusNode,
    this.isAutovalidateMode = false,
    this.isCurrentPasswordField = false,
    this.isPasswordField = false,
    this.isConfirmPasswordField = false,
    this.onFieldSubmit,
    this.enabledBoarderColor = ColorManager.textFieldEnableBorderColor,
    this.focusBoarderColor,
    this.onlyShowingBoarderError = false,
    this.enabled = true,
    this.isPhoneNumber = false,
    this.isLabelShowAlways = false,
  });

  @override
  Widget build(BuildContext context) {
    //print("..origina.......${allTextFormFieldVerticalPadding}..............value......${allTextFormFieldVerticalPadding.h}.......${(allTextFormFieldVerticalPadding-allTextFormFieldVerticalPadding.h).abs()}");
    return Center(
      child: ValueListenableBuilder(
          valueListenable: obSecureValue,
          builder: (context, value, _) {
            //  print("ValueListenableBuilder.....main.......${obSecureValue.value}+ isPass......$isPassword+....CurrrentPasswordForGlobal...$isCurrentPasswordForGlobal...isPasswordForGlobal.....$isPasswordForGlobal...ConfirmPassworGlobal........$isConfirmPasswordForGlobal");
            return TextFormField(
              inputFormatters: isDigitOnly! ?  [
                FilteringTextInputFormatter.digitsOnly,
              ] : null,
              readOnly: isReadOnly!,
              focusNode: focusNode,
              enabled: enabled,
              onTap: onTap != null ? () => onTap!() : null,
              //it was before
              //autovalidateMode: AutovalidateMode.always,
              //now this is set
              autovalidateMode: isAutovalidateMode! ? AutovalidateMode.always : AutovalidateMode.onUserInteraction,
              validator: validation != null && !onlyShowingBoarderError ? (String? txt) => validation!(txt) : null,
              controller: controller!,
              obscureText: isPassword,
              keyboardType: textInputType,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              onChanged: onChanged != null ? (String txt) => onChanged!(txt) : null,
              onFieldSubmitted: onFieldSubmit != null ? (String txt) => onFieldSubmit!(txt) : null,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                  prefixIconConstraints: BoxConstraints(maxHeight: 30, maxWidth: 40),
                  counterText: "",
                  isDense: false,
                  //for content padding workable it needs true
                  isCollapsed: true,
                  //isCollapsed: isContentPadding! ? true : false,
                  border: isOutlineBoarder! ?  const OutlineInputBorder() : InputBorder.none,
                  focusedBorder: /*focusBoarderColor == null ? null : */const OutlineInputBorder(
                    borderSide: BorderSide(
                        width: boarderWidthVariable, color: Colors.blue),
                  ),
                  //     // focusedBorder: OutlineInputBorder(
                  //     //   borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  //     // ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width:  boarderWidthVariable, color: enabledBoarderColor!),
                  ),
                  errorBorder: !onlyShowingBoarderError ? null : const OutlineInputBorder(
                    borderSide: BorderSide(
                      width:  boarderWidthVariable, // Set the border width as desired
                      color: Colors.red, // Set the border color for error
                    ),
                  ),
                  labelText: labelText,
                  floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                        (Set<MaterialState> states) {
                      final Color color = states.contains(MaterialState.error)
                          ? Theme.of(context).colorScheme.error
                          : Colors.orange;
                      return TextStyle(color: color, letterSpacing: 1.3, fontSize: 14);
                    },
                  ),

                  floatingLabelBehavior: isLabelShowAlways ? FloatingLabelBehavior.always  : null,
                  labelStyle: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
                  contentPadding: /*isContentPadding == false ? null :*/ EdgeInsets.symmetric(horizontal: contentPaddingHorizontal, vertical: contentPaddingVertical/*(contentPaddingVertical+extraVerticalPadding).h*/),
                  suffixIcon: suffixIcon == null
                      ? null
                      : Padding(
                    padding: iconPadding == null
                        ? const EdgeInsets.all(0)
                        : EdgeInsets.only(
                        left: iconPadding!, right: iconPadding!),
                    child: SizedBox(
                      child: IconButton(
                        onPressed: () {
                          if (controller!.text.isEmpty) return;
                          if(isCurrentPasswordField){
                            isCurrentPasswordForGlobal  = !isCurrentPasswordForGlobal;
                            isPassword = isCurrentPasswordForGlobal;
                            //obSecureValue.value = !(obSecureValue.value);
                          }
                          else if(isPasswordField){
                            isPasswordForGlobal = !isPasswordForGlobal;
                            isPassword = isPasswordForGlobal;
                          }
                          else if(isConfirmPasswordField){
                            isConfirmPasswordForGlobal = !isConfirmPasswordForGlobal;
                            isPassword = isConfirmPasswordForGlobal;
                          }
                          obSecureValue.value = !(obSecureValue.value);
                          if(isPassword){
                            suffixIcon = const Icon(Icons.visibility).icon;
                          }
                          else{
                            suffixIcon = const Icon(Icons.visibility_off).icon;
                          }
                        },
                        icon: Icon(suffixIcon, color: iconColor,),
                      ),
                    ),
                  ),
                  prefixIcon: isPhoneNumber ?
                  //null
                  //SizedBox( height: 10,child: Icon(Icons.add, color: iconColor, size: 15.r, ))
                  Container(
                    // color: Colors.red,
                    margin: const EdgeInsets.only(top: 3.0),
                    //  decoration: BoxDecoration(
                    //    // border: Border(
                    //    //   right: BorderSide( // Apply border to the right side
                    //    //     color:  Colors.grey, // Color of the border
                    //    //     width: 1.0, // Width of the border
                    //    //   ),
                    //    // ),
                    //  ),
                    width: 40,
                    //height: contentPaddingVertical.h,
                    child:  Center(child: Text("+88", style: TextStyle(fontSize: 14),),),
                  )
                      : prefixIcon == null
                      ? null
                      : SizedBox(
                    // height: 20,
                    // width: 20,
                    //child: Image.asset(prefixIconString!),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Icon(prefixIcon, color: iconColor, size: 20, ),
                    ),
                  ),
                  hintText: hintText == null ? null : hintText!,
                  //hintStyle: TextStyle(fontSize: 13.sp, color: Colors.red,),
                  filled: isFilled,
                  fillColor: fillColor,
                  //outlineboarder and error text may not stay together
                  errorText: isErrorValidation! ? null : errorText
              ),
            );
          }),
    );
  }
}
