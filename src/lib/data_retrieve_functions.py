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
    # Load ak and sk
    df_k = pd.read_csv(os.path.join(folder, 'baidu_ak_sk.txt'))
    ak = df_k.loc[df_k['item'] == 'ak', 'value'].item()
    sk = df_k.loc[df_k['item'] == 'sk', 'value'].item()
    # 以get请求为例http://api.map.baidu.com/geocoder/v2/?address=百度大厦&output=json&ak=你的ak
    queryStr = f"/place/v2/search?query={query}&location={location}&radius=500&output=json&page_size=20&page_num=0&ak={ak}"

    # 对queryStr进行转码，safe内的保留字符不转换
    encodedStr = urllib.parse.quote(queryStr, safe="/:=&?#+!$,;'@()*[]")
    # 在最后直接追加上your sk
    rawStr = encodedStr + sk
    # 计算sn
    sn = (hashlib.md5(urllib.parse.quote_plus(rawStr).encode("utf8")).hexdigest())
    # 由于URL里面含有中文，所以需要用parse.quote进行处理，然后返回最终可调用的url
    url = urllib.parse.quote("http://api.map.baidu.com" + queryStr + "&sn=" + sn, safe="/:=&?#+!$,;'@()*[]")
    data = urllib.request.urlopen(url)
    hjson = json.loads(data.read())
    return hjson


def zone_poi_search(row, poi_r_folder, list_df, target_file):
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
