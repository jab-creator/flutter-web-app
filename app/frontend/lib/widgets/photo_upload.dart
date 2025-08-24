import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/form_validators.dart';

/// Upload state for photo upload widget.
enum PhotoUploadState {
  initial,
  selecting,
  selected,
  uploading,
  uploaded,
  error,
}

/// A widget for uploading hero photos to Firebase Storage.
class PhotoUpload extends StatefulWidget {
  const PhotoUpload({
    super.key,
    this.onPhotoUploaded,
    this.onPhotoRemoved,
    this.initialPhotoUrl,
    this.maxSizeBytes = 5 * 1024 * 1024, // 5MB
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    this.storageRef,
    this.placeholder,
    this.width = 200,
    this.height = 200,
  });

  /// Callback when photo is successfully uploaded.
  final ValueChanged<String>? onPhotoUploaded;

  /// Callback when photo is removed.
  final VoidCallback? onPhotoRemoved;

  /// Initial photo URL to display.
  final String? initialPhotoUrl;

  /// Maximum file size in bytes.
  final int maxSizeBytes;

  /// Allowed file extensions.
  final List<String> allowedExtensions;

  /// Firebase Storage reference (optional).
  final Reference? storageRef;

  /// Placeholder widget when no photo is selected.
  final Widget? placeholder;

  /// Width of the photo display area.
  final double width;

  /// Height of the photo display area.
  final double height;

  @override
  State<PhotoUpload> createState() => _PhotoUploadState();
}

class _PhotoUploadState extends State<PhotoUpload> {
  PhotoUploadState _uploadState = PhotoUploadState.initial;
  String? _photoUrl;
  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.initialPhotoUrl;
    if (_photoUrl != null) {
      _uploadState = PhotoUploadState.uploaded;
    }
  }

  Future<void> _selectPhoto() async {
    setState(() {
      _uploadState = PhotoUploadState.selecting;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowedExtensions: widget.allowedExtensions,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Validate file
        final validationError = FormValidators.validateFileUpload(
          file.name,
          file.size,
        );
        
        if (validationError != null) {
          setState(() {
            _uploadState = PhotoUploadState.error;
            _errorMessage = validationError;
          });
          return;
        }

        // Check file size
        if (file.size > widget.maxSizeBytes) {
          setState(() {
            _uploadState = PhotoUploadState.error;
            _errorMessage = 'File size must be less than ${(widget.maxSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
          });
          return;
        }

        setState(() {
          _selectedImageBytes = file.bytes;
          _selectedFileName = file.name;
          _uploadState = PhotoUploadState.selected;
        });

        // Auto-upload if Firebase Storage reference is provided
        if (widget.storageRef != null) {
          await _uploadPhoto();
        }
      } else {
        setState(() {
          _uploadState = _photoUrl != null 
              ? PhotoUploadState.uploaded 
              : PhotoUploadState.initial;
        });
      }
    } catch (e) {
      setState(() {
        _uploadState = PhotoUploadState.error;
        _errorMessage = 'Failed to select photo: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImageBytes == null || _selectedFileName == null) return;

    setState(() {
      _uploadState = PhotoUploadState.uploading;
      _uploadProgress = 0.0;
      _errorMessage = null;
    });

    try {
      final storageRef = widget.storageRef ?? 
          FirebaseStorage.instance.ref().child('photos/${DateTime.now().millisecondsSinceEpoch}_$_selectedFileName');

      final uploadTask = storageRef.putData(
        _selectedImageBytes!,
        SettableMetadata(
          contentType: _getContentType(_selectedFileName!),
          customMetadata: {
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
        });
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _photoUrl = downloadUrl;
        _uploadState = PhotoUploadState.uploaded;
        _uploadProgress = 1.0;
      });

      widget.onPhotoUploaded?.call(downloadUrl);
    } catch (e) {
      setState(() {
        _uploadState = PhotoUploadState.error;
        _errorMessage = 'Failed to upload photo: ${e.toString()}';
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _photoUrl = null;
      _selectedImageBytes = null;
      _selectedFileName = null;
      _uploadState = PhotoUploadState.initial;
      _errorMessage = null;
      _uploadProgress = 0.0;
    });
    
    widget.onPhotoRemoved?.call();
  }

  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Widget _buildPhotoDisplay() {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      );
    } else if (_photoUrl != null) {
      return Image.network(
        _photoUrl!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.error,
              color: Colors.red,
              size: 48,
            ),
          );
        },
      );
    } else {
      return widget.placeholder ?? _buildDefaultPlaceholder();
    }
  }

  Widget _buildDefaultPlaceholder() {
    final theme = Theme.of(context);
    
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Add Photo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '(Optional)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    if (_uploadState != PhotoUploadState.uploading) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          LinearProgressIndicator(value: _uploadProgress),
          const SizedBox(height: 4),
          Text(
            'Uploading... ${(_uploadProgress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo display area
        GestureDetector(
          onTap: _uploadState == PhotoUploadState.uploading ? null : _selectPhoto,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  _buildPhotoDisplay(),
                  
                  // Upload overlay
                  if (_uploadState == PhotoUploadState.uploading)
                    Container(
                      width: widget.width,
                      height: widget.height,
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  
                  // Remove button
                  if (_photoUrl != null || _selectedImageBytes != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Action buttons
        const SizedBox(height: 12),
        Row(
          children: [
            if (_uploadState != PhotoUploadState.uploading) ...[
              OutlinedButton.icon(
                onPressed: _selectPhoto,
                icon: const Icon(Icons.photo_library),
                label: Text(_photoUrl != null ? 'Change Photo' : 'Select Photo'),
              ),
              
              if (_selectedImageBytes != null && widget.storageRef == null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _uploadPhoto,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload'),
                ),
              ],
            ],
          ],
        ),
        
        // Upload progress
        _buildUploadProgress(),
        
        // Error message
        _buildErrorMessage(),
        
        // Help text
        if (_uploadState == PhotoUploadState.initial) ...[
          const SizedBox(height: 8),
          Text(
            'Add a photo to make the gift page more personal. Supported formats: ${widget.allowedExtensions.join(', ').toUpperCase()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}