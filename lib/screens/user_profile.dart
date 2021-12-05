import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/screens/task_list.dart';
import 'package:to_do_list/util/services/api.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _userEditFormKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();

  List<XFile>? _imageFileList;
  dynamic _pickImageError;

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : [value];
  }

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  Future<dynamic> imagePickerModal() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        var snackBar = SnackBar(
          content: Text(_pickImageError.toString()),
        );

        if (_pickImageError != null) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        return SafeArea(
          child: Wrap(
            children: <Widget>[
              const ListTile(
                title: Text('Adicione uma foto de perfil'),
              ),
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Escolher da galeria'),
                  onTap: () {
                    _onImageButtonPressed(ImageSource.gallery);

                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Usar a Câmera'),
                onTap: () {
                  _onImageButtonPressed(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _editUser() async {
    if (_userEditFormKey.currentState!.validate()) {
      String base64 = base64Encode(
        File(_imageFileList![0].path).readAsBytesSync(),
      );

      User newUserData = User(
        name: _name.text,
        email: _email.text,
        username: currentUser.username,
        password: currentUser.password,
        picture: base64,
      );

      final response = await API.updateUser(newUserData);
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          parsed['message'] == 'User Successfully Updated') {
        setState(() {
          currentUser.name = newUserData.name;
          currentUser.email = newUserData.email;
          currentUser.picture = newUserData.picture;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TaskList(),
          ),
        );
      } else {
        final snackBar = SnackBar(
          content: Text(parsed['message']),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    _name.text = currentUser.name!;
    _email.text = currentUser.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          TextButton(
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () => _editUser(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Form(
            key: _userEditFormKey,
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: _imageFileList == null
                          ? Icon(
                              Icons.add_a_photo,
                              size: 64.0,
                              color: Theme.of(context).primaryColor,
                            )
                          : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20.0),
                                  child: Image.file(
                                    File(_imageFileList![0].path),
                                    height: 150.0,
                                    width: 150.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 102,
                                  child: Container(
                                    height: 48.0,
                                    width: 48.0,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: const Icon(
                                      Icons.photo,
                                      size: 32.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                    ),
                    onTap: () {
                      imagePickerModal();
                    },
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    label: Text('Nome'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "Nome"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  controller: _email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    label: Text('E-mail (Somente leitura)'),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Preencha o campo "E-mail"';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 32.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
