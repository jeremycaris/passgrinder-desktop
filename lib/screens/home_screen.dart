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
  final _masterPasswordController = TextEditingController();
  final _uniquePhraseController = TextEditingController();
  bool _showMaster = false;
  bool _showUnique = false;

  @override
  void dispose() {
    _masterPasswordController.dispose();
    _uniquePhraseController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password copied to clipboard', textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 40, right: 40, bottom: 180),
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
                          obscureText: !_showMaster,
                          style: const TextStyle(fontFamily: 'Lato', fontSize: 15, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Master Password',
                            hintText: 'Enter your master password',
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
                          },
                        ),
                        const SizedBox(height: 14),

                        // Unique Phrase Field
                        TextField(
                          controller: _uniquePhraseController,
                          obscureText: !_showUnique,
                          style: const TextStyle(fontFamily: 'Lato', fontSize: 15, color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Domain / Site / Unique Phrase (optional)',
                            hintText: 'e.g., gmail.com, MyBankApp, etc.',
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
                                onTap: () => service.setVariation(index),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue: service.variation,
                                      onChanged: (v) {
                                        if (v != null) service.setVariation(v);
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

                        // Generated Password Display or Empty State
                        if (service.generatedPassword.isNotEmpty)
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
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _copyToClipboard(service.generatedPassword);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Copy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lato')),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _masterPasswordController.clear();
                                        _uniquePhraseController.clear();
                                        service.clear();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text('Reset', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lato')),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        else
                          Stack(
                            children: [
                              Opacity(
                                opacity: 0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    PasswordField(
                                      password: 'placeholder',
                                      showPassword: false,
                                      onToggleVisibility: () {},
                                      onCopy: () {},
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: null,
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('Copy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lato')),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: null,
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            child: const Text('Reset', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lato')),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned.fill(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Text(
                                      'Enter your master password to generate a password. Add a unique phrase or variation to change the result.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ),
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
      ),
    );
  }
}
