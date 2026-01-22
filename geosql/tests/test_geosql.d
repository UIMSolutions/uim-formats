module geosql.tests.test_geosql;

import std.stdio;
import uim.geosql;

void testGeometryCreation() {
    writeln("Testing geometry creation...");
    
    auto point = new GeoPoint(10.0, 20.0);
    assert(point.isValid());
    assert(point.toWKT() == "POINT(10.000000 20.000000)");
    
    auto line = new GeoLineString([
        Coordinate(0, 0),
        Coordinate(1, 1)
    ]);
    assert(line.isValid());
    
    auto polygon = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(1, 0),
        Coordinate(1, 1),
        Coordinate(0, 1),
        Coordinate(0, 0)
    ]);
    assert(polygon.isValid());
    
    writeln("  ✓ Geometry creation tests passed");
}

void testWKTParsing() {
    writeln("Testing WKT parsing...");
    
    auto point = WKTParser.parse("POINT(5 10)");
    assert(point.type() == GeometryType.Point);
    
    auto line = WKTParser.parse("LINESTRING(0 0, 1 1, 2 2)");
    assert(line.type() == GeometryType.LineString);
    
    auto polygon = WKTParser.parse("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))");
    assert(polygon.type() == GeometryType.Polygon);
    
    writeln("  ✓ WKT parsing tests passed");
}

void testDistanceCalculations() {
    writeln("Testing distance calculations...");
    
    auto p1 = new GeoPoint(0, 0);
    auto p2 = new GeoPoint(3, 4);
    
    double distance = p1.distanceTo(p2);
    assert(distance == 5.0);
    
    writeln("  ✓ Distance calculation tests passed");
}

void testBoundingBoxes() {
    writeln("Testing bounding boxes...");
    
    auto line = new GeoLineString([
        Coordinate(-10, -5),
        Coordinate(0, 0),
        Coordinate(10, 5)
    ]);
    
    auto bbox = line.getBounds();
    assert(bbox.minX == -10);
    assert(bbox.minY == -5);
    assert(bbox.maxX == 10);
    assert(bbox.maxY == 5);
    
    assert(bbox.contains(Coordinate(0, 0)));
    assert(!bbox.contains(Coordinate(20, 20)));
    
    writeln("  ✓ Bounding box tests passed");
}

void testSpatialFunctions() {
    writeln("Testing spatial SQL functions...");
    
    string distFunc = SpatialFunctions.distance("loc1", "loc2");
    assert(distFunc == "ST_Distance(loc1, loc2)");
    
    string bufferFunc = SpatialFunctions.buffer("geom", 100.0);
    assert(bufferFunc == "ST_Buffer(geom, 100.000000)");
    
    string geomFromText = SpatialFunctions.geomFromText("POINT(10 20)", SRID.WGS84);
    assert(geomFromText == "ST_GeomFromText('POINT(10 20)', 4326)");
    
    writeln("  ✓ Spatial SQL function tests passed");
}

void testQueryBuilder() {
    writeln("Testing query builder...");
    
    auto point = new GeoPoint(10, 20);
    
    auto query = new GeoSQLBuilder()
        .select("id", "name")
        .from("places")
        .whereDistanceLessThan("location", point, 1000.0)
        .orderBy("name")
        .limit(10)
        .build();
    
    assert(query.length > 0);
    assert(query.indexOf("SELECT id, name") >= 0);
    assert(query.indexOf("FROM places") >= 0);
    assert(query.indexOf("LIMIT 10") >= 0);
    
    writeln("  ✓ Query builder tests passed");
}

void testGeometryValidation() {
    writeln("Testing geometry validation...");
    
    // Valid polygon
    auto validPoly = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(1, 0),
        Coordinate(1, 1),
        Coordinate(0, 1),
        Coordinate(0, 0)
    ]);
    assert(validPoly.isValid());
    
    // Invalid polygon (not closed)
    auto invalidPoly1 = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(1, 0),
        Coordinate(1, 1),
        Coordinate(0, 1)
    ]);
    assert(!invalidPoly1.isValid());
    
    // Invalid polygon (too few points)
    auto invalidPoly2 = new GeoPolygon([
        Coordinate(0, 0),
        Coordinate(1, 0)
    ]);
    assert(!invalidPoly2.isValid());
    
    writeln("  ✓ Geometry validation tests passed");
}

void main() {
    writeln("=== Running GeoSQL Tests ===\n");
    
    testGeometryCreation();
    testWKTParsing();
    testDistanceCalculations();
    testBoundingBoxes();
    testSpatialFunctions();
    testQueryBuilder();
    testGeometryValidation();
    
    writeln("\n=== All Tests Passed ✓ ===");
}
