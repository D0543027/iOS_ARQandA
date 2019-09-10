'''
把這個檔案丟到training model的資料夾再執行
轉完檔再把mlmodel檔丟到專題裡
要改哪些東西我有簡單打在文件裡

我訓練的浣熊model，可以先用這個去轉轉看，我確定可以轉
https://drive.google.com/file/d/1PVNnh-HQuhnAt2MlC3fBPSt7sdmlN87P/view?usp=sharing
'''

import coremltools
from keras.models import load_model
from keras.layers import Input
from yolo3.model import yolo_eval, yolo_body, tiny_yolo_body

weights_path = 'model_data/yolov3_raccoon.h5'
model_json_path = 'model_data/model.json'
num_classes = 1
model = yolo_body(Input(shape=(416, 416, 3)), 3, num_classes)
model.load_weights(weights_path)
json_string = model.to_json()
with open(model_json_path,"w") as f:
    f.write(json_string)
#input_name_shape_dict={'input1':[None,416,416,3]}

coreml_model = coremltools.converters.keras.convert((model_json_path, weights_path), input_names='input1',
    image_input_names='input1',
    output_names=['output1', 'output2', 'output3'],
    image_scale=1/255.)

coreml_model.input_description['input1'] = 'Input image'
coreml_model.output_description['output1'] = 'The 13x13 grid (Scale1)'
coreml_model.output_description['output2'] = 'The 26x26 grid (Scale2)'
coreml_model.output_description['output3'] = 'The 52x52 grid (Scale3)'

coreml_model.author = 'Original paper: Joseph Redmon, Ali Farhadi'
coreml_model.license = 'Public Domain'
coreml_model.short_description = "The YOLOv3 network from the paper 'YOLOv3: An Incremental Improvement'"

coreml_model.save('model_data/MyYolov3_raccoon.mlmodel')
