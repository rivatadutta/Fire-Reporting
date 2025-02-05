import 'package:fire_project/globalData/address_search.dart';
import 'package:fire_project/globalData/place_service.dart';
import 'package:fire_project/navbar/bottom_navbar_page.dart';
import 'package:fire_project/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fire_project/globalData/globalVariables.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:uuid/uuid.dart';

class EnterLocation extends StatefulWidget {

  final StoredUserData userData;

  EnterLocation({Key key, this.userData}) : super(key: key);

  _EnterLocationState createState() => _EnterLocationState();
}

class _EnterLocationState extends State<EnterLocation> {

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Global.kGoogleApiKey);

  final formKey = GlobalKey<FormState>();

  dynamic userAddress = Global.userAddress ?? "";

  final address1Controller =
      new TextEditingController(text: Global.userAddress ?? "");

  String _locationMessage;

  _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
    setState(() {
      _locationMessage = "${position.latitude}, ${position.longitude}";
    });
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print(' ${first.locality}, ${first.countryName}');

    // return first;
    address1Controller.text = "${position.latitude}, ${position.longitude}";

    Global.lat = '${position.latitude}';
    Global.long = '${position.longitude}';
    print(Global.lat + ' and ' + Global.long);
    _signInAddress();
  }

  void _signInAddress() {
    setState(() {
      if (formKey.currentState.validate()) {
        dynamic userAddress = address1Controller.text;
        print('userAddress is: ' + userAddress);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => TabsPage(userData: widget.userData),
            transitionsBuilder: (context, animation1, animation2, child) =>
                FadeTransition(opacity: animation1, child: child),
            transitionDuration: Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
              child: Container(
              padding: EdgeInsets.fromLTRB(30, 150, 30, 0),
                child: RichText(
                    text: TextSpan(
                      text: "And Your Location?",
                      style:  TextStyle(color: Colors.black87,fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: .1),
                      children: <TextSpan>[
                        TextSpan(
                            text: "\nThat's the only Information we need from you!", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, letterSpacing: 1.2, color:Colors.black45)),

                      ],
                    ),
                  ),
              ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: address1Controller,
                    readOnly: true,
                    onTap:() async {
                      final sessionToken = Uuid().v4();
                      final Suggestion result = await showSearch(context: context, delegate: AddressSearch(sessionToken),);
                      if (result != null)
                      {
                        setState(() {
                          address1Controller.text = result.description;
                          /* _streetNumber = placeDeatils.streetNumber;
                    _street = placeDeatils.street;
                    _city = placeDeatils.city;
                    _zipCode= placeDeatils.zipCode;*/

                        });}
                    },
                    style: TextStyle(fontSize: 25),
                    validator: (val) {
                      if (val.isEmpty) {
                        return "Please enter an address";
                      }
                      return null;
                    },
                    //controller: address1Controller,
                    decoration: InputDecoration(
                      hintText: "Enter address:",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrangeAccent),
                      ),
                    ),
                    onChanged: (text) {
                      userAddress = text;
                    },
                  ),
                ),
              ),
              Container(
                child: Text('or',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                child: TextButton(
                  onPressed: () {
                    userAddress = _getCurrentLocation();
                  },
                  child: Text('Use current location',
                      style:
                          TextStyle(fontSize: 24, color: Color(Global.selectedIconColor), fontWeight: FontWeight.w600, letterSpacing: .65,)),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _signInAddress();
        },
        backgroundColor: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded, color: Color(Global.selectedIconColor)),
      ),
    );
  }
}
