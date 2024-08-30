import 'package:flutter/material.dart';

class CustomDurationPicker extends StatefulWidget {
  final Duration initialDuration;
  final Function(Duration) onDurationChanged;

  CustomDurationPicker({
    required this.initialDuration,
    required this.onDurationChanged,
  });

  @override
  _CustomDurationPickerState createState() => _CustomDurationPickerState();
}

class _CustomDurationPickerState extends State<CustomDurationPicker> {
  late int hours;
  late int minutes;

  @override
  void initState() {
    super.initState();
    final duration = widget.initialDuration;
    hours = duration.inHours;
    minutes = duration.inMinutes % 60;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Enter Duration'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPicker('Hours', hours, (value) {
              if (value != null) {
                setState(() {
                  hours = value;
                  _updateDuration();
                });
              }
            }),
            _buildPicker('Minutes', minutes, (value) {
              if (value != null) {
                setState(() {
                  minutes = value;
                  _updateDuration();
                });
              }
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildPicker(String label, int value, ValueChanged<int?> onChanged) {
    return Expanded(
      child: Column(
        children: [
          Text(label),
          DropdownButton<int>(
            value: value,
            items: label == 'Hours'
                ? List.generate(16, (index) => index).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString().padLeft(2, '0')),
                    );
                  }).toList()
                : List.generate(60, (index) => index).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString().padLeft(2, '0')),
                    );
                  }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _updateDuration() {
    final newDuration = Duration(hours: hours, minutes: minutes);
    widget.onDurationChanged(newDuration);
  }
}
