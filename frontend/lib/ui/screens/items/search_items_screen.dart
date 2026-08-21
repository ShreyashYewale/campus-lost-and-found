import 'package:campus_lost_found/core/models/item.dart';
import 'package:campus_lost_found/core/offline/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SearchItemsScreen extends StatefulWidget {
  const SearchItemsScreen({Key? key}) : super(key: key);

  @override
  State<SearchItemsScreen> createState() => _SearchItemsScreenState();
}

class _SearchItemsScreenState extends State<SearchItemsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  List<Item> _items = [];
  bool _isLoading = true;

  final categories = ['All', 'electronics', 'id_cards', 'keys', 'bags', 'books', 'clothing', 'other'];
  final statuses = ['All', 'lost', 'found'];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final repository = context.read<ItemRepository>();
    try {
      final items = await repository.fetchItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Item> get filteredItems {
    final query = _searchController.text.toLowerCase();
    return _items.where((item) {
      final matchesSearch = query.isEmpty || item.title.toLowerCase().contains(query);
      final selectedCategory = _selectedCategory == 'All' ? null : _selectedCategory;
      final matchesCategory = selectedCategory == null || item.category.apiValue == selectedCategory;
      final selectedStatus = _selectedStatus == 'All' ? null : _selectedStatus;
      final itemTypeName = item.type.name;
      final matchesStatus = selectedStatus == null || itemTypeName == selectedStatus;
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
                            label: Text(cat == 'All' ? cat : cat.replaceAll('_', ' ')),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? const Center(child: Text('No items found'))
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final statusLabel = item.type.name;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Card(
                              child: ListTile(
                                leading: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: statusLabel == 'lost' ? Colors.red.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      statusLabel == 'lost' ? '❌' : '✅',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                title: Text(item.title),
                                subtitle: Text('${item.category.displayName} • ${item.location}'),
                                trailing: Text(
                                  item.formattedDate.isEmpty ? 'new' : item.formattedDate,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                onTap: () => context.push('/item/${item.id}'),
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
