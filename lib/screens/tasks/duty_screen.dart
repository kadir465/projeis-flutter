import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

const kBackgroundColor = Color(0xFF1D1E33);
const kAppBarColor = Color(0xFF1D1E33);
const kAppBarTextColor = Color.fromARGB(255, 230, 230, 255);
const kInputBackgroundColor = Color.fromARGB(255, 20, 22, 50);
const kHintTextColor = Color(0xFF6b7a8f);
const kMyMessageBubbleColor = Color(0xFF007AFF);
const kOtherMessageBubbleColor = Color(0xFF3A3A3C);
const kTimestampColor = Color(0xFFB0B0B0);
const kIconColor = Color(0xFF8E8E93);
const kDeleteIconColor = Color(0xFFFF453A);
const kSendButtonColor = Color(0xFF007AFF);

class DutyScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;

  const DutyScreen({
    Key? key,
    required this.receiverId,
    required this.receiverEmail,
  }) : super(key: key);

  @override
  State<DutyScreen> createState() => _DutyScreenState();
}

class _DutyScreenState extends State<DutyScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final String _currentUserId;
  late final String _chatId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _currentUserId = "error_user_not_found";
      _chatId = "error_chat_id";
      return;
    }
    _currentUserId = currentUser.uid;
    _createChatId();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _createChatId() {
    List<String> ids = [_currentUserId, widget.receiverId];
    ids.sort();
    _chatId = ids.join('_');
  }

  Future<void> _sendMessage() async {
    if (_isSending) return;
    final String messageText = _messageController.text.trim();
    final User? user = _auth.currentUser;

    if (messageText.isNotEmpty && user != null) {
      setState(() => _isSending = true);
      _messageController.clear();
      try {
        await _firestore.collection('chats').doc(_chatId).collection('messages').add({
          'text': messageText,
          'senderId': user.uid,
          'receiverId': widget.receiverId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mesaj gönderilemedi: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final bool? confirmDelete = await _showDeleteConfirmationDialog();
    if (confirmDelete != true) return;

    try {
      await _firestore.collection('chats').doc(_chatId).collection('messages').doc(messageId).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesaj silinemedi: $e')),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kInputBackgroundColor,
        title: const Text('Mesajı Sil', style: TextStyle(color: Colors.white)),
        content: const Text('Bu mesajı silmek istediğinizden emin misiniz?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil', style: TextStyle(color: kDeleteIconColor))),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mesajlar", style: TextStyle(color: kAppBarTextColor, fontSize: 16)),
        backgroundColor: kAppBarColor,
        elevation: 1.0,
      ),
      backgroundColor: kBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chats').doc(_chatId).collection('messages').orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Henüz mesaj yok...', style: TextStyle(color: Colors.grey)));
                _scrollToBottom();
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    bool isMe = messageData['senderId'] == _currentUserId;
                    Timestamp? ts = messageData['timestamp'] as Timestamp?;
                    return MessageBubble(
                      messageId: messages[index].id,
                      message: messageData['text'] ?? '',
                      isMe: isMe,
                      time: ts?.toDate(),
                      onDelete: isMe ? _deleteMessage : null,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: const BoxDecoration(color: kInputBackgroundColor, border: Border(top: BorderSide(color: Colors.black26, width: 0.5))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Mesaj yaz...', hintStyle: TextStyle(color: kHintTextColor), border: InputBorder.none),
                maxLines: 5,
                minLines: 1,
              ),
            ),
            IconButton(icon: Icon(Icons.send, color: _isSending ? Colors.grey : kSendButtonColor), onPressed: _isSending ? null : _sendMessage),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String messageId;
  final String message;
  final bool isMe;
  final DateTime? time;
  final Function(String)? onDelete;

  const MessageBubble({Key? key, required this.messageId, required this.message, required this.isMe, this.time, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String formattedTime = time != null ? DateFormat('HH:mm').format(time!) : '--:--';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe && onDelete != null) IconButton(icon: const Icon(Icons.delete_outline, color: kIconColor, size: 18), onPressed: () => onDelete!(messageId)),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: Material(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(isMe ? 18 : 4), topRight: Radius.circular(isMe ? 4 : 18), bottomLeft: const Radius.circular(18), bottomRight: const Radius.circular(18)),
                color: isMe ? kMyMessageBubbleColor : kOtherMessageBubbleColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(message, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(formattedTime, style: const TextStyle(color: kTimestampColor, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
