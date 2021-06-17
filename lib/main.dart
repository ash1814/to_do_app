import 'package:flutter/material.dart';
import 'package:test_todo/logic.dart';

import 'package:test_todo/model.dart';

import 'model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Todo> todoList;

  const MyApp({key,  this.todoList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(key: null,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final List<Todo> todoList;

  MyHomePage({key, List<Todo> todos})
      : this.todoList = todos ?? <Todo>[],
        super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TodoLogic _logic = TodoLogic();

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    _logic.streamController.sink.add(widget.todoList ?? <Todo>[]);
    super.initState();
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Todo Task List"),
      ),
      body: StreamBuilder<List<Todo>>(
          stream: _logic.streamController.stream,
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: TextField(
                      key: Key('todo-field'),
                      autofocus: true,
                      controller: _textEditingController,
                    )),
                ...showTodos(snapshot),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
            style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.green)
            )
            )
            ),

                        key: Key('add-todo'),
                        child: Text("Add a Todo"),
                        onPressed: () {
                          if (_textEditingController.text.isNotEmpty) {
                            _logic.addTodo(
                              _textEditingController.text,
                            );

                            _textEditingController.text = "";
                          }
                        },
                      ),
                      TextButton(
             style: ButtonStyle(
               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                   RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(18.0),
                       side: BorderSide(color: Colors.orangeAccent)
                   )
               ),
             ),

                        key: Key('delete-finished'),
                        child: Text("Delete Finished todos"),
                        onPressed: () {
                          _logic.removeFinishedTodos();
                        },
                        // Color: Colors.orangeAccent,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.red)
                              )
                          ),
                        ),
                        key: Key('delete-all'),
                        child: Text("Delete all"),
                        onPressed: () {
                          _logic.clearTodos();
                        },
                      ),
                    ]),
              ],
            );
          }),
    );
  }

  List<Widget> showTodos(AsyncSnapshot<List<Todo>> snapshot) {
    if (!snapshot.hasData || snapshot.data.length == 0) {
      return [
        Flexible(
          child: CircularProgressIndicator(),
        ),
      ];
    } else {
      return [
        Expanded(
          child: ListView.builder(
            itemCount: _logic.list.length,
            itemBuilder: (context, idx) => GestureDetector(
              key: Key('gd-$idx'),
              onLongPress: () {
                _logic.removeTodoByIndex(idx);
              },
              child: CheckboxListTile(
                key: ValueKey('$idx-${snapshot.data[idx].finished}-checkbox'),
                title: Text(
                  snapshot.data[idx].body,
                  key: ValueKey('$idx-todo'),
                ),
                value: snapshot.data[idx].finished,
                onChanged: (bool value) {
                  _logic.markItemFinished(idx, value);
                },
              ),
            ),
          ),
        )
      ];
    }
  }
}
