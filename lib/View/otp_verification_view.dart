import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'package:klink/ViewModel/auth_view_model.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => OtpVerificationViewState();
}

class OtpVerificationViewState extends State<OtpVerificationView> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenDim = MediaQuery.of(context);
    final screenWidth = screenDim.size.width;
    final screenHeight = screenDim.size.height;

    const focusedBorderColor = Color.fromRGBO(0, 0, 0, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_one.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth / 16,
                vertical: screenHeight / 6,
              ),
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight / 16,
                    horizontal: screenWidth / 16,
                  ),
                  child: Consumer<AuthViewModel>(
                    builder: (context, viewModel, child) {
                      return viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Verification',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Enter the 6-digit code sent to your email',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 48),

                                Pinput(
                                  length: 6,
                                  controller: pinController,
                                  focusNode: focusNode,
                                  defaultPinTheme: defaultPinTheme,
                                  separatorBuilder: (index) =>
                                      const SizedBox(width: 8),
                                  hapticFeedbackType:
                                      HapticFeedbackType.lightImpact,
                                  onCompleted: (pin) async {
                                    final viewModel =
                                        Provider.of<AuthViewModel>(
                                          context,
                                          listen: false,
                                        );
                                    final success = await viewModel.confirmOtp(
                                      pin,
                                    );

                                    if (!mounted) return;
                                    await showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        title: Text(
                                          success
                                              ? 'Verification succesful'
                                              : "Verfication failed",
                                          style: GoogleFonts.inter(),
                                        ),
                                        content: Text(
                                          success
                                              ? "Welcome to KLink"
                                              : viewModel.error ??
                                                    'Please enter the correct OTP',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  cursor: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 9,
                                        ),
                                        width: 22,
                                        height: 2,
                                        color: focusedBorderColor,
                                      ),
                                    ],
                                  ),
                                  focusedPinTheme: defaultPinTheme.copyWith(
                                    decoration: defaultPinTheme.decoration!
                                        .copyWith(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: focusedBorderColor,
                                          ),
                                        ),
                                  ),
                                  submittedPinTheme: defaultPinTheme.copyWith(
                                    decoration: defaultPinTheme.decoration!
                                        .copyWith(
                                          color: fillColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: focusedBorderColor,
                                          ),
                                        ),
                                  ),
                                  errorPinTheme: defaultPinTheme.copyBorderWith(
                                    border: Border.all(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
