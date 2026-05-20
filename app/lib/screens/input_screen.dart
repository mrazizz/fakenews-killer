import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../widgets/app_scaffold.dart';
import 'loading_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  List<XFile> _selectedImages = [];
  bool _hasText = false;
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
        if (_selectedImages.length > 5) {
          _selectedImages = _selectedImages.sublist(0, 5);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 5 images allowed.')),
          );
        }
      });
    }
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    setState(() => _isExtracting = true);
    
    String extractedText = '';
    if (_selectedImages.isNotEmpty) {
      for (var image in _selectedImages) {
        try {
          final inputImage = InputImage.fromFilePath(image.path);
          final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
          final recognizedText = await textRecognizer.processImage(inputImage);
          if (recognizedText.text.trim().isNotEmpty) {
            extractedText += '${recognizedText.text}\n\n';
          }
          textRecognizer.close();
        } catch (e) {
          debugPrint('OCR Error: $e');
        }
      }
    }

    if (!mounted) return;
    setState(() => _isExtracting = false);

    if (_selectedImages.isNotEmpty && extractedText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to extract text from image. Make sure the image contains text, or try completely restarting the app if you just hot-reloaded.',
          ),
          backgroundColor: Color(0xFFFF4444),
          duration: Duration(seconds: 4),
        ),
      );
      if (text.isEmpty) return; // Don't submit if we have no text at all
    }

    String claimText = text;
    if (extractedText.trim().isNotEmpty) {
      if (claimText.isNotEmpty) {
        claimText += '\n\n[Extracted from image]:\n$extractedText';
      } else {
        claimText = extractedText;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(claimText: claimText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'FakeNews Killer',
      currentRoute: 'home',
      showBackButton: false,
      body: Stack(
        children: [
          // ── Background Watermark Logo ───────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.4,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shield,
                      color: Colors.white,
                      size: 280,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Input Area ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Input Container ────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Image Preview (inside container) ───────────
                          if (_selectedImages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedImages.map((image) {
                                    return SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFF555555), width: 1),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(7),
                                              child: Image.file(
                                                File(image.path),
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.image, color: Color(0xFF8E8E8E), size: 28),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: -6,
                                            right: -6,
                                            child: GestureDetector(
                                              onTap: () => setState(() => _selectedImages.remove(image)),
                                              child: const CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Color(0xFF444444),
                                                child: Icon(Icons.close, size: 12, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                          // ROW 1 — Text input (tall, grows upward)
                          TextField(
                            controller: _textController,
                            maxLines: null,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Paste a claim, forward, or headline...',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF555555),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.fromLTRB(16, _selectedImages.isNotEmpty ? 8 : 16, 16, 8),
                            ),
                          ),

                          // ROW 2 — Buttons row (no divider)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                            child: Row(
                              children: [
                                // Add Screenshot button
                                TextButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Color(0xFF8E8E8E),
                                    size: 28,
                                  ),
                                  label: Text(
                                    'Add Screenshot',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF8E8E8E),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    minimumSize: Size.zero,
                                  ),
                                ),
                                const Spacer(),
                                // Send button — larger
                                GestureDetector(
                                  onTap: (_hasText || _selectedImages.isNotEmpty) && !_isExtracting
                                      ? _submit
                                      : null,
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        (_hasText || _selectedImages.isNotEmpty)
                                            ? Colors.white
                                            : const Color(0xFF2A2A2A),
                                    child: _isExtracting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                            ),
                                          )
                                        : Icon(
                                            Icons.arrow_upward,
                                            color:
                                                (_hasText || _selectedImages.isNotEmpty)
                                                    ? Colors.black
                                                    : const Color(0xFF555555),
                                            size: 22,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
