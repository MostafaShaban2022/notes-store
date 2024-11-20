import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _textEditingController = TextEditingController();
  Box? _todoxBox;
  @override
  void initState() {
    super.initState();
    Hive.openBox('todos_box').then((box) {
      setState(() {
        _todoxBox = box;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'your Notes !!',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () => _displayTextInputDialog(context),
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildUI() {
    if (_todoxBox == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ValueListenableBuilder(
        valueListenable: _todoxBox!.listenable(),
        builder: (context, Box box, widget) {
          final todosKeys = box.keys.toList();
          if (todosKeys.isEmpty) {
            return const Center(
              child: Text(
                'No Notes',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }
          return SizedBox.expand(
            child: ListView.builder(
                itemCount: todosKeys.length,
                itemBuilder: (context, index) {
                  Map todo = _todoxBox!.get(todosKeys[index]);
                  return ListTile(
                    title: Text(
                      todo['content'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      todo['time'],
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                    onLongPress: () async {
                      await _todoxBox!.delete(todosKeys[index]);
                    },
                    trailing: Checkbox(
                      activeColor: Colors.red,
                      value: todo['isDone'],
                      onChanged: (value) async {
                        todo['isDone'] = value;
                        await _todoxBox!.put(todosKeys[index], todo);
                      },
                    ),
                  );
                }),
          );
        });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'add a note',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            content: TextFormField(
              cursorColor: Colors.red,
              decoration: InputDecoration(
                hintText: 'subscribe',
                hintStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.red,
                    width: 1.75,
                  ),
                ),
              ),
              controller: _textEditingController,
            ),
            actions: [
              Center(
                child: MaterialButton(
                  onPressed: () {
                    _todoxBox?.add({
                      'content': _textEditingController.text,
                      'time': DateTime.now().toIso8601String(),
                      'isDone': false,
                    });
                    Navigator.pop(context);
                    _textEditingController.clear();
                  },
                  color: Colors.red,
                  textColor: Colors.white,
                  child: const Text('Ok'),
                ),
              ),
            ],
          );
        });
  }
}
