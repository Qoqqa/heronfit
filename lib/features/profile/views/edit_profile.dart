import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import '../../../core/theme.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  static String routeName = 'EditProfile';
  static String routePath = '/editProfile';

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  final TextEditingController heightTextController = TextEditingController();
  final TextEditingController weightTextController = TextEditingController();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode heightFocusNode = FocusNode();
  final FocusNode weightFocusNode = FocusNode();

  @override
  void dispose() {
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    heightTextController.dispose();
    weightTextController.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    heightFocusNode.dispose();
    weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: HeronFitTheme.bgLight,
        appBar: AppBar(
          backgroundColor: HeronFitTheme.bgLight,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => context.pop(), // Use context.pop()
          ),
          title: Text(
            'Edit Profile',
            style: HeronFitTheme.textTheme.headlineMedium?.copyWith(
              color: HeronFitTheme.primary,
              fontSize: 20,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: HeronFitTheme.bgSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: HeronFitTheme.primary,
                            width: 4,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              // Handle profile image tap
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1531123414780-f74242c2b052?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NDV8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: HeronFitTheme.bgLight,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 50,
                            color: Color(0x1A2C2B3B),
                            offset: Offset(0, 10),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0,
                                0,
                                0,
                                16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      0,
                                      0,
                                      16,
                                    ),
                                    child: Text(
                                      'FIRST NAME',
                                      textAlign: TextAlign.start,
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: HeronFitTheme.textPrimary,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: firstNameTextController,
                                      focusNode: firstNameFocusNode,
                                      autofocus: true,
                                      autofillHints: [AutofillHints.name],
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        alignLabelWithHint: false,
                                        hintText: 'Enter your first name',
                                        hintStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primaryDark,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.error,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedErrorBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: HeronFitTheme.error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0,
                                              0,
                                              0,
                                              16,
                                            ),
                                      ),
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(letterSpacing: 0.0),
                                      keyboardType: TextInputType.name,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0,
                                0,
                                0,
                                16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      0,
                                      0,
                                      16,
                                    ),
                                    child: Text(
                                      'LAST NAME',
                                      textAlign: TextAlign.start,
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: HeronFitTheme.textPrimary,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: lastNameTextController,
                                      focusNode: lastNameFocusNode,
                                      autofocus: true,
                                      autofillHints: [AutofillHints.name],
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        alignLabelWithHint: false,
                                        hintText: 'Enter your last name',
                                        hintStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primaryDark,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.error,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedErrorBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: HeronFitTheme.error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0,
                                              0,
                                              0,
                                              16,
                                            ),
                                      ),
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(letterSpacing: 0.0),
                                      keyboardType: TextInputType.name,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0,
                                0,
                                0,
                                16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      0,
                                      0,
                                      16,
                                    ),
                                    child: Text(
                                      'HEIGHT (cm)',
                                      textAlign: TextAlign.start,
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: HeronFitTheme.textPrimary,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: heightTextController,
                                      focusNode: heightFocusNode,
                                      autofocus: true,
                                      autofillHints: [AutofillHints.name],
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        alignLabelWithHint: false,
                                        hintText: 'Enter your height',
                                        hintStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primaryDark,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.error,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedErrorBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: HeronFitTheme.error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0,
                                              0,
                                              0,
                                              16,
                                            ),
                                      ),
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(letterSpacing: 0.0),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                0,
                                0,
                                0,
                                16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0,
                                      0,
                                      0,
                                      16,
                                    ),
                                    child: Text(
                                      'WEIGHT (kg)',
                                      textAlign: TextAlign.start,
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: HeronFitTheme.textPrimary,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: TextFormField(
                                      controller: weightTextController,
                                      focusNode: weightFocusNode,
                                      autofocus: true,
                                      autofillHints: [AutofillHints.name],
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        alignLabelWithHint: false,
                                        hintText: 'Enter your weight',
                                        hintStyle: HeronFitTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(letterSpacing: 0.0),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primary,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.primaryDark,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: HeronFitTheme.error,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                        ),
                                        focusedErrorBorder:
                                            UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: HeronFitTheme.error,
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(0),
                                            ),
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                              0,
                                              0,
                                              0,
                                              16,
                                            ),
                                      ),
                                      style: HeronFitTheme.textTheme.labelSmall
                                          ?.copyWith(letterSpacing: 0.0),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Save Changes
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeronFitTheme.primaryDark,
                    foregroundColor: HeronFitTheme.bgLight,
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: HeronFitTheme.textTheme.titleSmall?.copyWith(
                      color: HeronFitTheme.bgLight,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
