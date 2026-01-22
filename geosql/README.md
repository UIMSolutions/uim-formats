# UIM GeoSQL Library

Geographic/Spatial SQL support library for the UIM framework.

## Features

- **Geometry Types**: Support for Point, LineString, Polygon, MultiPoint, MultiLineString, MultiPolygon
- **WKT Support**: Well-Known Text parsing and generation
- **WKB Support**: Well-Known Binary format handling
- **Spatial Operations**: Distance, intersection, contains, within, and more
- **SQL Integration**: Seamless integration with UIM SQL query builder
- **Database Support**: Compatible with PostGIS, MySQL Spatial, SQL Server Spatial

## Installation

Add this to your `dub.sdl`:

```sdl
dependency "uim-geosql" path="../geosql"
```

## Quick Start

```d
import uim.geosql;

// Create a point
auto point = GeoPoint(10.0, 20.0);
writeln(point.toWKT()); // "POINT(10 20)"

// Create a linestring
auto line = GeoLineString([
    GeoPoint(0, 0),
    GeoPoint(1, 1),
    GeoPoint(2, 0)
]);

// Build spatial queries
auto query = GeoSQLBuilder()
    .select("id", "name", "ST_AsText(location) as location")
    .from("places")
    .where("ST_Distance(location, ST_GeomFromText('POINT(10 20)')) < 1000")
    .build();
```

## Geometry Types

### Point
```d
auto point = GeoPoint(longitude, latitude);
auto point3d = GeoPoint(x, y, z);
```

### LineString
```d
auto line = GeoLineString([point1, point2, point3]);
```

### Polygon
```d
auto polygon = GeoPolygon([
    [point1, point2, point3, point1] // exterior ring (must be closed)
]);
```

## Spatial Functions

The library provides wrappers for common spatial SQL functions:

- `ST_Distance()` - Calculate distance between geometries
- `ST_Contains()` - Check if one geometry contains another
- `ST_Within()` - Check if geometry is within another
- `ST_Intersects()` - Check if geometries intersect
- `ST_Buffer()` - Create buffer around geometry
- `ST_Area()` - Calculate area of polygon
- `ST_Length()` - Calculate length of linestring

## License

MIT License
