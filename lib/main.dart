import 'package:flutter/material.dart';
import 'models/post.dart';
import 'post_detail_page.dart';
import 'search.dart';
import 'profile.dart';

void main() => runApp(const ForumApp());

class ForumApp extends StatelessWidget {
  const ForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forum Diskusi Pelajar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Post> posts = [];

  void _onAddPost(Post newPost) {
    setState(() {
      posts.add(newPost);
    });
  }

  void _openAddPostForm(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: AddPostForm(onAddPost: _onAddPost),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ForumHome(posts: posts),
      SearchPage(allPosts: posts),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum Diskusi Pelajar'),
        centerTitle: true,
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () => _openAddPostForm(context),
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ForumHome extends StatelessWidget {
  final List<Post> posts;
  const ForumHome({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada pertanyaan.\nTambahkan post kamu dengan tombol +',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(post.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.content,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text('${post.kelas} • ${post.matkul}',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
              );
            },
          ),
        );
      },
    );
  }
}

class AddPostForm extends StatefulWidget {
  final Function(Post) onAddPost;
  const AddPostForm({super.key, required this.onAddPost});

  @override
  State<AddPostForm> createState() => _AddPostFormState();
}

class _AddPostFormState extends State<AddPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? selectedKelas;
  String? selectedMatkul;

  final List<String> kelasList = List.generate(12, (index) => 'Kelas ${index + 1}');
  final List<String> matkulList = [
    'Matematika',
    'Fisika',
    'Kimia',
    'Bahasa Indonesia',
    'Bahasa Inggris',
    'IPS',
    'Seni Budaya',
    'Agama',
    'TIK'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tambah Pertanyaan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Pertanyaan',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Isi judul' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Isi Pertanyaan',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Isi pertanyaan' : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Pilih Kelas',
              items: kelasList,
              value: selectedKelas,
              onChanged: (v) => setState(() => selectedKelas = v),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Pilih Mata Pelajaran',
              items: matkulList,
              value: selectedMatkul,
              onChanged: (v) => setState(() => selectedMatkul = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() &&
                    selectedKelas != null &&
                    selectedMatkul != null) {
                  final newPost = Post(
                    author: 'Kamu',
                    title: _titleController.text,
                    content: _contentController.text,
                    kelas: selectedKelas!,
                    matkul: selectedMatkul!,
                  );
                  widget.onAddPost(newPost);
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}