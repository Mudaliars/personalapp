import 'package:flutter/material.dart';

void main() {
  runApp(const PersonalApp());
}

class PersonalApp extends StatelessWidget {
  const PersonalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PersonalApp',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF05070F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<NoteItem> notes = [
    NoteItem('Launch checklist', 'Review APK build, test screens, refine UI.'),
    NoteItem('Buzars idea', 'AI audience intelligence SaaS for Meta and Google Ads.'),
  ];

  final List<ReminderItem> reminders = [
    ReminderItem('Check GitHub build', 'Today', 'Download APK artifact when complete.'),
    ReminderItem('Plan MVP', 'Tomorrow', 'Define first features and dashboard flow.'),
  ];

  final List<TaskItem> tasks = [
    TaskItem('Today', 'Test PersonalApp on phone'),
    TaskItem('This week', 'Add real notifications'),
    TaskItem('This month', 'Connect cloud sync'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      NotesPage(notes: notes, onAdd: _addNote),
      RemindersPage(reminders: reminders, onAdd: _addReminder),
      CalendarPage(tasks: tasks, onAdd: _addTask),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.3,
            colors: [Color(0xFF19234D), Color(0xFF05070F), Color(0xFF02030A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Header(),
              FuturisticTabs(
                selectedIndex: selectedIndex,
                onSelected: (index) => setState(() => selectedIndex = index),
              ),
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        ),
      ),
    );
  }

  void _addNote() async {
    final result = await showInputSheet(
      context,
      title: 'New note',
      firstLabel: 'Title',
      secondLabel: 'Note',
    );
    if (result != null) {
      setState(() => notes.insert(0, NoteItem(result.$1, result.$2)));
    }
  }

  void _addReminder() async {
    final result = await showInputSheet(
      context,
      title: 'New reminder',
      firstLabel: 'Reminder',
      secondLabel: 'Details',
    );
    if (result != null) {
      setState(() => reminders.insert(0, ReminderItem(result.$1, 'Soon', result.$2)));
    }
  }

  void _addTask() async {
    final result = await showInputSheet(
      context,
      title: 'New calendar task',
      firstLabel: 'When',
      secondLabel: 'Task',
    );
    if (result != null) {
      setState(() => tasks.insert(0, TaskItem(result.$1, result.$2)));
    }
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFF00D4FF)]),
              boxShadow: const [BoxShadow(color: Color(0x667C5CFF), blurRadius: 24)],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PersonalApp', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text('Notes, reminders, calendar', style: TextStyle(color: Color(0xFF98A2B3), fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x334DEBFF)),
              color: const Color(0x1417F3FF),
            ),
            child: const Text('SYNC OFF', style: TextStyle(fontSize: 11, letterSpacing: 1.2, color: Color(0xFF76E4F7))),
          ),
        ],
      ),
    );
  }
}

class FuturisticTabs extends StatelessWidget {
  const FuturisticTabs({super.key, required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('Notes', Icons.edit_note),
      ('Reminders', Icons.notifications_none),
      ('Calendar', Icons.calendar_month),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0x22141A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x1FFFFFFF)),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: selected
                        ? const LinearGradient(colors: [Color(0xFF7C5CFF), Color(0xFF00D4FF)])
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tabs[index].$2, size: 18, color: selected ? Colors.white : const Color(0xFF98A2B3)),
                      const SizedBox(width: 7),
                      Text(tabs[index].$1, style: TextStyle(color: selected ? Colors.white : const Color(0xFF98A2B3), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class NotesPage extends StatelessWidget {
  const NotesPage({super.key, required this.notes, required this.onAdd});
  final List<NoteItem> notes;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => ItemList(
        title: 'Neural notes',
        buttonText: 'Add note',
        onAdd: onAdd,
        children: notes.map((n) => GlassCard(title: n.title, subtitle: n.body, icon: Icons.notes)).toList(),
      );
}

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key, required this.reminders, required this.onAdd});
  final List<ReminderItem> reminders;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => ItemList(
        title: 'Reminder matrix',
        buttonText: 'Add reminder',
        onAdd: onAdd,
        children: reminders.map((r) => GlassCard(title: r.title, subtitle: '${r.time} - ${r.details}', icon: Icons.bolt)).toList(),
      );
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key, required this.tasks, required this.onAdd});
  final List<TaskItem> tasks;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => ItemList(
        title: 'Calendar stream',
        buttonText: 'Add task',
        onAdd: onAdd,
        children: tasks.map((t) => GlassCard(title: t.date, subtitle: t.task, icon: Icons.event_available)).toList(),
      );
}

class ItemList extends StatelessWidget {
  const ItemList({super.key, required this.title, required this.buttonText, required this.onAdd, required this.children});
  final String title;
  final String buttonText;
  final VoidCallback onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
              FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text(buttonText)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => children[index],
            ),
          ),
        ],
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0x181D2438),
        border: Border.all(color: const Color(0x22FFFFFF)),
        boxShadow: const [BoxShadow(color: Color(0x3300D4FF), blurRadius: 22, offset: Offset(0, 12))],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0x1F00D4FF),
            ),
            child: Icon(icon, color: const Color(0xFF76E4F7)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Color(0xFFB8C0CC), height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<(String, String)?> showInputSheet(
  BuildContext context, {
  required String title,
  required String firstLabel,
  required String secondLabel,
}) async {
  final first = TextEditingController();
  final second = TextEditingController();
  return showModalBottomSheet<(String, String)>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0B1020),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(22, 22, 22, MediaQuery.of(context).viewInsets.bottom + 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: first, decoration: InputDecoration(labelText: firstLabel, border: const OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: second, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: secondLabel, border: const OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final a = first.text.trim();
                  final b = second.text.trim();
                  if (a.isNotEmpty && b.isNotEmpty) Navigator.pop(context, (a, b));
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class NoteItem {
  NoteItem(this.title, this.body);
  final String title;
  final String body;
}

class ReminderItem {
  ReminderItem(this.title, this.time, this.details);
  final String title;
  final String time;
  final String details;
}

class TaskItem {
  TaskItem(this.date, this.task);
  final String date;
  final String task;
}
