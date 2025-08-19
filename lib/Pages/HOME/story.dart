import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class CreateStory extends StatefulWidget {
  const CreateStory({super.key});

  @override
  State<CreateStory> createState() => _CreateStoryState();
}

class _CreateStoryState extends State<CreateStory> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _backgroundType = 'gradient';
  Color _selectedColor = Colors.blue;
  int _selectedGradient = 0;

  final List<List<Color>> _gradients = [
    [Colors.purple, Colors.pink],
    [Colors.blue, Colors.cyan],
    [Colors.orange, Colors.red],
    [Colors.green, Colors.teal],
    [Colors.indigo, Colors.purple],
    [Colors.pink, Colors.orange],
  ];

  final List<Color> _solidColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _backgroundType = 'image';
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    try {
      Uint8List imageBytes = await imageFile.readAsBytes();
      debugPrint('Original image file size in bytes: ${imageBytes.length}');

      if (imageBytes.length > 500000) {
        final codec = await ui.instantiateImageCodec(
          imageBytes,
          targetWidth: 720,
          targetHeight: 1280,
        );
        final frame = await codec.getNextFrame();
        final compressedBytes = await frame.image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        imageBytes = compressedBytes!.buffer.asUint8List();
        debugPrint('Compressed image file size in bytes: ${imageBytes.length}');
      }

      String base64String = base64Encode(imageBytes);
      debugPrint('Base64 image length: ${base64String.length}');

      if (base64String.length > 700000) {
        throw Exception('Image too large even after compression');
      }

      return base64String;
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> _createStory() async {
    if (_textController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text or select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final userData = await _getCurrentUserData();
      final userName = "${userData['fname'] ?? ''} ${userData['lname'] ?? ''}".trim();
      final profileImage = userData['ppimage'] ?? '';

      String storyImageBase64;

      if (_selectedImage != null) {
        storyImageBase64 = await _convertImageToBase64(_selectedImage!);
      } else {
        storyImageBase64 = await _createTextStoryImage();
      }

      debugPrint('Final base64 length: ${storyImageBase64.length}');

      // ✅ FIXED: Create a new document with auto-generated ID instead of using user UID
      await FirebaseFirestore.instance
          .collection('stories')
          .add({
        'name': userName.isNotEmpty ? userName : 'Anonymous',
        'profileUrl': profileImage,
        'storyImage': storyImageBase64,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid, // Store user ID for reference but don't use as document ID
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story created successfully!')),
        );
      }
    } catch (e, st) {
      debugPrint('Error creating story: $e');
      debugPrint('$st');
      if (mounted) {
        String errorMessage = 'Failed to create story';
        if (e.toString().contains('too large')) {
          errorMessage = 'Image is too large. Please select a smaller image.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _createTextStoryImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(720, 1280);

    if (_backgroundType == 'gradient') {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: _gradients[_selectedGradient],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    } else if (_backgroundType == 'color') {
      final paint = Paint()..color = _selectedColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: _textController.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.width - 80);
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return base64Encode(byteData!.buffer.asUint8List());
  }

  Widget _buildBackgroundSelector() {
    return SizedBox(
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(_gradients.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _backgroundType = 'gradient';
                        _selectedGradient = index;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gradients[index],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _backgroundType == 'gradient' &&
                              _selectedGradient == index
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }),
                ...List.generate(_solidColors.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _backgroundType = 'color';
                        _selectedColor = _solidColors[index];
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _solidColors[index],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _backgroundType == 'color' &&
                              _selectedColor == _solidColors[index]
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryPreview() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: _backgroundType == 'gradient'
            ? LinearGradient(
          colors: _gradients[_selectedGradient],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: _backgroundType == 'color' ? _selectedColor : null,
      ),
      child: _selectedImage != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      )
          : Center(
        child: Text(
          _textController.text.isEmpty
              ? 'Your story text will appear here'
              : _textController.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Colors.black54,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Create Story', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createStory,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Share',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStoryPreview(),
            const SizedBox(height: 20),
            if (_selectedImage == null) ...[
              TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                maxLines: 3,
                onChanged: (text) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _buildBackgroundSelector(),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Add Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _backgroundType = 'gradient';
                      });
                    },
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Text Story'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}