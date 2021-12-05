import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:to_do_list/models/user.dart';
import 'package:to_do_list/screens/signin.dart';
import 'package:to_do_list/screens/user_profile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentUser.name!),
            accountEmail: Text(currentUser.email!),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: currentUser.picture != null
                  ? ClipOval(
                      // child: imageFromBase64String(currentUser.picture!),
                      child: Image.memory(
                      base64Decode(currentUser.picture!.toString()),
                      height: 150.0,
                      width: 150.0,
                      fit: BoxFit.cover,
                    ))
                  : Text(
                      currentUser.name![0].toUpperCase(),
                      style: const TextStyle(fontSize: 32.0),
                    ),
              radius: 50.0,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ListTile(
                  title: const Text('Meu Perfil'),
                  leading: const Icon(Icons.person),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfile(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Sair'),
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    currentUser = User();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignIn(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
