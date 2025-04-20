import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/profile/controllers/profile_controller.dart';
import 'package:heronfit/features/profile/models/user_model.dart';
import 'package:heronfit/widgets/loading_indicator.dart'; // Assuming you have a loading widget
import 'package:intl/intl.dart'; // For date formatting

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

      // Only call update if there are actual changes
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
      } else {
        // Check if the widget is still mounted before using context
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No changes detected.')));
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
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              _initialUserData?.avatar !=
                                      null // Changed from profileImageUrl
                                  ? NetworkImage(
                                    _initialUserData!
                                        .avatar!, // Changed from profileImageUrl
                                  )
                                  : null, // Use NetworkImage if URL exists
                          child:
                              _initialUserData?.avatar ==
                                      null // Changed from profileImageUrl
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () {
                              // TODO: Implement image picking logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Image picking not implemented yet.',
                                  ),
                                ),
                              );
                            },
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
