import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/common/constant.dart';
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
  bool _isLoading = false;

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

    final data = FormData.fromMap({
      "description": _descriptionController.text,
      "photo": await MultipartFile.fromFile(_image!.path),
    });

    final dio = Dio();
    final sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getString('token');

    try {
      await dio.post('$base_url/stories',
          data: data,
          options: Options(headers: {
            'Authorization': "Bearer $token",
            'Content-Type': 'multipart/form-data',
          }));

      ref.read(storyProvider).getAllStory();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[200],
          content: const Text('Success add story'),
        ),
      );

      // ignore: use_build_context_synchronously
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: () {
                        !_isLoading ? addStory() : null;
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Add Story',
                              style: TextStyle(fontSize: 18),
                            )))
            ],
          ),
        ),
      ),
    );
  }
}
