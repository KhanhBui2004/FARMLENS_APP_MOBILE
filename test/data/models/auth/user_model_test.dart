import 'package:farmlens_app/data/models/auth/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('User.fromJson parses snake_case full name and toJson exports it', () {
    final user = User.fromJson({
      'id': 'user-1',
      'username': 'farmer',
      'email': 'farmer@example.com',
      'full_name': 'Farmer One',
    });

    expect(user.id, 'user-1');
    expect(user.username, 'farmer');
    expect(user.email, 'farmer@example.com');
    expect(user.fullName, 'Farmer One');
    expect(user.toJson(), {
      'id': 'user-1',
      'username': 'farmer',
      'email': 'farmer@example.com',
      'full_name': 'Farmer One',
    });
  });

  test('User.fromJson falls back to camelCase fullName', () {
    final user = User.fromJson({
      'id': 'user-2',
      'username': 'analyst',
      'email': 'analyst@example.com',
      'fullName': 'Field Analyst',
    });

    expect(user.fullName, 'Field Analyst');
  });
}
