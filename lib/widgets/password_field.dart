import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PasswordField extends StatelessWidget {
  final String password;
  final bool showPassword;
  final VoidCallback onToggleVisibility;
  final VoidCallback onCopy;
  final VoidCallback onReset;
  final bool resetEnabled;
  final bool copyEnabled;

  const PasswordField({
    Key? key,
    required this.password,
    required this.showPassword,
    required this.onToggleVisibility,
    required this.onCopy,
    required this.onReset,
    required this.resetEnabled,
    required this.copyEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle iconBtnStyle = IconButton.styleFrom(
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      minimumSize: const Size(40, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF232a2e),
        border: Border.all(color: const Color(0xFF3a4249), width: 1.0),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                showPassword ? password : _maskPassword(password),
                style: const TextStyle(
                  fontFamily: 'SourceCodePro',
                  fontSize: 15,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.copy,
                size: 16,
                color: copyEnabled ? null : Colors.white.withOpacity(0.35),
              ),
              onPressed: copyEnabled ? onCopy : null,
              tooltip: 'Copy password',
              style: iconBtnStyle,
              constraints: const BoxConstraints(minWidth: 40),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(
                Icons.restart_alt,
                size: 18,
                color: resetEnabled ? null : Colors.white.withOpacity(0.35),
              ),
              onPressed: resetEnabled ? onReset : null,
              tooltip: 'Reset fields',
              style: iconBtnStyle,
              constraints: const BoxConstraints(minWidth: 40),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: FaIcon(showPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, size: 16),
              onPressed: onToggleVisibility,
              tooltip: showPassword ? 'Hide password' : 'Show password',
              style: iconBtnStyle,
              constraints: const BoxConstraints(minWidth: 40),
            ),
          ),
        ],
      ),
    );
  }

  String _maskPassword(String password) {
    return '*' * password.length;
  }
}
