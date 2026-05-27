import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gtg/models/venue.dart';
import 'package:gtg/theme/app_colors.dart';
import 'package:gtg/theme/app_tokens.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback? onTap;

  const VenueCard({super.key, required this.venue, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 134,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [AppShadows.card],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail — 118×118 square with 8px margins on all sides
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: venue.imageUrl,
                  width: 118,
                  height: 118,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.primaryLight,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, _) => Container(
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.primary),
                  ),
                ),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 4,
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(venue.name, style: AppTextStyles.venueName),
                    const SizedBox(height: 4),
                    // Status row: blue dot + blue text
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.statusBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          venue.status,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.statusBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating row
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 20, color: Color(0xFFFFB800)),
                        const SizedBox(width: 4),
                        Text(
                          venue.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price — "Avg. ₹X" in red + "/ Person" in gray (smaller)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Avg. ₹${venue.avgPricePerPerson}',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.primary,
                              ),
                            ),
                            const TextSpan(
                              text: '/ Person',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
