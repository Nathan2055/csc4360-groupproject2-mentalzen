import 'package:flutter/material.dart';
import 'package:mentalzen/services/authservice.dart';
import 'package:mentalzen/services/firestore_helper.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen(this.authService, this.dbHelper, {super.key});

  final AuthService authService;
  final FirestoreHelper dbHelper;

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Meditation',
    'Breathing',
    'Yoga',
    'Sleep',
    'Stress Relief',
  ];

  final List<Map<String, String>> _resources = [
    {
      'title': '5-Minute Meditation for Beginners',
      'category': 'Meditation',
      'duration': '5:00',
      'url': 'https://www.youtube.com/watch?v=inpok4MKVLM',
      'description': 'A simple guided meditation perfect for beginners',
    },
    {
      'title': 'Deep Breathing Exercise',
      'category': 'Breathing',
      'duration': '3:30',
      'url': 'https://www.youtube.com/watch?v=tybOi4hjZFQ',
      'description': 'Learn the 4-7-8 breathing technique for relaxation',
    },
    {
      'title': 'Morning Yoga Flow',
      'category': 'Yoga',
      'duration': '15:00',
      'url': 'https://www.youtube.com/watch?v=VaoV1PrYft4',
      'description': 'Gentle yoga flow to start your day',
    },
    {
      'title': 'Sleep Meditation',
      'category': 'Sleep',
      'duration': '20:00',
      'url': 'https://www.youtube.com/watch?v=aEqlQvczMJQ',
      'description': 'Guided meditation to help you fall asleep',
    },
    {
      'title': 'Stress Relief Meditation',
      'category': 'Stress Relief',
      'duration': '10:00',
      'url': 'https://www.youtube.com/watch?v=z6X5oEIg6Ak',
      'description': 'Release tension and anxiety with this guided practice',
    },
    {
      'title': 'Box Breathing Technique',
      'category': 'Breathing',
      'duration': '5:00',
      'url': 'https://www.youtube.com/watch?v=tEmt1Znux58',
      'description': 'Navy SEAL breathing technique for stress management',
    },
    {
      'title': 'Evening Yoga for Relaxation',
      'category': 'Yoga',
      'duration': '20:00',
      'url': 'https://www.youtube.com/watch?v=BiWDsfZ3zbo',
      'description': 'Wind down with this calming evening yoga practice',
    },
    {
      'title': 'Mindfulness Meditation',
      'category': 'Meditation',
      'duration': '10:00',
      'url': 'https://www.youtube.com/watch?v=6p_yaNFSYao',
      'description': 'Cultivate present moment awareness',
    },
  ];

  List<Map<String, String>> get _filteredResources {
    if (_selectedCategory == 'All') {
      return _resources;
    }
    return _resources
        .where((resource) => resource['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mindfulness Resources',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore guided meditations, breathing exercises, and more',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Category dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          // Resource cards
          ..._filteredResources.map((resource) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Show dialog with resource details
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(resource['title']!),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource['description']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 4),
                              Text(resource['duration']!),
                              const SizedBox(width: 16),
                              const Icon(Icons.category, size: 16),
                              const SizedBox(width: 4),
                              Text(resource['category']!),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'URL: ${resource['url']!}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(resource['category']!),
                          size: 32,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resource['title']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              resource['description']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  resource['duration']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    resource['category']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_outline, size: 32),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Meditation':
        return Icons.self_improvement;
      case 'Breathing':
        return Icons.air;
      case 'Yoga':
        return Icons.accessibility_new;
      case 'Sleep':
        return Icons.bedtime;
      case 'Stress Relief':
        return Icons.spa;
      default:
        return Icons.video_library;
    }
  }
}
