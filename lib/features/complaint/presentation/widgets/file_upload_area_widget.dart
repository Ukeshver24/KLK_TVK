import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../data/complaint_api_service.dart';

class AttachedImageItem {
  final String path;
  final String name;
  final String size;
  final int bytes;

  AttachedImageItem({
    required this.path,
    required this.name,
    required this.size,
    required this.bytes,
  });
}

class FileUploadAreaWidget extends StatefulWidget {
  final bool isTamil;
  final Function(List<String>) onImagesSelected;
  final List<String>? initialImages;

  const FileUploadAreaWidget({
    super.key,
    required this.isTamil,
    required this.onImagesSelected,
    this.initialImages,
  });

  @override
  State<FileUploadAreaWidget> createState() => _FileUploadAreaWidgetState();
}

class _FileUploadAreaWidgetState extends State<FileUploadAreaWidget> {
  final List<AttachedImageItem> _attachedImages = [];
  final ImagePicker _picker = ImagePicker();
  static const int _maxImages = 2;

  @override
  void initState() {
    super.initState();
    try {
      final platform = ImagePickerPlatform.instance;
      if (platform is ImagePickerAndroid) {
        platform.useAndroidPhotoPicker = true;
      }
    } catch (_) {}
    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      for (final path in widget.initialImages!) {
        if (path.isNotEmpty) {
          final file = File(path);
          final name = path.split('/').last;
          int bytes = 0;
          String sizeStr = 'Optimized';
          if (file.existsSync()) {
            bytes = file.lengthSync();
            final double sizeInMb = bytes / (1024 * 1024);
            sizeStr = sizeInMb >= 1.0
                ? '${sizeInMb.toStringAsFixed(1)} MB'
                : '${(bytes / 1024).toStringAsFixed(0)} KB';
          }
          _attachedImages.add(
            AttachedImageItem(
              path: path,
              name: name,
              size: sizeStr,
              bytes: bytes,
            ),
          );
        }
      }
    }
  }

  void _notifyParent() {
    widget.onImagesSelected(_attachedImages.map((e) => e.path).toList());
  }

  void _showImageSourcePicker() {
    final isTamil = widget.isTamil;

    if (_attachedImages.length >= _maxImages) {
      AppToast.showError(
        context,
        isTamil
            ? 'அதிகபட்சம் 2 புகைப்படங்கள் மட்டுமே இணைக்க முடியும்!'
            : 'Maximum 2 images can be attached!',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isTamil ? 'புகைப்படத்தை தேர்வு செய்க' : 'Select Photo Source',
                style: const TextStyle(
                  color: Color(0xFF2C0000),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isTamil
                    ? 'அதிகபட்சம் 2 படங்கள் • தயவுசெய்து GPS வரைபடப் படங்களை பதிவேற்றவும்'
                    : 'Max 2 images • Please Upload GPS map images',
                style: const TextStyle(
                  color: Color(0xFF8E7E7E),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Camera Option
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickFromCamera();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD6D6)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF8C0000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isTamil ? 'கேமரா (நேரடி படம்)' : 'Camera',
                              style: const TextStyle(
                                color: Color(0xFF2C0000),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Gallery Option
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickFromGallery();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD6D6)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF8C0000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isTamil ? 'கேலரி (Gallery)' : 'Gallery',
                              style: const TextStyle(
                                color: Color(0xFF2C0000),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    if (_attachedImages.length >= _maxImages) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80, // Native fast compression
      );

      if (pickedFile != null) {
        await _processAndAddImage(pickedFile);
      }
    } catch (_) {
      _simulateAddImage();
    }
  }

  Future<void> _pickFromGallery() async {
    final isTamil = widget.isTamil;
    if (_attachedImages.length >= _maxImages) {
      AppToast.showError(
        context,
        isTamil
            ? 'அதிகபட்சம் 2 புகைப்படங்கள் மட்டுமே இணைக்க முடியும்!'
            : 'Maximum 2 images can be attached!',
      );
      return;
    }

    final remainingSlots = _maxImages - _attachedImages.length;

    try {
      final platform = ImagePickerPlatform.instance;
      if (platform is ImagePickerAndroid) {
        platform.useAndroidPhotoPicker = true;
      }

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
        limit: remainingSlots,
      );

      if (pickedFiles.isNotEmpty) {
        if (pickedFiles.length > remainingSlots && mounted) {
          AppToast.showError(
            context,
            isTamil
                ? 'அதிகபட்சம் 2 படங்கள் மட்டுமே அனுமதிக்கப்படும்! முதல் 2 படங்கள் மட்டுமே இணைக்கப்பட்டன.'
                : 'Max 2 images allowed! Only the first 2 images were selected.',
          );
        }
        final toAdd = pickedFiles.take(remainingSlots).toList();
        for (final f in toAdd) {
          await _processAndAddImage(f);
        }
      }
    } catch (_) {
      _simulateAddImage();
    }
  }

  Future<void> _processAndAddImage(XFile file) async {
    if (_attachedImages.length >= _maxImages) return;

    // Instant client-side downscale/compression for large phone camera photos (5MB -> ~250KB)
    final String optimizedPath = await ComplaintApiService.compressImageFile(file.path);
    final File optimizedFile = File(optimizedPath);
    final int fileSizeBytes = optimizedFile.existsSync()
        ? optimizedFile.lengthSync()
        : await file.length();

    final double sizeInMb = fileSizeBytes / (1024 * 1024);
    final String sizeDisplay = sizeInMb >= 1.0
        ? '${sizeInMb.toStringAsFixed(1)} MB'
        : '${(fileSizeBytes / 1024).toStringAsFixed(0)} KB';

    setState(() {
      _attachedImages.add(
        AttachedImageItem(
          path: optimizedPath,
          name: file.name.isNotEmpty ? file.name : 'proof_image_${_attachedImages.length + 1}.jpg',
          size: sizeDisplay,
          bytes: fileSizeBytes,
        ),
      );
      _notifyParent();
    });
  }

  void _simulateAddImage() {
    if (_attachedImages.length >= _maxImages) return;

    final idx = _attachedImages.length + 1;
    setState(() {
      _attachedImages.add(
        AttachedImageItem(
          path: 'simulated_proof_photo_$idx.jpg',
          name: 'proof_photo_$idx.jpg',
          size: '420 KB',
          bytes: 430080,
        ),
      );
      _notifyParent();
    });
  }

  void _removeImageAt(int index) {
    if (index >= 0 && index < _attachedImages.length) {
      setState(() {
        _attachedImages.removeAt(index);
        _notifyParent();
      });
    }
  }

  void _openFullScreenPreview(int index) {
    if (index < 0 || index >= _attachedImages.length) return;
    final item = _attachedImages[index];
    final isTamil = widget.isTamil;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Bar with counter & close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isTamil
                          ? 'சான்று படம் ${index + 1} / ${_attachedImages.length}'
                          : 'Proof Image ${index + 1} of ${_attachedImages.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Zoomable Image Preview Area
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: item.path.isNotEmpty && File(item.path).existsSync()
                            ? Image.file(
                                File(item.path),
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                'assets/images/tvk_banner1.jpg',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.image_rounded,
                                  color: Colors.white54,
                                  size: 64,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Image Info Footer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFFFC107),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.name} (${item.size})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = widget.isTamil;
    final int currentCount = _attachedImages.length;
    final bool canAddMore = currentCount < _maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isTamil ? 'சான்று புகைப்படம் (தேவைப்பட்டால்)' : 'PROOF IMAGES (OPTIONAL)',
              style: const TextStyle(
                color: Color(0xFF6E6E6E),
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: currentCount > 0 ? const Color(0xFFFFF0F0) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentCount > 0 ? const Color(0xFFFFC5C5) : const Color(0xFFE0E0E0),
                ),
              ),
              child: Text(
                '$currentCount / $_maxImages',
                style: TextStyle(
                  color: currentCount > 0 ? const Color(0xFF8C0000) : const Color(0xFF757575),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 1. If no images yet, show the full upload dropzone
        if (currentCount == 0) ...[
          GestureDetector(
            onTap: _showImageSourcePicker,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAFA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4C5C5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_a_photo_rounded,
                      color: Color(0xFF8C0000),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isTamil
                        ? 'பிரச்சனை புகைப்படத்தைப் பதிவேற்றவும்'
                        : 'Upload Issue Photo(s)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2C0000),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECEC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isTamil
                          ? 'அதிகபட்சம் 2 படங்கள் • தயவுசெய்து GPS வரைபடப் படங்களை பதிவேற்றவும்'
                          : 'Max 2 images • Please Upload GPS map images',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        // 2. If 1 or 2 images are attached, show the list of attached cards + preview button
        if (currentCount > 0) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachedImages.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final img = _attachedImages[idx];
              final hasLocalFile = img.path.isNotEmpty && File(img.path).existsSync();

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEBE5E5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Thumbnail with tap-to-zoom indicator
                    GestureDetector(
                      onTap: () => _openFullScreenPreview(idx),
                      child: Stack(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFD6D6)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: hasLocalFile
                                  ? Image.file(
                                      File(img.path),
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.image_rounded,
                                      color: Color(0xFFD32F2F),
                                      size: 26,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // File Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            img.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF2C0000),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                img.size,
                                style: const TextStyle(
                                  color: Color(0xFF8E7E7E),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6FFED),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isTamil ? 'சுருக்கப்பட்டது' : 'Optimized',
                                  style: const TextStyle(
                                    color: Color(0xFF389E0D),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Preview Button (Eye)
                    IconButton(
                      onPressed: () => _openFullScreenPreview(idx),
                      icon: const Icon(
                        Icons.remove_red_eye_outlined,
                        color: Color(0xFF8C0000),
                        size: 20,
                      ),
                      tooltip: isTamil ? 'பெரிதாக்கிப் பார்' : 'Preview',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                    ),

                    const SizedBox(width: 4),

                    // Remove Button (✕)
                    GestureDetector(
                      onTap: () => _removeImageAt(idx),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5EBEB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF6B0000),
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Button to add 2nd image if only 1 is currently attached
          if (canAddMore) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: _showImageSourcePicker,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFD1D1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: Color(0xFF8C0000),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTamil
                          ? '+ 2-வது படம் சேர்க்க (விருப்பத்தேர்வு)'
                          : '+ Add 2nd Photo (Optional)',
                      style: const TextStyle(
                        color: Color(0xFF8C0000),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
