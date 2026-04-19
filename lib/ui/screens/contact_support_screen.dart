import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'Bug Report';
  bool _isSending = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });

      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSending = false;
          _isSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Contact Support', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isSent ? _buildSuccessState() : _buildFormState(),
      ),
    );
  }

  Widget _buildFormState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Report a bug or suggest a feature. We\'ll get back to you as soon as possible.',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            // Category Dropdown
            Text('Category', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  dropdownColor: AppColors.cardBackground,
                  style: GoogleFonts.inter(color: Colors.white),
                  items: ['Bug Report', 'Feature Request', 'General Question', 'Other']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email Field
            Text('Email (Optional)', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'your@email.com',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 20),

            // Message Field
            Text('Message', style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a message';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Tell us what\'s on your mind...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSending ? null : _submitForm,
                child: _isSending 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('SEND MESSAGE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 80),
            const SizedBox(height: 24),
            Text(
              'Message Sent!',
              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for your feedback. We have received your message and will review it shortly.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('BACK TO SETTINGS', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}
