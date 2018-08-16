import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Eat sleep poop',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Eat Sleep Poop'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  _MyHomePageState() {
    readNotes().then((val) {
      setState(() {
        //print(val);
        _notes = val;
        _prevNote = _notes.last;
      });
    });
  }

  List<Note> _notes = new List<Note>();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes.json');
  }

  Future<File> writeNotes() async {
    final file = await _localFile;

    String notesList = json.encode(_notes);

    print(notesList);

    return file.writeAsString(notesList);
  }

  Future<List<Note>> readNotes() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      //print("Contents: $contents");

      List<dynamic> notesDecoded = json.decode(contents);
      //print("notesDecoded: $notesDecoded.length");

      List<Note> notesList = new List<Note>();

      Iterator i = notesDecoded.iterator;
      while (i.moveNext()) {
        //print(i.current);
        notesList.add(Note.fromJson(i.current));
      }

      return notesList;
    } catch (e) {
      print(e);
      return new List<Note>();
    }
  }

  Note _prevNote;

  List<Widget> buildNotes() {
    List<Widget> widgets = new List<Widget>();
    for (var i = 0; i < _notes.length; i++) {
      widgets.add(new Entry(_notes[i]));
    }

    return widgets;
  }

  void _addNote(NoteType type) {
    if(_prevNote != null) {
      print("ERROR! _addNote was called but _endNote must not have been called");
    }

    setState(() {
      _prevNote = new Note(new DateTime.now().toString());
      _prevNote.setType(type);
    });

    _notes.add(_prevNote);

    writeNotes();
  }

  void _endNote(double value) {
    setState(() {
      _prevNote.amount = value;

      DateTime time = new DateTime.now();
      _prevNote.endTime = time.toString();
    });

    _prevNote = null;

    writeNotes();
  }

  List<Widget> getButtons() {
    List<Widget> widgets = new List<Widget>();

    if(_prevNote == null) {
      widgets.add(new RaisedButton(onPressed: () {
        _addNote(NoteType.eat);
      },
        child: new Text('Eating started'),
      ));

      widgets.add(new RaisedButton(onPressed: () {
        _addNote(NoteType.sleep);
      },
        child: new Text('Sleeping started'),
      ));
    } else if (_prevNote.getType() == NoteType.eat) {
      widgets.add(new RaisedButton(onPressed: () {
        _foobar();
      },
        child: new Text('Eating ended'),
      ));
    } else if (_prevNote.getType() == NoteType.sleep) {
      widgets.add(new RaisedButton(onPressed: () {
        Duration dur = DateTime.now().difference(_prevNote.getBeginTime());
        print("duration " + dur.inSeconds.toString());
        _endNote(dur.inMinutes.toDouble());
      },
        child: new Text('Sleeping ended'),
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new ListView(
              children: buildNotes(),
            )
          ),
          new Container(
            color: Colors.blueGrey,
            height: 100.0,
            child: new ButtonBar(
              alignment: MainAxisAlignment.center,
              children: getButtons(),
            )
          )
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future _foobar() async {
    await showDialog(
      context: context,
      child: new SimpleDialog(
        title: const Text('Ounces of milk'),
        children: <Widget>[
          new DialogEntry()
        ],
      )
    ).then((data) {
      if(data > 0) {
      _endNote(data);
      }
    });
  }
}

class DialogEntry extends StatefulWidget {
  DialogEntry({Key key}) : super(key: key);

  @override
  _DialogEntryState createState() => new _DialogEntryState();
}

class _DialogEntryState extends State<DialogEntry> {
  double _ounces = 3.0;
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
      new Slider(
        value: _ounces,
        onChanged: (val) {
          setState(() => _ounces = val);
        },
        min: 0.5,
        max: 10.0,
        divisions: 19,
      ),
      new ButtonBar(
      children: <Widget>[
        new FlatButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: new Text('Cancel')),
        new RaisedButton(onPressed: () {
          Navigator.of(context).pop(_ounces);
        }, child: new Text("$_ounces oz"))
        ],
      )
      ],
    );
  }

}



