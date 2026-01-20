import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final bool showCounter;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final bool filled;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final BorderRadius? borderRadius;
  final double? prefixIconSize;
  final Color? prefixIconColor;
  final bool isRequired;
  final String? errorText;
  final String? helperText;
  final bool readOnly;
  final Function()? onTap;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool expands;
  final String? initialValue;
  final bool autofocus;
  final Brightness? keyboardAppearance;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.showCounter = false,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.fillColor,
    this.filled = true,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.borderRadius,
    this.prefixIconSize,
    this.prefixIconColor,
    this.isRequired = false,
    this.errorText,
    this.helperText,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.expands = false,
    this.initialValue,
    this.autofocus = false,
    this.keyboardAppearance,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = false;
  FocusNode? _internalFocusNode;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _internalFocusNode = widget.focusNode ?? FocusNode();

    if (widget.initialValue != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode?.dispose();
    }
    super.dispose();
  }

  void _validate(String value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _hasError = error != null;
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate colors
    final defaultFillColor = isDark
        ? Colors.grey[900]
        : Colors.grey;

    final errorColor = theme.colorScheme.error;
    final focusedColor = theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  widget.label,
                  style: widget.labelStyle ?? TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _hasError
                        ? errorColor
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
                if (widget.isRequired)
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: errorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Text Field
        TextFormField(
          controller: widget.controller,
          focusNode: _internalFocusNode,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          onChanged: (value) {
            _validate(value);
            widget.onChanged?.call(value);
          },
          onFieldSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          expands: widget.expands,
          autofocus: widget.autofocus,
          keyboardAppearance: widget.keyboardAppearance,
          style: widget.style ?? TextStyle(
            fontSize: 16,
            color: widget.enabled
                ? theme.textTheme.bodyMedium?.color
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            fillColor: widget.fillColor ?? defaultFillColor,
            filled: widget.filled,
            contentPadding: widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: widget.border ?? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.dividerColor,
                width: 1,
              ),
            ),
            enabledBorder: widget.enabledBorder ?? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _hasError
                    ? errorColor
                    : theme.dividerColor,
                width: 1,
              ),
            ),
            focusedBorder: widget.focusedBorder ?? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _hasError
                    ? errorColor
                    : focusedColor,
                width: 2,
              ),
            ),
            errorBorder: widget.errorBorder ?? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: widget.focusedErrorBorder ?? OutlineInputBorder(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorColor,
                width: 2,
              ),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
              widget.prefixIcon,
              size: widget.prefixIconSize ?? 20,
              color: widget.prefixIconColor ?? (_hasError
                  ? errorColor
                  : theme.iconTheme.color?.withOpacity(0.6)),
            )
                : null,
            suffixIcon: _buildSuffixIcon(),
            errorText: widget.errorText ?? _errorMessage,
            helperText: widget.helperText,
            helperStyle: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
            counterText: widget.showCounter ? null : '',
            hintStyle: widget.hintStyle ?? TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
            ),
          ),
        ),

        // Character counter
        if (widget.maxLength != null && widget.showCounter)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${widget.controller.text.length}/${widget.maxLength}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility : Icons.visibility_off,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }

    return widget.suffixIcon;
  }
}

// Specialized text field variants
class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String hintText;

  const SearchTextField({
    Key? key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: '',
      hintText: hintText,
      prefixIcon: Icons.search,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(25),
      fillColor: Theme.of(context).colorScheme.surface,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const PasswordTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  double _strength = 0.0;

  void _calculateStrength(String password) {
    double strength = 0.0;

    if (password.length >= 8) strength += 0.25;
    if (password.length >= 12) strength += 0.25;

    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;

    setState(() {
      _strength = strength.clamp(0.0, 1.0);
    });

    widget.onChanged?.call(password);
  }

  Color _getStrengthColor() {
    if (_strength < 0.3) return Color(0xFFEA4335);
    if (_strength < 0.6) return Color(0xFFFBBC05);
    if (_strength < 0.8) return Color(0xFF34A853);
    return Color(0xFF4285F4);
  }

  String _getStrengthText() {
    if (_strength < 0.3) return 'Weak';
    if (_strength < 0.6) return 'Fair';
    if (_strength < 0.8) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: widget.label,
          hintText: widget.hintText ?? 'Enter your password',
          prefixIcon: Icons.lock,
          obscureText: true,
          validator: widget.validator,
          onChanged: _calculateStrength,
          suffixIcon: widget.controller.text.isNotEmpty
              ? Container(
            padding: EdgeInsets.only(right: 8),
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _getStrengthText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStrengthColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.circle,
                  size: 8,
                  color: _getStrengthColor(),
                ),
              ],
            ),
          )
              : null,
        ),

        // Password strength indicator
        if (widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: _strength,
                  backgroundColor: Colors.grey[200],
                  color: _getStrengthColor(),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                SizedBox(height: 4),
                Text(
                  'Password strength: ${_getStrengthText()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStrengthColor(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const PhoneTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hintText: hintText ?? 'Enter 10-digit phone number',
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      showCounter: true,
      validator: validator,
      onChanged: onChanged,

    );
  }
}