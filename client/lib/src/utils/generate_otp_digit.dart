import 'dart:math';

const Map<String, String> testPhoneNumbers = {
  '0111111111': '123456',
  '0999999999': '123456',
  '0888888888': '123456',
  '0222222222': '123456'
};

String generateOtp({required String phoneNumber, int length = 6}) {
  if (testPhoneNumbers.containsKey(phoneNumber)) {
    return testPhoneNumbers[phoneNumber]!;
  }

  final random = Random();
  String otp = '';
  for (int i = 0; i < length; i++) {
    otp += random.nextInt(10).toString(); // generates a digit between 0-9
  }
  return otp;
}

bool isTestNumber(String phoneNumber) {
  return testPhoneNumbers.containsKey(phoneNumber);
}
