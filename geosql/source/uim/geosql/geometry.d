module uim.geosql.geometry;

import uim.geosql.types;
import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.math;
import std.format;

/// Point geometry
class GeoPoint : IGeometry {
    Coordinate coordinate;
    
    this(double x, double y) {
        coordinate = Coordinate(x, y);
    }
    
    this(double x, double y, double z) {
        coordinate = Coordinate(x, y, z);
    }
    
    this(Coordinate coord) {
        coordinate = coord;
    }
    
    override GeometryType type() const {
        return GeometryType.Point;
    }
    
    override string toWKT() const {
        if (coordinate.is3D()) {
            return format("POINT Z (%f %f %f)", coordinate.x, coordinate.y, coordinate.z);
        }
        return format("POINT(%f %f)", coordinate.x, coordinate.y);
    }
    
    override bool isValid() const {
        return !isNaN(coordinate.x) && !isNaN(coordinate.y);
    }
    
    override BoundingBox getBounds() const {
        return BoundingBox(coordinate.x, coordinate.y, coordinate.x, coordinate.y);
    }
    
    double distanceTo(const GeoPoint other) const {
        return coordinate.distanceTo(other.coordinate);
    }
}

/// LineString geometry
class GeoLineString : IGeometry {
    Coordinate[] coordinates;
    
    this(Coordinate[] coords) {
        coordinates = coords;
    }
    
    override GeometryType type() const {
        return GeometryType.LineString;
    }
    
    override string toWKT() const {
        if (coordinates.length == 0) {
            return "LINESTRING EMPTY";
        }
        
        string coords = coordinates.map!(c => c.toString()).join(", ");
        return format("LINESTRING(%s)", coords);
    }
    
    override bool isValid() const {
        return coordinates.length >= 2;
    }
    
    override BoundingBox getBounds() const {
        if (coordinates.length == 0) {
            return BoundingBox(0, 0, 0, 0);
        }
        
        double minX = coordinates[0].x;
        double minY = coordinates[0].y;
        double maxX = coordinates[0].x;
        double maxY = coordinates[0].y;
        
        foreach (coord; coordinates) {
            minX = min(minX, coord.x);
            minY = min(minY, coord.y);
            maxX = max(maxX, coord.x);
            maxY = max(maxY, coord.y);
        }
        
        return BoundingBox(minX, minY, maxX, maxY);
    }
    
    /// Calculate the length of the linestring
    double length() const {
        double total = 0.0;
        for (size_t i = 1; i < coordinates.length; i++) {
            total += coordinates[i-1].distanceTo(coordinates[i]);
        }
        return total;
    }
}

/// Polygon geometry
class GeoPolygon : IGeometry {
    Coordinate[][] rings; // First ring is exterior, rest are holes
    
    this(Coordinate[][] rings) {
        this.rings = rings;
    }
    
    this(Coordinate[] exteriorRing) {
        this.rings = [exteriorRing];
    }
    
    override GeometryType type() const {
        return GeometryType.Polygon;
    }
    
    override string toWKT() const {
        if (rings.length == 0) {
            return "POLYGON EMPTY";
        }
        
        string[] ringStrings;
        foreach (ring; rings) {
            string coords = ring.map!(c => c.toString()).join(", ");
            ringStrings ~= format("(%s)", coords);
        }
        
        return format("POLYGON(%s)", ringStrings.join(", "));
    }
    
    override bool isValid() const {
        if (rings.length == 0) return false;
        
        // Exterior ring must have at least 4 points (including closing point)
        if (rings[0].length < 4) return false;
        
        // Rings must be closed (first point == last point)
        foreach (ring; rings) {
            if (ring.length < 4) return false;
            auto first = ring[0];
            auto last = ring[$-1];
            if (first.x != last.x || first.y != last.y) return false;
        }
        
        return true;
    }
    
    override BoundingBox getBounds() const {
        if (rings.length == 0 || rings[0].length == 0) {
            return BoundingBox(0, 0, 0, 0);
        }
        
        double minX = rings[0][0].x;
        double minY = rings[0][0].y;
        double maxX = rings[0][0].x;
        double maxY = rings[0][0].y;
        
        foreach (coord; rings[0]) {
            minX = min(minX, coord.x);
            minY = min(minY, coord.y);
            maxX = max(maxX, coord.x);
            maxY = max(maxY, coord.y);
        }
        
        return BoundingBox(minX, minY, maxX, maxY);
    }
}

/// MultiPoint geometry
class GeoMultiPoint : IGeometry {
    GeoPoint[] points;
    
    this(GeoPoint[] points) {
        this.points = points;
    }
    
    override GeometryType type() const {
        return GeometryType.MultiPoint;
    }
    
    override string toWKT() const {
        if (points.length == 0) {
            return "MULTIPOINT EMPTY";
        }
        
        string coords = points.map!(p => p.coordinate.toString()).join(", ");
        return format("MULTIPOINT(%s)", coords);
    }
    
    override bool isValid() const {
        return points.all!(p => p.isValid());
    }
    
    override BoundingBox getBounds() const {
        if (points.length == 0) {
            return BoundingBox(0, 0, 0, 0);
        }
        
        auto first = points[0].coordinate;
        double minX = first.x;
        double minY = first.y;
        double maxX = first.x;
        double maxY = first.y;
        
        foreach (point; points) {
            auto coord = point.coordinate;
            minX = min(minX, coord.x);
            minY = min(minY, coord.y);
            maxX = max(maxX, coord.x);
            maxY = max(maxY, coord.y);
        }
        
        return BoundingBox(minX, minY, maxX, maxY);
    }
}
