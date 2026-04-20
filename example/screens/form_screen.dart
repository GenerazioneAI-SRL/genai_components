import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';
import 'page_scaffold.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Form',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CLTextField(controller: _email, labelText: 'Email'),
          const SizedBox(height: 12),
          CLTextField(controller: _password, labelText: 'Password', isObscured: true),
        ],
      ),
    );
  }
}

