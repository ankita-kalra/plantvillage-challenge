import json
from PIL import Image


def store_rects(out_dir,json_input = '{"rects": [[0.41732283464566927, 0.4645669291338583, 0.47736220472440943, 0.5433070866141733, 0], [0.42618110236220474, 0.60498687664042, 0.5, 0.6876640419947506, 0], [0.46358267716535434, 0.8923884514435696, 0.49803149606299213, 0.9291338582677166, 1]], "type": "rect_collection"}',img_name = '1669712',data_dir = '/home/brt/plantvillage-ak/datasets/brt_data/healthy/'):
    try:
        decoded = json.loads(json_input)
        img_width = 1024
        img_height = 768
        
        img=Image.open(data_dir+img_name+'.bmp')
        # pretty printing of json-formatted string
        #print json.dumps(decoded, sort_keys=True, indent=4)
        bounding_boxes = decoded['rects']
        total_bb=len(bounding_boxes)
        for i in range(0,total_bb-1):
            temp_bb=bounding_boxes[i]
            print temp_bb
            temp_bb[0]=int(temp_bb[0]*img_width)
            temp_bb[1]=int(temp_bb[1]*img_height)
            temp_bb[2]=int(temp_bb[2]*img_width)
            temp_bb[3]=int(temp_bb[3]*img_height)
            print temp_bb
            if temp_bb[4]==0:
                temp_bb=(temp_bb[0],temp_bb[1],temp_bb[2],temp_bb[3])
                c_img=img.crop(temp_bb)
                c_img.save('../datasets/brt_data/'+out_dir+img_name+'_'+str(i)+'.jpg')
            elif temp_bb[4]==1:
                temp_bb=(temp_bb[0],temp_bb[1],temp_bb[2],temp_bb[3])
                c_img=img.crop(temp_bb)
                c_img.save('../datasets/brt_data/'+out_dir+img_name+'_'+str(i)+'.jpg')

    except (ValueError, KeyError, TypeError):
        print "JSON format error"