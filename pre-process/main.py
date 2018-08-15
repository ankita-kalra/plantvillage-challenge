import sys
import os
from preprocess_brt_data import *

#rearranging the brt data by cropping from ground truth boxes
preprocess_brt_data(0,0,True)
preprocess_brt_data(0,1,True)
preprocess_brt_data(1,0,True)
preprocess_brt_data(1,1,True)