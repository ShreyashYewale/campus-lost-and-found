import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

enum PendingOperationType { createItem, createClaim }

class PendingOperation {
  final String id;
  final PendingOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id']?.toString() ?? const Uuid().v4(),
      type: PendingOperationType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => PendingOperationType.createItem,
      ),
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? const {}),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PendingSyncService {
  static const _pendingBoxName = 'pending_operations';

  Box<Map>? _pendingBox;
  final _uuid = const Uuid();

  Future<void> initialize() async {
    _pendingBox = await Hive.openBox<Map>(_pendingBoxName);
  }

  List<PendingOperation> getPendingOperations() {
    final box = _pendingBox;
    if (box == null) return const [];

    return box.values
        .map((entry) => PendingOperation.fromJson(Map<String, dynamic>.from(entry)))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> enqueue(PendingOperation operation) async {
    final box = _pendingBox;
    if (box == null) return;
    await box.put(operation.id, operation.toJson());
  }

  Future<PendingOperation> enqueueCreateItem(Map<String, dynamic> payload) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: PendingOperationType.createItem,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await enqueue(operation);
    return operation;
  }

  Future<PendingOperation> enqueueCreateClaim(Map<String, dynamic> payload) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: PendingOperationType.createClaim,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await enqueue(operation);
    return operation;
  }

  Future<void> remove(String operationId) async {
    final box = _pendingBox;
    if (box == null) return;
    await box.delete(operationId);
  }

  int get pendingCount => getPendingOperations().length;
}
