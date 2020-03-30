import 'package:flutter/material.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class SwitchPreference extends StatefulWidget {
  const SwitchPreference({
    Key key,
    @required this.preference,
    @required this.title,
    this.subtitle,
  })  : assert(preference != null),
        assert(title != null),
        super(key: key);

  final Preference<bool> preference;
  final String title;
  final String subtitle;

  @override
  _SwitchPreferenceState createState() => _SwitchPreferenceState();
}

class _SwitchPreferenceState extends State<SwitchPreference> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _setValue(!widget.preference.getValue()),
      title: Text(widget.title),
      subtitle: widget.subtitle != null ? Text(widget.subtitle) : null,
      trailing: Switch.adaptive(
        value: widget.preference.getValue(),
        onChanged: _isUpdating ? null : _setValue,
      ),
    );
  }

  void _setValue(bool value) async {
    setState(() => _isUpdating = true);
    await widget.preference.setValue(value);
    setState(() => _isUpdating = false);
  }
}
