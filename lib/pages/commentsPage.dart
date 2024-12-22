import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/comments_viewmodel.dart';
import '../classes/comment.dart';

class CommentsPage extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  const CommentsPage({
    required this.courseId,
    required this.sectionId,
    required this.postId,
    Key? key,
  }) : super(key: key);

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editCommentController = TextEditingController();
  int? editingCommentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommentsViewModel>(context, listen: false)
          .fetchComments(widget.courseId, widget.sectionId, widget.postId);
    });
  }

  Widget buildCommentItem(Comment comment) {
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
                    style: const TextStyle(color: Colors.white)),
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
                      onPressed: () {
                        Provider.of<CommentsViewModel>(context, listen: false)
                            .editComment(
                                widget.courseId,
                                widget.sectionId,
                                widget.postId,
                                comment.id,
                                _editCommentController.text.trim());
                        setState(() => editingCommentId = null);
                      },
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
                onPressed: () {
                  Provider.of<CommentsViewModel>(context, listen: false)
                      .deleteComment(widget.courseId, widget.sectionId,
                          widget.postId, comment.id);
                },
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
                onPressed: () async {
                  await Provider.of<CommentsViewModel>(context, listen: false)
                      .toggleLike(widget.courseId, widget.sectionId,
                          widget.postId, comment);
                  Provider.of<CommentsViewModel>(context, listen: false)
                      .fetchComments(widget.courseId, widget.sectionId,
                          widget.postId); // تحديث التعليقات
                },
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
      body: Consumer<CommentsViewModel>(
        builder: (context, viewModel, child) {
          final comments = viewModel.comments;
          return Column(
            children: [
              Expanded(
                child: comments.isEmpty
                    ? const Center(child: Text("No comments yet"))
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) =>
                            buildCommentItem(comments[index]),
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
                      onPressed: () {
                        final commentText = _commentController.text.trim();
                        if (commentText.isNotEmpty) {
                          Provider.of<CommentsViewModel>(context, listen: false)
                              .addComment(widget.courseId, widget.sectionId,
                                  widget.postId, commentText)
                              .then((_) {
                            Provider.of<CommentsViewModel>(context,
                                    listen: false)
                                .fetchComments(widget.courseId,
                                    widget.sectionId, widget.postId);
                          });
                          _commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
