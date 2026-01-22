module uim.geosql.types;

import std.stdio;
import std.conv;
import std.math;
import std.array;
import std.algorithm;

/// Base geometry type enumeration
enum GeometryType {
    Point,
    LineString,
    Polygon,
    MultiPoint,
    MultiLineString,
    MultiPolygon,
    GeometryCollection
}

/// Coordinate struct for 2D/3D coordinates
struct Coordinate {
    double x;
    double y;
    double z = double.nan;
    
    /// Check if this is a 3D coordinate
    bool is3D() const {
        return !isNaN(z);
    }
    
    /// Calculate distance to another coordinate
    double distanceTo(const Coordinate other) const {
        double dx = x - other.x;
        double dy = y - other.y;
        
        if (is3D() && other.is3D()) {
            double dz = z - other.z;
            return sqrt(dx * dx + dy * dy + dz * dz);
        }
        return sqrt(dx * dx + dy * dy);
    }
    
    /// Convert to string representation
    string toString() const {
        if (is3D()) {
            return format("%f %f %f", x, y, z);
        }
        return format("%f %f", x, y);
    }
}

/// Base interface for all geometry types
interface IGeometry {
    /// Get the geometry type
    GeometryType type() const;
    
    /// Get WKT (Well-Known Text) representation
    string toWKT() const;
    
    /// Check if geometry is valid
    bool isValid() const;
    
    /// Get bounding box
    BoundingBox getBounds() const;
}

/// Bounding box representation
struct BoundingBox {
    double minX, minY, maxX, maxY;
    
    /// Check if this box contains a coordinate
    bool contains(const Coordinate coord) const {
        return coord.x >= minX && coord.x <= maxX &&
               coord.y >= minY && coord.y <= maxY;
    }
    
    /// Check if this box intersects another
    bool intersects(const BoundingBox other) const {
        return !(other.minX > maxX || other.maxX < minX ||
                 other.minY > maxY || other.maxY < minY);
    }
}
