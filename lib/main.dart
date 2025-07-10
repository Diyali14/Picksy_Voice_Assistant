import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';

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
        primaryColor: const Color(0xFF043CB4),
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
    "How can I help you?",
    "You ask, We deliver",
    "Ask away",
    "Want it, Get it...",
    "Ready to Buy?",
    "Go on, treat yourself...",
    "Let's do some shopping",
    "Need help? I'm listening",
    "Your comfort, our promise",
    "What's on your mind today?",
    "Spot it, Get it",
  ];
  int _promptIndex = 0;
  late FlutterTts flutterTts;
  bool _hasLaunchedFlipkart = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    flutterTts = FlutterTts();
  }

  void _listen() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == 'done') {
          setState(() => _isListening = false);
          _processCommand(_text);
        }
      },
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
        //partialResults: false,
      );
    }
  }

  void _speak(String text) async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.speak(text);
  }

  void _processCommand(String command) async {
    command = command.toLowerCase();

    if (command.contains("open walmart")) {
      if (_hasLaunchedFlipkart) {
        _speak("Opening Walmart for you.");
        return;
      }

      _hasLaunchedFlipkart = true;

      bool isInstalled = await DeviceApps.isAppInstalled("com.walmart.android");
      if (isInstalled) {
        DeviceApps.openApp("com.walmart.android");
        _speak("Opening Walmart for you");
      } else {
        _speak("Walmart is not installed. Opening in browser.");
        final Uri walmartUrl = Uri.parse("https://www.walmart.com");
        if (await canLaunchUrl(walmartUrl)) {
          await launchUrl(walmartUrl, mode: LaunchMode.externalApplication);
        } else {
          _speak("Can't open Walmart right now.");
        }
      }
    } else if (command.contains("stop") || command.contains("thank you")) {
      _speak("Pixi signing off, see you soon!");
      setState(() => _isListening = false);
      _speech.stop();
    } else if (command.contains("search")) {
      final query = command.replaceFirst("search", "").trim();
      if (query.isNotEmpty) {
        final Uri searchUrl = Uri.parse(
          "https://www.flipkart.com/search?q=$query",
        );
        _speak("Searching $query on Flipkart");
        if (await canLaunchUrl(searchUrl)) {
          await launchUrl(searchUrl, mode: LaunchMode.externalApplication);
        } else {
          _speak("Could not launch search");
        }
      } else {
        _speak("Please say what you want to search for");
      }
    } else {
      _speak("I didn't understand. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picksy', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF083DA0),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
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
                setState(() => _promptIndex++);
              },
              child: CircleAvatar(
                radius: 80,
                backgroundColor: const Color.fromARGB(255, 25, 3, 85),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF024BBF), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _text.isEmpty ? 'Say it...' : _text,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
