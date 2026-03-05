import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IslamicAIApp());
}

class IslamicAIApp extends StatelessWidget {
  const IslamicAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const IslamicChatScreen(),
    );
  }
}

class IslamicChatScreen extends StatefulWidget {
  const IslamicChatScreen({super.key});

  @override
  State<IslamicChatScreen> createState() => _IslamicChatScreenState();
}

class _IslamicChatScreenState extends State<IslamicChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isSending = false;
  String _activeTab = 'Quran';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  final String apiKey = "AIzaSyDHv6OYSeFDf6bWgnKVJHtC8qS3UxbNrGA";

  final List<String> _topics = [
    'Quran & Tafsir',
    'Salah & Worship',
    'Islamic Calendar',
    'Hadith & Sunnah',
  ];
  final List<String> _recentChats = [
    'Meaning of Surah Al-Fatiha',
    '5 Pillars of Islam',
    'Ramadan fasting rules',
    'Dua before sleeping',
    'Halal food guide',
  ];
  final List<String> _tabs = ['Quran', 'Hadith', 'Prayer', 'Fiqh'];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      systemInstruction: Content.system(
        "You are an expert Islamic AI Assistant. Your goal is to provide accurate answers based on the Holy Quran and Sahih Hadith.\n\nAlways provide answers in clear bullet points.\n\nLeave one line of space between each point for better readability.\n\nUse bold formatting (**) for key terms and headers.\n\nEnsure all Bengali text is rendered clearly.\n\nIf a reference is available, always cite the Surah, Ayah, or Hadith number.",
      ),
    );
    _chatSession = _model.startChat();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));
      setState(() {
        _messages.add({
          "role": "ai",
          "text": response.text ?? "দুঃখিত, আমি বুঝতে পারিনি।",
        });
      });
    } on GenerativeAIException catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "এআই ত্রুটি: ${e.message}"});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "ত্রুটি: $e"});
      });
    } finally {
      setState(() {
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1a1a1a),
                border: Border(
                  right: BorderSide(color: Colors.teal.withOpacity(0.3)),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Noor',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        Text(
                          'ISLAMIC ASSISTANT',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() {
                          _messages.clear();
                          _activeTab = 'Quran';
                        }),
                        icon: Icon(Icons.add, size: 18),
                        label: Text('New Conversation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'RECENT CHATS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _recentChats.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            _recentChats[index],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'TOPICS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: _topics
                          .map(
                            (topic) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.book, size: 16),
                                label: Text(
                                  topic,
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            'K',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Konok',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Free Plan - Jamialpur, BD',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0f0f0f),
                    border: Border(
                      bottom: BorderSide(color: Colors.teal.withOpacity(0.2)),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Islamic',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              Text(
                                '✨ AI',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Assistant',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _tabs
                              .map(
                                (tab) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: FilterChip(
                                    label: Text(tab),
                                    selected: _activeTab == tab,
                                    onSelected: (selected) =>
                                        setState(() => _activeTab = tab),
                                    backgroundColor: Colors.transparent,
                                    selectedColor: Colors.teal.withOpacity(0.3),
                                    side: BorderSide(
                                      color: _activeTab == tab
                                          ? Colors.amber
                                          : Colors.grey[700]!,
                                    ),
                                    labelStyle: TextStyle(
                                      color: _activeTab == tab
                                          ? Colors.amber
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('🌙', style: TextStyle(fontSize: 80)),
                              SizedBox(height: 20),
                              Text(
                                'بسم الله الرحمن الرحيم',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Assalamu Alaikum,\nKonok!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          itemCount: _messages.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isUser = msg["role"] == "user";
                            return _buildMessageBubble(msg["text"]!, isUser);
                          },
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0f0f0f),
                    border: Border(
                      top: BorderSide(color: Colors.teal.withOpacity(0.2)),
                    ),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (_messages.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                [
                                      '99 Names of Allah',
                                      'Dua for anxiety',
                                      'Islamic finance',
                                      'Signs of Qiyamah',
                                    ]
                                    .map(
                                      (text) => GestureDetector(
                                        onTap: () {
                                          _controller.text = text;
                                          _sendMessage();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey[700]!,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.teal.withOpacity(0.3),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: _controller,
                                onSubmitted: (_) => _sendMessage(),
                                decoration: InputDecoration(
                                  hintText: 'Ask about Quran...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (_isSending)
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: IconButton(
                                icon: Icon(Icons.send, color: Colors.white),
                                onPressed: _sendMessage,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!isUser)
          CircleAvatar(
            backgroundColor: Colors.teal.withOpacity(0.3),
            child: Icon(Icons.smart_toy, size: 18),
          ),
        SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Colors.teal.withOpacity(0.2) : Colors.grey[900],
              border: Border.all(
                color: isUser
                    ? Colors.teal.withOpacity(0.5)
                    : Colors.grey[800]!,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(color: Colors.white),
                strong: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                em: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
                h1: TextStyle(
                  color: Colors.amber,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                h2: TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                h3: TextStyle(
                  color: Colors.teal[200],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                listBullet: TextStyle(color: Colors.white),
                blockquote: TextStyle(
                  color: Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        if (isUser)
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, size: 18),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
