import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Represents a supported file format with metadata.
class SupportedFormat {
  final String extension;
  final String displayName;
  final String category;
  final IconData icon;
  final Color accentColor;

  const SupportedFormat({
    required this.extension,
    required this.displayName,
    required this.category,
    required this.icon,
    required this.accentColor,
  });

  static const List<SupportedFormat> imageFormats = [
    SupportedFormat(
        extension: 'jpg',
        displayName: 'JPEG',
        category: 'image',
        icon: Icons.image_rounded,
        accentColor: AppColors.accentImage),
    SupportedFormat(
        extension: 'png',
        displayName: 'PNG',
        category: 'image',
        icon: Icons.image_rounded,
        accentColor: AppColors.accentImage),
    SupportedFormat(
        extension: 'webp',
        displayName: 'WebP',
        category: 'image',
        icon: Icons.image_rounded,
        accentColor: AppColors.accentImage),
    SupportedFormat(
        extension: 'bmp',
        displayName: 'BMP',
        category: 'image',
        icon: Icons.image_rounded,
        accentColor: AppColors.accentImage),
    SupportedFormat(
        extension: 'gif',
        displayName: 'GIF',
        category: 'image',
        icon: Icons.image_rounded,
        accentColor: AppColors.accentImage),
    SupportedFormat(
        extension: 'tiff',
        displayName: 'TIFF',
        category: 'image',
        icon: Icons.image_rounded,
        accentColor: AppColors.accentImage),
    SupportedFormat(
        extension: 'ico',
        displayName: 'ICO',
        category: 'image',
        icon: Icons.image_rounded,
        accentColor: AppColors.accentImage),
  ];

  static const List<SupportedFormat> audioFormats = [
    SupportedFormat(
        extension: 'mp3',
        displayName: 'MP3',
        category: 'audio',
        icon: Icons.audiotrack_rounded,
        accentColor: AppColors.accentAudio),
    SupportedFormat(
        extension: 'aac',
        displayName: 'AAC',
        category: 'audio',
        icon: Icons.audiotrack_rounded,
        accentColor: AppColors.accentAudio),
    SupportedFormat(
        extension: 'wav',
        displayName: 'WAV',
        category: 'audio',
        icon: Icons.audiotrack_rounded,
        accentColor: AppColors.accentAudio),
    SupportedFormat(
        extension: 'flac',
        displayName: 'FLAC',
        category: 'audio',
        icon: Icons.audiotrack_rounded,
        accentColor: AppColors.accentAudio),
    SupportedFormat(
        extension: 'ogg',
        displayName: 'OGG',
        category: 'audio',
        icon: Icons.audiotrack_rounded,
        accentColor: AppColors.accentAudio),
  ];

  static const List<SupportedFormat> videoFormats = [
    SupportedFormat(
        extension: 'mp4',
        displayName: 'MP4',
        category: 'video',
        icon: Icons.videocam_rounded,
        accentColor: AppColors.accentVideo),
    SupportedFormat(
        extension: 'mkv',
        displayName: 'MKV',
        category: 'video',
        icon: Icons.videocam_rounded,
        accentColor: AppColors.accentVideo),
    SupportedFormat(
        extension: 'avi',
        displayName: 'AVI',
        category: 'video',
        icon: Icons.videocam_rounded,
        accentColor: AppColors.accentVideo),
    SupportedFormat(
        extension: 'mov',
        displayName: 'MOV',
        category: 'video',
        icon: Icons.videocam_rounded,
        accentColor: AppColors.accentVideo),
    SupportedFormat(
        extension: 'webm',
        displayName: 'WebM',
        category: 'video',
        icon: Icons.videocam_rounded,
        accentColor: AppColors.accentVideo),
  ];

  static const List<SupportedFormat> archiveFormats = [
    SupportedFormat(
        extension: 'zip',
        displayName: 'ZIP',
        category: 'archive',
        icon: Icons.folder_zip_rounded,
        accentColor: AppColors.accentArchive),
    SupportedFormat(
        extension: 'tar',
        displayName: 'TAR',
        category: 'archive',
        icon: Icons.folder_zip_rounded,
        accentColor: AppColors.accentArchive),
    SupportedFormat(
        extension: 'gz',
        displayName: 'GZ',
        category: 'archive',
        icon: Icons.folder_zip_rounded,
        accentColor: AppColors.accentArchive),
  ];

  static const List<SupportedFormat> textFormats = [
    SupportedFormat(
        extension: 'txt',
        displayName: 'TXT',
        category: 'text',
        icon: Icons.description_rounded,
        accentColor: AppColors.accentText),
    SupportedFormat(
        extension: 'csv',
        displayName: 'CSV',
        category: 'text',
        icon: Icons.description_rounded,
        accentColor: AppColors.accentText),
    SupportedFormat(
        extension: 'json',
        displayName: 'JSON',
        category: 'text',
        icon: Icons.description_rounded,
        accentColor: AppColors.accentText),
    SupportedFormat(
        extension: 'md',
        displayName: 'Markdown',
        category: 'text',
        icon: Icons.description_rounded,
        accentColor: AppColors.accentText),
    SupportedFormat(
        extension: 'html',
        displayName: 'HTML',
        category: 'text',
        icon: Icons.description_rounded,
        accentColor: AppColors.accentText),
    SupportedFormat(
        extension: 'xml',
        displayName: 'XML',
        category: 'text',
        icon: Icons.description_rounded,
        accentColor: AppColors.accentText),
  ];

  static const List<SupportedFormat> pdfFormats = [
    SupportedFormat(
        extension: 'pdf',
        displayName: 'PDF',
        category: 'pdf',
        icon: Icons.picture_as_pdf_rounded,
        accentColor: AppColors.accentPdf),
  ];
}
