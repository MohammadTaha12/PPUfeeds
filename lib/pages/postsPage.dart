// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '/viewmodels/posts_viewmodel.dart';
import '../classes/post.dart';
import 'commentsPage.dart';

class CoursePostsScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;

  const CoursePostsScreen({required this.courseId, required this.sectionId});

  @override
  _CoursePostsScreenState createState() => _CoursePostsScreenState();
}

class _CoursePostsScreenState extends State<CoursePostsScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _editPostController = TextEditingController();
  bool isLoading = true;
  int? editingPostId;
  bool isAddingPost = false;
  List<Post> posts = [];
  late CoursePostsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = CoursePostsViewModel(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
    );
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      posts = await viewModel.fetchPosts();
    } catch (e) {
      _showErrorDialog("Failed to load posts: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addPost() async {
    final postContent = _postController.text.trim();
    if (postContent.isEmpty) {
      _showErrorDialog("Post content cannot be empty.");
      return;
    }
    try {
      await viewModel.addPost(postContent);
      _postController.clear();
      _fetchPosts();
    } catch (e) {
      _showErrorDialog("Failed to add post: $e");
    }
  }

  Future<void> _updatePost(int postId) async {
    final updatedContent = _editPostController.text.trim();
    if (updatedContent.isEmpty) return;
    try {
      await viewModel.updatePost(postId, updatedContent);
      setState(() {
        editingPostId = null;
        _editPostController.clear();
      });
      _fetchPosts();
    } catch (e) {
      _showErrorDialog("Failed to update post: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPostSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.black),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isAddingPost = true;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Write something...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isAddingPost) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _postController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isAddingPost = false;
                      _postController.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Text(post.author[0].toUpperCase()),
            ),
            title: Text(
              post.author,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(post.datePosted),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  setState(() {
                    editingPostId = post.id;
                    _editPostController.text = post.body;
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: editingPostId == post.id
                ? Column(
                    children: [
                      TextField(
                        controller: _editPostController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Edit your post...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                editingPostId = null;
                                _editPostController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: Text("Cancel",
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _updatePost(post.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: Text("Save",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  )
                : Text(
                    post.body,
                    style: TextStyle(fontSize: 16),
                  ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommentsPage(
                        courseId: widget.courseId,
                        sectionId: widget.sectionId,
                        postId: post.id,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.comment, color: Colors.white),
                label: Text(
                  "View Comments",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          _buildAddPostSection(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : posts.isEmpty
                    ? Center(child: Text("No posts available."))
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return _buildPostItem(posts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
