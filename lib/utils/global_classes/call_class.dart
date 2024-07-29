import 'package:rxdart/rxdart.dart';

import '../../data/repositories/local/sqflite/sqf_lite_db.dart';
import '../global_variable.dart';

class CallClass{

  static CallClass? _instance;
  bool isStart;

  CallClass._internal({this.isStart = true});

  static CallClass getInstance({bool isStart = true}) {
  if (_instance == null) {
  _instance = CallClass._internal(isStart: isStart);
  }
  return _instance!;
  }


// Example usage in functions
  void f() {
  var obj = CallClass.getInstance(isStart: true);
  // Use obj as needed
  }

  void f2() {
  var obj = CallClass.getInstance();
  // Use obj as needed
  }


//   //static bool isNowCall = false;
//   bool isStart = true;
//
//   CallClass({
//     this.isStart = true,
// });
//
//
//    //static BehaviorSubject<int> counterSubject = BehaviorSubject<int>.seeded(1);
//    static BehaviorSubject<bool> isNowCall = BehaviorSubject<bool>.seeded(false);
//   // void incrementCounter() {
//   //   counterSubject.add(counterSubject.value + 1);
//   //   print("counterSubject...${counterSubject.value}");
//   // }
//   //
//   // int getCounterValue(){
//   //   int num  = counterSubject.value;
//   //  // print("num...$num");
//   //   return num;
//   // }
//
//   static bool getIsNowCallValue(){
//     print("num...$isNowCall");
//     return isNowCall.value;
//   }
//
//   static void setIsNowCallValue(bool flag){
//     isNowCall.add(flag);
//     print("iNowCall...s${isNowCall.value}");
//
//   }


  static storeDataInSqflite({double latitude = 0, double longitude = 0})async {
    var obj = CallClass.getInstance();
     print("isStart..1.${obj.isStart}");
    // if (!obj.isStart) {

       var map = {
         "latitude": "$latitude",
         "longitude": "$longitude",
       };
       String tableInfo =  "CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, latitude TEXT, longitude TEXT)";
       await SqfLitDb.createDatabaseAndInsertDataInTable(tableName: tableName, createTableInformation: tableInfo, map: map, databaseName: databaseName);

     // }else{
     //   print("isStart...${obj.isStart}");
     // }

}
}