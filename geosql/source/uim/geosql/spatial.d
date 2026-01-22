module uim.geosql.spatial;

import uim.geosql.types;
import uim.geosql.geometry;
import std.format;
import std.string;

/// Spatial SQL function builder
class SpatialFunctions {
    
    /// Generate ST_Distance SQL function
    static string distance(string geom1, string geom2) {
        return format("ST_Distance(%s, %s)", geom1, geom2);
    }
    
    /// Generate ST_Contains SQL function
    static string contains(string geom1, string geom2) {
        return format("ST_Contains(%s, %s)", geom1, geom2);
    }
    
    /// Generate ST_Within SQL function
    static string within(string geom1, string geom2) {
        return format("ST_Within(%s, %s)", geom1, geom2);
    }
    
    /// Generate ST_Intersects SQL function
    static string intersects(string geom1, string geom2) {
        return format("ST_Intersects(%s, %s)", geom1, geom2);
    }
    
    /// Generate ST_Buffer SQL function
    static string buffer(string geom, double distance) {
        return format("ST_Buffer(%s, %f)", geom, distance);
    }
    
    /// Generate ST_Area SQL function
    static string area(string geom) {
        return format("ST_Area(%s)", geom);
    }
    
    /// Generate ST_Length SQL function
    static string length(string geom) {
        return format("ST_Length(%s)", geom);
    }
    
    /// Generate ST_Centroid SQL function
    static string centroid(string geom) {
        return format("ST_Centroid(%s)", geom);
    }
    
    /// Generate ST_Envelope SQL function (bounding box)
    static string envelope(string geom) {
        return format("ST_Envelope(%s)", geom);
    }
    
    /// Generate ST_GeomFromText SQL function
    static string geomFromText(string wkt, int srid = 4326) {
        return format("ST_GeomFromText('%s', %d)", wkt, srid);
    }
    
    /// Generate ST_AsText SQL function
    static string asText(string geom) {
        return format("ST_AsText(%s)", geom);
    }
    
    /// Generate ST_AsBinary SQL function
    static string asBinary(string geom) {
        return format("ST_AsBinary(%s)", geom);
    }
    
    /// Generate ST_SRID SQL function
    static string srid(string geom) {
        return format("ST_SRID(%s)", geom);
    }
    
    /// Generate ST_Transform SQL function (coordinate transformation)
    static string transform(string geom, int toSRID) {
        return format("ST_Transform(%s, %d)", geom, toSRID);
    }
    
    /// Generate ST_Union SQL function
    static string union_(string geom1, string geom2) {
        return format("ST_Union(%s, %s)", geom1, geom2);
    }
    
    /// Generate ST_Difference SQL function
    static string difference(string geom1, string geom2) {
        return format("ST_Difference(%s, %s)", geom1, geom2);
    }
    
    /// Generate ST_Intersection SQL function
    static string intersection(string geom1, string geom2) {
        return format("ST_Intersection(%s, %s)", geom1, geom2);
    }
    
    /// Generate ST_DWithin SQL function (distance within)
    static string dWithin(string geom1, string geom2, double distance) {
        return format("ST_DWithin(%s, %s, %f)", geom1, geom2, distance);
    }
    
    /// Generate ST_MakePoint SQL function
    static string makePoint(double x, double y) {
        return format("ST_MakePoint(%f, %f)", x, y);
    }
    
    /// Generate ST_MakePoint SQL function for 3D
    static string makePoint(double x, double y, double z) {
        return format("ST_MakePoint(%f, %f, %f)", x, y, z);
    }
}

/// Spatial Reference System ID (SRID) constants
enum SRID {
    WGS84 = 4326,      /// World Geodetic System 1984 (GPS)
    WebMercator = 3857, /// Web Mercator (used by Google Maps, OpenStreetMap)
    NAD83 = 4269,      /// North American Datum 1983
    NAD27 = 4267,      /// North American Datum 1927
}
