import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/constant.dart';
import 'package:story_app/common/flavor_config.dart';
import 'package:story_app/providers/location_provider.dart';
import 'package:story_app/providers/story_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddStoryPage extends ConsumerStatefulWidget {
  const AddStoryPage({super.key});

  @override
  ConsumerState<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends ConsumerState<AddStoryPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;

  bool isLocationEnabled = false;
  late LatLng latLong;

  Future getImageGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future getImageCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  void _onLocationChanged(bool value) {
    setState(() {
      isLocationEnabled = value;
    });

    if (value) {
      onMyLocationButtonPress();
      _locationController.text = ref.read(locationProvider).address;
    }
  }

  void onMyLocationButtonPress() async {
    late bool serviceEnabled;
    late LocationPermission permissionGranted;
    late Position position;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
    }

    permissionGranted = await Geolocator.checkPermission();
    if (permissionGranted == LocationPermission.denied) {
      permissionGranted = await Geolocator.requestPermission();
      if (permissionGranted != LocationPermission.whileInUse) {
        return;
      }
    }

    position = await Geolocator.getCurrentPosition();

    ref.watch(locationProvider).setLatLong(
          position.latitude,
          position.longitude,
        );
  }

  Future addStory() async {
    if (_image == null || _descriptionController.text.isEmpty) {
      return ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image and description cannot be empty'),
        ),
      );
    }

    setState(() {
      _isLoading = true;
    });

    final data = isLocationEnabled
        ? FormData.fromMap({
            'description': _descriptionController.text,
            'photo': await MultipartFile.fromFile(_image!.path),
            'lat': ref.watch(locationProvider).lat.toString(),
            'lon': ref.watch(locationProvider).long.toString(),
          })
        : FormData.fromMap({
            'description': _descriptionController.text,
            'photo': await MultipartFile.fromFile(_image!.path),
          });

    final dio = Dio();
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('token');

    try {
      await dio.post('$baseUrl/stories',
          data: data,
          options: Options(
            headers: {
              'Authorization': "Bearer $token",
              'Content-Type': 'multipart/form-data',
            },
          ));

      if (FlavorConfig.instance.flavor == FlavorType.free ||
          !isLocationEnabled) {
        ref.read(storyProvider).setUseLocation = false;
      }
      ref.read(storyProvider).getAllStory(reset: true);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[200],
          content: const Text('Success add story'),
        ),
      );

      ref.context.pop();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[200],
          content: const Text('Error Ngab'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }

    return;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationRef = ref.watch(locationProvider);
    _locationController.text = locationRef.address;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(AppLocalizations.of(context)!.addStory),
        ),
        actions: [
          Container(margin: const EdgeInsets.only(right: 16), width: 36),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  color: Colors.grey[100],
                  width: double.infinity,
                  height: 300,
                  child: InkWell(
                    onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          getImageGallery();
                                          context.pop();
                                        },
                                        child: const Column(
                                          children: [
                                            Icon(
                                              Icons.photo,
                                              size: 36,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Gallery',
                                              style: TextStyle(fontSize: 11),
                                            )
                                          ],
                                        )),
                                    const SizedBox(width: 32),
                                    InkWell(
                                        onTap: () {
                                          getImageCamera();
                                          context.pop();
                                        },
                                        child: const Column(
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 36,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Camera',
                                              style: TextStyle(fontSize: 11),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                              ));
                        }),
                    child: _image == null
                        ? const Center(
                            child: Icon(
                            Icons.add_a_photo,
                            size: 50,
                          ))
                        : Image.file(
                            File(_image!.path),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      hintText:
                          AppLocalizations.of(context)!.writeDescriptionHere,
                      hintStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  )),
              const SizedBox(height: 16),
              FlavorConfig.instance.flavor == FlavorType.paid
                  ? Text(
                      AppLocalizations.of(context)!.enableLocation,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    )
                  : const SizedBox(),
              FlavorConfig.instance.flavor == FlavorType.paid
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Switch(
                              value: isLocationEnabled,
                              onChanged: _onLocationChanged),
                          const Spacer(),
                          isLocationEnabled && locationRef.lat.isNotEmpty
                              ? TextButton(
                                  onPressed: () => context.push(
                                      "/location-picker/${locationRef.lat}/${locationRef.long}"),
                                  child: Text(
                                    AppLocalizations.of(context)!.pickFromMap,
                                  ))
                              : const SizedBox(),
                        ],
                      ),
                    )
                  : const SizedBox(),
              const SizedBox(height: 16),
              locationRef.address.isNotEmpty && isLocationEnabled
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _locationController,
                        readOnly: true,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          hintText: AppLocalizations.of(context)!
                              .writeDescriptionHere,
                          hintStyle: const TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ))
                  : const SizedBox(),
              const SizedBox(height: 16),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: () async {
                        !_isLoading ? await addStory() : null;
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              AppLocalizations.of(context)!.addStory,
                              style: const TextStyle(fontSize: 18),
                            )))
            ],
          ),
        ),
      ),
    );
  }
}
