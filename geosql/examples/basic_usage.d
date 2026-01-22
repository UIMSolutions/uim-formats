module geosql.examples.basic_usage;

import std.stdio;
import uim.geosql;

void main() {
    writeln("=== UIM GeoSQL Basic Usage Examples ===\n");
    
    // Example 1: Creating geometries
    writeln("1. Creating Geometries:");
    auto point = new GeoPoint(10.0, 20.0);
    writeln("  Point: ", point.toWKT());
    
    auto point3d = new GeoPoint(10.0, 20.0, 30.0);
    writeln("  3D Point: ", point3d.toWKT());
    
    auto lineString = new GeoLineString([
        Coordinate(0, 0),
        Coordinate(1, 1),
        Coordinate(2, 0)
    ]);
    writeln("  LineString: ", lineString.toWKT());
    writeln("  Length: ", lineString.length());
    
    auto polygon = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(4, 0),
        Coordinate(4, 4),
        Coordinate(0, 4),
        Coordinate(0, 0)  // Closing point
    ]);
    writeln("  Polygon: ", polygon.toWKT());
    
    // Example 2: Parsing WKT
    writeln("\n2. Parsing WKT:");
    auto parsedPoint = WKTParser.parse("POINT(5 10)");
    writeln("  Parsed: ", parsedPoint.toWKT());
    
    auto parsedLine = WKTParser.parse("LINESTRING(0 0, 1 1, 2 2)");
    writeln("  Parsed: ", parsedLine.toWKT());
    
    // Example 3: Distance calculations
    writeln("\n3. Distance Calculations:");
    auto p1 = new GeoPoint(0, 0);
    auto p2 = new GeoPoint(3, 4);
    writeln("  Distance between ", p1.toWKT(), " and ", p2.toWKT(), ": ", p1.distanceTo(p2));
    
    // Example 4: Bounding boxes
    writeln("\n4. Bounding Boxes:");
    auto bbox = lineString.getBounds();
    writeln("  LineString bounds: minX=", bbox.minX, " minY=", bbox.minY, 
            " maxX=", bbox.maxX, " maxY=", bbox.maxY);
    
    // Example 5: Spatial SQL functions
    writeln("\n5. Spatial SQL Functions:");
    writeln("  ST_Distance: ", SpatialFunctions.distance("location", "ST_GeomFromText('POINT(0 0)')"));
    writeln("  ST_Contains: ", SpatialFunctions.contains("boundary", "point_geom"));
    writeln("  ST_Buffer: ", SpatialFunctions.buffer("location", 100.0));
    writeln("  ST_GeomFromText: ", SpatialFunctions.geomFromText("POINT(10 20)", SRID.WGS84));
    
    // Example 6: Multi-geometries
    writeln("\n6. Multi-Geometries:");
    auto multiPoint = new GeoMultiPoint([
        new GeoPoint(0, 0),
        new GeoPoint(1, 1),
        new GeoPoint(2, 2)
    ]);
    writeln("  MultiPoint: ", multiPoint.toWKT());
    
    writeln("\n=== Examples Complete ===");
}
