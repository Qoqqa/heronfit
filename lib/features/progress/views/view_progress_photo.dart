import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:intl/intl.dart';
import 'package:solar_icons/solar_icons.dart'; // Import SolarIcons

class ViewProgressPhotosWidget extends ConsumerStatefulWidget {
  const ViewProgressPhotosWidget({super.key});

  @override
  ConsumerState<ViewProgressPhotosWidget> createState() =>
      _ViewProgressPhotosWidgetState();
}

class _ViewProgressPhotosWidgetState
    extends ConsumerState<ViewProgressPhotosWidget> {
  int _selectedPhotoIndex = 0;

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);
    final theme = Theme.of(context); // Get theme

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Set background to transparent
          elevation: 0, // Remove elevation
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              SolarIconsOutline.altArrowLeft, // Use SolarIcons
              color: theme.primaryColor, // Use primary color
              size: 28, // Adjust size as needed
            ),
            onPressed: () => context.canPop() ? context.pop() : null,
          ),
          title: Text(
            'Progress Photos',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.primaryColor, // Use primary color
              fontWeight: FontWeight.bold, // Set font weight to bold
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: true,
          child: progressRecordsAsyncValue.when(
            data: (allRecords) {
              final photoRecords =
                  allRecords
                      .where(
                        (r) => r.photoUrl != null && r.photoUrl!.isNotEmpty,
                      )
                      .toList();

              if (_selectedPhotoIndex >= photoRecords.length &&
                  photoRecords.isNotEmpty) {
                _selectedPhotoIndex = photoRecords.length - 1;
              }
              if (photoRecords.isEmpty) {
                _selectedPhotoIndex = 0;
              }

              if (photoRecords.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No progress photos found. Add photos via the Update Weight screen.',
                      style: theme.textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final selectedRecord = photoRecords[_selectedPhotoIndex];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              selectedRecord.photoUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  SolarIconsOutline.gallery, // Use SolarIcons
                                  color:
                                      theme.primaryColor, // Use primary color
                                  size: 24,
                                ),
                                tooltip: 'View All Photos',
                                onPressed: () {
                                  context.push('/progressPhotoList');
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  SolarIconsOutline
                                      .squareTransferVertical, // Use SolarIcons
                                  color:
                                      theme.primaryColor, // Use primary color
                                  size: 24,
                                ),
                                tooltip: 'Compare Photos',
                                onPressed: () {
                                  context.push('/compareProgressPhotos');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${selectedRecord.weight} kg',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(selectedRecord.date),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        scrollDirection: Axis.horizontal,
                        itemCount: photoRecords.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final record = photoRecords[index];
                          final isSelected = _selectedPhotoIndex == index;

                          return Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: theme.primaryColor,
                                        width: 3,
                                      )
                                      : Border.all(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                            ),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  _selectedPhotoIndex = index;
                                });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  record.photoUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.error_outline,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading progress photos: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
