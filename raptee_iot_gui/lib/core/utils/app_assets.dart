import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

class AppAssets {
  // --- Registry (Add paths here so you don't type strings in UI) ---
  static const String logo = "assets/images/logo.svg";
  static const String bikeIcon = "assets/icons/bike.svg";
  
  // --- The Smart Loader ---
  // Use: AppAssets.load(AppAssets.logo)
  static Widget load(String source, {
    double? width, 
    double? height, 
    Color? color, 
    BoxFit fit = BoxFit.contain
  }) {
    // 1. Network Image (Cached)
    if (source.startsWith("http")) {
      return CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: 20, height: 20, 
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)
          )
        ),
        errorWidget: (context, url, error) => Icon(Icons.error, color: AppColors.error),
      );
    }

    // 2. SVG (Local)
    if (source.endsWith(".svg")) {
      return SvgPicture.asset(
        source,
        width: width,
        height: height,
        fit: fit,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    }

    // 3. PNG/JPG (Local)
    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      color: color,
    );
  }
}