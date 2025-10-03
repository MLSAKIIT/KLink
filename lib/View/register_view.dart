import 'package:flutter/material.dart';
import 'package:klink/View/otp_verification_view.dart';
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
  AuthTab _selected = AuthTab.register;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenDim = MediaQuery.of(context);
    final screenWidth = screenDim.size.width;
    final screenHeight = screenDim.size.height;
    final bottomSafe = screenDim.padding.bottom;
    final viewportHeight =
        screenDim.size.height -
        screenDim.padding.top -
        screenDim.padding.bottom;

    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.black,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_two.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: viewportHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth / 16,
                        right: screenWidth / 16,
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
                        vertical: screenHeight / 8,
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
                          child: Consumer<AuthViewModel>(
                            builder: (context, viewModel, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Let's get \nStarted!",
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Name
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      'Name',
                                      style: GoogleFonts.inter(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _usernameController,
                                    cursorColor: Colors.black,
                                    onChanged: viewModel.verifyUsername,
                                    decoration: InputDecoration(
                                      errorText: viewModel.username.error,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                      hintText: 'Alok Sharma',
                                      hintStyle: GoogleFonts.inter(),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Email
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 5,
                                    ),
                                    child: Text(
                                      'Email',
                                      style: GoogleFonts.inter(
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _emailController,
                                    cursorColor: Colors.black,
                                    onChanged: viewModel.verifyEmail,
                                    decoration: InputDecoration(
                                      errorText: viewModel.email.error,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                      hintText: '12345678@kiit.ac.in',
                                      hintStyle: GoogleFonts.inter(),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // Send OTP
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: viewModel.isLoading
                                          ? null
                                          : () async {
                                              viewModel.verifyUsername(
                                                _usernameController.text,
                                              );
                                              viewModel.verifyEmail(
                                                _emailController.text,
                                              );

                                              final ok = await viewModel
                                                  .registerUser();
                                              if (!mounted) return;

                                              if (!ok) {
                                                final msg =
                                                    viewModel.error ??
                                                    'Please check your details and try again.';
                                                await showDialog<void>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    title: Text(
                                                      'Couldn’t send code',
                                                      style:
                                                          GoogleFonts.inter(),
                                                    ),
                                                    content: Text(msg),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                // Move to OTP screen
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const OtpVerificationView(),
                                                  ),
                                                );
                                              }
                                            },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
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
                                                  textStyle: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
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
