import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedCategory;
  File? _selectedImage;
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select image. Please try again.'),
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an incident category.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Firebase submission will be implemented in the backend stage.
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Form validated! Firebase submission will be connected next.',
        ),
        backgroundColor: Color(0xFF239B69),
        duration: Duration(seconds: 3),
      ),
    );
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
    const primaryColor = Color(0xFF2457C5);
    const darkColor = Color(0xFF17243A);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report an Incident',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help improve your campus',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Provide accurate information about the problem so the appropriate team can address it.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 25),

              _buildLabel('Incident Title'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Broken water pipe near the library',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an incident title.';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must contain at least 5 characters.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Incident Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Select a category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Campus Location'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Block A, Second Floor',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the incident location.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              _buildLabel('Incident Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Describe what happened and provide any useful details...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the incident.';
                  }
                  if (value.trim().length < 15) {
                    return 'Please provide at least 15 characters.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              _buildLabel('Attach a Photo'),
              const SizedBox(height: 5),
              const Text(
                'Add a photo to help staff understand the problem. This is optional.',
                style: TextStyle(fontSize: 13, color: Colors.blueGrey),
              ),

              const SizedBox(height: 12),

              if (_selectedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    _selectedImage!,
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove photo'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ] else
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD5DEEC),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 38,
                          color: primaryColor,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to upload a photo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: darkColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select an image from your gallery',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Report',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Your report will be reviewed by campus staff.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF17243A),
      ),
    );
  }
}
