module uim.geosql.querybuilder;

import uim.geosql.types;
import uim.geosql.geometry;
import uim.geosql.spatial;
import std.array;
import std.algorithm;
import std.format;
import std.string;

/// Extended SQL query builder with spatial capabilities
class GeoSQLBuilder {
    private string[] _select;
    private string _from;
    private string[] _where;
    private string[] _orderBy;
    private string[] _groupBy;
    private int _limit = -1;
    private int _offset = -1;
    
    /// Add SELECT columns
    GeoSQLBuilder select(string[] columns...) {
        _select ~= columns;
        return this;
    }
    
    /// Set FROM table
    GeoSQLBuilder from(string table) {
        _from = table;
        return this;
    }
    
    /// Add WHERE condition
    GeoSQLBuilder where(string condition) {
        _where ~= condition;
        return this;
    }
    
    /// Add spatial WHERE condition: distance less than
    GeoSQLBuilder whereDistanceLessThan(string geomColumn, IGeometry geom, double maxDistance) {
        string condition = format("%s < %f", 
            SpatialFunctions.distance(geomColumn, 
                SpatialFunctions.geomFromText(geom.toWKT())),
            maxDistance);
        _where ~= condition;
        return this;
    }
    
    /// Add spatial WHERE condition: contains
    GeoSQLBuilder whereContains(string geomColumn, IGeometry geom) {
        string condition = format("%s = true", 
            SpatialFunctions.contains(geomColumn, 
                SpatialFunctions.geomFromText(geom.toWKT())));
        _where ~= condition;
        return this;
    }
    
    /// Add spatial WHERE condition: within
    GeoSQLBuilder whereWithin(string geomColumn, IGeometry geom) {
        string condition = format("%s = true", 
            SpatialFunctions.within(geomColumn, 
                SpatialFunctions.geomFromText(geom.toWKT())));
        _where ~= condition;
        return this;
    }
    
    /// Add spatial WHERE condition: intersects
    GeoSQLBuilder whereIntersects(string geomColumn, IGeometry geom) {
        string condition = format("%s = true", 
            SpatialFunctions.intersects(geomColumn, 
                SpatialFunctions.geomFromText(geom.toWKT())));
        _where ~= condition;
        return this;
    }
    
    /// Add spatial WHERE condition: within distance
    GeoSQLBuilder whereDWithin(string geomColumn, IGeometry geom, double distance) {
        string condition = format("%s = true", 
            SpatialFunctions.dWithin(geomColumn, 
                SpatialFunctions.geomFromText(geom.toWKT()), distance));
        _where ~= condition;
        return this;
    }
    
    /// Add ORDER BY clause
    GeoSQLBuilder orderBy(string column, bool ascending = true) {
        _orderBy ~= format("%s %s", column, ascending ? "ASC" : "DESC");
        return this;
    }
    
    /// Order by distance from a geometry
    GeoSQLBuilder orderByDistance(string geomColumn, IGeometry geom, bool ascending = true) {
        string distExpr = SpatialFunctions.distance(geomColumn, 
            SpatialFunctions.geomFromText(geom.toWKT()));
        _orderBy ~= format("%s %s", distExpr, ascending ? "ASC" : "DESC");
        return this;
    }
    
    /// Add GROUP BY clause
    GeoSQLBuilder groupBy(string[] columns...) {
        _groupBy ~= columns;
        return this;
    }
    
    /// Set LIMIT
    GeoSQLBuilder limit(int limit) {
        _limit = limit;
        return this;
    }
    
    /// Set OFFSET
    GeoSQLBuilder offset(int offset) {
        _offset = offset;
        return this;
    }
    
    /// Build the SQL query string
    string build() {
        string query;
        
        // SELECT
        if (_select.length == 0) {
            query = "SELECT *";
        } else {
            query = format("SELECT %s", _select.join(", "));
        }
        
        // FROM
        if (_from.length > 0) {
            query ~= format(" FROM %s", _from);
        }
        
        // WHERE
        if (_where.length > 0) {
            query ~= format(" WHERE %s", _where.join(" AND "));
        }
        
        // GROUP BY
        if (_groupBy.length > 0) {
            query ~= format(" GROUP BY %s", _groupBy.join(", "));
        }
        
        // ORDER BY
        if (_orderBy.length > 0) {
            query ~= format(" ORDER BY %s", _orderBy.join(", "));
        }
        
        // LIMIT
        if (_limit > 0) {
            query ~= format(" LIMIT %d", _limit);
        }
        
        // OFFSET
        if (_offset > 0) {
            query ~= format(" OFFSET %d", _offset);
        }
        
        return query;
    }
    
    /// Reset the builder
    void reset() {
        _select = [];
        _from = null;
        _where = [];
        _orderBy = [];
        _groupBy = [];
        _limit = -1;
        _offset = -1;
    }
}
