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
  // Optional FocusNodes with skipTraversal: true to exclude reset/visibility from tab order
  final FocusNode? resetFocusNode;
  final FocusNode? visibilityFocusNode;

  const PasswordField({
    super.key,
    required this.password,
    required this.showPassword,
    required this.onToggleVisibility,
    required this.onCopy,
    required this.onReset,
    required this.resetEnabled,
    required this.copyEnabled,
    this.resetFocusNode,
    this.visibilityFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = MediaQuery.of(context).platformBrightness == Brightness.light;
    const onLight = Color(0xFF1e2629);
    final borderColor = isLightMode ? Colors.grey.shade300 : const Color(0xFF3a4249);
    final panelColor = isLightMode ? Colors.white : const Color(0xFF232a2e);
    final iconColor = isLightMode ? onLight : Colors.white;
    const primaryGreen = Color(0xFF6baf78);
    // IconButton styling with visible focus/highlight indicators for consistency
    // focusColor: shown when tabbed to, highlightColor: shown on click
    final ButtonStyle iconBtnStyle = IconButton.styleFrom(
      hoverColor: Colors.transparent,
      focusColor: primaryGreen.withValues(alpha: 0.1),
      highlightColor: primaryGreen.withValues(alpha: 0.15),
      splashFactory: InkRipple.splashFactory,
      backgroundColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      minimumSize: const Size(40, 40),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        border: Border.all(color: borderColor, width: 1.0),
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
                style: TextStyle(
                  fontFamily: 'SourceCodePro',
                  fontSize: 15,
                  letterSpacing: 1.0,
                  color: isLightMode ? onLight : Colors.white,
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
                color: copyEnabled ? iconColor : (isLightMode ? onLight.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.35)),
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
              focusNode: resetFocusNode,
              icon: Icon(
                Icons.restart_alt,
                size: 18,
                color: resetEnabled ? iconColor : (isLightMode ? onLight.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.35)),
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
              focusNode: visibilityFocusNode,
              icon: FaIcon(
                showPassword ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye, 
                size: 16, 
                color: showPassword 
                  ? iconColor 
                  : (isLightMode ? onLight.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.35)),
              ),
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
