import 'package:flutter/material.dart';

class WhiteSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const WhiteSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _WhiteSwitchState createState() => _WhiteSwitchState();
}

class _WhiteSwitchState extends State<WhiteSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(
      value: widget.value,
      onChanged: widget.onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.grey[300],
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Colors.grey[300],
    );
  }
}