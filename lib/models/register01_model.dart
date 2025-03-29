import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterModel {
  /// State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();

  // State field(s) for firstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(String?)? firstNameTextControllerValidator;

  String? _firstNameTextControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }
    return null;
  }

  // State field(s) for lastName widget.
  FocusNode? lastNameFocusNode;
  TextEditingController? lastNameTextController;
  String? Function(String?)? lastNameTextControllerValidator;

  String? _lastNameTextControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }
    return null;
  }

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(String?)? emailAddressTextControllerValidator;

  String? _emailAddressTextControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(String?)? passwordTextControllerValidator;

  String? _passwordTextControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }
    return null;
  }

  // State field(s) for passwordConfirm widget.
  FocusNode? passwordConfirmFocusNode;
  TextEditingController? passwordConfirmTextController;
  late bool passwordConfirmVisibility;
  String? Function(String?)? passwordConfirmTextControllerValidator;

  String? _passwordConfirmTextControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }
    return null;
  }

  // Stores action output result for custom actions.
  String? error;

  /// Initialize state fields.
  void initState() {
    firstNameTextController = TextEditingController();
    firstNameFocusNode = FocusNode();
    firstNameTextControllerValidator = _firstNameTextControllerValidator;

    lastNameTextController = TextEditingController();
    lastNameFocusNode = FocusNode();
    lastNameTextControllerValidator = _lastNameTextControllerValidator;

    emailAddressTextController = TextEditingController();
    emailAddressFocusNode = FocusNode();
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;

    passwordTextController = TextEditingController();
    passwordFocusNode = FocusNode();
    passwordVisibility = false;
    passwordTextControllerValidator = _passwordTextControllerValidator;

    passwordConfirmTextController = TextEditingController();
    passwordConfirmFocusNode = FocusNode();
    passwordConfirmVisibility = false;
    passwordConfirmTextControllerValidator =
        _passwordConfirmTextControllerValidator;
  }

  /// Dispose state fields.
  void dispose() {
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastNameFocusNode?.dispose();
    lastNameTextController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    passwordConfirmFocusNode?.dispose();
    passwordConfirmTextController?.dispose();
  }

  /// Register user and insert data into the 'users' table.
  Future<String?> registerUser() async {
    final supabase = Supabase.instance.client;

    final email = emailAddressTextController?.text.trim();
    final password = passwordTextController?.text.trim();
    final firstName = firstNameTextController?.text.trim();
    final lastName = lastNameTextController?.text.trim();

    if (email == null ||
        password == null ||
        firstName == null ||
        lastName == null) {
      return 'Please fill in all fields';
    }

    try {
      // Step 1: Register the user with Supabase Auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Step 2: Insert additional user data into the 'users' table
        final userId = response.user!.id; // Get the user's unique ID
        await supabase.from('users').insert({
          'id': userId, // Use the user's unique ID as the primary key
          'created_at': DateTime.now().toIso8601String(), // Add timestamp
          'first_name': firstName,
          'last_name': lastName,
          'email_address': email,
        });

        return null; // Success
      } else {
        return 'Registration failed';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
