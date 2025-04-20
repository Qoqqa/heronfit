import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:heronfit/core/router/app_routes.dart'; // Import AppRoutes
import 'package:heronfit/features/progress/controllers/progress_controller.dart'; // Import controller
import 'package:heronfit/features/progress/models/progress_record.dart'; // Import model

class ProgressPhotosListWidget extends ConsumerWidget {
  const ProgressPhotosListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressRecordsAsyncValue = ref.watch(progressRecordsProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
          ),
          title: Text(
            'Progress Photos',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontSize: 20,
              letterSpacing: 0.0,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.compare_arrows,
                color: Theme.of(context).primaryColor,
              ),
              tooltip: 'Compare Photos',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigate to Compare Photos (TODO)'),
                  ),
                );
              },
            ),
          ],
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: progressRecordsAsyncValue.when(
              data: (records) {
                final photoRecords =
                    records
                        .where(
                          (r) => r.photoUrl != null && r.photoUrl!.isNotEmpty,
                        )
                        .toList();

                if (photoRecords.isEmpty) {
                  return const Center(
                    child: Text(
                      'No progress photos found. Add some via Update Weight screen.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemCount: photoRecords.length,
                  itemBuilder: (context, index) {
                    final record = photoRecords[index];
                    return Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.1),
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${record.date.toLocal().toString().split(' ')[0]}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      'Weight: ${record.weight} kg',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(letterSpacing: 0.0),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    record.photoUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) =>
                      Center(child: Text('Error loading photos: $error')),
            ),
          ),
        ),
      ),
    );
  }
}
