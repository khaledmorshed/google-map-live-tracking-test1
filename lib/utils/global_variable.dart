import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global_classes/color_manager.dart';

//bool obSecureConfirmValue = true;
SharedPreferences? sh_prefs;
ValueNotifier obSecureValue = ValueNotifier(false);
ValueNotifier obSecurePasswordValue = ValueNotifier(false);
bool isCurrentPasswordForGlobal = true;
bool isPasswordForGlobal = true;
bool isConfirmPasswordForGlobal = true;
const String txt = "https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-980x653.jpg";
dynamic nullValue = "null";

//
int globalTotalValue = 0;
int globalPerPage = 20;
double tableHeaderRowHeight = 37;
double tableRecordRowHeight = 36;
double tableFooterHeight = 30;



//Button color variable
Color clearButtonBgColor = Colors.grey;
Color clearButtonTextColor = Colors.white;
Color applyButtonBgColor = Colors.blue;
Color applyButtonTextColor = Colors.white;
Color downloadPdfButtonBgColor = ColorManager.teal600;
Color downloadPdfButtonTextColor = Colors.white;
Color canCelButtonBgColor =  ColorManager.red400;
Color canCelButtonTextColor =  Colors.white;
Color saveButtonBgColor =  ColorManager.teal600;
Color saveButtonTextColor =  Colors.white;
Color addToCartButtBgColor =  ColorManager.purple400;
Color addToCartButtTextColor =  Colors.white;

Color addToAttachmentButtBgColor =  ColorManager.indigo400;
Color addToAttachmentIconColor =  Colors.white;


//download pdf variable
String pdfDownloadSuccessfulMessage = "Download Successful";
String pdfDownloadUnSuccessfulMessage = "Download Failed";

//all button height
const double allElevatedButtonHeight = 43;

//TextFormField
const double allTextFormFieldVerticalPadding = 10.3;
const double allTextFormFieldHorizontalPadding = 15;

//Filter section
const double buttonHeightInFilterSection = 35;
const double buttonBorderRadiusInFilterSection = 25;
const Color activeButtonColorInFilterSection = ColorManager.teal600;
const Color inactiveButtonColorInFilterSection = ColorManager.grey400;
//const Color inactiveButtonColorInFilterSection = ColorManager.indigo100;
const Color activeTextColorInFilterSection = Colors.white;
const Color inactiveTextColorInFilterSection = Colors.black;

//error
String wrong = "wrong";
String validation = "validation";

//padding
double screenLeftPadding = 15;
double screenRightPadding = 15;

//font size
double generalFontSize = 14;
double lessThanGeneralFontSize = 13;
double moreThanGeneralFontSize = 15;
double popupMenuHeight = 40;
double popupMenuElevation = 1.5;

//Radius
const double buttonRadiusValue = 5;

//table variable
//const Color tableHeaderColor = ColorManager.cyan300;
Color tableHeaderColor = ColorManager.brandColorWhite200;
Color tableColumnVisibilityColor = Colors.white;
Color tableActionIconColor = ColorManager.brandColorBlack500;
double tableActionIconSize = 22;

//Color tableHeaderColor = ColorManager.green300;

//sub total color
const Color subTotalColor = ColorManager.cyan200;

//data format showing system
String dateFormatShowingString = "y-MM-dd";

//button and textformfield
const double boarderWidthVariable = 0.5;
const Color boarderColorVariable = ColorManager.grey400;
const Color backGroundColorVariable = ColorManager.whiteOnly;
const double boarderRadiusVariable = 5;

//selected button color
const Color selectButtonColor = ColorManager.cyanOnly;
const Color selectButtonTextColor = ColorManager.whiteOnly;

String databaseName = "google_map_db";
String tableName = "google_map_data";
int distanceFilter = 20;
