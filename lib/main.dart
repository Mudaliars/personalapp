import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  await notifications.initialize(const InitializationSettings(android: android));
  runApp(const PersonalApp());
}

class PersonalApp extends StatelessWidget {
  const PersonalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PersonalApp',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF070A12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      home: const HomeShell(),
    );
  }
}

class AppItem {
  AppItem({required this.id, required this.title, this.body = '', this.dateTime, this.done = false});
  final int id;
  String title;
  String body;
  DateTime? dateTime;
  bool done;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'dateTime': dateTime?.toIso8601String(),
        'done': done,
      };

  factory AppItem.fromJson(Map<String, dynamic> j) => AppItem(
        id: j['id'],
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        dateTime: j['dateTime'] == null ? null : DateTime.parse(j['dateTime']),
        done: j['done'] ?? false,
      );
}

class Store {
  static Future<List<AppItem>> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? [];
    return raw.map((e) => AppItem.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> save(String key, List<AppItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, items.map((e) => jsonEncode(e.toJson())).toList());
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  final titles = ['Notes', 'Reminders', 'Calendar'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const FuturisticBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Column(
                children: [
                  Header(title: titles[tab]),
                  const SizedBox(height: 18),
                  Expanded(
                    child: IndexedStack(
                      index: tab,
                      children: const [NotesPage(), RemindersPage(), CalendarPage()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: GlassNav(
            selected: tab,
            onChanged: (v) => setState(() => tab = v),
          ),
        ),
      ],
    );
  }
}

class FuturisticBackground extends StatelessWidget {
  const FuturisticBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.3,
          colors: [Color(0xFF24164F), Color(0xFF070A12), Color(0xFF03050A)],
        ),
      ),
      child: CustomPaint(painter: GridPainter(), size: Size.infinite),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 34) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Header extends StatelessWidget {
  const Header({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PERSONAL OS', style: TextStyle(letterSpacing: 3, color: Color(0xFF8EF9FF), fontSize: 11)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
        ]),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.12)),
            color: Colors.white.withOpacity(.06),
          ),
          child: const Icon(Icons.auto_awesome, color: Color(0xFF8EF9FF)),
        )
      ],
    );
  }
}

class Glass extends StatelessWidget {
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(.12)),
            color: Colors.white.withOpacity(.07),
          ),
          child: child,
        ),
      ),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<AppItem> notes = [];
  @override
  void initState() { super.initState(); Store.load('notes').then((v) => setState(() => notes = v)); }
  Future<void> persist() => Store.save('notes', notes);

  @override
  Widget build(BuildContext context) => ItemList(
        empty: 'No notes yet',
        items: notes,
        icon: Icons.notes,
        onAdd: () => openEditor(context, 'New note', false),
        onEdit: (i) => openEditor(context, 'Edit note', false, item: i),
        onDelete: (i) async { setState(() => notes.removeWhere((e) => e.id == i.id)); await persist(); },
      );

  Future<void> openEditor(BuildContext context, String title, bool withDate, {AppItem? item}) async {
    final result = await showItemEditor(context, title: title, item: item, withDate: withDate);
    if (result == null) return;
    setState(() {
      notes.removeWhere((e) => e.id == result.id);
      notes.insert(0, result);
    });
    await persist();
  }
}

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});
  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<AppItem> reminders = [];
  @override
  void initState() { super.initState(); Store.load('reminders').then((v) => setState(() => reminders = v)); }
  Future<void> persist() => Store.save('reminders', reminders);

  @override
  Widget build(BuildContext context) => ItemList(
        empty: 'No reminders yet',
        items: reminders..sort((a, b) => (a.dateTime ?? DateTime(2999)).compareTo(b.dateTime ?? DateTime(2999))),
        icon: Icons.notifications_active,
        onAdd: () => openEditor(context, 'New reminder', true),
        onEdit: (i) => openEditor(context, 'Edit reminder', true, item: i),
        onDelete: (i) async { setState(() => reminders.removeWhere((e) => e.id == i.id)); await notifications.cancel(i.id); await persist(); },
      );

  Future<void> openEditor(BuildContext context, String title, bool withDate, {AppItem? item}) async {
    final result = await showItemEditor(context, title: title, item: item, withDate: withDate);
    if (result == null) return;
    setState(() {
      reminders.removeWhere((e) => e.id == result.id);
      reminders.add(result);
    });
    await scheduleReminder(result);
    await persist();
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<AppItem> tasks = [];
  @override
  void initState() { super.initState(); Store.load('tasks').then((v) => setState(() => tasks = v)); }
  Future<void> persist() => Store.save('tasks', tasks);

  @override
  Widget build(BuildContext context) => Column(children: [
        Glass(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(DateFormat('EEE d').format(DateTime.now()), style: const TextStyle(color: Color(0xFF8EF9FF))),
          ]),
        ),
        const SizedBox(height: 14),
        Expanded(child: ItemList(
          empty: 'No calendar tasks yet',
          items: tasks..sort((a, b) => (a.dateTime ?? DateTime(2999)).compareTo(b.dateTime ?? DateTime(2999))),
          icon: Icons.event,
          onAdd: () => openEditor(context, 'New calendar task', true),
          onEdit: (i) => openEditor(context, 'Edit calendar task', true, item: i),
          onDelete: (i) async { setState(() => tasks.removeWhere((e) => e.id == i.id)); await persist(); },
        )),
      ]);

  Future<void> openEditor(BuildContext context, String title, bool withDate, {AppItem? item}) async {
    final result = await showItemEditor(context, title: title, item: item, withDate: withDate);
    if (result == null) return;
    setState(() {
      tasks.removeWhere((e) => e.id == result.id);
      tasks.add(result);
    });
    await persist();
  }
}

