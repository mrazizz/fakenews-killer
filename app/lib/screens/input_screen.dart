import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'loading_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _textController = TextEditingController();
  final ApiService _apiService = ApiService();
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot uploaded successfully')),
        );
      }
    }
  }

  void _checkNow() {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or upload a screenshot')),
      );
      return;
    }

    final analysisFuture = _apiService.analyzeText(text.isNotEmpty ? text : 'Checking screenshot...');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(analysisFuture: analysisFuture),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000816),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset('assets/images/logo.png', width: 32, height: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, color: Color(0xFF3B82F6))),
        ),
        title: Text(
          'FakeNews Killer',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What needs fact-checking?',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Paste any claim, forward, or headline',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF93C5FD),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type or paste here...',
                    hintStyle: TextStyle(color: const Color(0xFF93C5FD).withOpacity(0.6)),
                    filled: true,
                    fillColor: const Color(0xFF0A1628),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1F35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF2ECC71)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedImage!.name,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFE74C3C)),
                        onPressed: () => setState(() => _selectedImage = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file, color: Color(0xFF3B82F6)),
                label: const Text('Upload Screenshot'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  side: const BorderSide(color: Color(0xFF3B82F6)),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF3B82F6),
                ),
                child: ElevatedButton(
                  onPressed: _checkNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Analyze Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
