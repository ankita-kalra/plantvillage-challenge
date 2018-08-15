from subprocess import call
import os
import sys
import numpy as np
import pandas as pd
from io import StringIO
from tabulate import tabulate
from store_rects import *

rearrange_data=True
full_data_prefix='/home/brt/plantvillage-ak/datasets/'

def preprocess_brt_data(healthy=0,tag=0,rearrange_data=True):

    out_dir=''
    tag_dir=''
    dump=''
    data_dir = './'
    meta_data_csv='not_stressed_plants.csv'
    if tag==0 and healthy==1:
        tag_dir = 'healthy/'
        out_dir = 'h_c'
        dump = 'not_stressed_names'
        meta_data_csv='not_stressed_plants.csv'
    elif tag==0 and healthy==0:
        tag_dir = 'not_healthy/'
        out_dir = 'n_c'
        dump = 'stressed_names'
        meta_data_csv='stressed_plants.csv'
    elif tag==1 and healthy==1:
        tag_dir = 'healthy/'
        out_dir = 'h_w'
        dump = 'not_stressed_names'
        meta_data_csv='not_stressed_plants.csv'
    elif tag==1 and healthy==0:
        tag_dir = 'not_healthy/'
        out_dir = 'n_w'
        dump = 'stressed_names'
        meta_data_csv='stressed_plants.csv'
    else:
        print "error! please check inputs!"
        sys.exit()
    full_data_path=full_data_prefix+tag_dir

    #reading the filename of the images
    file_path = os.path.join(data_dir,dump+'.txt')
    with open(file_path, 'r') as f:
        filenames = f.readlines()
    csv_file=meta_data_csv
    df = pd.read_csv(csv_file)
    #extracting different columns
    table_matrix=df.as_matrix(columns=df.columns[0:3])
    print table_matrix.shape
    #tabulating the data
    #print(tabulate(df, headers='keys', tablefmt='psql'))

    #copying data from cornhub to local, make do_scp=True, if data is not available in local
    if rearrange_data:
        for i in range(0, len(filenames)-1):
            print filenames[i]
            filenames[i]=filenames[i].rstrip()
            image_bounding_box =table_matrix[i,2]
            print out_dir, image_bounding_box, filenames[i], full_data_path
            store_rects(out_dir,image_bounding_box,filenames[i],full_data_path)
    
    return out_dir

