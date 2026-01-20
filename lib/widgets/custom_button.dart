import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final IconData? icon;
  final double? iconSize;
  final bool fullWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool hasShadow;
  final bool isDisabled;
  final String? tooltip;
  final bool isOutlined;
  final Color? loadingColor;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.iconSize,
    this.fullWidth = true,
    this.borderRadius,
    this.padding,
    this.hasShadow = false,
    this.isDisabled = false,
    this.tooltip,
    this.isOutlined = false,
    this.loadingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate colors based on button type
    final bgColor = backgroundColor ?? (isOutlined
        ? Colors.transparent
        : theme.primaryColor);

    final fgColor = foregroundColor ?? (isOutlined
        ? theme.primaryColor
        : Colors.white);

    final borderSide = isOutlined
        ? BorderSide(
      color: borderColor ?? theme.primaryColor,
      width: 2.0,
    )
        : BorderSide.none;

    final buttonChild = isLoading
        ? SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation(
          loadingColor ?? fgColor,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: iconSize ?? 20,
            color: fgColor,
          ),
          SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: fgColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );

    final button = Container(
      width: fullWidth ? double.infinity : width,
      height: height ?? 52,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: hasShadow && !isDisabled && !isLoading
            ? [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: isOutlined
          ? OutlinedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          side: borderSide,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          minimumSize: Size(0, 0),
        ),
        child: buttonChild,
      )
          : ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
            side: borderSide,
          ),
          minimumSize: Size(0, 0),
        ),
        child: buttonChild,
      ),
    );

    if (tooltip != null && !isDisabled && !isLoading) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// Specialized button variants
class SOSButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SOSButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      text: 'SOS EMERGENCY',
      backgroundColor: Color(0xFFEA4335),
      foregroundColor: Colors.white,
      icon: Icons.warning,
      hasShadow: true,
      isLoading: isLoading,
      borderRadius: BorderRadius.circular(20),
      height: 60,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      tooltip: 'Tap and hold for 3 seconds to activate emergency alert',
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      hasShadow: true,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;

  const SecondaryButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isOutlined: true,
      isLoading: isLoading,
    );
  }
}

class IconButtonCircle extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const IconButtonCircle({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor ?? Colors.white,
          size: size * 0.5,
        ),
        padding: EdgeInsets.zero,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}