class ItemList extends StatelessWidget {
  const ItemList({super.key, required this.items, required this.onAdd, required this.onEdit, required this.onDelete, required this.empty, required this.icon});
  final List<AppItem> items;
  final VoidCallback onAdd;
  final void Function(AppItem) onEdit;
  final void Function(AppItem) onDelete;
  final String empty;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      items.isEmpty
          ? Center(child: Text(empty, style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 16)))
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 86),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, idx) {
                final item = items[idx];
                return Glass(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: const Color(0xFF7C5CFF).withOpacity(.25)),
                      child: Icon(icon, color: const Color(0xFF8EF9FF)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: GestureDetector(
                      onTap: () => onEdit(item),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        if (item.body.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text(item.body, style: TextStyle(color: Colors.white.withOpacity(.7)))),
                        if (item.dateTime != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat('EEE, d MMM • HH:mm').format(item.dateTime!), style: const TextStyle(color: Color(0xFF8EF9FF), fontSize: 12))),
                      ]),
                    )),
                    IconButton(onPressed: () => onDelete(item), icon: Icon(Icons.delete_outline, color: Colors.white.withOpacity(.55))),
                  ]),
                );
              },
            ),
      Positioned(
        right: 4,
        bottom: 14,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF8EF9FF),
          foregroundColor: const Color(0xFF061018),
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ),
    ]);
  }
}

class GlassNav extends StatelessWidget {
  const GlassNav({super.key, required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    final items = [Icons.notes, Icons.alarm, Icons.calendar_month];
    final labels = ['Notes', 'Remind', 'Calendar'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Glass(
        padding: const EdgeInsets.all(8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: List.generate(3, (i) {
          final active = selected == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: active ? const Color(0xFF7C5CFF).withOpacity(.45) : Colors.transparent),
              child: Row(children: [Icon(items[i], color: active ? const Color(0xFF8EF9FF) : Colors.white60), if (active) ...[const SizedBox(width: 8), Text(labels[i], style: const TextStyle(fontWeight: FontWeight.bold))]]),
            ),
          );
        })),
      ),
    );
  }
}

Future<AppItem?> showItemEditor(BuildContext context, {required String title, AppItem? item, required bool withDate}) async {
  final titleCtrl = TextEditingController(text: item?.title ?? '');
  final bodyCtrl = TextEditingController(text: item?.body ?? '');
  DateTime selected = item?.dateTime ?? DateTime.now().add(const Duration(hours: 1));
  return showModalBottomSheet<AppItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(builder: (context, setModal) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Glass(
        padding: const EdgeInsets.all(22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: bodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Details', border: OutlineInputBorder())),
          if (withDate) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, color: Color(0xFF8EF9FF)),
              title: Text(DateFormat('EEE, d MMM yyyy • HH:mm').format(selected)),
              onTap: () async {
                final d = await showDatePicker(context: context, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime(2100), initialDate: selected);
                if (d == null) return;
                final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selected));
                if (t == null) return;
                setModal(() => selected = DateTime(d.year, d.month, d.day, t.hour, t.minute));
              },
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                Navigator.pop(context, AppItem(
                  id: item?.id ?? DateTime.now().millisecondsSinceEpoch.remainder(1000000000),
                  title: titleCtrl.text.trim(),
                  body: bodyCtrl.text.trim(),
                  dateTime: withDate ? selected : null,
                ));
              },
              child: const Padding(padding: EdgeInsets.all(14), child: Text('Save')),
            ),
          ),
        ]),
      ),
    )),
  );
}

Future<void> scheduleReminder(AppItem item) async {
  if (item.dateTime == null || item.dateTime!.isBefore(DateTime.now())) return;
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'personalapp_reminders',
      'PersonalApp Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );
  await notifications.zonedSchedule(
    item.id,
    item.title,
    item.body.isEmpty ? 'Reminder' : item.body,
    tz.TZDateTime.from(item.dateTime!, tz.local),
    details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
