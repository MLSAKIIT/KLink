import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenDim = MediaQuery.of(context);
    final screenWidth = screenDim.size.width;
    final screenHeight = screenDim.size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_one.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth / 16,
              vertical: screenHeight / 16,
            ),
            child: Card(
              child: OtpTextField(
                showCursor: false,
                showFieldAsBox: true,
                numberOfFields: 6,
                onCodeChanged: (String code) {},
                onSubmit: (String verificationCode) {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
