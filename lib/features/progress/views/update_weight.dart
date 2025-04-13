import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

// Use the proper Supabase instance
final supabase = Supabase.instance.client;

class UpdateWeightWidget extends StatefulWidget {
  const UpdateWeightWidget({super.key});

  static String routeName = 'UpdateWeight';
  static String routePath = '/updateWeight';

  @override
  State<UpdateWeightWidget> createState() => _UpdateWeightWidgetState();
}

class _UpdateWeightWidgetState extends State<UpdateWeightWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController textController1 = TextEditingController(); // Weight
  final TextEditingController textController2 = TextEditingController(); // Date
  XFile? _uploadedImage;
  String? _uploadedImageUrl;

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Set today's date as default
    textController2.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    textController1.dispose();
    textController2.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String source) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    try {
      if (source == 'Camera') {
        pickedFile = await picker.pickImage(source: ImageSource.camera);
      } else if (source == 'Gallery') {
        pickedFile = await picker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile != null) {
        setState(() {
          _uploadedImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (_uploadedImage == null) {
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
      );
    }
    
    // Handle web platform specifically
    if (kIsWeb) {
      return Image.network(
        _uploadedImage!.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
          );
        },
      );
    } else {
      // For mobile platforms
      return Image.file(
        File(_uploadedImage!.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
          );
        },
      );
    }
  }

  Future<void> _uploadData() async {
    if (_uploadedImage == null || textController1.text.isEmpty || textController2.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and select an image!')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        throw Exception('You must be logged in to upload data');
      }

      String? publicUrl;
      final fileName = _uploadedImage!.name;
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // Handle file upload for web and mobile
      if (kIsWeb) {
        // For web, we need to handle the file differently
        final bytes = await _uploadedImage!.readAsBytes();
        
        // Upload image to Supabase Storage
        await supabase
            .storage
            .from('image')
            .uploadBinary('imagelist/$uniqueFileName', bytes);
      } else {
        // For mobile platforms
        final imageFile = File(_uploadedImage!.path);
        final bytes = await imageFile.readAsBytes();
        
        // Upload image to Supabase Storage
        await supabase
            .storage
            .from('image')
            .uploadBinary('imagelist/$uniqueFileName', bytes);
      }

      // Get public URL
      publicUrl = supabase
          .storage
          .from('image')
          .getPublicUrl('imagelist/$uniqueFileName');

      setState(() {
        _uploadedImageUrl = publicUrl;
      });

      // Insert into Supabase Table with proper error handling
      final response = await supabase
          .from('update_weight')
          .insert({
            'date': textController2.text,
            'pic': publicUrl,
            'email': user.email,
            'weight': textController1.text,
            'identifier_id': user.id,
          });

      if (response.error != null) {
        throw Exception('Insert failed: ${response.error!.message}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data inserted successfully!')),
        );
        
        // Clear fields after successful upload
        textController1.clear();
        textController2.text = DateTime.now().toString().split(' ')[0];
        setState(() {
          _uploadedImage = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Update Weight',
            style: GoogleFonts.poppins(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 40,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 10),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildTextFieldRow(context, 'Weight (kg)', textController1, '0', TextInputType.number),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          _buildTextFieldRow(context, 'Date', textController2, 'YYYY-MM-DD', TextInputType.datetime),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress Photo',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                                onSelected: _pickImage,
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'Camera', child: Text('Camera')),
                                  const PopupMenuItem(value: 'Gallery', child: Text('Gallery')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(thickness: 2, color: Theme.of(context).primaryColor),
                          const SizedBox(height: 16),
                          Container(
                            width: 225,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildImagePreview(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Changes',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
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

  Widget _buildTextFieldRow(BuildContext context, String label, TextEditingController controller, String hint, TextInputType keyboardType) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}