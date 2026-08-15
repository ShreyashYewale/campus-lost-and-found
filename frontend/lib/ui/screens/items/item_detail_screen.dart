import 'package:campus_lost_found/core/models/item.dart';
import 'package:campus_lost_found/core/services/auth_service.dart';
import 'package:campus_lost_found/core/services/item_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isClaiming = false;
  bool _isLoading = true;
  Item? _item;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final itemService = context.read<ItemService>();
    try {
      final item = await itemService.fetchItemById(widget.itemId);
      if (mounted) {
        setState(() {
          _item = item;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _item == null
              ? const Center(child: Text('Item not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: _item!.type == ItemType.lost
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        child: Center(
                          child: Text(
                            _item!.type == ItemType.lost ? '❌ LOST' : '✅ FOUND',
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
                              _item!.title,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              children: [
                                Chip(label: Text(_item!.category.name)),
                                Chip(label: Text(_item!.status.name.toUpperCase())),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(_item!.location, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_item!.formattedDate.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(_item!.formattedDate, style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 24),
                            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(_item!.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                            const SizedBox(height: 24),
                            const Text('Posted by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                    _item!.postedByName ?? 'Unknown',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  if (_item!.formattedDate.isNotEmpty)
                                    Text(
                                      _item!.formattedDate,
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
                                label: _isClaiming ? const Text('Processing...') : const Text('Claim This Item'),
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
      final authService = context.read<AuthService>();
      final itemService = context.read<ItemService>();

      final claimantId = authService.userId;
      if (claimantId == null || _item == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to claim an item')),
          );
        }
        return;
      }

      final success = await itemService.createClaim(
        itemId: _item!.id,
        claimantId: claimantId,
        message: '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Claim request sent!' : 'Failed to submit claim.')),
        );
        if (success) context.pop();
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
