import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heronfit/features/profile/controllers/profile_controller.dart';
import 'package:heronfit/features/profile/models/user_model.dart';
import 'package:heronfit/widgets/loading_indicator.dart'; // Assuming you have a loading widget
import 'package:intl/intl.dart'; // For date formatting
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import dart:io for File
import 'package:solar_icons/solar_icons.dart';
import 'package:heronfit/core/theme.dart'; // Assuming you have a theme file

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
      isScrollControlled: true, // Make the modal larger
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          minChildSize: 0.2,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
              ),
            );
          },
        );
      },
    );

    if (source != null) {
      try {
        image = await picker.pickImage(source: source);

        if (image != null) {
          setState(() {
            _pickedImage = image;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('No image selected.')));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileUpdateState = ref.watch(profileControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: HeronFitTheme.primary,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: HeronFitTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: userProfileAsync.when(
          data: (userData) {
            if (userData == null) {
              return const Center(child: Text('User data not available.'));
            }
            if (_initialUserData == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _initializeControllers(userData);
                  setState(() {});
                }
              });
              return const LoadingIndicator();
            }
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 16,
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Profile Picture ---
                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 50 + 4 + 4,
                                      backgroundColor: colorScheme.primary,
                                      child: CircleAvatar(
                                        radius: 50 + 4,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundImage:
                                              _pickedImage != null
                                                  ? FileImage(
                                                    File(_pickedImage!.path),
                                                  )
                                                  : _initialUserData?.avatar !=
                                                      null
                                                  ? NetworkImage(
                                                    _initialUserData!.avatar!,
                                                  )
                                                  : const AssetImage(
                                                        'assets/images/heronfit_icon.png',
                                                      )
                                                      as ImageProvider,
                                          child:
                                              _pickedImage == null &&
                                                      (_initialUserData
                                                                  ?.avatar ==
                                                              null ||
                                                          _initialUserData
                                                                  ?.avatar ==
                                                              '')
                                                  ? const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                  )
                                                  : null,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(
                                          SolarIconsOutline.camera,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor:
                                              colorScheme.onPrimary,
                                        ),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // --- Form Fields ---
                              ..._buildProfileFields(context),
                              const Spacer(),
                              // --- Save Changes Button ---
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      SolarIconsOutline.folderCheck,
                                      size: 22,
                                    ),
                                    label: Text(
                                      profileUpdateState is AsyncLoading
                                          ? 'Saving...'
                                          : 'Save Changes',
                                      style: textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: HeronFitTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed:
                                        profileUpdateState is AsyncLoading
                                            ? null
                                            : _saveProfile,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const LoadingIndicator(),
          error:
              (error, stackTrace) =>
                  Center(child: Text('Error loading profile: $error')),
        ),
      ),
    );
  }

  List<Widget> _buildProfileFields(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return [
      const SizedBox(height: 16),
      TextFormField(
        controller: _firstNameController,
        decoration: const InputDecoration(labelText: 'First Name'),
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Please enter your first name'
                    : null,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _lastNameController,
        decoration: const InputDecoration(labelText: 'Last Name'),
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Please enter your last name'
                    : null,
        textInputAction: TextInputAction.next,
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
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _weightController,
        decoration: const InputDecoration(labelText: 'Weight (kg)'),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value != null &&
              value.isNotEmpty &&
              double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
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
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _contactController,
        decoration: const InputDecoration(labelText: 'Contact Number'),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value != null &&
              value.isNotEmpty &&
              !RegExp(r'^[0-9\+\-\s()]+$').hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
        textInputAction: TextInputAction.done,
      ),
    ];
  }
}
