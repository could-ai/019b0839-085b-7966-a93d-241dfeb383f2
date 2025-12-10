import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gratitude_entry.dart';
import '../services/gratitude_service.dart';

class GratitudeHomeScreen extends StatefulWidget {
  const GratitudeHomeScreen({super.key});

  @override
  State<GratitudeHomeScreen> createState() => _GratitudeHomeScreenState();
}

class _GratitudeHomeScreenState extends State<GratitudeHomeScreen> {
  final GratitudeService _service = GratitudeService();
  final TextEditingController _textController = TextEditingController();
  
  List<GratitudeEntry> _entries = [];
  String _view = 'today'; // 'today' or 'history'
  int _streak = 0;
  bool _isLoading = true;

  final List<String> _prompts = [
    "What made you smile today?",
    "Who are you grateful for and why?",
    "What's something beautiful you noticed?",
    "What challenge helped you grow?",
    "What comfort or luxury do you appreciate?"
  ];
  late String _currentPrompt;

  @override
  void initState() {
    super.initState();
    _currentPrompt = _prompts[DateTime.now().millisecondsSinceEpoch % _prompts.length];
    _loadData();
  }

  Future<void> _loadData() async {
    final entries = await _service.loadEntries();
    setState(() {
      _entries = entries;
      _streak = _service.calculateStreak(entries);
      _isLoading = false;
    });
  }

  Future<void> _addEntry() async {
    if (_textController.text.trim().isEmpty) return;

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    final newEntry = GratitudeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _textController.text.trim(),
      date: todayDate,
      timestamp: now,
    );

    final updatedEntries = [..._entries, newEntry];
    await _service.saveEntries(updatedEntries);

    setState(() {
      _entries = updatedEntries;
      _streak = _service.calculateStreak(updatedEntries);
      _textController.clear();
      // Rotate prompt after answering
      _currentPrompt = _prompts[DateTime.now().millisecondsSinceEpoch % _prompts.length];
    });
  }

  void _deleteEntry(String id) async {
    final updatedEntries = _entries.where((e) => e.id != id).toList();
    await _service.saveEntries(updatedEntries);
    setState(() {
      _entries = updatedEntries;
      _streak = _service.calculateStreak(updatedEntries);
    });
  }

  List<GratitudeEntry> _getTodayEntries() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    return _entries.where((e) => e.date.isAtSameMomentAs(todayDate)).toList();
  }

  List<GratitudeEntry> _getWeekEntries() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _entries.where((e) => e.date.isAfter(weekAgo)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF1F2), // rose-50
              Color(0xFFFDF2F8), // pink-50
              Color(0xFFFAF5FF), // purple-50
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildStatsCards(),
                      const SizedBox(height: 32),
                      _buildViewToggle(),
                      const SizedBox(height: 24),
                      if (_view == 'today') _buildInputSection(),
                      const SizedBox(height: 24),
                      _buildEntriesList(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Color(0xFFF43F5E), size: 32), // rose-500
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFE11D48), Color(0xFF9333EA)], // rose-600 to purple-600
              ).createShader(bounds),
              child: const Text(
                'Daily Gratitude',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Required for ShaderMask
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Cultivate joy and appreciation through daily reflection',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid logic
        final isWide = constraints.maxWidth > 600;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _buildStatCard(
              icon: Icons.calendar_today,
              iconColor: const Color(0xFFE11D48), // rose-600
              bgColor: const Color(0xFFFFE4E6), // rose-100
              label: 'Current Streak',
              value: '$_streak days',
              borderColor: const Color(0xFFFFE4E6),
              width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
            ),
            _buildStatCard(
              icon: Icons.trending_up,
              iconColor: const Color(0xFF9333EA), // purple-600
              bgColor: const Color(0xFFF3E8FF), // purple-100
              label: 'Total Entries',
              value: '${_entries.length}',
              borderColor: const Color(0xFFF3E8FF),
              width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
            ),
            _buildStatCard(
              icon: Icons.auto_awesome,
              iconColor: const Color(0xFFDB2777), // pink-600
              bgColor: const Color(0xFFFCE7F3), // pink-100
              label: 'This Week',
              value: '${_getWeekEntries().length}',
              borderColor: const Color(0xFFFCE7F3),
              width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
    required Color borderColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              Text(
                value,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        _buildToggleButton('Today', 'today'),
        const SizedBox(width: 12),
        _buildToggleButton('History', 'history'),
      ],
    );
  }

  Widget _buildToggleButton(String label, String viewKey) {
    final isSelected = _view == viewKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _view = viewKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF43F5E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFF43F5E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentPrompt,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "I'm grateful for...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addEntry,
              icon: const Icon(Icons.add),
              label: const Text('Add to Journal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    final displayEntries = _view == 'today' ? _getTodayEntries() : _entries.reversed.toList();

    if (displayEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.edit_note, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                _view == 'today' 
                  ? "No entries yet today. Start by adding one!" 
                  : "Your journal is empty.",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = displayEntries[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite, size: 16, color: Color(0xFFF43F5E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.text,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM d, y • h:mm a').format(entry.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                onPressed: () => _deleteEntry(entry.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }
}
