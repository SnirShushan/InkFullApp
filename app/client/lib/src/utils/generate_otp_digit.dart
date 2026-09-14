import 'dart:math';

const Map<String, String> testPhoneNumbers = {
  '0111111111': '123456',
  '0999999999': '123456',
  '0888888888': '123456',
  '0222222222': '123456'
};

/// Strip formatting / country code so 099-999-9999 and +9720999999999 match.
String normalizeLocalPhone(String phoneNumber) {
  var digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('972') && digits.length > 9) {
    digits = digits.substring(3);
  }
  if (digits.length == 9) {
    digits = '0$digits';
  }
  return digits;
}

String? demoOtpFor(String phoneNumber) {
  return testPhoneNumbers[normalizeLocalPhone(phoneNumber)];
}

String generateOtp({required String phoneNumber, int length = 6}) {
  final demoOtp = demoOtpFor(phoneNumber);
  if (demoOtp != null) {
    return demoOtp;
  }

  final random = Random();
  String otp = '';
  for (int i = 0; i < length; i++) {
    otp += random.nextInt(10).toString();
  }
  return otp;
}

bool isTestNumber(String phoneNumber) {
  return demoOtpFor(phoneNumber) != null;
}
