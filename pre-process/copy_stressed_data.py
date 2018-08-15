from subprocess import call
import os
import sys
import numpy as np
import pandas as pd
from io import StringIO
from tabulate import tabulate

data_dir = './'
out_dir = './'
dump = 'stressed_crop_path_names'
do_scp = True

#reading the filename of the images
file_path = os.path.join(data_dir,dump+'.txt')
with open(file_path, 'r') as f:
   filenames = f.readlines()

#copying data from cornhub to local, make do_scp=True, if data is not available in local
if do_scp:
    for i in range(0, len(filenames)-1):
        print filenames[i]
        tmp=filenames[i].rstrip()
        cmd = "rsync -r brt@beast:"+tmp+" ../datasets/brt_data/not_healthy/"
        print cmd
        call(cmd.split(" "))

# #tabulating the data
# csv_file='stressed_plants.csv'
# df = pd.read_csv(csv_file)
# #print(tabulate(df, headers='keys', tablefmt='psql'))

# #extracting different columns
# table_matrix=df.as_matrix(columns=df.columns[0:3])
# print table_matrix.shape

# image_names=table_matrix[:,0]
# image_path_names=table_matrix[:,1]
# image_bounding_boxes =table_matrix[:,2]

