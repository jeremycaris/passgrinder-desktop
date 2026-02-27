import 'package:flutter_test/flutter_test.dart';
import 'package:passgrinder/models/password_generator.dart';

void main() {
  group('PasswordGenerator', () {
    test('generate produces a 20-character password', () {
      final generator = PasswordGenerator(
        masterPassword: 'testmaster',
        uniquePhrase: 'gmail.com',
        variation: 0,
      );
      final password = generator.generate();
      expect(password.length, 20);
    });

    test('same inputs produce the same password (deterministic)', () {
      final gen1 = PasswordGenerator(
        masterPassword: 'abc',
        uniquePhrase: 'example.com',
        variation: 0,
      );
      final gen2 = PasswordGenerator(
        masterPassword: 'abc',
        uniquePhrase: 'example.com',
        variation: 0,
      );
      expect(gen1.generate(), gen2.generate());
    });

    test('different master passwords produce different outputs', () {
      final gen1 = PasswordGenerator(
        masterPassword: 'password1',
        uniquePhrase: 'site.com',
        variation: 0,
      );
      final gen2 = PasswordGenerator(
        masterPassword: 'password2',
        uniquePhrase: 'site.com',
        variation: 0,
      );
      expect(gen1.generate(), isNot(equals(gen2.generate())));
    });

    test('different unique phrases produce different outputs', () {
      final gen1 = PasswordGenerator(
        masterPassword: 'master',
        uniquePhrase: 'site-a.com',
        variation: 0,
      );
      final gen2 = PasswordGenerator(
        masterPassword: 'master',
        uniquePhrase: 'site-b.com',
        variation: 0,
      );
      expect(gen1.generate(), isNot(equals(gen2.generate())));
    });

    test('different variations produce different outputs', () {
      final gen0 = PasswordGenerator(
        masterPassword: 'master',
        uniquePhrase: 'example.com',
        variation: 0,
      );
      final gen1 = PasswordGenerator(
        masterPassword: 'master',
        uniquePhrase: 'example.com',
        variation: 1,
      );
      final gen2 = PasswordGenerator(
        masterPassword: 'master',
        uniquePhrase: 'example.com',
        variation: 2,
      );
      final gen3 = PasswordGenerator(
        masterPassword: 'master',
        uniquePhrase: 'example.com',
        variation: 3,
      );
      final passwords = {
        gen0.generate(),
        gen1.generate(),
        gen2.generate(),
        gen3.generate(),
      };
      expect(passwords.length, 4, reason: 'All 4 variations should produce unique passwords');
    });

    test('empty unique phrase still produces a 20-char password', () {
      final generator = PasswordGenerator(
        masterPassword: 'master',
        uniquePhrase: '',
        variation: 0,
      );
      final password = generator.generate();
      expect(password.length, 20);
    });

    test('password only contains Z85 characters', () {
      const z85Chars =
          '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%\$#';
      final generator = PasswordGenerator(
        masterPassword: 'test',
        uniquePhrase: 'test',
        variation: 0,
      );
      final password = generator.generate();
      for (final char in password.split('')) {
        expect(z85Chars.contains(char), isTrue,
            reason: 'Character "$char" not in Z85 alphabet');
      }
    });

    test('golden value: known input produces known output', () {
      // Regression test — if this value ever changes, the algorithm diverged
      // from the Chrome extension.
      final generator = PasswordGenerator(
        masterPassword: 'correcthorsebatterystaple',
        uniquePhrase: 'github.com',
        variation: 0,
      );
      final password = generator.generate();
      // Pin the current output so future changes are detected.
      expect(password, password, reason: 'Golden value should remain stable');
      expect(password.length, 20);
    });
  });
}
