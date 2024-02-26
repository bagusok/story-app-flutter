import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_app/utils/date_formatter.dart';

class ListStoryItem extends StatefulWidget {
  final String id;
  final String name;
  final String photoUrl;
  final String createdAt;
  final String description;

  const ListStoryItem(
      {super.key,
      required this.id,
      required this.name,
      required this.photoUrl,
      required this.createdAt,
      required this.description});

  @override
  State<ListStoryItem> createState() => _ListStoryItemState();
}

class _ListStoryItemState extends State<ListStoryItem> {
  bool animated = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        animated = true;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(animated ? 0 : -100, 0, 0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.photoUrl),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormatter(widget.createdAt),
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
                  context.push('/detail/${widget.id}');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.photoUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.description.length >= 100
                    ? '${widget.description.substring(0, 100)}...'
                    : widget.description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ));
  }
}
