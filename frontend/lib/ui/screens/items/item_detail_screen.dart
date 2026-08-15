import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isClaiming = false;

  // Dummy item data
  final Map<String, Map<String, dynamic>> itemData = {
    '1': {
      'title': 'Blue Backpack',
      'category': 'Bags',
      'status': 'lost',
      'location': 'Library Entrance',
      'date': 'Dec 10, 2024',
      'description': 'Lost a blue Adidas backpack with laptop inside. Very important.',
      'postedBy': 'John Doe',
      'postedDate': '2 days ago',
      'color': Colors.red.shade100,
    },
    '2': {
      'title': 'iPhone 14 Pro',
      'category': 'Electronics',
      'status': 'found',
      'location': 'Cafeteria',
      'date': 'Dec 12, 2024',
      'description': 'Found an iPhone 14 Pro with space grey color. Screen intact.',
      'postedBy': 'Jane Smith',
      'postedDate': '1 day ago',
      'color': Colors.green.shade100,
    },
    '3': {
      'title': 'ID Card',
      'category': 'Documents',
      'status': 'found',
      'location': 'Student Center',
      'date': 'Dec 14, 2024',
      'description': 'Found an ID card near the student center help desk.',
      'postedBy': 'Admin',
      'postedDate': '3 hours ago',
      'color': Colors.green.shade100,
    },
  };

  @override
  Widget build(BuildContext context) {
    final item = itemData[widget.itemId] ?? itemData['1']!;
    final title = item['title'] as String;
    final category = item['category'] as String;
    final status = item['status'] as String;
    final location = item['location'] as String;
    final date = item['date'] as String;
    final description = item['description'] as String;
    final postedBy = item['postedBy'] as String;
    final postedDate = item['postedDate'] as String;
    final color = item['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              color: color,
              child: Center(
                child: Text(
                  status == 'lost' ? '❌ LOST' : '✅ FOUND',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      Chip(label: Text(category)),
                      Chip(label: Text(status.toUpperCase())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        location,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Posted by',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          postedBy,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          postedDate,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isClaiming ? null : _handleClaim,
                      icon: const Icon(Icons.check_circle),
                      label: _isClaiming
                          ? const Text('Processing...')
                          : const Text('Claim This Item'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.mail),
                      label: const Text('Contact Poster'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClaim() async {
    setState(() => _isClaiming = true);
    try {
      // TODO: Implement actual claim backend call
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim request sent!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }
}
