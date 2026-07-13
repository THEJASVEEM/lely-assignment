import 'package:flutter/material.dart';

class UsernameTextField extends StatelessWidget {
  const UsernameTextField({
    required this.controller,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('username_field'),
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Enter username',
        prefixIcon: const Icon(Icons.person_outline),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        errorText: errorText,
      ),
    );
  }
}
