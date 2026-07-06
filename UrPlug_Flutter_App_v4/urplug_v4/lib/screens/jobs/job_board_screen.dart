import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/service_category.dart';
import '../../theme/app_colors.dart';
import '../chat/chat_screen.dart';
import '../provider/public_provider_profile_screen.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Post a job',
            onPressed: () => _openPostJobSheet(context),
          ),
        ],
      ),
      body: MockData.jobPosts.isEmpty
          ? const Center(child: Text('No active job posts yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MockData.jobPosts.length,
              itemBuilder: (context, index) {
                final job = MockData.jobPosts[index];
                final category = DefaultCategories.all.firstWhere(
                  (c) => c.id == job.categoryId,
                  orElse: () => DefaultCategories.all.last,
                );
                // Find a matching provider to link the Respond button to
                final matchingProvider = MockData.providers.firstWhere(
                  (p) => p.categoryId == job.categoryId,
                  orElse: () => MockData.providers.first,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(category.icon,
                              size: 18, color: AppColors.primaryGreen),
                          const SizedBox(width: 6),
                          Text(category.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Text(
                            _timeAgo(job.createdAt),
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text(job.description),
                        if (job.voiceNoteUrl != null) ...[
                          const SizedBox(height: 8),
                          const Row(children: [
                            Icon(Icons.play_circle_outline, size: 18),
                            SizedBox(width: 6),
                            Text('Voice note attached',
                                style: TextStyle(fontSize: 12.5)),
                          ]),
                        ],
                        const SizedBox(height: 10),
                        Row(children: [
                          Icon(Icons.place_outlined,
                              size: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.zone.landmark ?? 'Zone on file',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6)),
                            ),
                          ),
                          // ── Respond button — opens provider profile ──────
                          OutlinedButton(
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                              builder: (_) => PublicProviderProfileScreen(
                                  providerId: matchingProvider.id),
                            )),
                            child: const Text('View Provider'),
                          ),
                          const SizedBox(width: 6),
                          // ── Chat directly ──────────────────────────────
                          ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                providerId: matchingProvider.id,
                                providerName: matchingProvider.name,
                              ),
                            )),
                            icon: const Icon(Icons.chat_bubble_outline,
                                size: 14),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPostJobSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Post a job'),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _openPostJobSheet(BuildContext context) {
    final descController = TextEditingController();
    String selectedCategory = DefaultCategories.all.first.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Post a Job Request',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration:
                      const InputDecoration(labelText: 'Category'),
                  items: DefaultCategories.all
                      .map((c) => DropdownMenuItem(
                          value: c.id, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) => setSheetState(
                      () => selectedCategory = v ?? selectedCategory),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Describe the job'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Voice note feature coming soon')),
                  ),
                  icon: const Icon(Icons.mic_none_rounded),
                  label: const Text('Attach voice note'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Job posted successfully!')),
                      );
                    },
                    child: const Text('Post job'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
