import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class StoryViewerPage extends StatefulWidget {
  final List<QueryDocumentSnapshot> stories;
  final int initialIndex;

  const StoryViewerPage({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  Timer? _storyTimer;
  final int _storyDuration = 5; // seconds

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      duration: Duration(seconds: _storyDuration),
      vsync: this,
    );
    _startStoryTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _storyTimer?.cancel();
    super.dispose();
  }

  void _startStoryTimer() {
    _storyTimer?.cancel();
    _progressController.reset();
    _progressController.forward();

    _storyTimer = Timer(Duration(seconds: _storyDuration), () {
      _nextStory();
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _currentIndex++;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _startStoryTimer();
    }
  }

  void _onTap(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tapX = details.globalPosition.dx;

    if (tapX < screenWidth * 0.3) {
      // Tapped left side - previous story
      _previousStory();
    } else if (tapX > screenWidth * 0.7) {
      // Tapped right side - next story
      _nextStory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapDown: _onTap,
          child: Stack(
            children: [
              // Story content
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _startStoryTimer();
                },
                itemCount: widget.stories.length,
                itemBuilder: (context, index) {
                  final storyData = widget.stories[index].data() as Map<String, dynamic>;
                  return _buildStoryContent(storyData);
                },
              ),

              // Progress bars
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: List.generate(
                    widget.stories.length,
                        (index) => Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.symmetric(horizontal: 1),
                        child: LinearProgressIndicator(
                          value: index < _currentIndex
                              ? 1.0
                              : index == _currentIndex
                              ? _progressController.value
                              : 0.0,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Header with user info
              Positioned(
                top: 35,
                left: 16,
                right: 16,
                child: _buildHeader(),
              ),

              // Close button
              Positioned(
                top: 35,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (widget.stories.isEmpty) return SizedBox.shrink();

    final currentStoryData = widget.stories[_currentIndex].data() as Map<String, dynamic>;
    final userName = currentStoryData['name'] ?? 'Unknown';
    final profileUrl = currentStoryData['profileUrl'] ?? '';
    final timestamp = currentStoryData['timestamp'] as Timestamp?;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipOval(
            child: profileUrl.isNotEmpty
                ? Image.memory(
              base64Decode(profileUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                );
              },
            )
                : Container(
              color: Colors.grey,
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              if (timestamp != null)
                Text(
                  _formatTimeAgo(timestamp.toDate()),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryContent(Map<String, dynamic> storyData) {
    final storyImage = storyData['storyImage'] ?? '';

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: storyImage.isNotEmpty
          ? Image.memory(
        base64Decode(storyImage),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: 50,
              ),
            ),
          );
        },
      )
          : Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(
            Icons.image,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}