import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heronfit/features/progress/controllers/progress_controller.dart';
import 'package:heronfit/features/progress/models/progress_record.dart';
import 'package:intl/intl.dart';

class CompareProgressPhotosWidget extends ConsumerStatefulWidget {
  const CompareProgressPhotosWidget({super.key});

  @override
  ConsumerState<CompareProgressPhotosWidget> createState() =>
      _CompareProgressPhotosWidgetState();
}

class _CompareProgressPhotosWidgetState
    extends ConsumerState<CompareProgressPhotosWidget> {
  ProgressRecord? _selectedPhoto1;
  ProgressRecord? _selectedPhoto2;

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            onPressed: () => context.canPop() ? context.pop() : null,
          ),
          title: Text(
            'Compare Photos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              letterSpacing: 0.0,
            ),
          ),
          centerTitle: true,
          elevation: 0,
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

              if (photoRecords.length < 2) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'You need at least two progress photos to compare. Add more photos via the Update Weight screen.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildComparisonImage(context, _selectedPhoto1, 1),
                          const VerticalDivider(thickness: 1),
                          _buildComparisonImage(context, _selectedPhoto2, 2),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildPhotoSelector(context, photoRecords),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading photos: $error',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonImage(
    BuildContext context,
    ProgressRecord? record,
    int position,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child:
                  record?.photoUrl != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          record!.photoUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
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
                                  size: 40,
                                ),
                              ),
                        ),
                      )
                      : Center(
                        child: Text(
                          'Select Photo $position',
                          style: Theme.of(context).textTheme.labelMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            record != null ? _formatDate(record.date) : '-',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            record != null ? '${record.weight} kg' : '-',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelector(
    BuildContext context,
    List<ProgressRecord> photoRecords,
  ) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      color: Theme.of(context).cardColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoRecords.length,
        itemBuilder: (context, index) {
          final record = photoRecords[index];
          final isSelected1 = _selectedPhoto1?.id == record.id;
          final isSelected2 = _selectedPhoto2?.id == record.id;
          final isSelected = isSelected1 || isSelected2;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected1) {
                  _selectedPhoto1 = null;
                } else if (isSelected2) {
                  _selectedPhoto2 = null;
                } else {
                  if (_selectedPhoto1 == null) {
                    _selectedPhoto1 = record;
                  } else if (_selectedPhoto2 == null) {
                    _selectedPhoto2 = record;
                  } else {
                    _selectedPhoto1 = record;
                    _selectedPhoto2 = null;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Deselected Photo 2. Tap another photo to select it.',
                        ),
                      ),
                    );
                  }
                }
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      record.photoUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) => const Center(
                            child: Icon(Icons.error_outline, size: 30),
                          ),
                    ),
                    if (!isSelected)
                      Container(color: Colors.black.withOpacity(0.3)),
                    if (isSelected)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.8),
                          child: Text(
                            isSelected1 ? 'Photo 1' : 'Photo 2',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
