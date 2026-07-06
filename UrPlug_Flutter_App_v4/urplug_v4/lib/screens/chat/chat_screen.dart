import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat_and_jobs.dart';
import '../../theme/app_colors.dart';
import 'work_agreement_sheet.dart';

const _uuid = Uuid();

class ChatScreen extends StatefulWidget {
  final String providerId;
  final String providerName;
  const ChatScreen(
      {super.key, required this.providerId, required this.providerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'welcome',
      senderId: 'provider',
      type: MessageType.text,
      text: 'Hi! Thanks for reaching out. How can I help?',
      sentAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  // ── Send helpers ────────────────────────────────────────────────────────────

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        senderId: 'me',
        type: MessageType.text,
        text: text,
        sentAt: DateTime.now(),
      ));
      _textController.clear();
    });
    _scrollToBottom();
    // TODO (production): persist messages via Firestore with E2E encryption.
  }

  void _sendVoiceNotePlaceholder() {
    setState(() {
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        senderId: 'me',
        type: MessageType.voiceNote,
        voiceNoteDuration: const Duration(seconds: 14),
        sentAt: DateTime.now(),
      ));
    });
    _scrollToBottom();
    // TODO (production): wire up audio recording for voice notes.
  }

  Future<void> _openWorkAgreement() async {
    final agreement = await showModalBottomSheet<WorkAgreement>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const WorkAgreementSheet(),
    );
    if (agreement != null && mounted) {
      setState(() {
        _messages.add(ChatMessage(
          id: _uuid.v4(),
          senderId: 'me',
          type: MessageType.workAgreement,
          agreement: agreement,
          sentAt: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.providerName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const Text('End-to-end encrypted',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.lock_outline, size: 18),
          ),
        ],
      ),
      body: Column(children: [
        // ── Messages ──────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            itemCount: _messages.length,
            itemBuilder: (context, index) =>
                _MessageBubble(message: _messages[index]),
          ),
        ),

        // ── Input bar ─────────────────────────────────────────────────
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(children: [
              // Work agreement button
              IconButton(
                tooltip: 'Work Agreement',
                onPressed: _openWorkAgreement,
                icon: const Icon(Icons.checklist_rtl_outlined),
                color: AppColors.primaryGreen,
              ),
              // Text field
              Expanded(
                child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendText(),
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24)),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Voice note button
              IconButton(
                tooltip: 'Record voice note',
                onPressed: _sendVoiceNotePlaceholder,
                icon: const Icon(Icons.mic_none_rounded),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              // Send button
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: _sendText,
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == 'me';
    final bubbleColor =
        isMe ? AppColors.primaryGreen : Theme.of(context).cardColor;
    final textColor =
        isMe ? Colors.white : Theme.of(context).colorScheme.onSurface;

    Widget content;
    switch (message.type) {
      case MessageType.text:
        content =
            Text(message.text ?? '', style: TextStyle(color: textColor));
        break;

      case MessageType.voiceNote:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: textColor),
            const SizedBox(width: 6),
            Container(
                width: 80, height: 3, color: textColor.withValues(alpha: 0.35)),
            const SizedBox(width: 8),
            Text(
              '0:${(message.voiceNoteDuration?.inSeconds ?? 0).toString().padLeft(2, '0')}',
              style: TextStyle(color: textColor, fontSize: 12),
            ),
          ],
        );
        break;

      case MessageType.workAgreement:
        final a = message.agreement!;
        content = Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white.withValues(alpha: 0.15)
                : AppColors.primaryGreenLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.checklist_rtl_outlined,
                    size: 16, color: textColor),
                const SizedBox(width: 6),
                Text('Work Agreement',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: textColor)),
              ]),
              const SizedBox(height: 6),
              _AgreementRow('Scope', a.jobScope, textColor),
              _AgreementRow('Fee range', a.laborFeeRange, textColor),
              _AgreementRow('Materials', a.materialsResponsibility, textColor),
              _AgreementRow(
                  'Completion',
                  '${a.completionDate.day}/${a.completionDate.month}/${a.completionDate.year}',
                  textColor),
            ],
          ),
        );
        break;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: isMe
              ? null
              : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: content,
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  const _AgreementRow(this.label, this.value, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 12.5, color: textColor),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
