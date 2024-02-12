import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/utils/date_formatter.dart';

class ListStoryItem extends StatelessWidget {
  late String id;
  late String name;
  late String photoUrl;
  late String createdAt;
  late String description;

  ListStoryItem(
      {super.key,
      required this.id,
      required this.name,
      required this.photoUrl,
      required this.createdAt,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(photoUrl),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateFormatter(createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              context.push('/detail/$id');
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 400,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description.length >= 100
                ? '${description.substring(0, 100)}...'
                : description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
