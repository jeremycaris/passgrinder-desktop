import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:passgrinder/services/generator_service.dart';
import '../widgets/password_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const MethodChannel _appEventsChannel = MethodChannel('appEvents');
  final _masterPasswordController = TextEditingController();
  final _uniquePhraseController = TextEditingController();
  final _masterPasswordFocusNode = FocusNode();
  bool _showMaster = false;
  bool _showUnique = false;
  bool _scheduledFocus = false;
  Timer? _autoResetTimer;
  static const Duration _autoResetDuration = Duration(minutes: 1);
  GeneratorService? _service;

  void _focusMasterField() {
    if (_scheduledFocus) return;
    _scheduledFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledFocus = false;
      if (!mounted) return;
      _masterPasswordFocusNode.requestFocus();
    });
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
    return Scaffold(
      body: SafeArea(
        child: Center(
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
                          style: const TextStyle(fontFamily: 'SourceCodePro', fontSize: 15, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Master Password',
                            labelStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Colors.white70),
                            floatingLabelStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Colors.white),
                            hintText: 'Enter your master password',
                            hintStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Colors.white38),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 8),
                              child: FaIcon(FontAwesomeIcons.lock, size: 16),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _showMaster = !_showMaster),
                              icon: FaIcon(_showMaster ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, size: 16),
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
                          style: const TextStyle(fontFamily: 'SourceCodePro', fontSize: 15, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Domain / Site / Unique Phrase (optional)',
                            labelStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Colors.white70),
                            floatingLabelStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Colors.white),
                            hintText: 'e.g., gmail.com, MyBankApp, etc.',
                            hintStyle: const TextStyle(fontFamily: 'SourceCodePro', color: Colors.white38),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 8),
                              child: FaIcon(FontAwesomeIcons.link, size: 16),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _showUnique = !_showUnique),
                              icon: FaIcon(_showUnique ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, size: 16),
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
                                color: Colors.white70,
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
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 22),

                        // Generated Password Display
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PasswordField(
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
      ),
    );
  }
}
