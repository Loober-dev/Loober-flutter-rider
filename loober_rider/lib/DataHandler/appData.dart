import 'package:flutter/cupertino.dart';
import 'package:loober_rider/Models/address.dart';

class AppData extends ChangeNotifier{
  Address pickUpLocation, dropOffLocation;

  void updatePickUpLocationAddress(Address pickUpAddress){
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress){
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}