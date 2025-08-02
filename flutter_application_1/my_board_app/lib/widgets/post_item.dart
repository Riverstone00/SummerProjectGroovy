// lib/widgets/post_item.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/post.dart';

class PostItem extends StatelessWidget {
  final Post post;
  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(post.imagePath!),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 180,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.image, size: 60)),
              ),
            const SizedBox(height: 8),
            Text(post.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                if (post.price != null)
                  Row(children: [
                    const Icon(Icons.price_check, size: 16),
                    const SizedBox(width: 4),
                    Text(post.price!),
                  ]),
                if (post.duration != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(post.duration!),
                ],
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.favorite_border),
                SizedBox(width: 16),
                Icon(Icons.comment_outlined),
                SizedBox(width: 16),
                Icon(Icons.share),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
