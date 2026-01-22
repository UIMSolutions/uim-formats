module geosql.examples.spatial_operations;

import std.stdio;
import uim.geosql;

void main() {
    writeln("=== UIM GeoSQL Spatial Operations Examples ===\n");
    
    // Example 1: Working with different SRIDs
    writeln("1. Spatial Reference Systems:");
    writeln("  WGS84 (GPS): ", SRID.WGS84);
    writeln("  Web Mercator: ", SRID.WebMercator);
    writeln("  NAD83: ", SRID.NAD83);
    writeln();
    
    // Example 2: Spatial predicates
    writeln("2. Spatial Predicates:");
    writeln("  Contains: ", SpatialFunctions.contains("polygon_col", "point_col"));
    writeln("  Within: ", SpatialFunctions.within("point_col", "polygon_col"));
    writeln("  Intersects: ", SpatialFunctions.intersects("geom1", "geom2"));
    writeln("  DWithin: ", SpatialFunctions.dWithin("geom1", "geom2", 500.0));
    writeln();
    
    // Example 3: Spatial measurements
    writeln("3. Spatial Measurements:");
    writeln("  Distance: ", SpatialFunctions.distance("loc1", "loc2"));
    writeln("  Area: ", SpatialFunctions.area("polygon"));
    writeln("  Length: ", SpatialFunctions.length("linestring"));
    writeln();
    
    // Example 4: Spatial processing
    writeln("4. Spatial Processing:");
    writeln("  Buffer: ", SpatialFunctions.buffer("location", 1000.0));
    writeln("  Centroid: ", SpatialFunctions.centroid("polygon"));
    writeln("  Envelope: ", SpatialFunctions.envelope("geometry"));
    writeln("  Union: ", SpatialFunctions.union_("geom1", "geom2"));
    writeln("  Intersection: ", SpatialFunctions.intersection("geom1", "geom2"));
    writeln("  Difference: ", SpatialFunctions.difference("geom1", "geom2"));
    writeln();
    
    // Example 5: Format conversions
    writeln("5. Format Conversions:");
    writeln("  AsText: ", SpatialFunctions.asText("geometry"));
    writeln("  AsBinary: ", SpatialFunctions.asBinary("geometry"));
    writeln("  GeomFromText: ", SpatialFunctions.geomFromText("POINT(10 20)", SRID.WGS84));
    writeln("  Transform: ", SpatialFunctions.transform("geometry", SRID.WebMercator));
    writeln();
    
    // Example 6: Geometry validation
    writeln("6. Geometry Validation:");
    auto validPolygon = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(1, 0),
        Coordinate(1, 1),
        Coordinate(0, 1),
        Coordinate(0, 0)
    ]);
    writeln("  Valid polygon: ", validPolygon.isValid());
    
    auto invalidPolygon = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(1, 0)
    ]);
    writeln("  Invalid polygon (too few points): ", invalidPolygon.isValid());
    writeln();
    
    // Example 7: Bounding box operations
    writeln("7. Bounding Box Operations:");
    auto line = new GeoLineString([
        Coordinate(-10, -5),
        Coordinate(0, 0),
        Coordinate(10, 5)
    ]);
    auto bbox = line.getBounds();
    writeln("  Bounds: [", bbox.minX, ", ", bbox.minY, "] to [", bbox.maxX, ", ", bbox.maxY, "]");
    writeln("  Contains (5, 2.5): ", bbox.contains(Coordinate(5, 2.5)));
    writeln("  Contains (15, 10): ", bbox.contains(Coordinate(15, 10)));
    writeln();
    
    // Example 8: Complex query combining operations
    writeln("8. Complex Spatial Query:");
    auto poi = new GeoPoint(-122.4194, 37.7749);
    
    auto complexQuery = new GeoSQLBuilder()
        .select(
            "id",
            "name",
            SpatialFunctions.distance("location", 
                SpatialFunctions.geomFromText(poi.toWKT())) ~ " as distance",
            SpatialFunctions.asText("location") ~ " as wkt",
            SpatialFunctions.area(
                SpatialFunctions.buffer("location", 1000.0)
            ) ~ " as buffer_area"
        )
        .from("places")
        .where(SpatialFunctions.dWithin("location", 
            SpatialFunctions.geomFromText(poi.toWKT()), 5000.0) ~ " = true")
        .orderBy("distance")
        .limit(10)
        .build();
    
    writeln(complexQuery);
    
    writeln("\n=== Spatial Operations Examples Complete ===");
}
