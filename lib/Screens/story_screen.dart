import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../rounded_button.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key? key}) : super(key: key);

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isTextRead = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    setState(() {
      _isTextRead = currentScroll >= maxScrollExtent;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Your Journey Begins..."),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Replace with your image asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay with opacity
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Content with SingleChildScrollView
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.black.withOpacity(0.8),
                      constraints: const BoxConstraints(maxHeight: 400), // Limit the height to 400
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Welcome, \nTask Adventurer!",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(fontSize: 18, color: Colors.white),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                    "In a realm where productivity meets adventure, you embark on a journey of personal growth and achievement. Our app empowers you to conquer your day by planning and tracking your tasks.\n\n",
                                  ),
                                  TextSpan(
                                    text:
                                    "Whether it's completing daily quests, vanquishing important goals, or leveling up your productivity, our app is your trusted ally in this grand adventure.\n\n",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                    "Stay motivated as you earn points for each completed task and witness your progress unfold like a map of victories.\n",
                                  ),
                                  TextSpan(
                                    text:
                                    "With our app, you can customize your tasks, mark them complete, and track your scores based on your achievements. Each task completed brings you closer to your ultimate goal, guiding you through a journey of self-improvement and accomplishment.",
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            RoundedButton(
                              btnText: "Begin Your Journey",
                              btnWidth: double.infinity, // Full width button
                              btnTextStyle: const TextStyle(fontSize: 18), // Increased font size
                              onBtnPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
