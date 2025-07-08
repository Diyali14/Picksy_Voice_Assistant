import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const PixiApp());
}

class PixiApp extends StatelessWidget {
  const PixiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixi',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF0071CE),
      ),
      home: const PixiHomePage(),
    );
  }
}

class PixiHomePage extends StatefulWidget {
  const PixiHomePage({super.key});

  @override
  State<PixiHomePage> createState() => _PixiHomePageState();
}

class _PixiHomePageState extends State<PixiHomePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Say something...';
  final List<String> _prompts = [
    "Go on, treat yourself",
    "How can I help you?",
    "What’s on your mind today?",
  ];
  int _promptIndex = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pixi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0071CE),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _prompts[_promptIndex % _prompts.length],
                key: ValueKey<int>(_promptIndex),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0071CE),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () {
                _listen();
                setState(() {
                  _promptIndex++;
                });
              },
              child: CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF0071CE),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0071CE), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _text.isEmpty ? 'Say something...' : _text,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
