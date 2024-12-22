import 'package:flutter/material.dart';
import 'package:flutter_application_3/viewmodels/comments_viewmodel.dart';
import '../classes/comment.dart';

class CommentsPage extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  const CommentsPage({
    required this.courseId,
    required this.sectionId,
    required this.postId,
  });

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final CommentsViewModel _viewModel = CommentsViewModel();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editCommentController = TextEditingController();
  int? editingCommentId;

  @override
  void initState() {
    super.initState();
    _viewModel.fetchComments(widget.courseId, widget.sectionId, widget.postId);
  }

  Widget _buildCommentItem(Comment comment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.redAccent,
                child: Text(comment.author[0].toUpperCase(),
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.author,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    comment.datePosted,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              editingCommentId == comment.id
                  ? IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _viewModel.editComment(widget,
                          comment.id, _editCommentController.text.trim(), () {
                        setState(() => editingCommentId = null);
                      }),
                    )
                  : IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        setState(() {
                          editingCommentId = comment.id;
                          _editCommentController.text = comment.body;
                        });
                      },
                    ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _viewModel.deleteComment(widget, comment.id),
              ),
            ],
          ),
          const SizedBox(height: 5),
          editingCommentId == comment.id
              ? TextField(
                  controller: _editCommentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(comment.body),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  comment.isLiked
                      ? Icons.thumb_up
                      : Icons.thumb_up_alt_outlined,
                  color: comment.isLiked ? Colors.blue : Colors.grey,
                ),
                onPressed: () => _viewModel.toggleLike(widget, comment),
              ),
              Text("${comment.likesCount} Likes"),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _viewModel.commentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  final comments = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) =>
                        _buildCommentItem(comments[index]),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration:
                        const InputDecoration(hintText: "Add a comment..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _viewModel.addComment(
                      widget, _commentController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
