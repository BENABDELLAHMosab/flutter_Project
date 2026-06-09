import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    print('BOOKING CARD: ${booking.hotelName} / ${booking.hotelCity} / ${booking.status}');

    final isCancelled = booking.status == 'cancelled';
    final isConfirmed = booking.status == 'confirmed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (booking.hotelImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      booking.hotelImageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.hotel,
                            size: 32,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hotel, color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded( // Prevents title overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.hotelName.isNotEmpty ? booking.hotelName : 'Hôtel inconnu',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.hotelCity.isNotEmpty ? booking.hotelCity : 'Ville inconnue',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCancelled ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCancelled ? 'Annulée' : 'Confirmée',
                    style: TextStyle(
                      color: isCancelled ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row( // Using Expanded around date column to prevent right overflow
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arrivée', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        booking.checkIn,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Départ', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        booking.checkOut,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row( // Using Wrap or Expanded to prevent price vs button overlap
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.totalPrice} DH',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isConfirmed)
                  OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Annuler', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
