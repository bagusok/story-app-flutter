import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story_app/providers/location_provider.dart';

class LocationPicker extends ConsumerStatefulWidget {
  final String lat;
  final String long;

  const LocationPicker({super.key, required this.lat, required this.long});

  @override
  ConsumerState<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends ConsumerState<LocationPicker> {
  late GoogleMapController mapController;

  late final Set<Marker> markers = {};

  bool mouted = false;

  late String address;

  LatLng myLocation = const LatLng(0, 0);

  void defineMarker(double lat, double long) async {
    ref.read(locationProvider).setLatLong(lat, long);

    final marker = Marker(
      markerId: const MarkerId("source"),
      position: ref.read(locationProvider).latLong,
      infoWindow: const InfoWindow(
          title: "Your Location", snippet: "Your Location is here!"),
    );

    setState(() {
      markers.clear();
      markers.add(marker);
    });

    mapController.animateCamera(
        CameraUpdate.newLatLng(ref.read(locationProvider).latLong));

    List<Placemark> placemarks = await placemarkFromCoordinates(
        ref.read(locationProvider).latLong.latitude,
        ref.read(locationProvider).latLong.longitude);

    var mergeAddress =
        "${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}, ${placemarks.first.postalCode}";

    ref.read(locationProvider).setAddress = mergeAddress;
  }

  void _goToMyLocation() async {
    var location = await Geolocator.getCurrentPosition();

    myLocation = LatLng(location.latitude, location.longitude);
  }

  @override
  void initState() {
    defineMarker(ref.read(locationProvider).latLong.latitude,
        ref.read(locationProvider).latLong.longitude);
    mouted = true;

    Future.microtask(() => _goToMyLocation());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: mouted
                ? Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (controller) {
                          setState(() {
                            mapController = controller;
                          });
                        },
                        onLongPress: (latLong) {
                          defineMarker(latLong.latitude, latLong.longitude);
                        },
                        initialCameraPosition: CameraPosition(
                            target: ref.watch(locationProvider).latLong,
                            zoom: 15),
                        markers: markers,
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () {
                              if (myLocation.latitude != 0) {
                                defineMarker(
                                    myLocation.latitude, myLocation.longitude);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3))
                                  ]),
                              child: const Icon(Icons.my_location_outlined),
                            ),
                          )),
                      ref.watch(locationProvider).address.isNotEmpty
                          ? Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3))
                                      ]),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ref.watch(locationProvider).address,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        onPressed: () {
                                          ref.context.pop();
                                        },
                                        child: Text(
                                          "Select Location",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  )
                : const CircularProgressIndicator()));
  }
}
