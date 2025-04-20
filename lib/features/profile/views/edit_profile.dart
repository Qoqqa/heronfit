import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/profile/controllers/profile_controller.dart';
import 'package:heronfit/features/profile/models/user_model.dart';
import 'package:heronfit/widgets/loading_indicator.dart'; // Assuming you have a loading widget
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import dart:io for File

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _birthdayController;
  late TextEditingController _contactController;

  UserModel? _initialUserData;
  XFile? _pickedImage; // State variable to hold the picked image file

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _birthdayController = TextEditingController();
    _contactController = TextEditingController();

    // Initialize controllers when initial data is available
    // We use listen to handle the async nature of the provider
    ref.listenManual(userProfileProvider, (previous, next) {
      if (next is AsyncData<UserModel?> && next.value != null) {
        _initializeControllers(next.value!);
      }
    }, fireImmediately: true);
  }

  void _initializeControllers(UserModel userData) {
    _initialUserData = userData;
    _firstNameController.text =
        userData.first_name ?? ''; // Changed from firstName
    _lastNameController.text =
        userData.last_name ?? ''; // Changed from lastName
    _heightController.text = userData.height?.toString() ?? '';
    _weightController.text = userData.weight?.toString() ?? '';
    _birthdayController.text = userData.birthday ?? '';
    _contactController.text = userData.contact ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthdayController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate;
    try {
      initialDate =
          _birthdayController.text.isNotEmpty
              ? DateFormat('yyyy-MM-dd').parse(_birthdayController.text)
              : DateTime.now();
    } catch (e) {
      initialDate = DateTime.now(); // Fallback if parsing fails
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900), // Adjust range as needed
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Prepare the data map, only include fields that have changed
      final Map<String, dynamic> updatedData = {};

      if (_firstNameController.text != (_initialUserData?.first_name ?? '')) {
        // Changed from firstName
        updatedData['first_name'] = _firstNameController.text;
      }
      if (_lastNameController.text != (_initialUserData?.last_name ?? '')) {
        // Changed from lastName
        updatedData['last_name'] = _lastNameController.text;
      }
      if (_heightController.text !=
          (_initialUserData?.height?.toString() ?? '')) {
        updatedData['height'] = int.tryParse(_heightController.text);
      }
      if (_weightController.text !=
          (_initialUserData?.weight?.toString() ?? '')) {
        updatedData['weight'] = double.tryParse(_weightController.text);
      }
      if (_birthdayController.text != (_initialUserData?.birthday ?? '')) {
        updatedData['birthday'] = _birthdayController.text;
      }
      if (_contactController.text != (_initialUserData?.contact ?? '')) {
        updatedData['contact'] = _contactController.text;
      }

      // Check if a new image was picked
      final imageToUpload = _pickedImage; // Capture the value

      // Call update for text fields if there are changes
      if (updatedData.isNotEmpty) {
        ref
            .read(profileControllerProvider.notifier)
            .updateUserProfile(updatedData)
            .then((_) {
              // Check if the widget is still mounted before using context
              if (!mounted) return;
              // Check the state after the future completes
              final state = ref.read(profileControllerProvider);
              if (state is AsyncData) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green, // Added for clarity
                  ),
                );
                // Optionally navigate back
                // Navigator.of(context).pop();
              } else if (state is AsyncError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating profile: ${state.error}'),
                    backgroundColor:
                        Theme.of(
                          context,
                        ).colorScheme.error, // Use theme error color
                  ),
                );
              }
            })
            .catchError((error) {
              // Check if the widget is still mounted before using context
              if (!mounted) return;
              // This catchError might be redundant if the controller handles it,
              // but can be useful for unexpected errors.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('An unexpected error occurred: $error'),
                  backgroundColor:
                      Theme.of(
                        context,
                      ).colorScheme.error, // Use theme error color
                ),
              );
            });
      }

      // Call upload avatar if a new image was picked
      if (imageToUpload != null) {
        ref
            .read(profileControllerProvider.notifier)
            .uploadAndUpdateAvatar(imageToUpload)
            .then((_) {
              if (!mounted) return;
              final state = ref.read(profileControllerProvider);
              if (state is AsyncData) {
                // Optionally show a separate success message for avatar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Avatar updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Clear the picked image after successful upload
                setState(() {
                  _pickedImage = null;
                });
              } else if (state is AsyncError) {
                // Error handled by the general profile update state watcher?
                // Or show specific error here if needed.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating avatar: ${state.error}'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            })
            .catchError((error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'An unexpected error occurred uploading avatar: $error',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            });
      } else if (updatedData.isEmpty) {
        // Only show "No changes" if neither text fields nor image changed
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image;

    // Show a dialog or bottom sheet to choose the source
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    // If a source was selected, proceed with picking
    if (source != null) {
      try {
        image = await picker.pickImage(
          source: source,
          // Optionally add image quality constraints
          // imageQuality: 50, // 0-100
          // maxWidth: 800, // Optional max width
        );

        if (image != null) {
          setState(() {
            _pickedImage = image;
          });
        } else {
          // User canceled the picker from the chosen source
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('No image selected.')));
          }
        }
      } catch (e) {
        // Handle potential errors during picking (e.g., permissions)
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
        }
      }
    } else {
      // User dismissed the source selection sheet
      if (mounted) {
        // Optionally show a message, or just do nothing
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Image source selection cancelled.')),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileUpdateState = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (profileUpdateState is AsyncLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed:
                  _initialUserData != null
                      ? _saveProfile
                      : null, // Disable save if initial data not loaded
            ),
        ],
      ),
      body: userProfileAsync.when(
        data: (userData) {
          if (userData == null) {
            // This case might happen if the user logs out while on this screen
            // or if the initial fetch fails in a way that returns null.
            return const Center(child: Text('User data not available.'));
          }
          // Initialize controllers if _initialUserData is still null (first load)
          if (_initialUserData == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Ensure widget is still in the tree
                _initializeControllers(userData);
                // Force a rebuild after controllers are initialized
                setState(() {});
              }
            });
            // Show loading while controllers initialize post-frame
            return const LoadingIndicator();
          }

          // Build the form once initial data is loaded and controllers are set
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Profile Picture (Placeholder/Optional) ---
                  Center(
                    child: Stack(
                      children: [
                        // Apply nested CircleAvatars for borders
                        CircleAvatar(
                          // Outer border
                          radius:
                              50 +
                              2 +
                              2, // Base radius + inner width (2) + outer width (2)
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.primary, // Outer border color
                          child: CircleAvatar(
                            // Inner border
                            radius: 50 + 2, // Base radius + inner width (2)
                            backgroundColor: Colors.white, // Inner border color
                            child: CircleAvatar(
                              // Original Avatar with image
                              radius: 50,
                              // Show picked image preview if available, else network/placeholder
                              backgroundImage:
                                  _pickedImage != null
                                      ? FileImage(File(_pickedImage!.path))
                                      : _initialUserData?.avatar != null
                                      ? NetworkImage(_initialUserData!.avatar!)
                                      : null // Use NetworkImage if URL exists
                                          as ImageProvider?, // Cast to ImageProvider
                              child:
                                  _pickedImage == null &&
                                          _initialUserData?.avatar == null
                                      ? const Icon(Icons.person, size: 50)
                                      : null,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            style: IconButton.styleFrom(
                              // Add background for visibility
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed:
                                _pickImage, // Call the image picking method
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Form Fields ---
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null; // Allow empty
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null; // Allow empty
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _birthdayController,
                    decoration: const InputDecoration(
                      labelText: 'Birthday',
                      hintText: 'yyyy-MM-dd',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        try {
                          DateFormat('yyyy-MM-dd').parseStrict(value);
                        } catch (e) {
                          return 'Invalid date format (yyyy-MM-dd)';
                        }
                      }
                      return null; // Allow empty
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      // Basic validation - could be more complex
                      if (value != null &&
                          value.isNotEmpty &&
                          !RegExp(r'^[0-9\+\-\s()]+$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null; // Allow empty
                    },
                  ),
                  const SizedBox(height: 32),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: profileUpdateState is AsyncLoading ? null : _saveProfile,
                  //     child: profileUpdateState is AsyncLoading
                  //         ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  //         : const Text('Save Changes'),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error:
            (error, stackTrace) =>
                Center(child: Text('Error loading profile: $error')),
      ),
    );
  }
}
