import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Loads a network image with a loader and error fallback, or renders a local
/// asset directly if [imageUrl] points into the asset bundle instead of a URL.
class LoadedImage extends StatelessWidget {
  final String imageUrl;
  final String? fallbackImage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BoxFit? roundedImageFit;
  final Color? color;
  final BoxShape boxShape;
  final Widget? alternativeWidget;
  final bool showLoader;

  const LoadedImage({
    super.key,
    required this.imageUrl,
    this.fallbackImage,
    this.boxShape = BoxShape.rectangle,
    this.width,
    this.fit = BoxFit.contain,
    this.roundedImageFit = BoxFit.cover,
    this.height,
    this.color,
    this.showLoader = true,
    this.alternativeWidget,
  });

  @override
  Widget build(BuildContext context) {
    bool isImgUrlValid = Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false;
    // If the url is invalid just display alternative or default widget
    if (!isImgUrlValid) {
      if (imageUrl.contains('assets/')) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
        );
      }
      if (alternativeWidget != null) {
        return alternativeWidget!;
      }
      return Container(
        height: height,
        width: width,
        constraints: const BoxConstraints(minHeight: 300),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      color: color,
      fit: fit,
      imageBuilder: boxShape == BoxShape.circle
          ? (context, imageProvider) {
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  shape: boxShape,
                  image: DecorationImage(image: imageProvider, fit: roundedImageFit),
                ),
              );
            }
          : null,
      placeholder: (context, url) => showLoader
          ? Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.brandPrimary),
                ),
              ),
            )
          : const SizedBox.shrink(),
      errorWidget: (context, url, error) {
        // If there is a fallback image then load it
        if (fallbackImage != null) {
          return CachedNetworkImage(
            imageUrl: fallbackImage!,
            width: width,
            height: height,
            color: color,
            fit: fit,
            imageBuilder: boxShape == BoxShape.circle
                ? (context, imageProvider) {
                    return Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                        shape: boxShape,
                        image: DecorationImage(image: imageProvider, fit: roundedImageFit),
                      ),
                    );
                  }
                : null,
            placeholder: (context, url) => showLoader
                ? Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(context.colors.brandPrimary),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            errorWidget: (context, url, error) {
              // If fallback url failed too, just display alternative or default widget
              if (alternativeWidget != null) {
                return alternativeWidget!;
              }
              return SizedBox(height: height, width: width);
            },
          );
        }
        // Display alternative widget if it exits
        if (alternativeWidget != null) {
          return alternativeWidget!;
        }
        return SizedBox(height: height, width: width);
      },
    );
  }
}
