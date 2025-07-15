import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/custom_loader.dart';
import '../../providers/task_providers.dart';
import '../../../../core/models/task_comment_model.dart';

class TaskCommentsWidget extends ConsumerStatefulWidget {
  final String taskId;

  const TaskCommentsWidget({super.key, required this.taskId});

  @override
  ConsumerState<TaskCommentsWidget> createState() => _TaskCommentsWidgetState();
}

class _TaskCommentsWidgetState extends ConsumerState<TaskCommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};
  final Map<String, bool> _showReplyForm = {};

  @override
  void dispose() {
    _commentController.dispose();
    for (final controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final content = _commentController.text.trim();
    _commentController.clear();

    await ref
        .read(commentCreationProvider.notifier)
        .addComment(taskId: widget.taskId, content: content);
  }

  void _addReply(String parentCommentId) async {
    final controller = _replyControllers[parentCommentId];
    if (controller == null || controller.text.trim().isEmpty) return;

    final content = controller.text.trim();
    controller.clear();
    setState(() {
      _showReplyForm[parentCommentId] = false;
    });

    await ref
        .read(commentCreationProvider.notifier)
        .addComment(
          taskId: widget.taskId,
          content: content,
          parentCommentId: parentCommentId,
        );
  }

  void _toggleReplyForm(String commentId) {
    setState(() {
      _showReplyForm[commentId] = !(_showReplyForm[commentId] ?? false);
      if (_showReplyForm[commentId] == true) {
        _replyControllers[commentId] ??= TextEditingController();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsAsync = ref.watch(taskCommentsProvider(widget.taskId));
    final commentCreationState = ref.watch(commentCreationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments Header
        Row(
          children: [
            Icon(Icons.comment_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Comments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Add Comment Form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _commentController.clear(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed:
                          commentCreationState.isLoading ? null : _addComment,
                      child:
                          commentCreationState.isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Add Comment'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Comments List
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No comments yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to add a comment!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Separate top-level comments and replies
            final topLevelComments =
                comments
                    .where((comment) => comment.parentCommentId == null)
                    .toList();

            return Column(
              children:
                  topLevelComments.map((comment) {
                    final replies =
                        comments
                            .where((c) => c.parentCommentId == comment.id)
                            .toList();

                    return _CommentItem(
                      comment: comment,
                      replies: replies,
                      onReply: () => _toggleReplyForm(comment.id),
                      showReplyForm: _showReplyForm[comment.id] ?? false,
                      replyController: _replyControllers[comment.id],
                      onAddReply: () => _addReply(comment.id),
                      onCancelReply:
                          () => setState(() {
                            _showReplyForm[comment.id] = false;
                          }),
                      isAddingReply: commentCreationState.isLoading,
                    );
                  }).toList(),
            );
          },
          loading: () => const Center(child: CustomLoader()),
          error:
              (error, _) => Center(
                child: Text(
                  'Error loading comments: $error',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
        ),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final TaskCommentModel comment;
  final List<TaskCommentModel> replies;
  final VoidCallback onReply;
  final bool showReplyForm;
  final TextEditingController? replyController;
  final VoidCallback onAddReply;
  final VoidCallback onCancelReply;
  final bool isAddingReply;

  const _CommentItem({
    required this.comment,
    required this.replies,
    required this.onReply,
    required this.showReplyForm,
    this.replyController,
    required this.onAddReply,
    required this.onCancelReply,
    required this.isAddingReply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    comment.authorName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.authorName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (comment.isEdited)
                  Chip(
                    label: Text('Edited', style: theme.textTheme.bodySmall),
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Comment Content
            Text(comment.content, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),

            // Comment Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: onReply,
                  icon: const Icon(Icons.reply, size: 16),
                  label: Text('Reply (${replies.length})'),
                ),
              ],
            ),

            // Reply Form
            if (showReplyForm) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: replyController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Write a reply...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onCancelReply,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: isAddingReply ? null : onAddReply,
                          child:
                              isAddingReply
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Reply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Replies
            if (replies.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(left: 24),
                child: Column(
                  children:
                      replies.map((reply) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        theme.colorScheme.secondary,
                                    child: Text(
                                      reply.authorName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: theme.colorScheme.onSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          reply.authorName,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          _formatDate(reply.createdAt),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.outline,
                                                fontSize: 10,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                reply.content,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
