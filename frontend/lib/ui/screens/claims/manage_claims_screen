import 'package:campus_lost_found/core/models/claim.dart';
import 'package:campus_lost_found/core/services/api_service.dart';
import 'package:campus_lost_found/core/services/auth_service.dart';
import 'package:campus_lost_found/core/services/claim_service.dart';
import 'package:campus_lost_found/core/widgets/verify_otp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Where a poster (e.g. Alice) manages claims on the items she posted:
/// approve/reject a pending claim, then verify the claimant's OTP at hand-over.
class ManageClaimsScreen extends StatefulWidget {
  const ManageClaimsScreen({Key? key}) : super(key: key);

  @override
  State<ManageClaimsScreen> createState() => _ManageClaimsScreenState();
}

class _ManageClaimsScreenState extends State<ManageClaimsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Claim> _claims = [];
  String? _busyClaimId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    await auth.ensureInitialized();
    if (!auth.isAuthenticated || auth.userId == null || auth.token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Please sign in to manage claims.';
      });
      return;
    }

    try {
      context.read<ApiService>().setSessionToken(auth.token);
      final claimService = context.read<ClaimService>();
      final claims = await claimService.fetchClaimsToApprove(auth.userId!);
      if (mounted) {
        setState(() {
          _claims = claims;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approve(Claim claim) async {
    setState(() => _busyClaimId = claim.id);
    try {
      final ok = await context.read<ClaimService>().approveClaim(claim.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Approved. An OTP was sent to the claimant.'
                : 'Could not approve the claim.'),
          ),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _busyClaimId = null);
    }
  }

  Future<void> _reject(Claim claim) async {
    setState(() => _busyClaimId = claim.id);
    try {
      await context.read<ClaimService>().rejectClaim(claim.id);
      await _load();
    } finally {
      if (mounted) setState(() => _busyClaimId = null);
    }
  }

  Future<void> _verify(Claim claim) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => VerifyOtpDialog(claimId: claim.id),
    );
    await _load();
  }

  Widget _statusChip(String status) {
    Color c;
    switch (status) {
      case 'approved':
        c = Colors.green;
        break;
      case 'rejected':
        c = Colors.red;
        break;
      default:
        c = Colors.orange;
    }
    return Chip(
      label: Text(status.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: c,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claims on My Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.push('/login'),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
                  ),
                )
              : _claims.isEmpty
                  ? const Center(child: Text('No claims on your items yet.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _claims.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final claim = _claims[i];
                          final busy = _busyClaimId == claim.id;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          claim.itemTitle ?? 'Item',
                                          style: const TextStyle(
                                              fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      _statusChip(claim.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Claimed by: ${claim.claimantName ?? 'Unknown'}'),
                                  if (claim.otpVerified)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text('OTP verified - handover complete',
                                          style: TextStyle(color: Colors.green)),
                                    ),
                                  const SizedBox(height: 8),
                                  if (busy)
                                    const Center(child: CircularProgressIndicator())
                                  else if (claim.isPending)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _approve(claim),
                                            icon: const Icon(Icons.check),
                                            label: const Text('Approve'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _reject(claim),
                                            icon: const Icon(Icons.close),
                                            label: const Text('Reject'),
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (claim.isApproved && !claim.otpVerified)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _verify(claim),
                                        icon: const Icon(Icons.verified_user),
                                        label: const Text('Verify Collection OTP'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}