import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Dummy item data for demo
final dummyItems = [
  {
    'id': '1',
    'title': 'Blue Backpack',
    'category': 'Bags',
    'status': 'lost',
    'location': 'Library Entrance',
    'date': '2 days ago'
  },
  {
    'id': '2',
    'title': 'iPhone 14 Pro',
    'category': 'Electronics',
    'status': 'found',
    'location': 'Cafeteria',
    'date': '1 day ago'
  },
  {
    'id': '3',
    'title': 'ID Card',
    'category': 'Documents',
    'status': 'found',
    'location': 'Student Center',
    'date': '3 hours ago'
  },
  {
    'id': '4',
    'title': 'Black Jacket',
    'category': 'Clothing',
    'status': 'lost',
    'location': 'Gym',
    'date': '5 days ago'
  },
];

class SearchItemsScreen extends StatefulWidget {
  const SearchItemsScreen({Key? key}) : super(key: key);

  @override
  State<SearchItemsScreen> createState() => _SearchItemsScreenState();
}

class _SearchItemsScreenState extends State<SearchItemsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final categories = ['All', 'Electronics', 'Accessories', 'Clothing', 'Documents', 'Bags', 'Keys', 'Other'];
  final statuses = ['All', 'lost', 'found'];

  List<Map<String, dynamic>> get filteredItems {
    return dummyItems.where((item) {
      final matchesSearch = item['title']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesStatus = _selectedStatus == 'All' || item['status'] == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse Items')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...statuses.map((status) {
                        final isSelected = _selectedStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedStatus = status),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No items found'))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Card(
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: item['status'] == 'lost' ? Colors.red.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  item['status'] == 'lost' ? '❌' : '✅',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            title: Text(item['title']),
                            subtitle: Text('${item['category']} • ${item['location']}'),
                            trailing: Text(
                              item['date'],
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () => context.push('/item/${item['id']}'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
