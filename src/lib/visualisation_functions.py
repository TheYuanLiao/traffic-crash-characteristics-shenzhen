# -*- coding: utf-8 -*-
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import contextily as ctx
import cartopy.crs as ccrs
import numpy as np
# To make it pretty
import matplotlib as mpl

mpl.rcParams.update(mpl.rcParamsDefault)
mpl.style.use('seaborn-colorblind')
font = {'size': 16}
mpl.rc('font', **font)


# Visualize the clustering t-sne
def plot_clustering(X_red, labels, title=None):
    x_min, x_max = np.min(X_red, axis=0), np.max(X_red, axis=0)
    X_red = (X_red - x_min) / (x_max - x_min)

    plt.figure(figsize=(6, 4))
    plt.scatter(X_red[:, 0], X_red[:, 1],
                color=plt.cm.nipy_spectral(labels / 10.), alpha=0.4, s=5)

    plt.xticks([])
    plt.yticks([])
    if title is not None:
        plt.title(title, size=17)
    plt.axis('off')
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.show()


def parallel_coordinates(X, labels, fig_folder=None, fig_name="clusters_parallel.png", save=False):
    num_cluster = len(set(labels))
    cluster_colors = {x: y for x, y in zip(range(1, num_cluster + 1), sns.color_palette("Set2", num_cluster))}
    # Specify the features of interest and the classes of the target
    classes = set(labels)
    features = ['food', 'hotel', 'shopping', 'life', 'beauty',
                'tourism', 'leisure', 'sports', 'education',
                'media', 'medical', 'auto', 'finance', 'real_estate',
                'company', 'gov_org', 'access', 'nature', 'transport']
    feature_names_dict = dict(food="Food", hotel="Hotel", shopping="Shopping", life="Life", beauty="Beauty",
                              tourism="Tourism", leisure="Leisure", sports="Sports", education="Education",
                              media="Media", medical="Medical", auto="Automobile", finance="Finance",
                              real_estate="Real estate", company="Company", gov_org="Organisations", access="Access",
                              nature="Nature", transport="Transport")  # , "poi_num":"# POIs"
    df2plot = pd.DataFrame(X, columns=features)
    df2plot.loc[:, "cluster"] = labels
    Y = {}
    for cluster in classes:
        Y[cluster] = df2plot.loc[df2plot["cluster"] == cluster,
                                 [f for f in features if f != "cluster"]].describe().transpose()[
            ['25%', '50%', '75%']].transpose()
    x = list(range(1, len(features) + 1))
    fig, ax = plt.subplots(1, 1, figsize=(13, 5))
    for cluster, Y2plot in Y.items():
        ax.plot(x, Y2plot.loc["50%"], label="LUC%s" % cluster, color=cluster_colors[cluster])
        ax.fill_between(x, Y2plot.loc["25%"], Y2plot.loc["75%"], interpolate=True, alpha=0.3,
                        color=cluster_colors[cluster])
    for i in x:
        plt.axvline(x=i, lw=0.5, color="gray")
    ax.set_xticks(x)
    ax.set_ylabel('Normalized number of POIs')
    ax.set_xticklabels([feature_names_dict[features[j - 1]] for j in x], rotation=45)
    # plt.legend(title='Land-use cluster', ncol=1, labelspacing=0.05, bbox_to_anchor=(1, 0.5), frameon=False)
    plt.tight_layout()
    if save:
        plt.savefig(fig_folder + fig_name, dpi=300)
    plt.show()


def add_basemap(ax, zoom=15, url='http://tile.stamen.com/toner/tileZ/tileX/tileY.png'):
    xmin, xmax, ymin, ymax = ax.axis()
    basemap, extent = ctx.bounds2img(xmin, ymin, xmax, ymax, zoom=zoom, url=url)
    ax.imshow(basemap, extent=extent, interpolation='bilinear')
    # restore original x/y limits
    ax.axis((xmin, xmax, ymin, ymax))

