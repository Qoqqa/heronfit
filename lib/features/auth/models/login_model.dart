import 'package:heronfit/features/auth/views/login_screen.dart';
import 'package:flutter/material.dart';

class LoginModel {
  final LoginScreen widget;

  LoginModel(this.widget);

  ///  State fields for stateful widgets in this page.
  final formKey = GlobalKey<FormState>();

  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  String? _emailAddressTextControllerValidator(
    BuildContext context,
    String? val,
  ) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // State field(s) for password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }
    return null;
  }

  void initState(BuildContext context) {
    // Note: The LoginScreen itself now manages its controllers and focus nodes.
    // This model might need refactoring or removal if it's no longer used
    // to manage the state *for* the LoginScreen stateful widget.
    // The validation logic might be moved directly into the LoginScreen's FormValidators.

    // emailAddressFocusNode = FocusNode(); // Likely redundant
    // emailAddressTextController = TextEditingController(); // Likely redundant
    // emailAddressTextControllerValidator = _emailAddressTextControllerValidator; // Logic moved to LoginScreen

    // passwordFocusNode = FocusNode(); // Likely redundant
    // passwordTextController = TextEditingController(); // Likely redundant
    // passwordVisibility = false; // State handled in LoginScreen
    // passwordTextControllerValidator = _passwordTextControllerValidator; // Logic moved to LoginScreen
    print(
      "LoginModel initState: Consider refactoring/removing this model if state is managed within LoginScreen.",
    );
  }

  void dispose() {
    // emailAddressFocusNode?.dispose(); // Handled by LoginScreen
    // emailAddressTextController?.dispose(); // Handled by LoginScreen
    // passwordFocusNode?.dispose(); // Handled by LoginScreen
    // passwordTextController?.dispose(); // Handled by LoginScreen
    print(
      "LoginModel dispose: Controllers/FocusNodes should be disposed in LoginScreen.",
    );
  }
}
