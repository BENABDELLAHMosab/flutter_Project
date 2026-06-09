import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../utils/app_colors.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;

  const BookingCard({super.key, required this.booking, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = booking.status == 'Cancelled';
    final Color statusColor = isCancelled ? AppColors.error : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    booking.hotel?.imageUrl ?? '',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.hotel),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.hotel?.name ?? 'Hotel Inconnu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${booking.hotel?.city ?? ''}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          booking.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dates', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${booking.checkIn} - ${booking.checkOut}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('${booking.totalPrice} DH', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            if (!isCancelled && onCancel != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Annuler la réservation'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
