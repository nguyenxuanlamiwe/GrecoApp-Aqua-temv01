import 'package:flutter/material.dart';

typedef SecuredFieldValidator = String? Function(String? value);

class SecuredField extends StatefulWidget {
  final TextEditingController? controller;
  final SecuredFieldValidator? validator;
  final Widget? icon;
  final String? hintText;
  const SecuredField(
      {Key? key, this.controller, this.icon, this.hintText, this.validator})
      : super(key: key);

  @override
  State<SecuredField> createState() => _SecuredFieldState();
}

class _SecuredFieldState extends State<SecuredField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        prefixIcon: widget.icon,
        hintText: widget.hintText,
        helperText: "",
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscureText = !_obscureText),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
              size: 20,
            ),
          ),
        ),
      ),
      validator: widget.validator,
    );
  }
}
