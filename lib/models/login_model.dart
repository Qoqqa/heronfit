import '/views/auth/login_widget.dart' show LoginWidget;
import 'package:flutter/material.dart';

class LoginModel {
  final LoginWidget widget;

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
    emailAddressFocusNode = FocusNode();
    emailAddressTextController = TextEditingController();
    emailAddressTextControllerValidator = _emailAddressTextControllerValidator;

    passwordFocusNode = FocusNode();
    passwordTextController = TextEditingController();
    passwordVisibility = false;
    passwordTextControllerValidator = _passwordTextControllerValidator;
  }

  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
