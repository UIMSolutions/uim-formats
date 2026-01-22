module uim.geosql.wkt;

import uim.geosql.types;
import uim.geosql.geometry;
import std.string;
import std.array;
import std.algorithm;
import std.conv;
import std.regex;
import std.stdio;

/// Parse WKT (Well-Known Text) string to geometry
class WKTParser {
    
    /// Parse a WKT string and return appropriate geometry
    static IGeometry parse(string wkt) {
        wkt = wkt.strip();
        
        if (wkt.toUpper().startsWith("POINT")) {
            return parsePoint(wkt);
        } else if (wkt.toUpper().startsWith("LINESTRING")) {
            return parseLineString(wkt);
        } else if (wkt.toUpper().startsWith("POLYGON")) {
            return parsePolygon(wkt);
        } else if (wkt.toUpper().startsWith("MULTIPOINT")) {
            return parseMultiPoint(wkt);
        }
        
        throw new Exception("Unsupported WKT geometry type: " ~ wkt);
    }
    
    /// Parse POINT WKT
    static GeoPoint parsePoint(string wkt) {
        auto match = matchFirst(wkt, regex(r"POINT\s*Z?\s*\(([^)]+)\)", "i"));
        if (match.empty) {
            throw new Exception("Invalid POINT WKT: " ~ wkt);
        }
        
        auto coords = parseCoordinate(match[1]);
        return new GeoPoint(coords);
    }
    
    /// Parse LINESTRING WKT
    static GeoLineString parseLineString(string wkt) {
        auto match = matchFirst(wkt, regex(r"LINESTRING\s*\(([^)]+)\)", "i"));
        if (match.empty) {
            throw new Exception("Invalid LINESTRING WKT: " ~ wkt);
        }
        
        auto coords = parseCoordinateSequence(match[1]);
        return new GeoLineString(coords);
    }
    
    /// Parse POLYGON WKT
    static GeoPolygon parsePolygon(string wkt) {
        auto match = matchFirst(wkt, regex(r"POLYGON\s*\((.+)\)", "i"));
        if (match.empty) {
            throw new Exception("Invalid POLYGON WKT: " ~ wkt);
        }
        
        Coordinate[][] rings;
        auto ringMatches = matchAll(match[1], regex(r"\(([^)]+)\)"));
        
        foreach (ringMatch; ringMatches) {
            rings ~= parseCoordinateSequence(ringMatch[1]);
        }
        
        return new GeoPolygon(rings);
    }
    
    /// Parse MULTIPOINT WKT
    static GeoMultiPoint parseMultiPoint(string wkt) {
        auto match = matchFirst(wkt, regex(r"MULTIPOINT\s*\((.+)\)", "i"));
        if (match.empty) {
            throw new Exception("Invalid MULTIPOINT WKT: " ~ wkt);
        }
        
        GeoPoint[] points;
        auto coords = parseCoordinateSequence(match[1]);
        
        foreach (coord; coords) {
            points ~= new GeoPoint(coord);
        }
        
        return new GeoMultiPoint(points);
    }
    
    /// Parse a single coordinate from string
    private static Coordinate parseCoordinate(string coordStr) {
        auto parts = coordStr.strip().split!isWhite();
        
        if (parts.length < 2) {
            throw new Exception("Invalid coordinate: " ~ coordStr);
        }
        
        double x = to!double(parts[0]);
        double y = to!double(parts[1]);
        
        if (parts.length >= 3) {
            double z = to!double(parts[2]);
            return Coordinate(x, y, z);
        }
        
        return Coordinate(x, y);
    }
    
    /// Parse a sequence of coordinates
    private static Coordinate[] parseCoordinateSequence(string coordSeq) {
        Coordinate[] coords;
        
        auto parts = coordSeq.split(",");
        foreach (part; parts) {
            coords ~= parseCoordinate(part);
        }
        
        return coords;
    }
}

/// Builder for creating WKT strings
class WKTBuilder {
    
    /// Build WKT for a point
    static string buildPoint(double x, double y) {
        return format("POINT(%f %f)", x, y);
    }
    
    /// Build WKT for a 3D point
    static string buildPoint(double x, double y, double z) {
        return format("POINT Z (%f %f %f)", x, y, z);
    }
    
    /// Build WKT for a linestring
    static string buildLineString(Coordinate[] coords) {
        if (coords.length == 0) {
            return "LINESTRING EMPTY";
        }
        
        string coordStr = coords.map!(c => c.toString()).join(", ");
        return format("LINESTRING(%s)", coordStr);
    }
    
    /// Build WKT for a polygon
    static string buildPolygon(Coordinate[][] rings) {
        if (rings.length == 0) {
            return "POLYGON EMPTY";
        }
        
        string[] ringStrs;
        foreach (ring; rings) {
            string coordStr = ring.map!(c => c.toString()).join(", ");
            ringStrs ~= format("(%s)", coordStr);
        }
        
        return format("POLYGON(%s)", ringStrs.join(", "));
    }
}
