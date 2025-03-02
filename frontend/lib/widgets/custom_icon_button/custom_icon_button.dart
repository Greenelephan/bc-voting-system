import 'package:flutter/material.dart';

// Define the custom CustomIconButton
class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isPressed;
  final bool isEnabled;
  final double buttonSize;
  final double iconSize;
  final double textSize;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.tooltip,
    required this.onPressed,
    this.isPressed = false,
    this.isEnabled = true,
    this.buttonSize = 500.0,
    this.iconSize = 0,
    this.textSize = 0,
  });

  @override
  CustomIconButtonState createState() => CustomIconButtonState();
}

class CustomIconButtonState extends State<CustomIconButton> {

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _isPressed = widget.isPressed;
  }

 @override
Widget build(BuildContext context) {
   double iconSize = widget.iconSize == 0 ? widget.buttonSize * 0.5 : widget.iconSize;
   double textSize = widget.textSize == 0 ? widget.buttonSize * 0.1 : widget.textSize;
  final colorScheme = Theme.of(context).colorScheme;

  Color backgroundColor = widget.isEnabled
      ? _isPressed
      ? colorScheme.primary
      : colorScheme.primary
      : colorScheme.onSurface.withOpacity(0.12);

  Color contentColor = widget.isEnabled
      ? colorScheme.onPrimary
      : colorScheme.onSurface.withOpacity(0.38);

  return GestureDetector(
    onTapDown: widget.isEnabled ? (_) => _onPressed(true) : null,
    onTapUp: widget.isEnabled ? (_) => _onPressed(false) : null,
    onTapCancel: widget.isEnabled ? () => _onPressed(false) : null,
    onTap: widget.isEnabled ? widget.onPressed : null,

    child: MouseRegion(
      onEnter: widget.isEnabled ? (_) => _onHover(true) : null,
      onExit: widget.isEnabled ? (_) => _onHover(false) : null,
      cursor: SystemMouseCursors.click,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),

        decoration: BoxDecoration(
          color: _isHovered ? colorScheme.secondary : backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: _isHovered
              ? [const BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 1)]
              : [],
        ),

        child: SizedBox(
          width: widget.buttonSize,
          height: widget.buttonSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(widget.icon, color: contentColor, size: iconSize),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.text,
                    style: TextStyle(color: contentColor, fontSize: textSize),
                  ),
                  const SizedBox(width: 8.0),
                  Tooltip(
                    message: widget.tooltip,
                    child: Icon(Icons.info_outline, color: contentColor, size: textSize),
                  ),
                ]
              ),
            ],
          ),
        )
      ),
    ),
  );
}

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  void _onPressed(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
  }
}