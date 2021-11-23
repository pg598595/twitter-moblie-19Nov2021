import 'package:flutter_test/flutter_test.dart';
import 'package:twitter/utils/validator.dart';

void main() {
  test('Empty Email Test', () {
    var result = Validator.validateEmail(email: '');
    expect(result, 'Please enter email address');
  });

  test('Invalid Email Test', () {
    var result = Validator.validateEmail(email:'');
    expect(result, 'Please enter email address');
  });

  test('Valid Email Test', () {
    var result = Validator.validateEmail(email:'priyanka.gupta@gmail.com');
    expect(result, null);
  });

  test('Empty Password Test', () {
    var result = Validator.validatePassword(password: '');
    expect(result, 'Please enter password');
  });

  test('Invalid Password Test', () {
    var result = Validator.validatePassword(password:'123');
    expect(result, 'Enter a password with length at least 6');
  });

  test('Valid Password Test', () {
    var result = Validator.validatePassword(password:'ajay12345');
    expect(result, null);
  });

}