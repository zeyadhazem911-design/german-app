import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() => runApp(const App());

class W {
  final String de, ar;
  const W(this.de, this.ar);
}

class L {
  final String title, body;
  const L(this.title, this.body);
}

const words = <String, List<W>>{
  'A1': [
    W('Hallo', 'مرحبا'), W('Danke', 'شكرا'), W('Bitte', 'من فضلك'),
    W('Ja', 'نعم'), W('Nein', 'لا'), W('Wasser', 'ماء'),
    W('Brot', 'خبز'), W('Haus', 'بيت'), W('Guten Morgen', 'صباح الخير'),
    W('Tschüss', 'مع السلامة'),
  ],
  'A2': [
    W('Bahnhof', 'محطة القطار'), W('Arbeit', 'عمل'), W('Freund', 'صديق'),
    W('Zeit', 'وقت'), W('kaufen', 'يشتري'), W('Wohnung', 'شقة'),
    W('Wetter', 'طقس'), W('Reise', 'رحلة'),
  ],
  'B1': [
    W('Erfahrung', 'خبرة'), W('Entscheidung', 'قرار'),
    W('Gesellschaft', 'مجتمع'), W('Umwelt', 'بيئة'),
    W('vergleichen', 'يقارن'), W('Verantwortung', 'مسؤولية'),
    W('Möglichkeit', 'إمكانية'), W('Beruf', 'مهنة'),
  ],
};

const lessons = <String, List<L>>{
  'A1': [
    L('أدوات التعريف: der / die / das',
        'كل اسم في الألمانية له جنس:\n• der للمذكر: der Mann (الرجل)\n• die للمؤنث: die Frau (المرأة)\n• das للمحايد: das Kind (الطفل)\nانطق الاسم دايماً مع أداته وإنت بتحفظه.'),
    L('التعريف بالنفس',
        'Ich heiße Ali. = اسمي علي.\nIch komme aus Ägypten. = أنا من مصر.\nIch bin 25 Jahre alt. = عمري 25 سنة.'),
  ],
  'A2': [
    L('الماضي التام (Perfekt)',
        'يتكوّن من haben/sein + التصريف الثالث للفعل:\nIch habe Brot gekauft. = اشتريت خبزاً.\nIch bin nach Berlin gefahren. = سافرت إلى برلين.'),
  ],
  'B1': [
    L('الجملة الفرعية مع weil',
        'بعد weil يروح الفعل في آخر الجملة:\nIch lerne Deutsch, weil ich in Deutschland arbeiten möchte.\n= أتعلم الألمانية لأني أريد العمل في ألمانيا.'),
  ],
};

final tts = FlutterTts();
Future<void> speak(String t) async {
  await tts.setLanguage('de-DE');
  await tts.speak(t);
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
        title: 'تعلّم الألمانية',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        builder: (c, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
        home: const Home(),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String lv = 'A1';
  int tab = 0;
  @override
  Widget build(BuildContext c) {
    final ws = words[lv]!;
    final pages = <Widget>[
      Lessons(lessons[lv] ?? const []),
      Cards(key: ValueKey('c$lv'), ws: ws),
      Quiz(key: ValueKey('q$lv'), ws: ws),
      Quiz(key: ValueKey('g$lv'), ws: ws, timed: true),
      const Connect(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعلّم الألمانية'),
        actions: [
          DropdownButton<String>(
            value: lv,
            underline: const SizedBox(),
            items: words.keys
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) => setState(() => lv = v!),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'دروس'),
          NavigationDestination(icon: Icon(Icons.style), label: 'بطاقات'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'اختبار'),
          NavigationDestination(icon: Icon(Icons.sports_esports), label: 'لعبة'),
          NavigationDestination(icon: Icon(Icons.forum), label: 'تواصل'),
        ],
      ),
    );
  }
}

