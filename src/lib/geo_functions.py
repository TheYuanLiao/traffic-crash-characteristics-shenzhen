# -*- coding: utf-8 -*-
from geopandas import GeoDataFrame
from shapely.geometry import Point
import geopandas as gpd


def df2gdf_point(df, x_field, y_field, crs={'init': 'epsg:4326'}):
    geometry = [Point(xy) for xy in zip(df[x_field], df[y_field])]
    gdf = GeoDataFrame(df, crs=crs, geometry=geometry)
    return gdf


def point2zone(gdf_zone, gdf, var2return="zone"):
    gdf_zone = gpd.sjoin(gdf, gdf_zone.loc[:, [var2return, "geometry"]], how="left")
    return gdf_zone.loc[:, var2return].values
