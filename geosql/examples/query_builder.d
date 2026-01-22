module geosql.examples.query_builder;

import std.stdio;
import uim.geosql;

void main() {
    writeln("=== UIM GeoSQL Query Builder Examples ===\n");
    
    // Example 1: Simple spatial query
    writeln("1. Find locations within distance:");
    auto searchPoint = new GeoPoint(-73.935242, 40.730610); // NYC coordinates
    
    auto query1 = new GeoSQLBuilder()
        .select("id", "name", "ST_AsText(location) as location")
        .from("places")
        .whereDistanceLessThan("location", searchPoint, 1000.0)
        .orderByDistance("location", searchPoint)
        .limit(10)
        .build();
    
    writeln(query1);
    writeln();
    
    // Example 2: Find points within a polygon
    writeln("2. Find points within polygon:");
    auto boundary = new GeoPolygon([
        Coordinate(-74.0, 40.7),
        Coordinate(-73.9, 40.7),
        Coordinate(-73.9, 40.8),
        Coordinate(-74.0, 40.8),
        Coordinate(-74.0, 40.7)
    ]);
    
    auto query2 = new GeoSQLBuilder()
        .select("*")
        .from("restaurants")
        .whereWithin("location", boundary)
        .orderBy("name")
        .build();
    
    writeln(query2);
    writeln();
    
    // Example 3: Find intersecting geometries
    writeln("3. Find intersecting areas:");
    auto searchArea = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(10, 0),
        Coordinate(10, 10),
        Coordinate(0, 10),
        Coordinate(0, 0)
    ]);
    
    auto query3 = new GeoSQLBuilder()
        .select("id", "name", "ST_Area(boundary) as area")
        .from("districts")
        .whereIntersects("boundary", searchArea)
        .groupBy("id", "name", "boundary")
        .orderBy("area", false) // Descending
        .build();
    
    writeln(query3);
    writeln();
    
    // Example 4: Complex spatial query with multiple conditions
    writeln("4. Complex query - nearby locations outside boundary:");
    auto center = new GeoPoint(-73.935242, 40.730610);
    auto exclusionZone = new GeoPolygon([
        Coordinate(-73.94, 40.73),
        Coordinate(-73.93, 40.73),
        Coordinate(-73.93, 40.74),
        Coordinate(-73.94, 40.74),
        Coordinate(-73.94, 40.73)
    ]);
    
    auto query4 = new GeoSQLBuilder()
        .select(
            "id",
            "name",
            SpatialFunctions.distance("location", 
                SpatialFunctions.geomFromText(center.toWKT())) ~ " as distance"
        )
        .from("stores")
        .whereDWithin("location", center, 5000.0)
        .where("NOT " ~ SpatialFunctions.within("location", 
            SpatialFunctions.geomFromText(exclusionZone.toWKT())))
        .orderByDistance("location", center)
        .limit(20)
        .build();
    
    writeln(query4);
    writeln();
    
    // Example 5: Aggregation with spatial functions
    writeln("5. Aggregate query - count by distance ranges:");
    auto queryCenter = new GeoPoint(0, 0);
    
    auto query5 = new GeoSQLBuilder()
        .select(
            "CASE " ~
            "  WHEN " ~ SpatialFunctions.distance("location", 
                SpatialFunctions.geomFromText(queryCenter.toWKT())) ~ " < 1000 THEN 'near' " ~
            "  WHEN " ~ SpatialFunctions.distance("location", 
                SpatialFunctions.geomFromText(queryCenter.toWKT())) ~ " < 5000 THEN 'medium' " ~
            "  ELSE 'far' " ~
            "END as distance_range",
            "COUNT(*) as count"
        )
        .from("locations")
        .groupBy("distance_range")
        .orderBy("count", false)
        .build();
    
    writeln(query5);
    writeln();
    
    // Example 6: Using spatial transformations
    writeln("6. Query with coordinate transformation:");
    auto wgs84Point = new GeoPoint(-122.4194, 37.7749); // San Francisco in WGS84
    
    auto query6 = new GeoSQLBuilder()
        .select(
            "id",
            "name",
            SpatialFunctions.asText(
                SpatialFunctions.transform("location", SRID.WebMercator)
            ) ~ " as location_web_mercator"
        )
        .from("landmarks")
        .whereDistanceLessThan("location", wgs84Point, 10000.0)
        .build();
    
    writeln(query6);
    
    writeln("\n=== Query Examples Complete ===");
}
