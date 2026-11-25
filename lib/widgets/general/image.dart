
import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:furmate/services/images_service.dart';

class CustomImage extends StatefulWidget {
  final String id;
  final String imagePath;
  final double size;

  const CustomImage({
    super.key,
    required this.id,
    required this.imagePath,
    this.size = 50,
  });

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  final ImageService _imageService = ImageService();

  Future<Uint8List>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    if (widget.imagePath.startsWith('/api/pets/')) {
      // Pet image
      _imageFuture = _imageService.getPetImage(widget.id);
    } else if (widget.imagePath == '/api/users/me/image') {
      // User profile image
      _imageFuture = _imageService.getUserImage();
    } else {
      _imageFuture = null;
    }
  }

  @override
  void didUpdateWidget(covariant CustomImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.id != widget.id ||
        oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageFuture == null) {
      return CircleAvatar(
        radius: widget.size,
        child: Icon(
          widget.imagePath == '/api/users/me/image'
              ? Icons.person
              : Icons.pets, size: 30
        ),
      );
    }

    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Failed to load image: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return CircleAvatar(
            radius: widget.size,
            child: Icon(
              widget.imagePath == '/api/users/me/image'
                  ? Icons.person
                  : Icons.pets, size: 30
            ),
          );
        }

        return CircleAvatar(
          radius: widget.size,
          backgroundImage: MemoryImage(snapshot.data!),
        );
      },
    );
  }
}