class Entry extends StatelessWidget{
  Entry(this.note);

  final cardTextStyle = const TextStyle(
    fontFamily: 'Josefin',
    color: Colors.white,
    fontSize: 18.0,
  );

  final Note note;

  Widget makeNoteCard() {
    return new Container(
      height: 120.0,
      margin: new EdgeInsets.only(left: 48.0, right: 16.0),
      constraints: new BoxConstraints.expand(),
      decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: new Color(0xFF443366),
          borderRadius: new BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            new BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: new Offset(2.0, 10.0)
            )
          ]
      ),
      child: new Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 8.0
            ),
            child: new Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(note.getBeginTimeString(), style: cardTextStyle),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: new Text('->', style: cardTextStyle),
                ),
                new Text(note.getEndTimeString(), style: cardTextStyle)
              ],
            ),
          ),
          new Text(note.getAmountString(), style: cardTextStyle,),
        ],
      ),
    );
  }

    final noteThumb = new Container(
      margin: new EdgeInsets.symmetric(
          vertical: 16.0
      ),
      alignment: FractionalOffset.centerLeft,
      child: new Image(
        image: new AssetImage("assets/planet_sleepy.png"),
        height: 92.0,
        width: 92.0,
      ),
    );

    @override
    Widget build(BuildContext context) {
      return new Container (
        height: 120.0,
        margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0
        ),
        child: new Stack(
          children: <Widget>[
            makeNoteCard(),
            noteThumb,
          ],
        ),
      );
    }
}

//
//enum RecordType {
//  sleepStart, sleepEnd, eatStart, eatEnd
//}
//
//class Record {
//  Record(this.time, this.recordType, {this.amount});
//
//  DateTime time;
//  RecordType recordType;
//  double amount;
//
//  String getType() {
//    switch (recordType) {
//      case RecordType.sleepEnd:
//        return "Sleep ended";
//      case RecordType.sleepStart:
//        return "Sleep started";
//      case RecordType.eatStart:
//        return "Eating started";
//      case RecordType.eatEnd:
//        return "Ate " + amount.toString() + " ounces";
//    }
//
//    return "Record type did not find match";
//  }
//}

enum NoteType {
  sleep, eat
}

class Note {
  Note(this.beginTime, {this.endTime: "", this.amount: -1.0});

  String beginTime = "";
  String endTime;
  double amount;
  String type;

  Note.fromJson(Map<String, dynamic> json)
    : beginTime = json['beginTime'],
      endTime = json['endTime'],
      amount = json['amount'],
      type = json['type'];

  Map<String, dynamic> toJson() =>
      {
        'beginTime': beginTime,
        'endTime': endTime,
        'amount': amount,
        'type': type,
      };

  NoteType getType() {
    if(type == "Eat") {
      return NoteType.eat;
    } else if (type == "Sleep") {
      return NoteType.sleep;
    }

    return null;
  }

  void setType(NoteType type) {
    switch(type) {
      case NoteType.eat:
        this.type = "Eat";
        break;
      case NoteType.sleep:
        this.type = "Sleep";
        break;
    }
  }

  DateTime getBeginTime() {
    DateTime time = DateTime.parse(beginTime);
    print(time.toString());
    return time;
  }

  DateTime getEndTime() {
    return DateTime.parse(endTime);
  }

  String getBeginTimeString() {
    if(beginTime == "") {
      return "";
    } else {
      return new DateFormat.jm().format(getBeginTime());
    }
  }

  String getEndTimeString() {
    if(endTime == "") {
      return "";
    } else {
      return new DateFormat.jm().format(getEndTime());
    }
  }

  String getAmountString() {
    if(amount < 0.0) {
      return "";
    }
    switch(getType()) {
      case NoteType.eat:
        return "$amount ounces";
      case NoteType.sleep:
        int time = amount.floor();
        return "$time minutes";
    }
    return "";
  }
}