class Lessons extends StatelessWidget {
  final List<L> ls;
  const Lessons(this.ls, {super.key});
  @override
  Widget build(BuildContext c) => ls.isEmpty
      ? const Center(child: Text('دروس هذا المستوى قريباً'))
      : ListView(
          padding: const EdgeInsets.all(12),
          children: ls
              .map((l) => Card(
                    child: ExpansionTile(
                      title: Text(l.title),
                      childrenPadding: const EdgeInsets.all(16),
                      children: [
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(l.body,
                                style: const TextStyle(fontSize: 16, height: 1.6)))
                      ],
                    ),
                  ))
              .toList(),
        );
}

class Cards extends StatefulWidget {
  final List<W> ws;
  const Cards({super.key, required this.ws});
  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  int i = 0;
  bool flip = false;
  @override
  Widget build(BuildContext c) {
    final w = widget.ws[i];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Text('${i + 1} / ${widget.ws.length}'),
        const SizedBox(height: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => flip = !flip),
            child: Card(
              color: flip
                  ? Theme.of(c).colorScheme.secondaryContainer
                  : Theme.of(c).colorScheme.primaryContainer,
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(flip ? w.ar : w.de,
                      style: const TextStyle(
                          fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(flip ? '' : 'اضغط لعرض المعنى'),
                  if (!flip)
                    IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => speak(w.de)),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          FilledButton.tonal(
              onPressed: i > 0 ? () => setState(() { i--; flip = false; }) : null,
              child: const Text('السابق')),
          FilledButton(
              onPressed: i < widget.ws.length - 1
                  ? () => setState(() { i++; flip = false; })
                  : null,
              child: const Text('التالي')),
        ]),
      ]),
    );
  }
}

class Quiz extends StatefulWidget {
  final List<W> ws;
  final bool timed;
  const Quiz({super.key, required this.ws, this.timed = false});
  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final r = Random();
  late W cur;
  late List<String> opts;
  int score = 0, n = 0, left = 30;
  bool done = false;
  String? picked;
  Timer? t;

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  void start() {
    score = 0; n = 0; left = 30; done = false;
    next();
    t?.cancel();
    if (widget.timed) {
      t = Timer.periodic(const Duration(seconds: 1), (_) {
        if (left <= 1) {
          t?.cancel();
          setState(() => done = true);
        } else {
          setState(() => left--);
        }
      });
    }
  }

  void next() {
    cur = widget.ws[r.nextInt(widget.ws.length)];
    final o = widget.ws.where((w) => w != cur).map((w) => w.ar).toList()..shuffle();
    opts = [cur.ar, ...o.take(3)]..shuffle();
    picked = null;
  }

  void pick(String a) {
    if (picked != null || done) return;
    setState(() {
      picked = a;
      n++;
      if (a == cur.ar) score++;
    });
    speak(cur.de);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (!widget.timed && n >= 8) {
        setState(() => done = true);
      } else {
        setState(next);
      }
    });
  }

  @override
  Widget build(BuildContext c) {
    if (done) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.emoji_events, size: 72, color: Colors.amber),
          Text('النتيجة: $score / $n', style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => setState(start), child: const Text('العب تاني')),
        ]),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Text(widget.timed ? '⏱ $left ث   |   النقاط: $score' : 'سؤال ${n + 1} / 8   |   النقاط: $score'),
        const SizedBox(height: 24),
        const Text('إيه معنى:'),
        Text(cur.de, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ...opts.map((o) {
          Color? col;
          if (picked != null) {
            if (o == cur.ar) col = Colors.green.shade200;
            else if (o == picked) col = Colors.red.shade200;
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                    backgroundColor: col, padding: const EdgeInsets.all(16)),
                onPressed: () => pick(o),
                child: Text(o, style: const TextStyle(fontSize: 18)),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

class Connect extends StatelessWidget {
  const Connect({super.key});
  @override
  Widget build(BuildContext c) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.people, size: 72),
            const SizedBox(height: 12),
            const Text('تدرّب على الكلام مع متعلمين زيك',
                style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('الميزة دي محتاجة سيرفر (Firebase) وهتتفعّل في الخطوة الجاية.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ScaffoldMessenger.of(c)
                  .showSnackBar(const SnackBar(content: Text('قريباً'))),
              child: const Text('ابحث عن شريك محادثة'),
            ),
          ]),
        ),
      );
}
