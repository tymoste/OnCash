import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../Providers/group_expences_provider.dart';
import '../Models/user.dart';
import '../Utils/shared_preference.dart';

class GroupCreate extends StatefulWidget {
  @override
  _GroupCreateState createState() => _GroupCreateState();
}

class _GroupCreateState extends State<GroupCreate> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  File? _groupImage;
  late Future<User> userData;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userData = UserPreferences().getUser();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File originalImage = File(pickedFile.path);

      File resizedImage = await _resizeImage(originalImage);

      setState(() {
        _groupImage = resizedImage;
      });
    }
  }

  Future<File> _resizeImage(File file) async {
    final bytes = await file.readAsBytes();

    final decodedImage = img.decodeImage(bytes);

    if (decodedImage != null) {
      final resized = img.copyResize(
        decodedImage,
        width: 515,
        height: 515,
      );

      final tempDir = await getTemporaryDirectory();

      final resizedFile = File('${tempDir.path}/resized_image.jpg');

      await resizedFile.writeAsBytes(img.encodeJpg(resized));

      return resizedFile;
    }

    throw Exception("Failed to decode and resize image");
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupExpencesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              Text(
                'Group Image:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: _groupImage == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Tap to select an image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Image.file(
                        _groupImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    userData.then((data) async {
                      if (_groupImage != null) {
                        await groupProvider.createGroup(
                          data.jwt,
                          _groupNameController.text,
                          File(_groupImage!.path),
                        );
                      } else {
                        print("No image selected!");
                      }
                    });
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
