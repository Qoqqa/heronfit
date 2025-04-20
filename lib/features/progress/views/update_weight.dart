import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // For date formatting if needed

class UpdateWeightWidget extends ConsumerStatefulWidget {
  const UpdateWeightWidget({super.key});

  @override
  ConsumerState<UpdateWeightWidget> createState() => _UpdateWeightWidgetState();
}

class _UpdateWeightWidgetState extends ConsumerState<UpdateWeightWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  XFile? _selectedImageXFile;
  bool _isLoading = false;
  String? _errorMessage;
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageXFile = pickedFile;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<String?> _uploadImage(XFile imageXFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in.');

      final fileExt = imageXFile.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${imageXFile.name.isNotEmpty ? imageXFile.name.split('.').last : fileExt}';
      final filePath = '$userId/$fileName';

      final imageBytes = await imageXFile.readAsBytes();
      final imageMimeType = imageXFile.mimeType;

      await _supabase.storage
          .from('progress_pics')
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: imageMimeType,
            ),
          );

      final imageUrlResponse = _supabase.storage
          .from('progress_pics')
          .getPublicUrl(filePath);

      return imageUrlResponse;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      if (e is StorageException) {
        print('Supabase Storage Error Details: ${e.message}');
      }
      return null;
    }
  }

  Future<void> _submitWeight() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      String? imageUrl;
      if (_selectedImageXFile != null) {
        imageUrl = await _uploadImage(_selectedImageXFile!);
        if (imageUrl == null) {
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Failed to upload image. Please try again.';
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
          return;
        }
      }

      try {
        final weight = double.parse(_weightController.text);

        await ref
            .read(progressRecordsProvider.notifier)
            .addWeightEntry(weight, imageUrl);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight logged successfully!')),
        );
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to log weight: $e';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log New Weight'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Current Weight (kg)',
                      hintText: 'Enter your current weight',
                      prefixIcon: Icon(
                        Icons.monitor_weight_outlined,
                        color: theme.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Add Progress Photo (Optional)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _selectedImageXFile != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  kIsWeb
                                      ? Image.network(
                                        _selectedImageXFile!.path,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )
                                      : Image.file(
                                        File(_selectedImageXFile!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                            )
                            : Center(
                              child: Icon(
                                Icons.image_search,
                                size: 50,
                                color: theme.hintColor,
                              ),
                            ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImageXFile != null)
                    TextButton.icon(
                      onPressed:
                          () => setState(() => _selectedImageXFile = null),
                      icon: Icon(Icons.clear, color: theme.colorScheme.error),
                      label: Text(
                        'Remove Image',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitWeight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: theme.colorScheme.primary
                          .withAlpha(128),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Text(
                              'Save Weight Log',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
