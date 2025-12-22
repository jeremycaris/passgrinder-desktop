import 'package:flutter/material.dart';
import 'package:passgrinder/screens/home_screen.dart';
import 'package:passgrinder/services/generator_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GeneratorService>(
          create: (_) => GeneratorService(),
        ),
      ],
      child: const PassGrinderApp(),
    ),
  );
}


class PassGrinderApp extends StatelessWidget {
  const PassGrinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Extension styling: dark background #1e2629, Lato body font, Source Code Pro for monospace
    final bg = const Color(0xFF1e2629);
    const primaryGreen = Color(0xFF6baf78); // Extension primary

    final baseTextTheme = TextTheme(
      bodySmall: const TextStyle(fontFamily: 'Lato', fontSize: 11, fontWeight: FontWeight.w300),
      bodyMedium: const TextStyle(fontFamily: 'Lato', fontSize: 15, fontWeight: FontWeight.w300),
      bodyLarge: const TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w300),
      titleMedium: const TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w400),
      titleSmall: const TextStyle(fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w400),
    );

    final darkScheme = const ColorScheme.dark(
      primary: primaryGreen,
      secondary: primaryGreen,
      surface: Color(0xFF1e2629),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Lato',
      iconTheme: const IconThemeData(color: Colors.white70),
      textTheme: baseTextTheme.copyWith(
        bodySmall: const TextStyle(fontFamily: 'Lato', fontSize: 11, fontWeight: FontWeight.w300),
        bodyMedium: const TextStyle(fontFamily: 'Lato', fontSize: 15, fontWeight: FontWeight.w300),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(primaryGreen),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF232a2e),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return primaryGreen;
          return Colors.white54;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return primaryGreen;
          return Colors.white54;
        }),
        labelStyle: WidgetStateTextStyle.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontFamily: 'Lato');
          }
          return const TextStyle(color: Colors.white70, fontWeight: FontWeight.w400, fontFamily: 'Lato');
        }),
        hintStyle: const TextStyle(color: Colors.white38, fontFamily: 'Lato'),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF3a4249), width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryGreen, width: 1.5),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );

    // Light mode theme: lighter grey background and dark text (#1e2629)
    final lightBg = const Color(0xFFF2F4F7);
    const onLight = Color(0xFF1e2629);
    final lightScheme = const ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryGreen,
      surface: Color(0xFFF2F4F7),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onLight,
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Lato',
      iconTheme: const IconThemeData(color: onLight),
      textTheme: baseTextTheme.copyWith(
        bodySmall: const TextStyle(fontFamily: 'Lato', fontSize: 11, fontWeight: FontWeight.w300, color: onLight),
        bodyMedium: const TextStyle(fontFamily: 'Lato', fontSize: 15, fontWeight: FontWeight.w300, color: onLight),
        bodyLarge: const TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w300, color: onLight),
        titleMedium: const TextStyle(fontFamily: 'Lato', fontSize: 16, fontWeight: FontWeight.w400, color: onLight),
        titleSmall: const TextStyle(fontFamily: 'Lato', fontSize: 14, fontWeight: FontWeight.w400, color: onLight),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(primaryGreen),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return primaryGreen;
          return onLight.withValues(alpha: 0.6);
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return primaryGreen;
          return onLight.withValues(alpha: 0.6);
        }),
        labelStyle: const TextStyle(color: onLight, fontWeight: FontWeight.w400, fontFamily: 'SourceCodePro'),
        floatingLabelStyle: const TextStyle(color: primaryGreen, fontWeight: FontWeight.w400, fontFamily: 'SourceCodePro'),
        hintStyle: const TextStyle(color: Colors.black38, fontFamily: 'SourceCodePro'),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: primaryGreen, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );

    return MaterialApp(
      title: 'Passgrinder',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
