import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_application_1/core/app_colors.dart';

/// Widget reutilizable que renderiza una tarjeta de psicólogo compacta.
///
/// Parámetros:
/// - [photoUrl]: URL de la foto del psicólogo (opcional, muestra avatar si es null)
/// - [name]: Nombre del psicólogo (requerido)
/// - [specialty]: Especialidad principal (ej. "Depresión, Ansiedad")
/// - [rating]: Calificación 0..5 (opcional)
/// - [price]: Precio por sesión (opcional, en MXN por defecto)
/// - [isAvailable]: Si está disponible (opcional)
/// - [onTap]: Callback al presionar la tarjeta
/// - [isLoading]: Si está en estado de carga (muestra skeleton)
///
/// Características:
/// - CachedNetworkImage con fade-in y fallback
/// - Shimmer skeleton loader
/// - Responsive design
/// - Dark mode compatible
/// - Null-safe con defaults descriptivos
class PsychologistCard extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final String specialty;
  final double? rating;
  final int? price;
  final bool isAvailable;
  final VoidCallback onTap;
  final bool isLoading;

  const PsychologistCard({
    Key? key,
    this.photoUrl,
    required this.name,
    required this.specialty,
    this.rating,
    this.price,
    this.isAvailable = false,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    if (isLoading) {
      return _buildSkeletonLoader(isDarkMode);
    }

    return _buildCard(context, isDarkMode);
  }

  /// Construye el skeleton loader mientras carga
  Widget _buildSkeletonLoader(bool isDarkMode) {
    final bgColor = isDarkMode ? Colors.grey[800] : Colors.grey[200];
    final highlightColor = isDarkMode ? Colors.grey[700] : Colors.grey[100];

    return Shimmer.fromColors(
      baseColor: bgColor ?? Colors.grey[200]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            // Imagen placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            // Textos placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta completa con datos
  Widget _buildCard(BuildContext context, bool isDarkMode) {
    final borderColor = isDarkMode ? Colors.grey[700] : const Color(0xFFE2E8F0);
    final bgColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColorPrimary = isDarkMode ? Colors.white : Colors.black;
    final textColorSecondary =
        isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto / Avatar
                _buildPhoto(isDarkMode),
                const SizedBox(width: 16),
                // Información - Expandido para evitar overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        name.isNotEmpty ? name : 'Sin nombre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Kantumruy Pro',
                          color: textColorPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Especialidad
                      Text(
                        specialty.isNotEmpty
                            ? specialty
                            : 'Especialidad no especificada',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Kantumruy Pro',
                          color: textColorSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      // Rating + Precio + Disponibilidad - Responsive wrap
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Rating
                            if (rating != null && rating! > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Color(0xFFFFA500),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: textColorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            if (price != null && price! > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Text(
                                  '\$$price MXN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (isAvailable)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Disponible',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Botón "Ver perfil" - Responsive
                      ElevatedButton.icon(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text(
                          'Ver',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Kantumruy Pro',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el widget de foto con fallback
  Widget _buildPhoto(bool isDarkMode) {
    final photoUrlValid = photoUrl != null && photoUrl!.isNotEmpty;

    if (!photoUrlValid) {
      // Fallback: CircleAvatar con iniciales
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundColor:
              isDarkMode ? Colors.grey[800] : Colors.grey[200],
          child: Text(
            _getInitials(name),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    // CachedNetworkImage con fade-in
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 300),
          placeholder: (ctx, url) => Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
          errorWidget: (ctx, url, error) => Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.person_rounded,
                size: 40,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Extrae iniciales del nombre (ej. "Juan Pérez" → "JP")
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
