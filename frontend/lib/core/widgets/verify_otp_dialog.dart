import 'package:campus_lost_found/core/services/item_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
 
/// A simple dialog the item owner (finder) uses to verify the OTP that the
/// claimant received when their claim was approved. On success the backend
/// marks the claim verified and the item resolved.
///
/// Usage:
///   showDialog(
///     context: context,
///     builder: (_) => VerifyOtpDialog(claimId: someClaimId),
///   );
class VerifyOtpDialog extends StatefulWidget {
  /// Optional. If null, the dialog asks the user to enter the Claim ID too.
  final String? claimId;
 
  const VerifyOtpDialog({Key? key, this.claimId}) : super(key: key);
 
  @override
  State<VerifyOtpDialog> createState() => _VerifyOtpDialogState();
}
 
class _VerifyOtpDialogState extends State<VerifyOtpDialog> {
  final _codeController = TextEditingController();
  final _claimIdController = TextEditingController();
  bool _isVerifying = false;
  String? _error;
 
  @override
  void dispose() {
    _codeController.dispose();
    _claimIdController.dispose();
    super.dispose();
  }
 
  Future<void> _verify() async {
    final code = _codeController.text.trim();
    final claimId = widget.claimId ?? _claimIdController.text.trim();
    if (claimId.isEmpty) {
      setState(() => _error = 'Enter the Claim ID.');
      return;
    }
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return;
    }
 
    setState(() {
      _isVerifying = true;
      _error = null;
    });
 
    try {
      final itemService = context.read<ItemService>();
      final result = await itemService.verifyClaimOtp(
        claimId: claimId,
        code: code,
      );
 
      if (!mounted) return;
 
      if (result.success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      } else {
        setState(() {
          _error = result.message.isNotEmpty ? result.message : 'Verification failed.';
          _isVerifying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isVerifying = false;
        });
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify collection OTP'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ask the claimant for the 6-digit OTP they received and enter it here '
            'to confirm hand-over.',
          ),
          const SizedBox(height: 16),
          if (widget.claimId == null) ...[
            TextField(
              controller: _claimIdController,
              decoration: const InputDecoration(
                labelText: 'Claim ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'OTP',
              hintText: '123456',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verify,
          child: _isVerifying
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Verify'),
        ),
      ],
    );
  }
}
 