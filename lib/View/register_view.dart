import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klink/ViewModel/auth_view_model.dart';
import 'package:klink/View/login_view.dart';
import 'package:klink/widgets/auth_bottom_bar.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthTab _selected = AuthTab.register;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenDim = MediaQuery.of(context);
    final screenWidth = screenDim.size.width;
    final screenHeight = screenDim.size.height;
    final bottomSafe = screenDim.padding.bottom;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.black,
          body: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_two.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: screenHeight / 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth / 16,
                        right: screenWidth / 16,
                        top: screenHeight / 40,
                      ),
                      child: SizedBox(
                        child: Image.asset(
                          'assets/icon/icon_invert.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth / 16,
                        vertical: screenHeight / 16,
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth / 16,
                            vertical: screenHeight / 40,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Let's get \nStarted!",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 35,
                                  ),
                                ),
                              ),

                              SizedBox(height: 30),

                              Consumer<AuthViewModel>(
                                builder: (context, viewModel, child) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: 5,
                                        ),
                                        child: Text(
                                          'Name',
                                          style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _usernameController,
                                        cursorColor: Colors.black,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          errorText: viewModel.username.error,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          focusColor: Colors.black,
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                          ),
                                          hintText: 'Alok Sharma',
                                          hintStyle: GoogleFonts.inter(),
                                        ),
                                      ),

                                      SizedBox(height: 20),

                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 5,
                                          horizontal: 5,
                                        ),
                                        child: Text(
                                          'Email',
                                          style: GoogleFonts.inter(
                                            textStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _emailController,
                                        cursorColor: Colors.black,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          errorText: viewModel.email.error,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                            ),
                                          ),
                                          focusColor: Colors.black,
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 2,
                                            ),
                                          ),
                                          hintText: '12345678@kiit.ac.in',
                                          hintStyle: GoogleFonts.inter(),
                                        ),
                                      ),

                                      SizedBox(height: 30),

                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xff000000,
                                            ),
                                            foregroundColor: const Color(
                                              0xffffffff,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: viewModel.isLoading
                                              ? null
                                              : () async {
                                                  final username =
                                                      _usernameController.text;
                                                  final email =
                                                      _emailController.text;
                                                  final password =
                                                      _passwordController.text;
                                                  viewModel.verifyUsername(
                                                    username,
                                                  );
                                                  viewModel.verifyEmail(email);
                                                  viewModel.verifyPassword(
                                                    password,
                                                  );

                                                  final success =
                                                      await viewModel
                                                          .registerUser();

                                                  if (!success) {
                                                    if (!mounted) {
                                                      return;
                                                    }
                                                    viewModel.error == null
                                                        ? null
                                                        : await showDialog<
                                                            void
                                                          >(
                                                            context: context,
                                                            builder: (context) => AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              title: Text(
                                                                'Registration Failed',
                                                                style:
                                                                    GoogleFonts.inter(),
                                                              ),
                                                              content: Text(
                                                                viewModel
                                                                        .error ??
                                                                    'Please check your credentials and try again',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                        context,
                                                                      ).pop(),
                                                                  child:
                                                                      const Text(
                                                                        'OK',
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                  } else {
                                                    if (!mounted) {
                                                      return;
                                                    }
                                                    await showDialog<void>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        title: Text(
                                                          'Registration successful',
                                                          style:
                                                              GoogleFonts.inter(),
                                                        ),
                                                        content: Text(
                                                          viewModel.error ??
                                                              "Check your email for the verification link",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(),
                                                            child: const Text(
                                                              'OK',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: viewModel.isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : Text(
                                                    'Register',
                                                    style: GoogleFonts.inter(
                                                      textStyle: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: screenWidth / 16,
          right: screenWidth / 16,
          bottom: bottomSafe + 12,
          child: AuthBottomBar(
            selected: _selected,
            onTapLogin: () async {
              if (_selected != AuthTab.login) {
                setState(() => _selected = AuthTab.login);
                await Future.delayed(const Duration(milliseconds: 220));
              }
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
            onTapRegister: () async {
              if (_selected == AuthTab.register) return;
              setState(() => _selected = AuthTab.register);
              await Future.delayed(const Duration(milliseconds: 220));
            },
          ),
        ),
      ],
    );
  }
}
