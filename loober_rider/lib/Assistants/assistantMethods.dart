import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loober_rider/Assistants/requestAssistant.dart';
import 'package:loober_rider/DataHandler/appData.dart';
import 'package:loober_rider/Models/address.dart';
import 'package:loober_rider/Models/allUsers.dart';
import 'package:loober_rider/Models/directionDetails.dart';
import 'package:loober_rider/configMaps.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  static Future<String> searchCoordonatedAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != 'failed') {
      //placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]
          ["long_name"]; //to get house/office number
      st2 = response["results"][0]["address_components"][1]
          ["long_name"]; //to get street number
      st3 = response["results"][0]["address_components"][5]
          ["long_name"]; //to get city
      st4 = response["results"][0]["address_components"][6]
          ["long_name"]; //to get country
      placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if(res == "failed"){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails){
    //in terms of USD
    double timeTravelledFare = (directionDetails.durationValue / 60) * 0.05; //initially (* 0.20)
    double distanceTravelledFare = (directionDetails.distanceValue / 1000) * 0.05; //initially (* 0.20)
    double totalFareAmount = timeTravelledFare + distanceTravelledFare;

    //Local currency conversion
    //$1 = GHC5.8
    //double totalLocalAmount = totalFareAmount * 5.8;

    return totalFareAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String userId = firebaseUser.uid;
    DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot)
      {
        if(dataSnapShot.value != null){
          userCurrentInfo = Users.fromSnapshot(dataSnapShot);
        }
      });
  }
}
