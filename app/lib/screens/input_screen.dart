import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_scaffold.dart';
import 'loading_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  XFile? _selectedImage;
  bool _hasText = false;

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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    final claimText = text.isNotEmpty ? text : 'Checking screenshot...';

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
            child: Center(
              child: Opacity(
                opacity: 0.04,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
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
                    // ── Image Preview (if attached) ────────────────
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 4),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2A2A2A),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image,
                                        color: Color(0xFF8E8E8E), size: 28),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedImage = null),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Input Container ────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2A2A2A),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ROW 1 — Text input
                          TextField(
                            controller: _textController,
                            maxLines: null,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Paste a claim, forward, or headline...',
                              hintStyle: GoogleFonts.inter(
                                color: const Color(0xFF555555),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),

                          // Thin divider
                          const Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Color(0xFF2A2A2A),
                          ),

                          // ROW 2 — Buttons row
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: Row(
                              children: [
                                // Add Screenshot button
                                TextButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Color(0xFF8E8E8E),
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Add Screenshot',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF8E8E8E),
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const Spacer(),
                                // Send button — white circle, black arrow
                                GestureDetector(
                                  onTap: (_hasText || _selectedImage != null)
                                      ? _submit
                                      : null,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        (_hasText || _selectedImage != null)
                                            ? Colors.white
                                            : const Color(0xFF2A2A2A),
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color:
                                          (_hasText || _selectedImage != null)
                                              ? Colors.black
                                              : const Color(0xFF555555),
                                      size: 18,
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
