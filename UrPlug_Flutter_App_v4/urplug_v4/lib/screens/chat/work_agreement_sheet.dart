import 'package:flutter/material.dart';
import '../../models/chat_and_jobs.dart';

class WorkAgreementSheet extends StatefulWidget {
  const WorkAgreementSheet({super.key});

  @override
  State<WorkAgreementSheet> createState() => _WorkAgreementSheetState();
}

class _WorkAgreementSheetState extends State<WorkAgreementSheet> {
  final _scopeController = TextEditingController();
  final _feeRangeController = TextEditingController();
  final _materialsController = TextEditingController();
  DateTime _completionDate = DateTime.now().add(const Duration(days: 2));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completionDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _completionDate = picked);
  }

  void _submit() {
    if (_scopeController.text.trim().isEmpty) return;
    Navigator.of(context).pop(WorkAgreement(
      jobScope: _scopeController.text.trim(),
      laborFeeRange: _feeRangeController.text.trim().isEmpty ? 'To be discussed' : _feeRangeController.text.trim(),
      materialsResponsibility:
          _materialsController.text.trim().isEmpty ? 'To be discussed' : _materialsController.text.trim(),
      completionDate: _completionDate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Work Agreement Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              'Records agreed terms for both sides — no payment is processed here.',
              style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _scopeController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Job scope'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feeRangeController,
              decoration: const InputDecoration(labelText: 'Labor fee range (e.g. UGX 50,000–80,000)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _materialsController,
              decoration: const InputDecoration(labelText: 'Materials responsibility'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Completion date'),
                child: Text('${_completionDate.day}/${_completionDate.month}/${_completionDate.year}'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _submit, child: const Text('Share in chat')),
            ),
          ],
        ),
      ),
    );
  }
}
