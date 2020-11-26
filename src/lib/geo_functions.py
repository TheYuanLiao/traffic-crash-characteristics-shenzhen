# -*- coding: utf-8 -*-
from geopandas import GeoDataFrame
from shapely.geometry import Point
import geopandas as gpd


def df2gdf_point(df, x_field, y_field, crs={'init': 'epsg:4326'}):
    """
    Convert a dataframe into a geodataframe with the specified x and y point coordinates.
    :param df: dataframe that contains X and Y
    :param x_field: string, column name for X
    :param y_field: string, column name for Y
    :param crs: crs of X and Y
    :return: a geodataframe of Points
    """
    geometry = [Point(xy) for xy in zip(df[x_field], df[y_field])]
    gdf = GeoDataFrame(df, crs=crs, geometry=geometry)
    return gdf


def point2zone(gdf_zone, gdf, var2return="zone"):
    """
    Find the zone number of a Point geodataframe.
    :param gdf_zone: geodataframe, zones
    :param gdf: geodataframe, points
    :param var2return: specified field to return
    :return: an 1-d array of var2return
    """
    gdf_zone = gpd.sjoin(gdf, gdf_zone.loc[:, [var2return, "geometry"]], how="left")
    return gdf_zone.loc[:, var2return].values
