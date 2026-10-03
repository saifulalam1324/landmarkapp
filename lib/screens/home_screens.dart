import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../service/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  String? prediction;
  bool isLoading = false;

  Future<void> pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              // CAMERA
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  takePhoto();
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  chooseFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          prediction = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Camera error: $e")));
    }
  }

  Future<void> chooseFromGallery() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          prediction = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Gallery error: $e")));
    }
  }

  Future<void> predictLandmark() async {
    // Check image
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    // Start loading
    setState(() {
      isLoading = true;
      prediction = null;
    });

    try {
      final result = await ApiService.predictLandmark(selectedImage!);

      setState(() {
        prediction = result['prediction'].toString();
      });
    } catch (e) {
      setState(() {
        prediction = "Prediction failed";
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      // Stop loading
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Landmark Recognition",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF073A4B),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    width: 300,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 300,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "No image selected",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed: isLoading ? null : pickImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text("Select Image"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              if (selectedImage != null)
                ElevatedButton.icon(
                  onPressed: isLoading ? null : predictLandmark,
                  icon: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.search),
                  label: Text(
                    isLoading ? "Predicting..." : "Recognize Landmark",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF073A4B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              if (prediction != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF073A4B)),
                  ),
                  child: Column(
                    children: [
                      // LOCATION ICON
                      const Icon(
                        Icons.location_on,
                        size: 40,
                        color: Color(0xFF073A4B),
                      ),

                      const SizedBox(height: 10),

                      // TITLE
                      const Text(
                        "Predicted Landmark",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // PREDICTION
                      Text(
                        prediction!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF073A4B),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}