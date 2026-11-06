import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/report_provider.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'Electricity';
  XFile? _selectedImage;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Electricity',
    'Water Supply',
    'Sanitation',
    'Damaged Furniture',
    'Broken Facilities',
    'Campus Safety',
    'Other',
  ];

  // Select an optional photo.
  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
      );

      if (image == null || !mounted) return;

      // Keep uploaded images below 5 MB.
      final bytes = await image.readAsBytes();

      if (bytes.length > 5 * 1024 * 1024) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please choose an image smaller than 5 MB.'),
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _selectedImage = image;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select image.'),
        ),
      );
    }
  }

  // Upload the selected photo to Supabase Storage.
  Future<String?> _uploadImage(String studentId) async {
    if (_selectedImage == null) return null;

    final bytes = await _selectedImage!.readAsBytes();

    final extension = _selectedImage!.name.contains('.')
        ? _selectedImage!.name.split('.').last.toLowerCase()
        : 'jpg';

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Each student's photos are stored in their own folder.
    final photoPath = '$studentId/report_$timestamp.$extension';

    final contentType = _selectedImage!.mimeType ??
        (extension == 'png'
            ? 'image/png'
            : extension == 'webp'
                ? 'image/webp'
                : 'image/jpeg');

    await Supabase.instance.client.storage
        .from('incident-photos')
        .uploadBinary(
          photoPath,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
          ),
        );

    return photoPath;
  }

  // Submit the report to Firestore.
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in before submitting.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    String? uploadedPhotoPath;

    try {
      // Upload the optional photo first.
      uploadedPhotoPath = await _uploadImage(user.uid);

      if (!mounted) return;

      // Save the report details and photo path in Firestore.
      final success = await context.read<ReportProvider>().submitReport(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            location: _locationController.text.trim(),
            studentId: user.uid,
            studentEmail: user.email ?? '',
            photoPath: uploadedPhotoPath,
          );

      if (!mounted) return;

      if (success) {
        _titleController.clear();
        _locationController.clear();
        _descriptionController.clear();

        setState(() {
          _selectedCategory = 'Electricity';
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your incident report was submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Remove the uploaded photo if saving the report failed.
        if (uploadedPhotoPath != null) {
          try {
            await Supabase.instance.client.storage
                .from('incident-photos')
                .remove([uploadedPhotoPath]);
          } catch (_) {
            // The report failed even if cleanup also fails.
          }
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Report submission failed. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase error: ${e.message ?? e.code}'),
        ),
      );
    } on StorageException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo upload failed: ${e.message}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report an Issue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help improve your campus',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us about an issue that needs attention.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Report title.
              const Text(
                'Issue Title',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Broken lights in the library',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Enter a title with at least 5 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category.
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Location.
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Block A, Room 204',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the location.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description.
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 15) {
                    return 'Description must contain at least 15 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Optional photo.
              const Text(
                'Attach a Photo (Optional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              if (_selectedImage != null) ...[
                FutureBuilder(
                  future: _selectedImage!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          snapshot.data!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }

                    return const SizedBox(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ] else
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _pickImage,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Choose Photo'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

              const SizedBox(height: 30),

              // Submit.
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
