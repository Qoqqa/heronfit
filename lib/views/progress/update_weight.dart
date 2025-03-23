import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Initialize Supabase Client
final supabaseClient = SupabaseClient(
  'https://dktxspcehngtrbnvhkfh.supabase.co',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrdHhzcGNlaG5ndHJibnZoa2ZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE1MTg5MTgsImV4cCI6MjA1NzA5NDkxOH0.jqN6T0KBFU0rzgxZFBp0ngE0s0Ug0jA4qUKs1uxD7tw',
);

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
  void dispose() {
    textController1.dispose();
    textController2.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String source) async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

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
  
    // Read image bytes
    final bytes = await _uploadedImage!.readAsBytes();
    final fileName = _uploadedImage!.name;
    final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

    // Upload image to Supabase Storage
    final storageResponse = await supabaseClient
        .storage
        .from('image')
        .uploadBinary('imagelist/$uniqueFileName', bytes);

    if (storageResponse.isEmpty) {
      // Get public URL
      final publicUrl = supabaseClient
          .storage
          .from('image')
          .getPublicUrl('imagelist/$uniqueFileName');

      setState(() {
        _uploadedImageUrl = publicUrl;
      });

      final user = supabaseClient.auth.currentUser;

    // Insert into Supabase Table
   final insertResponse = await supabaseClient
    .from('update_weight')
    .update({
      'date': textController2.text,
      'pic': publicUrl,
      'email': user?.email ?? 'unknown',
      'weight': textController1.text,
      'identifier_id': user?.id ?? 'unknown',
    });  
if (insertResponse.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Insert failed! Error: ${insertResponse.error!.message}')),
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Data inserted successfully!')),
  );
}
} 
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: $e')),
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
                  _buildTextFieldRow(context, 'Weight (kg)', textController1, '0'),
                  const SizedBox(height: 16),
                  Divider(thickness: 2, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  _buildTextFieldRow(context, 'Date', textController2, 'Date'),
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
                      child: _uploadedImage != null
                          ? Image.network(
                              _uploadedImage!.path,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                            ),
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildTextFieldRow(BuildContext context, String label, TextEditingController controller, String hint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
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
