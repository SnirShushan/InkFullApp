import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: "login_bg",
        child: Container(
          foregroundDecoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: [0.2, 0.7]),
          ),
          // decoration: BoxDecoration(
          //     image: DecorationImage(
          //         colorFilter: ColorFilter.mode(
          //             Colors.black.withOpacity(0.5), BlendMode.dstATop),
          //         fit: BoxFit.cover,
          //         image: const AssetImage("assets/images/login/bg_login_old.png")))
          // child: Image.asset("assets/images/login/bg_login_old.jpg",
          //     fit: BoxFit.cover),
          child: Image.asset("assets/images/login/bg_login_old.jpg",
              fit: BoxFit.cover),
        ));
  }
}
