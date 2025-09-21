import 'package:flutter_test/flutter_test.dart';
import 'package:food_discovery_app/core/utils/location_utils.dart';

void main() {
  group('LocationUtils', () {
    group('calculateDistance', () {
      test('should return 0 for same coordinates', () {
        const lat = 19.0760;
        const lon = 72.8777;

        expect(
          LocationUtils.calculateDistance(lat, lon, lat, lon),
          0.0,
        );
      });

      test('should calculate correct distance between Mumbai locations', () {
        // Colaba to Bandra (approximately 13-14 km)
        const colabaLat = 18.9217;
        const colabaLon = 72.8327;
        const bandraLat = 19.0540;
        const bandraLon = 72.8340;

        final distance = LocationUtils.calculateDistance(
          colabaLat,
          colabaLon,
          bandraLat,
          bandraLon,
        );

        expect(distance, greaterThan(13.0));
        expect(distance, lessThan(15.0));
      });

      test('should calculate small distances accurately', () {
        // 1 km apart (approximate)
        const lat1 = 19.0760;
        const lon1 = 72.8777;
        const lat2 = 19.0850;
        const lon2 = 72.8777;

        final distance =
            LocationUtils.calculateDistance(lat1, lon1, lat2, lon2);

        expect(distance, greaterThan(0.9));
        expect(distance, lessThan(1.1));
      });
    });

    group('isWithinRadius', () {
      test('should return true for points within radius', () {
        const centerLat = 19.0760;
        const centerLon = 72.8777;
        const nearbyLat = 19.0800;
        const nearbyLon = 72.8800;

        expect(
          LocationUtils.isWithinRadius(
            centerLat,
            centerLon,
            nearbyLat,
            nearbyLon,
            2.0,
          ),
          true,
        );
      });

      test('should return false for points outside radius', () {
        const centerLat = 19.0760;
        const centerLon = 72.8777;
        const farLat = 19.2307; // Borivali
        const farLon = 72.8567;

        expect(
          LocationUtils.isWithinRadius(
            centerLat,
            centerLon,
            farLat,
            farLon,
            5.0,
          ),
          false,
        );
      });

      test('should handle edge cases at exact radius', () {
        const centerLat = 19.0760;
        const centerLon = 72.8777;
        const edgeLat = 19.0940; // Approximately 2km north
        const edgeLon = 72.8777;

        final distance = LocationUtils.calculateDistance(
          centerLat,
          centerLon,
          edgeLat,
          edgeLon,
        );

        // Test with radius slightly larger than actual distance
        expect(
          LocationUtils.isWithinRadius(
            centerLat,
            centerLon,
            edgeLat,
            edgeLon,
            distance + 0.1,
          ),
          true,
        );

        // Test with radius slightly smaller than actual distance
        expect(
          LocationUtils.isWithinRadius(
            centerLat,
            centerLon,
            edgeLat,
            edgeLon,
            distance - 0.1,
          ),
          false,
        );
      });
    });
  });
}
