import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ITATS',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 237, 230, 226),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> notes = [];
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    GetNotes();
  }

/* START FUNCTION */
  Future<void> GetNotes() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.4:8080/notes_app/api.php'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
            notes = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
        print('Error: $e');
    }
  }

  Future<void> addNote() async {
    String title = titleController.text;
    String content = contentController.text;
    if (title.isNotEmpty && content.isNotEmpty) {
      await addNoteToApi(title, content); // Panggil fungsi untuk menambahkan catatan
      titleController.clear(); // Bersihkan input
      contentController.clear(); // Bersihkan input
      GetNotes(); // Memperbarui daftar catatan
    } else {
      // Tampilkan pesan kesalahan jika input kosong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan Isi tidak boleh kosong.')),
      );
    }
  }

  // Fungsi untuk memanggil API
  Future<void> addNoteToApi(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.4:8080/notes_app/api.php'),
        body: {
          'title': title,
          'content': content,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Gagal Membuat Catatan.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteNote(int id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.4:8080/notes_app/api.php'),
      body: {'id': id.toString()},
    );
    if (response.statusCode == 200) {
      GetNotes();
    } else {
      throw Exception('Gagal Menghapus Catatan.');
    }
  }

  Future<void> editNote(int id, String title, String content) async {
    try {
      final response = await http.put(
        Uri.parse('http://192.168.1.4:8080/notes_app/api.php'),
        body: {
          'id': id.toString(),
          'title': title,
          'content': content,
        },
      );
      if (response.statusCode == 200) {
        GetNotes(); // Memperbarui daftar catatan setelah pengeditan
      } else {
        throw Exception('Failed to edit note');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
/* END FUNCTION */

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Notes Apps - Tambah Catatan';
      case 1:
        return 'Notes Apps - List Catatan';
      case 2:
        return 'Notes Apps - Profil Kelompok';
      default:
        return 'ITATS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 106, 0),
        title: RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
            text: _getAppBarTitle(currentPageIndex),
            style: const TextStyle(
              fontSize: 16,
              color:  Colors.white,
            ),
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        height: 70,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.add), label: 'Tambah Catatan'),
          NavigationDestination(icon: Icon(Icons.folder), label: 'List Catatan',),
          NavigationDestination(icon: Icon(Icons.people), label: 'Profil',),
        ],
      ),

      body: IndexedStack(
        index: currentPageIndex,
        children: <Widget>[
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column( // Menggunakan Column untuk menampung beberapa widget
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Judul'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: contentController,
                      decoration: InputDecoration(labelText: 'Isi'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Panggil fungsi untuk menambahkan catatan
                      addNote();
                    },
                    child: Text('Tambah'),
                  ),
                ],
              ),
            ),
          ),
          // Halaman kedua untuk menampilkan daftar catatan
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(notes[index]['title']),
                  subtitle: Text(notes[index]['content']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Mengatur ukuran baris agar tidak mengisi ruang
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Pastikan ID yang dikirim adalah integer
                          deleteNote(int.parse(notes[index]['id'].toString())); // Konversi ID ke integer
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
          child: ListView.builder(
            itemCount: 3, // Jumlah nama yang ingin ditampilkan
            itemBuilder: (context, index) {
              // Daftar nama dan informasi
              List<Map<String, String>> names = [
                {'name': 'Iksan Arya Dinata', 'info': '13.2023.1.01157'},
                {'name': 'Gianluki Akbar', 'info': '13.2023.1.01193'},
                {'name': 'Faishal Nafi’ Rabbani', 'info': '13.2023.1.01210'},
              ];
              return ListTile(
                title: Text(names[index]['name']!),
                subtitle: Text(names[index]['info']!),
              );
            },
          ),
        ),
        ],
      ),
    );
  }
}
