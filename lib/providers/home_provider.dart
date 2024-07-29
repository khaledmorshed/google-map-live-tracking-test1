import 'package:flutter/cupertino.dart';

class HomeProvider with ChangeNotifier{
  bool isNowCall = false;

  f(){
    notifyListeners();
  }
}