import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/core/router/app_routes.dart';
import 'package:heronfit/core/theme.dart';
import 'package:heronfit/widgets/loading_indicator.dart';
import '../controllers/registration_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class RegisterRoleSelectionScreen extends ConsumerStatefulWidget {
  const RegisterRoleSelectionScreen({super.key});

  @override
  ConsumerState<RegisterRoleSelectionScreen> createState() => _RegisterRoleSelectionScreenState();
}

class _RegisterRoleSelectionScreenState extends ConsumerState<RegisterRoleSelectionScreen> {
  bool _isLoading = false;
  String? _selectedRole;
  String? _verificationDocumentPath;
  bool _showFacultyStaffSection = false;

  Future<void> _pickAndUploadVerificationDocument() async {
    // 1. Pick file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final email = ref.read(registrationProvider).email;
      final fileName = 'verification_documents/${email.trim()}_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';

      setState(() => _isLoading = true); // Show loading indicator during upload

      try {
        final file = File(filePath);
        final String uploadedPath = await Supabase.instance.client.storage
            .from('user-documents') // Ensure this bucket exists and has correct policies
            .upload(fileName, file);

        ref.read(registrationProvider.notifier).updateVerificationDocumentUrl(uploadedPath);
        setState(() {
          _verificationDocumentPath = uploadedPath;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification document uploaded.'), backgroundColor: Colors.green),
        );
      } on StorageException catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document upload failed: ${e.message}'), backgroundColor: HeronFitTheme.error),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document upload error: $e'), backgroundColor: HeronFitTheme.error),
        );
      }
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No document selected.'), backgroundColor: HeronFitTheme.error),
      );
    }
  }

  void _continueRegistration() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role.'), backgroundColor: HeronFitTheme.error),
      );
      return;
    }

    if (_selectedRole == 'FACULTY_STAFF' && _verificationDocumentPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a verification document.'), backgroundColor: HeronFitTheme.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registrationNotifier = ref.read(registrationProvider.notifier);

      registrationNotifier.updateUserRole(_selectedRole!);

      if (_selectedRole == 'STUDENT') {
        registrationNotifier.updateRoleStatus('VERIFIED');
        registrationNotifier.updateVerificationDocumentUrl(null);
      } else if (_selectedRole == 'FACULTY_STAFF') {
        registrationNotifier.updateRoleStatus('PENDING_VERIFICATION');
        // Document URL already updated during upload
      } else { // PUBLIC
        registrationNotifier.updateRoleStatus('VERIFIED');
        registrationNotifier.updateVerificationDocumentUrl(null);
      }

      if (mounted) {
        context.pushNamed(AppRoutes.registerGettingToKnow);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: HeronFitTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(registrationProvider).email;
    final isUmakEmail = email.toLowerCase().endsWith('@umak.edu.ph');

    return Scaffold(
      backgroundColor: HeronFitTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HeronFitTheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title and description
                      Text(
                        'Select Your Role',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.headlineSmall?.copyWith(
                          color: HeronFitTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isUmakEmail 
                            ? 'We detected you\'re using a UMAK email. Please select your role at the university.'
                            : 'Please select your role to continue.',
                        textAlign: TextAlign.center,
                        style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                          color: HeronFitTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Role selection cards
                      if (isUmakEmail) ...[
                        // Student option
                        _buildRoleCard(
                          title: 'Student',
                          description: 'I am a student at the University of Makati',
                          isSelected: _selectedRole == 'STUDENT',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'STUDENT';
                              _showFacultyStaffSection = false;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Faculty/Staff option
                        _buildRoleCard(
                          title: 'Faculty/Staff',
                          description: 'I am a faculty member or staff at the University of Makati',
                          isSelected: _selectedRole == 'FACULTY_STAFF',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'FACULTY_STAFF';
                              _showFacultyStaffSection = true;
                            });
                          },
                        ),
                      ] else ...[
                        // Public option for non-UMAK emails
                        _buildRoleCard(
                          title: 'Public',
                          description: 'I am a member of the public interested in fitness',
                          isSelected: _selectedRole == 'PUBLIC',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'PUBLIC';
                              _showFacultyStaffSection = false;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Faculty/Staff verification section
                      if (_showFacultyStaffSection) ...[
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Faculty/Staff Verification',
                          style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                            color: HeronFitTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please upload a document to verify your faculty/staff status. This could be your ID card, appointment letter, or any official document.',
                          style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                            color: HeronFitTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Document upload button
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickAndUploadVerificationDocument,
                          icon: const Icon(Icons.upload_file),
                          label: Text(_verificationDocumentPath == null 
                              ? 'Upload Verification Document' 
                              : 'Change Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HeronFitTheme.bgSecondary,
                            foregroundColor: HeronFitTheme.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        if (_verificationDocumentPath != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Document uploaded successfully',
                            textAlign: TextAlign.center,
                            style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        Text(
                          'Note: Your account will be pending verification until an administrator approves your faculty/staff status.',
                          style: HeronFitTheme.textTheme.bodySmall?.copyWith(
                            color: HeronFitTheme.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Continue button
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: LoadingIndicator(),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _continueRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HeronFitTheme.primary,
                    foregroundColor: HeronFitTheme.textWhite,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: HeronFitTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? HeronFitTheme.primary.withOpacity(0.1) : HeronFitTheme.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? HeronFitTheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected ? true : null,
              onChanged: (_) => onTap(),
              activeColor: HeronFitTheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: HeronFitTheme.textTheme.titleMedium?.copyWith(
                      color: HeronFitTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: HeronFitTheme.textTheme.bodyMedium?.copyWith(
                      color: HeronFitTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
