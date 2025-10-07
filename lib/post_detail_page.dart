import 'package:flutter/material.dart';
import 'models/post.dart'; // <- import model Post

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  int upvotes = 0;
  int downvotes = 0;
  bool? userVote; // true = upvote, false = downvote, null = belum memilih

  final List<Comment> comments = [];
  final TextEditingController commentController = TextEditingController();

  void _selectVote(bool isUpvote) {
    setState(() {
      if (userVote == isUpvote) {
        if (isUpvote) upvotes--;
        else downvotes--;
        userVote = null;
      } else {
        if (userVote == true) upvotes--;
        else if (userVote == false) downvotes--;

        if (isUpvote) upvotes++;
        else downvotes++;
        userVote = isUpvote;
      }
    });
  }

  void _addComment(String text, [Comment? parent]) {
    if (text.trim().isEmpty) return;
    setState(() {
      if (parent == null) {
        comments.add(Comment(author: 'Kamu', content: text));
      } else {
        parent.replies.add(Comment(author: 'Kamu', content: text));
      }
    });
    commentController.clear();
  }

  Widget _buildComment(Comment comment, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 20.0, top: 6.0),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.author,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(comment.content),
              const SizedBox(height: 4),
              // upvote & downvote untuk komentar
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_upward,
                        color: comment.userVote == true
                            ? Colors.orange
                            : Colors.grey),
                    iconSize: 20,
                    onPressed: () {
                      setState(() {
                        if (comment.userVote == true) {
                          comment.upvotes--;
                          comment.userVote = null;
                        } else {
                          if (comment.userVote == false) comment.downvotes--;
                          comment.upvotes++;
                          comment.userVote = true;
                        }
                      });
                    },
                  ),
                  Text('${comment.upvotes}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.arrow_downward,
                        color: comment.userVote == false
                            ? Colors.blue
                            : Colors.grey),
                    iconSize: 20,
                    onPressed: () {
                      setState(() {
                        if (comment.userVote == false) {
                          comment.downvotes--;
                          comment.userVote = null;
                        } else {
                          if (comment.userVote == true) comment.upvotes--;
                          comment.downvotes++;
                          comment.userVote = false;
                        }
                      });
                    },
                  ),
                  Text('${comment.downvotes}', style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  TextButton(
                    child: const Text("Balas"),
                    onPressed: () => _showReplyDialog(comment),
                  )
                ],
              ),
              ...comment.replies
                  .map((reply) => _buildComment(reply, depth: depth + 1))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplyDialog(Comment parent) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Balas Komentar'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'Tulis balasan...'),
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Kirim'),
            onPressed: () {
              _addComment(replyController.text, parent);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: Text(post.title)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(post.content),
            const SizedBox(height: 8),
            Text('${post.kelas} • ${post.matkul}',
                style: const TextStyle(color: Colors.grey)),
            const Divider(),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward,
                      color: userVote == true ? Colors.orange : Colors.grey),
                  onPressed: () => _selectVote(true),
                ),
                Text('$upvotes'),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.arrow_downward,
                      color: userVote == false ? Colors.blue : Colors.grey),
                  onPressed: () => _selectVote(false),
                ),
                Text('$downvotes'),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: comments.map((c) => _buildComment(c)).toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration:
                    const InputDecoration(hintText: 'Tulis komentar...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(commentController.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Comment {
  final String author;
  final String content;
  final List<Comment> replies;
  int upvotes;
  int downvotes;
  bool? userVote;

  Comment({
    required this.author,
    required this.content,
    List<Comment>? replies,
    this.upvotes = 0,
    this.downvotes = 0,
    this.userVote,
  }) : replies = replies ?? [];
}
