import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/screens/signin.dart';
import 'package:to_do_list/screens/task_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:to_do_list/util/services/users.service.dart';
import 'package:to_do_list/widgets/delete_account_dialog.dart';
import 'package:to_do_list/widgets/update_user_password_dialog.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _userEditFormKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();

  File? _imageFile;
  dynamic _pickImageError;

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
      );

      if (pickedFile != null) {
        _cropImage(File(pickedFile.path));
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

  Future<void> _cropImage(File file) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        maxHeight: 150,
        maxWidth: 150,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Recortar',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            activeControlsWidgetColor: Theme.of(context).primaryColor),
        iosUiSettings: const IOSUiSettings(
          title: 'Recortar',
        ));

    if (croppedFile!.path.isNotEmpty) {
      setState(() {
        _imageFile = croppedFile;
      });
    }
  }

  _editUser() async {
    if (_userEditFormKey.currentState!.validate()) {
      String? base64 = _imageFile != null
          ? base64Encode(
              File(_imageFile!.path).readAsBytesSync(),
            )
          : currentUser.picture!;

      User newUserData = User(
        name: _name.text,
        email: _email.text,
        username: currentUser.username,
        password: currentUser.password,
        picture: base64,
      );

      await UserService.update(newUserData).then((response) async {
        var body = jsonDecode(await response.transform(utf8.decoder).join());

        if (response.statusCode == 200 &&
            body['message'] == 'User Successfully Updated') {
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
            content: Text(body['message']),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
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
    double screenHeight = MediaQuery.of(context).size.height;
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
        physics: const NeverScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: screenHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Form(
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
                                child: currentUser.picture == null
                                    ? _imageFile != null
                                        ? Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                child: Image.file(
                                                  File(_imageFile!.path),
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
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: const Icon(
                                                    Icons.photo,
                                                    size: 32.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        : Icon(
                                            Icons.add_a_photo,
                                            size: 64.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          )
                                    : Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            child: Image.memory(
                                              base64Decode(
                                                currentUser.picture!.toString(),
                                              ),
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
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
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
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 32.0,
                    ),
                    TextButton(
                      child: const Text('Alterar Usuário / Senha'),
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (_) => const UpdateAuthDialog(),
                        );

                        if (result != null && result != false) {
                          setState(() {
                            currentUser.username = result[0];
                            currentUser.password = result[1];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight / 3.5,
                child: Center(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.red.shade100,
                      ),
                    ),
                    child: const Text(
                      'Excluir Conta',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (_) => const DeleteAccountDialog(),
                      );

                      if (result != null && result) {
                        currentUser = User();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignIn(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
