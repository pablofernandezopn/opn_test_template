import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double radius;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: width != null ? _withSizeBox(_image(context)) : _image(context),
    );
  }

  Widget _withSizeBox(Widget child) {
    return SizedBox(
      width: width,
      height: width,
      child: child,
    );
  }

  Widget _image(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.fill,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return const Icon(
          Icons.image_outlined,
        );
      },
    );
  }
}