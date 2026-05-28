import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'signup_page.dart';
import 'profile_check_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final AuthService _auth = AuthService();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  // LOGIN FUNCTION
  Future<void> _loginUser() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      await _auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const ProfileCheckPage(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login Failed: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [

            // TOP DESIGN
            Container(
              width: double.infinity,
              height: 320,

              decoration: BoxDecoration(
                color: Colors.green[800],

                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 100,
                    height: 100,

                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      Icons.electric_car,
                      size: 60,
                      color: Colors.green[800],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "EV Finder & Book",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Charge your journey",

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // FORM
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 40,
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Welcome Back!",

                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Login to continue",

                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,

                      keyboardType:
                      TextInputType.emailAddress,

                      decoration: InputDecoration(
                        labelText: "Email Address",

                        prefixIcon:
                        const Icon(Icons.email_outlined),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),

                      validator: (v) {

                        if (v == null || !v.contains("@")) {
                          return "Enter valid email";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD
                    TextFormField(
                      controller: _passwordController,

                      obscureText: true,

                      decoration: InputDecoration(
                        labelText: "Password",

                        prefixIcon:
                        const Icon(Icons.lock_outline),

                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),

                      validator: (v) {

                        if (v == null || v.length < 6) {
                          return "Password too short";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,

                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],

                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                        ),

                        onPressed:
                        isLoading ? null : _loginUser,

                        child: isLoading

                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )

                            : const Text(
                          "Login",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SIGNUP PAGE BUTTON
                    Center(
                      child: TextButton(

                        onPressed: () {

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder: (context) =>
                              const SignupPage(),
                            ),
                          );
                        },

                        child: const Text(
                          "Create New Account",

                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}