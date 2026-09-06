import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ink/src/data/model/currentUser.dart';
import 'package:ink/src/data/source/network/user_api.dart';
import 'package:ink/src/ui/screen/auth/registration_screen.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/business_dashboard.dart';
import 'package:ink/src/ui/screen/business_user/dashboard/bussinessdashboard_binding.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard.dart';
import 'package:ink/src/ui/screen/dashboard/dashboard_binding.dart';
import 'package:ink/src/ui/screen/profile/select_category.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/common.dart';
import 'package:ink/src/utils/webService.dart';

class GoogleSignInController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future signInWithGoogle() async {
    // try {
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential authResult =
          await auth.signInWithCredential(credential);

      WebService.printMsg("google user : ${authResult.user.toString()}");

      final User? user = authResult.user;

      if (user != null) {
        //start login using API

        await Network.signInWithGoogle(user).then((value) async {
          //if login success
          if (value == true) {
            // displayMessage("נכנס בהצלחה", Theme.of(Get.context!).primaryColor);
            AppUser currentUser = await WebService.getCurrentUser();
            if (currentUser.stylesList != null &&
                currentUser.stylesList!.isNotEmpty) {
              if (currentUser.profile?.isRegister == "1") {
                WebService.setRegistrationData("false");
                Get.to(RegistrationScreen(
                    isphonenumberLogin: false,
                    nameReg: currentUser.profile!.name.toString() == ""
                        ? user.displayName.toString()
                        : currentUser.profile!.name.toString(),
                    phonenoReg: authResult.user!.phoneNumber.toString(),
                    emailReg: authResult.user!.email.toString()));
              } else {
                if (currentUser.profile!.userType.toString() == "2") {
                  Get.offAll(
                      BusinessDashBoard(
                        initialIndex: 0,
                      ),
                      binding: BusinessDashBoardBinding());
                } else {
                  currentUser.profile!.styles.toString().isNotEmpty
                      ? Get.offAll(
                      const DashBoard(
                        initialIndex: 0,
                      ),
                      binding: DashBoardBinding())
                      : Get.offAll(const SelectCategory(
                    fromLogin: true,
                  ));
                }
              }
            }else{
              displayMessageIcon(
                  message: tr("alerts.something_went_wrong"),
                  color: errorColor,
                  snackposition: SnackPosition.BOTTOM,
                  imageData: AppAssets.errorIcon);
            }

            //check user type is user business or normal user
          } else {
            displayMessageIcon(
                message: tr("alerts.something_went_wrong"),
                color: errorColor,
                snackposition: SnackPosition.BOTTOM,
                imageData: AppAssets.errorIcon);
          }
        });
      } else {
        WebService.printMsg("user is null");
      }
    } else {
      print("catch user is null");
      return null;
    }
    // } catch (error) {
    //   print("catch controller sign in");
    //   displayMessage(error.toString(), errorColor);
    //   return null;
    // }
  }

  Future signOut() async {
    await auth.signOut();
    await googleSignIn.signOut();
  }
}
