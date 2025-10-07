import 'package:flutter/material.dart';
import 'models/post.dart';
import 'post_detail_page.dart';

class SearchPage extends StatefulWidget {
  final List<Post> allPosts;

  const SearchPage({super.key, required this.allPosts});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = '';
  String selectedKelas = '';
  String selectedMatkul = '';

  final List<String> kelasList =
  List.generate(12, (index) => 'Kelas ${index + 1}');

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
    // Filter posts
    final filteredPosts = widget.allPosts.where((post) {
      final matchesQuery = searchQuery.isEmpty ||
          post.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.kelas.toLowerCase().contains(searchQuery.toLowerCase()) ||
          post.matkul.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesKelas =
          selectedKelas.isEmpty || post.kelas.toLowerCase() == selectedKelas.toLowerCase();
      final matchesMatkul =
          selectedMatkul.isEmpty || post.matkul.toLowerCase() == selectedMatkul.toLowerCase();
      return matchesQuery && matchesKelas && matchesMatkul;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pencarian Forum')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
            const SizedBox(height: 10),

            // Dropdown kelas & matkul
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kelas'),
                    value: selectedKelas.isEmpty ? 'All' : selectedKelas,
                    items: ['All', ...kelasList]
                        .map((kelas) => DropdownMenuItem(
                      value: kelas,
                      child: Text(kelas),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedKelas = value == 'All' ? '' : value ?? '');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Mata Pelajaran'),
                    value: selectedMatkul.isEmpty ? 'All' : selectedMatkul,
                    items: ['All', ...matkulList]
                        .map((matkul) => DropdownMenuItem(
                      value: matkul,
                      child: Text(matkul),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => selectedMatkul = value == 'All' ? '' : value ?? '');
                    },
                  ),
                ),
              ],
            ),


            // Hasil pencarian
            Expanded(
              child: filteredPosts.isEmpty
                  ? const Center(child: Text('Tidak ada hasil'))
                  : ListView.builder(
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(post.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          '${post.kelas} • ${post.matkul}\n${post.content}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(post: post),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
