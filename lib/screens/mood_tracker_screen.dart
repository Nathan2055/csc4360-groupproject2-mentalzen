import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  int _selectedMood = 5;
  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _availableTags = [
    'Happy',
    'Sad',
    'Anxious',
    'Calm',
    'Stressed',
    'Excited',
    'Tired',
    'Energetic',
    'Grateful',
    'Frustrated'
  ];

  final Map<int, Map<String, dynamic>> _moodData = {
    1: {'emoji': '😢', 'label': 'Very Sad', 'color': Colors.red},
    2: {'emoji': '😕', 'label': 'Sad', 'color': Colors.orange},
    3: {'emoji': '😐', 'label': 'Neutral', 'color': Colors.amber},
    4: {'emoji': '🙂', 'label': 'Good', 'color': Colors.lightGreen},
    5: {'emoji': '😊', 'label': 'Great', 'color': Colors.green},
  };

  Future<void> _saveMoodEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .collection('mood_entries')
          .add({
        'mood_rating': _selectedMood,
        'mood_label': _moodData[_selectedMood]!['label'],
        'tags': _selectedTags,
        'notes': _notesController.text,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mood entry saved successfully!')),
        );
        _notesController.clear();
        setState(() {
          _selectedMood = 5;
          _selectedTags.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving mood entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Mood selector
            Center(
              child: Column(
                children: [
                  Text(
                    _moodData[_selectedMood]!['emoji'],
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _moodData[_selectedMood]!['label'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _moodData[_selectedMood]!['color'],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Slider(
                    value: _selectedMood.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: _moodData[_selectedMood]!['color'],
                    onChanged: (value) {
                      setState(() {
                        _selectedMood = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Mood tags
            const Text(
              'Add tags (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade700,
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Notes
            const Text(
              'Add notes (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMoodEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _moodData[_selectedMood]!['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Mood Entry',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}
