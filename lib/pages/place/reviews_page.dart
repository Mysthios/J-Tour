import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/place/review_card.dart';
import 'package:j_tour/providers/review_provider.dart';

class ReviewsPage extends ConsumerStatefulWidget {
  final Place place;
  
  const ReviewsPage({super.key, required this.place});

  @override
  ConsumerState<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends ConsumerState<ReviewsPage> {
  
  @override
  void initState() {
    super.initState();
    // Load reviews when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).getReviewsByPlace(widget.place.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch review state
    final reviewState = ref.watch(reviewProvider);
    final reviews = reviewState.reviews;
    final isLoading = reviewState.isLoading;
    final error = reviewState.error;
    final ratingDistribution = reviewState.ratingDistribution;
    final averageRating = reviewState.averageRating;
    final totalReviews = reviewState.totalReviews;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Penilaian dan Ulasan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              ref.read(reviewProvider.notifier).refreshReviews(widget.place.id);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(reviewProvider.notifier).refreshReviews(widget.place.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error handling
              if (error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(reviewProvider.notifier).clearError();
                        },
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                ),

              // Rating Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Semua Penilaian ($totalReviews Ulasan)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Rating bars
                    if (totalReviews > 0)
                      ...List.generate(5, (index) {
                        int stars = 5 - index;
                        int count = ratingDistribution[stars] ?? 0;
                        double percentage = totalReviews > 0 ? count / totalReviews : 0;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                '$stars',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.star, color: Colors.orange, size: 12),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: percentage,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '$count',
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Reviews List
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Ulasan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<ReviewSortType>(
                          icon: const Icon(Icons.sort),
                          onSelected: (sortType) {
                            ref.read(reviewProvider.notifier).sortReviews(sortType);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: ReviewSortType.newest,
                              child: Text('Terbaru'),
                            ),
                            const PopupMenuItem(
                              value: ReviewSortType.oldest,
                              child: Text('Terlama'),
                            ),
                            const PopupMenuItem(
                              value: ReviewSortType.highestRating,
                              child: Text('Rating Tertinggi'),
                            ),
                            const PopupMenuItem(
                              value: ReviewSortType.lowestRating,
                              child: Text('Rating Terendah'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Loading indicator
                    if (isLoading && reviews.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    // Empty state
                    else if (reviews.isEmpty && !isLoading)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada ulasan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jadilah yang pertama memberikan ulasan!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    // Reviews list
                    else
                      ...reviews.map((review) => ReviewCard(review: review)),
                      
                    // Load more button (if needed)
                    if (reviews.isNotEmpty && !isLoading)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ref.read(reviewProvider.notifier).loadMoreReviews(widget.place.id);
                          },
                          child: const Text('Muat Lebih Banyak'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Floating Action Button untuk add review
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add/edit review page
          _showAddReviewDialog();
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddReviewDialog() {
    // Contoh dialog sederhana untuk add review
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(placeId: widget.place.id),
    );
  }
}

// Dialog untuk menambah review
class AddReviewDialog extends ConsumerStatefulWidget {
  final String placeId;
  
  const AddReviewDialog({super.key, required this.placeId});

  @override
  ConsumerState<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends ConsumerState<AddReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(reviewSubmittingProvider);
    
    return AlertDialog(
      title: const Text('Tambah Ulasan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rating:'),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Icon(
                  index < _rating ? Icons.star : Icons.star_outline,
                  color: Colors.orange,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text('Komentar:'),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Tulis ulasan Anda...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting ? null : () {
            Navigator.pop(context);
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSubmitting ? null : _submitReview,
          child: isSubmitting 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Kirim'),
        ),
      ],
    );
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi komentar')),
      );
      return;
    }

    final success = await ref.read(reviewProvider.notifier).createReview(
      placeId: widget.placeId,
      userId: 'current_user_id', // Ganti dengan user ID yang sebenarnya
      userName: 'User Name', // Ganti dengan nama user yang sebenarnya
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ulasan berhasil ditambahkan')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan ulasan')),
      );
    }
  }
}