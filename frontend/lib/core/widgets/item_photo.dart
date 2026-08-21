import 'package:flutter/material.dart';

class ItemPhoto extends StatelessWidget {
  final String? photoUrl;
  final ItemTypeBadge type;
  final double height;

  const ItemPhoto({
    super.key,
    required this.photoUrl,
    required this.type,
    this.height = 250,
  });

  @override
  Widget build(BuildContext context) {
    final background = type == ItemTypeBadge.lost
        ? Colors.red.shade100
        : Colors.green.shade100;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(background),
      );
    }

    return _placeholder(background);
  }

  Widget _placeholder(Color background) {
    return Container(
      width: double.infinity,
      height: height,
      color: background,
      child: Center(
        child: Text(
          type == ItemTypeBadge.lost ? 'LOST' : 'FOUND',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

enum ItemTypeBadge { lost, found }
