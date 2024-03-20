import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timboo/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController userNameController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Center(
        child: ListView(
          children: [
            SizedBox(
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 250, vertical: 50),
                elevation: 10,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Column(
                    children: [
                      const Image(
                        image: AssetImage('assets/initial.jpg'),
                      ),
                      bottomSpaceeee,
                      TextField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          labelText: 'Kullanıcı Adı',
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.amber,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      bottomSpace,
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person),
                          suffixIcon: const Icon(Icons.lock),
                          labelText: 'Şifre',
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Colors.amber,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      bottomSpacee,
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize:
                              Size(MediaQuery.of(context).size.width, 55),
                          backgroundColor: Colors.purple,
                        ),
                        onPressed: () {
                          // downloadFile();
                          loginControl(
                            context,
                            userNameController.text,
                            passwordController.text,
                          );
                        },
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'VAGRoundedStd',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
