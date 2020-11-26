# -*- coding: utf-8 -*-
import osmnx as ox
import pandas as pd
from geopandas import GeoDataFrame
import os
import json
import urllib.request
import urllib.parse
import hashlib
import csv
import numpy as np


def osm_net_retrieve(bbox, network_type, osm_folder="OSM/"):
    """
    Download .shp format road network within the specified bounding box
    :param bbox: tuple of (north, south, east, west)
    :param network_type: string e.g., 'drive'
    :param osm_folder: string, path to save the downloaded shapefile
    :return: None
    """
    north, south, east, west = bbox
    G = ox.graph_from_bbox(north, south, east, west, network_type=network_type)
    ox.save_graphml(G, filepath=os.path.join(osm_folder, network_type + '_network.graphml'))
    gdf = ox.graph_to_gdfs(G)
    edge = gdf[1]
    edge = edge.loc[:, ['geometry', 'highway', 'junction', 'length', 'maxspeed', 'name', 'oneway',
                        'osmid', 'u', 'v', 'width']]

    fields = ['highway', 'junction', 'length', 'maxspeed', 'name', 'oneway',
              'osmid', 'u', 'v', 'width']
    df_inter = pd.DataFrame()
    for f in fields:
        df_inter[f] = edge[f].astype(str)
    gdf_edge = GeoDataFrame(df_inter, geometry=edge["geometry"])
    gdf_edge.to_file(osm_folder + network_type + "_net.shp")


def osm_net_retrieve_polygon(polygon, network_type, osm_folder="OSM/"):
    """
    Download .shp format road network within the specified polygon
    :param polygon: polygon geodataframe
    :param network_type: string e.g., 'drive'
    :param osm_folder: string, path to save the downloaded shapefile
    :return: None
    """
    G = ox.graph_from_polygon(polygon, network_type=network_type)
    ox.save_graphml(G, filepath=os.path.join(osm_folder, network_type + '_network.graphml'))
    gdf = ox.graph_to_gdfs(G)
    edge = gdf[1]
    edge = edge.loc[:, ['geometry', 'highway', 'junction', 'length', 'maxspeed', 'name', 'oneway',
                        'osmid', 'u', 'v', 'width']]

    fields = ['highway', 'junction', 'length', 'maxspeed', 'name', 'oneway',
              'osmid', 'u', 'v', 'width']
    df_inter = pd.DataFrame()
    for f in fields:
        df_inter[f] = edge[f].astype(str)
    gdf_edge = GeoDataFrame(df_inter, geometry=edge["geometry"])
    gdf_edge.to_file(osm_folder + network_type + "_net.shp")


def baidu_poi(query, location, folder):
    """
    Search a certain POI at a given location's 500-m radius area.
    :param query: string e.g., '美食'
    :param location: string coordinates e.g., '34.004,56.214'
    :param folder: string path to save the returned json file
    :return: a json object containing the results returned by the API
    """
    # Load ak and sk
    df_k = pd.read_csv(os.path.join(folder, 'baidu_ak_sk.txt'))
    ak = df_k.loc[df_k['item'] == 'ak', 'value'].item()
    sk = df_k.loc[df_k['item'] == 'sk', 'value'].item()
    queryStr = f"/place/v2/search?query={query}&location={location}&radius=500&output=json&page_size=20&page_num=0&ak={ak}"
    encodedStr = urllib.parse.quote(queryStr, safe="/:=&?#+!$,;'@()*[]")
    # add sk
    rawStr = encodedStr + sk
    # calculate sn
    sn = (hashlib.md5(urllib.parse.quote_plus(rawStr).encode("utf8")).hexdigest())
    # Use parse.quote to process Chinese and return the usable url
    url = urllib.parse.quote("http://api.map.baidu.com" + queryStr + "&sn=" + sn, safe="/:=&?#+!$,;'@()*[]")
    data = urllib.request.urlopen(url)
    hjson = json.loads(data.read())
    return hjson


def zone_poi_search(row, poi_r_folder, list_df, target_file):
    """
    Take a row of a dataframe and write the corresponding POIs to the target file.
    :param row: a row of a dataframe
    :param poi_r_folder: path to save the target_file
    :param list_df: a list that contains the finished queries e.g., [(9, '美食'), ..., (1976, '美食')]
    :param target_file: string, file to write the the number of the POI
    :return:
    """
    if (row["zone"], row["POI"]) not in list_df:
        location = str(row["Y"]) + "," + str(row["X"])
        data = baidu_poi(row["POI"], location, poi_r_folder)
        if data["status"] == 0:
            rec_total = data["total"]
        else:
            rec_total = np.nan
        with open(os.path.join(poi_r_folder, target_file), 'a', newline='', encoding='utf-8-sig') as f:
            w = csv.writer(f)
            w.writerows([(row["zone"], row["POI"], rec_total)])


def poi_req_prep(df_grids, folder, csv_file_name='zone_visit_poi', batch=False):
    """
    Prepare queries to send to the API
    :param df_grids: a dataframe of zones' centroids, ['zone', 'X', 'Y']
    :param folder: path to save the query batches
    :param csv_file_name: string, file name to save the query batches
    :param batch: boolean, if true, divide the queries into batches
    :return:
    """
    POI_list = ["美食", "酒店", "购物", "生活服务", "丽人", "旅游景点", "休闲娱乐", "运动健身",
                "教育培训", "文化传媒", "医疗", "汽车服务", "金融", "房地产", "公司企业",
                "政府机构", "出入口", "自然地物", "交通设施"]
    df_query = pd.DataFrame(
        [(row['zone'], row['X'], row['Y'], x) for _, row in df_grids.iterrows() for x in POI_list],
        columns=["zone", "X", "Y", "POI"])

    if batch:
        def chunk(seq, size):
            return (seq[pos:pos + size] for pos in range(0, len(seq), size))

        batch_size = 30000
        batch = 1
        for df_chunk in chunk(df_query, batch_size):
            file = csv_file_name + "_batch%s.csv" % batch
            df_chunk.to_csv(os.path.join(folder, file), index=False, encoding="utf-8-sig")
            batch += 1
    else:
        df_query.to_csv(os.path.join(folder, csv_file_name + '.csv'), index=False, encoding="utf-8-sig")

    with open(os.path.join(folder, csv_file_name + "_output.csv"), 'a', newline='', encoding='utf-8-sig') as f:
        w = csv.writer(f)
        w.writerows([("zone", "POI", "POI_num")])

    return df_query
