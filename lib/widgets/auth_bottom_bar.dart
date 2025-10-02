import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AuthTab { login, register }

class AuthBottomBar extends StatelessWidget {
  final AuthTab selected;
  final VoidCallback onTapLogin;
  final VoidCallback onTapRegister;

  const AuthBottomBar({
    super.key,
    required this.selected,
    required this.onTapLogin,
    required this.onTapRegister,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 56;
    final border = BorderRadius.circular(40);

    return Material(
      elevation: 8,
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: border,
        side: const BorderSide(color: Colors.white, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: barHeight,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedAlign(
                alignment: selected == AuthTab.login
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: onTapLogin,
                      child: Center(
                        child: Text(
                          'Login',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selected == AuthTab.login
                                  ? Colors.white
                                  : const Color(0xff818181),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: onTapRegister,
                      child: Center(
                        child: Text(
                          'Register',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selected == AuthTab.register
                                  ? Colors.white
                                  : const Color(0xff818181),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
