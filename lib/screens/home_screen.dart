import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:passgrinder/services/generator_service.dart';
import '../widgets/password_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _appEventsChannel = MethodChannel('appEvents');
  static const MethodChannel _settingsChannel = MethodChannel('settings');
  final _masterPasswordController = TextEditingController();
  final _uniquePhraseController = TextEditingController();
  final _masterPasswordFocusNode = FocusNode();
  bool _showMaster = false;
  bool _showUnique = false;
  bool _scheduledFocus = false;
  Timer? _autoResetTimer;
  static const Duration _autoResetDuration = Duration(minutes: 1);
  GeneratorService? _service;
  String _appVersion = 'v.dev';
  bool _launchAtLogin = false;

  void _focusMasterField() {
    if (_scheduledFocus) return;
    _scheduledFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledFocus = false;
      if (!mounted) return;
      _masterPasswordFocusNode.requestFocus();
    });
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final ver = info.version.isNotEmpty ? 'v${info.version}' : 'v.dev';
      if (!mounted) return;
      setState(() {
        _appVersion = ver;
      });
    } catch (_) {
      // Keep default on failure
    }
  }

  Future<void> _loadLaunchAtLoginPreference() async {
    try {
      final result = await _settingsChannel.invokeMethod('getLaunchAtLogin');
      if (!mounted) return;
      setState(() {
        _launchAtLogin = result == true;
      });
    } catch (_) {
      // Keep default on failure
    }
  }

  Future<void> _toggleLaunchAtLogin() async {
    final newValue = !_launchAtLogin;
    try {
      await _settingsChannel.invokeMethod('setLaunchAtLogin', newValue);
      if (!mounted) return;
      setState(() {
        _launchAtLogin = newValue;
      });
    } catch (_) {
      // Failed to set, revert
    }
  }

  void _scheduleAutoReset() {
    _autoResetTimer?.cancel();
    _autoResetTimer = Timer(_autoResetDuration, () {
      if (!mounted) return;
      final service = context.read<GeneratorService>();
      _masterPasswordController.clear();
      _uniquePhraseController.clear();
      service.clear();
      _focusMasterField();
      _autoResetTimer = null;
    });
  }

  void _cancelAutoReset() {
    _autoResetTimer?.cancel();
    _autoResetTimer = null;
  }

  void _onServiceChanged() {
    if (!mounted) return;
    final pwd = _service?.generatedPassword ?? '';
    if (pwd.isNotEmpty) {
      _scheduleAutoReset();
    } else {
      _cancelAutoReset();
    }
  }

  @override
  void initState() {
    super.initState();
    // Auto-focus the master password field when the screen loads
    _focusMasterField();

    _loadVersion();
    _loadLaunchAtLoginPreference();

    // Listen for macOS app/window lifecycle events from native code
    _appEventsChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'appHidden':
        case 'appWillTerminate':
          if (!mounted) return;
          final service = context.read<GeneratorService>();
          _masterPasswordController.clear();
          _uniquePhraseController.clear();
          service.clear();
          _cancelAutoReset();
          _focusMasterField();
          break;
        default:
          break;
      }
    });

    // Attach listener to service after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service = context.read<GeneratorService>();
      _service?.addListener(_onServiceChanged);
    });
  }

  @override
  void dispose() {
    _masterPasswordController.dispose();
    _uniquePhraseController.dispose();
    _masterPasswordFocusNode.dispose();
    _cancelAutoReset();
    _service?.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    final mq = MediaQuery.of(context);
    final snackBottom = math.max(
      (mq.size.height - mq.padding.vertical) / 2 - 24,
      mq.padding.bottom + 16,
    );
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password copied to clipboard', textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(left: 40, right: 40, bottom: snackBottom),
        backgroundColor: const Color(0xFF6baf78),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Detect system appearance to selectively restyle inputs in light mode
    final isLightMode = MediaQuery.of(context).platformBrightness == Brightness.light;
    const primaryGreen = Color(0xFF6baf78);
    const lightFieldFill = Colors.white;
    final lightFieldBorder = Colors.grey.shade300;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Consumer<GeneratorService>(
                  builder: (context, service, _) {
                final isResetDisabled =
                    service.masterPassword.isEmpty && service.uniquePhrase.isEmpty && service.variation == 0;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Master Password Field
                        TextField(
                          controller: _masterPasswordController,
                          focusNode: _masterPasswordFocusNode,
                          obscureText: !_showMaster,
                          style: TextStyle(
                            fontFamily: 'SourceCodePro',
                            fontSize: 15,
                            color: isLightMode ? Colors.black87 : Colors.white,
                          ),
                          decoration: isLightMode
                              ? InputDecoration(
                                  labelText: 'Master Password',
                                  hintText: 'Enter your master password',
                                labelStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Color(0xFF1e2629)),
                                floatingLabelStyle:
                                  const TextStyle(fontFamily: 'SourceCodePro', color: Color(0xFF6baf78)),
                                hintStyle:
                                  const TextStyle(fontFamily: 'SourceCodePro', color: Colors.black38),
                                  filled: true,
                                  fillColor: lightFieldFill,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: lightFieldBorder, width: 1.0),
                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: primaryGreen, width: 1.5),
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 12, right: 8),
                                    child: FaIcon(FontAwesomeIcons.lock, size: 16),
                                  ),
                                  prefixIconConstraints:
                                      const BoxConstraints(minWidth: 0, minHeight: 0),
                                  suffixIconConstraints:
                                      const BoxConstraints(minWidth: 40, minHeight: 40),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _showMaster = !_showMaster),
                                    icon: FaIcon(
                                        _showMaster
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        size: 16),
                                    tooltip: _showMaster ? 'Hide' : 'Show',
                                  ),
                                )
                              : InputDecoration(
                                  labelText: 'Master Password',
                                  labelStyle: const TextStyle(
                                      fontFamily: 'SourceCodePro', color: Colors.white70),
                                  floatingLabelStyle: const TextStyle(
                                      fontFamily: 'SourceCodePro', color: Colors.white),
                                  hintText: 'Enter your master password',
                                  hintStyle: const TextStyle(
                                      fontFamily: 'SourceCodePro', color: Colors.white38),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 12, right: 8),
                                    child: FaIcon(FontAwesomeIcons.lock, size: 16),
                                  ),
                                  prefixIconConstraints:
                                      const BoxConstraints(minWidth: 0, minHeight: 0),
                                  suffixIconConstraints:
                                      const BoxConstraints(minWidth: 40, minHeight: 40),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _showMaster = !_showMaster),
                                    icon: FaIcon(
                                        _showMaster
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        size: 16),
                                    tooltip: _showMaster ? 'Hide' : 'Show',
                                  ),
                                ),
                          onChanged: (value) {
                            service.setMasterPassword(value);
                            _scheduleAutoReset();
                          },
                        ),
                        const SizedBox(height: 14),

                        // Unique Phrase Field
                        TextField(
                          controller: _uniquePhraseController,
                          obscureText: !_showUnique,
                          style: TextStyle(
                            fontFamily: 'SourceCodePro',
                            fontSize: 15,
                            color: isLightMode ? Colors.black87 : Colors.white,
                          ),
                          decoration: isLightMode
                              ? InputDecoration(
                                  labelText: 'Unique Phrase (optional)',
                                  hintText: 'e.g., gmail.com, MyBankApp, etc.',
                                labelStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Color(0xFF1e2629)),
                                floatingLabelStyle:
                                  const TextStyle(fontFamily: 'SourceCodePro', color: Color(0xFF6baf78)),
                                hintStyle:
                                  const TextStyle(fontFamily: 'SourceCodePro', color: Colors.black38),
                                  filled: true,
                                  fillColor: lightFieldFill,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: lightFieldBorder, width: 1.0),
                                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: primaryGreen, width: 1.5),
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 12, right: 8),
                                    child: FaIcon(FontAwesomeIcons.link, size: 16),
                                  ),
                                  prefixIconConstraints:
                                      const BoxConstraints(minWidth: 0, minHeight: 0),
                                  suffixIconConstraints:
                                      const BoxConstraints(minWidth: 40, minHeight: 40),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _showUnique = !_showUnique),
                                    icon: FaIcon(
                                        _showUnique
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        size: 16),
                                    tooltip: _showUnique ? 'Hide' : 'Show',
                                  ),
                                )
                              : InputDecoration(
                                  labelText: 'Unique Phrase (optional)',
                                  labelStyle: const TextStyle(
                                      fontFamily: 'SourceCodePro', color: Colors.white70),
                                  floatingLabelStyle: const TextStyle(
                                      fontFamily: 'SourceCodePro', color: Colors.white),
                                  hintText: 'e.g., gmail.com, MyBankApp, etc.',
                                  hintStyle: const TextStyle(
                                      fontFamily: 'SourceCodePro', color: Colors.white38),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(left: 12, right: 8),
                                    child: FaIcon(FontAwesomeIcons.link, size: 16),
                                  ),
                                  prefixIconConstraints:
                                      const BoxConstraints(minWidth: 0, minHeight: 0),
                                  suffixIconConstraints:
                                      const BoxConstraints(minWidth: 40, minHeight: 40),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _showUnique = !_showUnique),
                                    icon: FaIcon(
                                        _showUnique
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        size: 16),
                                    tooltip: _showUnique ? 'Hide' : 'Show',
                                  ),
                                ),
                          onChanged: (value) {
                            service.setUniquePhrase(value);
                            _scheduleAutoReset();
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Use the website URL, domain name, or app name where this password will be used to grind your master password into something more unique.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isLightMode ? const Color(0xFF1e2629) : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Variation selection matches extension behavior
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runSpacing: 6,
                            spacing: 18,
                            children: List.generate(4, (index) {
                              final label = index == 0 ? 'Default' : 'Variation $index';
                              return GestureDetector(
                                onTap: () {
                                  service.setVariation(index);
                                  _scheduleAutoReset();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue: service.variation,
                                      onChanged: (v) {
                                        if (v != null) {
                                          service.setVariation(v);
                                          _scheduleAutoReset();
                                        }
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                    ),
                                    Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, fontFamily: 'Lato')),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Use a variation if you are required to change your password without needing to change your master password or unique phrase.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isLightMode ? const Color(0xFF1e2629) : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Generated Password Display with Login Icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: PasswordField(
                                password: service.generatedPassword,
                                showPassword: service.showPassword,
                                onToggleVisibility: () {
                                  service.toggleShowPassword();
                                },
                                onCopy: () {
                                  _copyToClipboard(service.generatedPassword);
                                },
                                onReset: () {
                                  _masterPasswordController.clear();
                                  _uniquePhraseController.clear();
                                  service.clear();
                                  _cancelAutoReset();
                                  _focusMasterField();
                                },
                                resetEnabled: !isResetDisabled,
                                copyEnabled: service.generatedPassword.isNotEmpty,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 40,
                              child: IconButton(
                                icon: Icon(
                                  _launchAtLogin ? Icons.check_circle : Icons.check_circle_outline,
                                  size: 18,
                                  color: _launchAtLogin
                                      ? primaryGreen
                                      : (isLightMode
                                          ? const Color(0xFF1e2629).withOpacity(0.35)
                                          : Colors.white.withOpacity(0.35)),
                                ),
                                onPressed: _toggleLaunchAtLogin,
                                tooltip: _launchAtLogin ? 'Launch at login enabled' : 'Launch at login disabled',
                                style: IconButton.styleFrom(
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(40, 40),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                constraints: const BoxConstraints(minWidth: 40),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
                  },
                ),
              ),
            ),
            // Bottom-center version tag
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _appVersion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w300,
                    fontSize: 9,
                    color: isLightMode ? Colors.black38 : Colors.white38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
