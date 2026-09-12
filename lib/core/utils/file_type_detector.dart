import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Maps file extensions to categories and accent colors.
class FileTypeDetector {
  FileTypeDetector._();

  static const Map<String, String> _extensionToCategory = {
    // Image
    'jpg': 'image', 'jpeg': 'image', 'png': 'image', 'webp': 'image',
    'bmp': 'image', 'gif': 'image', 'tiff': 'image', 'tif': 'image',
    'ico': 'image', 'tga': 'image', 'heic': 'image',
    // Audio
    'mp3': 'audio', 'aac': 'audio', 'wav': 'audio', 'flac': 'audio',
    'ogg': 'audio', 'opus': 'audio', 'm4a': 'audio', 'amr': 'audio',
    'aiff': 'audio',
    // Video
    'mp4': 'video', 'mkv': 'video', 'avi': 'video', 'mov': 'video',
    'webm': 'video', 'flv': 'video', '3gp': 'video', 'ogv': 'video',
    'ts': 'video', 'm4v': 'video',
    // Archive
    'zip': 'archive', 'tar': 'archive', 'gz': 'archive', 'bz2': 'archive',
    // Text
    'txt': 'text', 'md': 'text', 'html': 'text', 'csv': 'text',
    'json': 'text', 'xml': 'text',
    // PDF
    'pdf': 'pdf',
  };

  static String categoryForExtension(String ext) {
    return _extensionToCategory[ext.toLowerCase().replaceAll('.', '')] ??
        'unknown';
  }

  static Color accentColorForCategory(String category) {
    switch (category) {
      case 'image':
        return AppColors.accentImage;
      case 'audio':
        return AppColors.accentAudio;
      case 'video':
        return AppColors.accentVideo;
      case 'archive':
        return AppColors.accentArchive;
      case 'text':
        return AppColors.accentText;
      case 'pdf':
        return AppColors.accentPdf;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData iconForCategory(String category) {
    switch (category) {
      case 'image':
        return Icons.image_rounded;
      case 'audio':
        return Icons.audiotrack_rounded;
      case 'video':
        return Icons.videocam_rounded;
      case 'archive':
        return Icons.folder_zip_rounded;
      case 'text':
        return Icons.description_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
