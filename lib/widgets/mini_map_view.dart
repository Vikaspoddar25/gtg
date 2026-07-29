import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:gtg/theme/app_colors.dart';

/// A small map preview centered on a lat/lng.
///
/// Renders a real interactive Mapbox map on Android/iOS. The stable Mapbox
/// Maps Flutter SDK (v2) has no web renderer, so on web this falls back to
/// a static, non-interactive placeholder styled like a map — swap this out
/// once Mapbox's web SDK (v3) reaches a stable release.
class MiniMapView extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final bool showMarker;

  /// When false, camera gestures (pan/zoom/rotate) are disabled — used for
  /// decorative/background maps (e.g. the Home screen header).
  final bool interactive;

  const MiniMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 14,
    this.showMarker = true,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || latitude == 0 && longitude == 0) {
      return _StaticMapPlaceholder(showMarker: showMarker);
    }
    return _InteractiveMap(
      latitude: latitude,
      longitude: longitude,
      zoom: zoom,
      showMarker: showMarker,
      interactive: interactive,
    );
  }
}

class _InteractiveMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final bool showMarker;
  final bool interactive;

  const _InteractiveMap({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.showMarker,
    required this.interactive,
  });

  @override
  State<_InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<_InteractiveMap> {
  Future<void> _onMapCreated(mb.MapboxMap map) async {
    if (!widget.interactive) {
      await map.gestures.updateSettings(mb.GesturesSettings(
        rotateEnabled: false,
        pitchEnabled: false,
        scrollEnabled: false,
        pinchToZoomEnabled: false,
        doubleTapToZoomInEnabled: false,
        doubleTouchToZoomOutEnabled: false,
      ));
    }
    if (widget.showMarker) {
      final manager = await map.annotations.createPointAnnotationManager();
      await manager.create(mb.PointAnnotationOptions(
        geometry: mb.Point(
          coordinates: mb.Position(widget.longitude, widget.latitude),
        ),
        iconSize: 1.2,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return mb.MapWidget(
      key: ValueKey('map-${widget.latitude}-${widget.longitude}'),
      viewport: mb.CameraViewportState(
        center: mb.Point(
          coordinates: mb.Position(widget.longitude, widget.latitude),
        ),
        zoom: widget.zoom,
      ),
      onMapCreated: _onMapCreated,
    );
  }
}

class _StaticMapPlaceholder extends StatelessWidget {
  final bool showMarker;
  const _StaticMapPlaceholder({required this.showMarker});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8ECEF),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.5,
            child: Icon(
              Icons.map_outlined,
              size: 64,
              color: AppColors.textPrimary.withValues(alpha: 0.4),
            ),
          ),
          if (showMarker)
            const Icon(
              Icons.location_pin,
              size: 36,
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }
}
