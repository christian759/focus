import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/premium_background.dart';
import '../widgets/duration_picker_3d.dart';
import 'package:focus/core/theme.dart';
import '../../features/focus/focus_provider.dart';
import '../../features/dnd/dnd_service.dart';
import 'session_screen.dart';

class CreateFocusScreen extends ConsumerStatefulWidget {
  const CreateFocusScreen({super.key});

  @override
  ConsumerState<CreateFocusScreen> createState() => _CreateFocusScreenState();
}

class _CreateFocusScreenState extends ConsumerState<CreateFocusScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Read Game of thrones');
  int _selectedMinutes = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Create new focus',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                
                // Focus Name Input
                Text(
                  'Focus name',
                  style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
                ),
                const SizedBox(height: 12),
                IntrinsicWidth(
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter name...',
                      hintStyle: TextStyle(color: Colors.white10),
                    ),
                  ),
                ).animate().fadeIn().scale(),
                
                const Spacer(flex: 1),
                
                // Duration Picker
                Text(
                  'Focus time in mins',
                  style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
                ),
                const SizedBox(height: 24),
                DurationPicker3D(
                  onDurationChanged: (value) {
                    setState(() => _selectedMinutes = value);
                  },
                ),
                

                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final granted = await DndService.requestDndPermission(context);
                          if (granted) {
                            await DndService.turnOnDnd();
                          }
                          ref.read(focusProvider.notifier).startSession(_selectedMinutes);
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SessionScreen()),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        ),
                        child: Text(
                          'Deep Focus (DND)',
                          style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          ref.read(focusProvider.notifier).startSession(_selectedMinutes);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SessionScreen()),
                          );
                        },
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
