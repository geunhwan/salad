#!/bin/bash

openvino_path="/home/geunhwan/work/repo/openvino/bin/intel64/RelWithDebInfo"
#model_path="/home/geunhwan/work/val_model/23ww13_dynamic_23.0.0-10239-1b72352f6f2-API2.0"
model_path="/home/geunhwan/work/val_model/23ww21_dynamic_23.0.0-10923-4c2096ad9c6-RC3-API2.0"
timestamp=$(date +%y%m%d_%H%M%S)
result_file="./dynamic_model_coverage/${timestamp}.csv"
result_table_file="./dynamic_model_coverage/${timestamp}_table.csv"

models=(
    "GNMT"
    "bert-base-ner"
    "bert-base-uncased-cola"
    "bert-base-uncased-mrpc"
    "bert-base-uncased-qqp"
    "bert-base-uncased-sst2"
    "bert-large-uncased-whole-word-masking-squad-0001"
    "bert-large-uncased-whole-word-masking-squad-emb-0001"
    "bert-small-uncased-whole-word-masking-squad-0002"
    "bert-small-uncased-whole-word-masking-squad-emb-int8-0001"
    "bert-small-uncased-whole-word-masking-squad-int8-0002"
    "ctpn"
    "distilbert-base-uncased-cola"
    "distilbert-base-uncased-mrpc"
    "east_resnet_v1_50"
    "electra-base-cola"
    "electra-base-mrpc"
    "electra-base-qqp"
    "electra-base-sst2"
    "faster_rcnn_inception_resnet_v2_atrous_coco"
    "faster_rcnn_inception_v2_coco"
    "higher-hrnet-w32-512"
    "human-pose-estimation-0001"
    "human-pose-estimation-0002"
    "human-pose-estimation-0003"
    "human-pose-estimation-0004"
    "human-pose-estimation-0005"
    "human-pose-estimation-0006"
    "human-pose-estimation-0007"
    "human-pose-estimation-3d-0001"
    "instance-segmentation-security-0002"
    "learning-to-see-in-the-dark-fuji"
    "learning-to-see-in-the-dark-sony"
    "lpcnet_decoder"
    "lpcnet_encoder"
    "mask_rcnn_inception_resnet_v2_atrous_coco"
    "mask_rcnn_inception_v2_coco"
    "mask_rcnn_resnet101_atrous_coco"
    "mobilebert"
    "mtcnn-o"
    "mtcnn-p"
    "mtcnn-r"
    "openpose-pose"
    "pointrend-resnet50-fpn-pytorch"
    "pp-ocr-det"
    "pp-ocr-rec"
    "quartznet-15x5-en"
    "quartznet-decoder"
    "quartznet-encoder"
    "retinanet"
    "rnnt_encoder"
    "rnnt_joint"
    "rnnt_prediction"
    "roberta-base-cola"
    "roberta-base-mrpc"
    "roberta-base-sst2"
    "sbert-base-mean-tokens"
    "tacotron_2_decoder"
    "tacotron_2_encoder"
    "tacotron_2_postnet"
    "text-to-speech-en-0001-generation"
    "text-to-speech-en-multi-0001-generation"
    "tinybert_6layer_768dim_cola"
    "wav2vec2-base"
    "wavernn-upsampler"
)

declare -A frameworks
frameworks["GNMT"]="tf/tf_frozen"
frameworks["bert-base-ner"]="onnx/onnx"
frameworks["bert-base-uncased-cola"]="onnx/onnx"
frameworks["bert-base-uncased-mrpc"]="onnx/onnx"
frameworks["bert-base-uncased-qqp"]="onnx/onnx"
frameworks["bert-base-uncased-sst2"]="onnx/onnx"
frameworks["bert-large-uncased-whole-word-masking-squad-0001"]="onnx/onnx"
frameworks["bert-large-uncased-whole-word-masking-squad-emb-0001"]="onnx/onnx"
frameworks["bert-small-uncased-whole-word-masking-squad-0002"]="onnx/onnx"
frameworks["bert-small-uncased-whole-word-masking-squad-emb-int8-0001"]="onnx/onnx"
frameworks["bert-small-uncased-whole-word-masking-squad-int8-0002"]="onnx/onnx"
frameworks["ctpn"]="tf/tf_frozen"
frameworks["distilbert-base-uncased-cola"]="onnx/onnx"
frameworks["distilbert-base-uncased-mrpc"]="onnx/onnx"
frameworks["east_resnet_v1_50"]="tf/tf_frozen"
frameworks["electra-base-cola"]="onnx/onnx"
frameworks["electra-base-mrpc"]="onnx/onnx"
frameworks["electra-base-qqp"]="onnx/onnx"
frameworks["electra-base-sst2"]="onnx/onnx"
frameworks["faster_rcnn_inception_resnet_v2_atrous_coco"]="tf/tf_frozen"
frameworks["faster_rcnn_inception_v2_coco"]="tf/tf_frozen"
frameworks["higher-hrnet-w32-512"]="onnx/onnx"
frameworks["human-pose-estimation-0001"]="caffe/caffe"
frameworks["human-pose-estimation-0002"]="onnx/onnx"
frameworks["human-pose-estimation-0003"]="onnx/onnx"
frameworks["human-pose-estimation-0004"]="onnx/onnx"
frameworks["human-pose-estimation-0005"]="onnx/onnx"
frameworks["human-pose-estimation-0006"]="onnx/onnx"
frameworks["human-pose-estimation-0007"]="onnx/onnx"
frameworks["human-pose-estimation-3d-0001"]="onnx/onnx"
frameworks["instance-segmentation-security-0002"]="onnx/onnx"
frameworks["learning-to-see-in-the-dark-fuji"]="tf/tf_frozen"
frameworks["learning-to-see-in-the-dark-sony"]="tf/tf_frozen"
frameworks["lpcnet_decoder"]="onnx/onnx"
frameworks["lpcnet_encoder"]="onnx/onnx"
frameworks["mask_rcnn_inception_resnet_v2_atrous_coco"]="tf/tf_frozen"
frameworks["mask_rcnn_inception_v2_coco"]="tf/tf_frozen"
frameworks["mask_rcnn_resnet101_atrous_coco"]="tf/tf_frozen"
frameworks["mobilebert"]="onnx/onnx"
frameworks["mtcnn-o"]="caffe/caffe"
frameworks["mtcnn-p"]="caffe/caffe"
frameworks["mtcnn-r"]="caffe/caffe"
frameworks["openpose-pose"]="tf/tf_frozen"
frameworks["pointrend-resnet50-fpn-pytorch"]="onnx/onnx"
frameworks["pp-ocr-det"]="paddle/paddle"
frameworks["pp-ocr-rec"]="paddle/paddle"
frameworks["quartznet-15x5-en"]="onnx/onnx"
frameworks["quartznet-decoder"]="onnx/onnx"
frameworks["quartznet-encoder"]="onnx/onnx"
frameworks["retinanet"]="tf/tf_frozen"
frameworks["rnnt_encoder"]="onnx/onnx"
frameworks["rnnt_joint"]="onnx/onnx"
frameworks["rnnt_prediction"]="onnx/onnx"
frameworks["roberta-base-cola"]="onnx/onnx"
frameworks["roberta-base-mrpc"]="onnx/onnx"
frameworks["roberta-base-sst2"]="onnx/onnx"
frameworks["sbert-base-mean-tokens"]="onnx/onnx"
frameworks["tacotron_2_decoder"]="onnx/onnx"
frameworks["tacotron_2_encoder"]="onnx/onnx"
frameworks["tacotron_2_postnet"]="onnx/onnx"
frameworks["text-to-speech-en-0001-generation"]="onnx/onnx"
frameworks["text-to-speech-en-multi-0001-generation"]="onnx/onnx"
frameworks["tinybert_6layer_768dim_cola"]="onnx/onnx"
frameworks["wav2vec2-base"]="onnx/onnx"
frameworks["wavernn-upsampler"]="onnx/onnx"

declare -A shape_options
shape_options["GNMT"]="-data_shape IteratorGetNext:0[1,25][1,50],IteratorGetNext:1[1][1]"
shape_options["bert-base-ner"]="-data_shape input_ids[1,64][1,128],attention_mask[1,64][1,128],token_type_ids[1,64][1,128] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?]"
shape_options["bert-base-uncased-cola"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["bert-base-uncased-mrpc"]="-data_shape input_ids[1,64][1,128],input_mask[1,64][1,128],segment_ids[1,64][1,128] -shape input_ids[1,?],input_mask[1,?],segment_ids[1,?]"
shape_options["bert-base-uncased-qqp"]="-data_shape input_ids[1,64][1,128]"
shape_options["bert-base-uncased-sst2"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["bert-large-uncased-whole-word-masking-squad-0001"]="-data_shape input_ids[1,192][1,384],attention_mask[1,192][1,384],token_type_ids[1,192][1,384] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?]"
shape_options["bert-large-uncased-whole-word-masking-squad-emb-0001"]="-data_shape input_ids[1,16][1,32],attention_mask[1,16][1,32],token_type_ids[1,16][1,32],position_ids[1,16][1,32] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]"
shape_options["bert-small-uncased-whole-word-masking-squad-0002"]="-data_shape input_ids[1,192][1,384],attention_mask[1,192][1,384],token_type_ids[1,192][1,384],position_ids[1,192][1,384] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]"
shape_options["bert-small-uncased-whole-word-masking-squad-emb-int8-0001"]="-data_shape input_ids[1,16][1,32],attention_mask[1,16][1,32],token_type_ids[1,16][1,32],position_ids[1,16][1,32] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]"
shape_options["bert-small-uncased-whole-word-masking-squad-int8-0002"]="-data_shape input_ids[1,192][1,384],attention_mask[1,192][1,384],token_type_ids[1,192][1,384],position_ids[1,192][1,384] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]"
shape_options["ctpn"]="-data_shape Placeholder[1,300,300,3][1,600,600,3]"
shape_options["distilbert-base-uncased-cola"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["distilbert-base-uncased-mrpc"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["east_resnet_v1_50"]="-data_shape input_images[1,512,960,3][1,1024,1920,3]"
shape_options["electra-base-cola"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["electra-base-mrpc"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["electra-base-qqp"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["electra-base-sst2"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["faster_rcnn_inception_resnet_v2_atrous_coco"]="-data_shape image_tensor[1,300,512,3][1,600,1024,3]"
shape_options["faster_rcnn_inception_v2_coco"]="-data_shape image_tensor[1,300,512,3][1,600,1024,3]"
shape_options["higher-hrnet-w32-512"]="-data_shape image[1,3,256,256][1,3,512,512]"
shape_options["human-pose-estimation-0001"]="-data_shape data[1,3,128,228][1,3,256,456]"
shape_options["human-pose-estimation-0002"]="-data_shape image[1,3,224,224][1,3,288,288]"
shape_options["human-pose-estimation-0003"]="-data_shape image[1,3,192,192][1,3,352,352]"
shape_options["human-pose-estimation-0004"]="-data_shape image[1,3,224,224][1,3,448,448]"
shape_options["human-pose-estimation-0005"]="-data_shape image[1,3,224,224][1,3,288,288]"
shape_options["human-pose-estimation-0006"]="-data_shape image[1,3,192,192][1,3,352,352]"
shape_options["human-pose-estimation-0007"]="-data_shape image[1,3,224,224][1,3,448,448]"
shape_options["human-pose-estimation-3d-0001"]="-data_shape data[1,3,128,224][1,3,256,448]"
shape_options["instance-segmentation-security-0002"]="-data_shape image[1,3,384,512][1,3,768,1024]"
shape_options["learning-to-see-in-the-dark-fuji"]="-data_shape Placeholder[1,640,860,9][1,1280,1920,9]"
shape_options["learning-to-see-in-the-dark-sony"]="-data_shape Placeholder[1,512,808,4][1,1080,1616,4]"
shape_options["lpcnet_decoder"]="-data_shape input_1[1,1,3][1,6,3],input_4[1,1,128][1,6,128],input_5[1,384][6,384],input_6[1,16][6,16]"
shape_options["lpcnet_encoder"]="-data_shape input_2[1,255,42][1,511,42],input_3[1,255,1][1,511,1]"
shape_options["mask_rcnn_inception_resnet_v2_atrous_coco"]="-data_shape image_tensor[1,400,682,3][1,800,1365,3]"
shape_options["mask_rcnn_inception_v2_coco"]=""
shape_options["mask_rcnn_resnet101_atrous_coco"]="-data_shape image_tensor[1,400,682,3][1,800,1365,3]"
shape_options["mobilebert"]="-data_shape result.1[1,192][1,384],result.2[1,192][1,384],result.3[1,192][1,384] -shape result.1[1,?],result.2[1,?],result.3[1,?]"
shape_options["mtcnn-o"]="-data_shape data[1,1,24,24][1,3,48,48]"
shape_options["mtcnn-p"]="-data_shape data[1,1,360,640][1,3,720,1280]"
shape_options["mtcnn-r"]="-data_shape data[1,1,12,12][1,3,24,24]"
shape_options["openpose-pose"]="-data_shape image[1,3,184,328][1,3,368,656]"
shape_options["pointrend-resnet50-fpn-pytorch"]="-data_shape image[1,3,400,672][1,3,800,1344]"
shape_options["pp-ocr-det"]="-data_shape x[1,3,640,640]"
shape_options["pp-ocr-rec"]="-data_shape x[1,3,32,100]"
shape_options["quartznet-15x5-en"]="-data_shape audio_signal[1,64,64][1,64,128]"
shape_options["quartznet-decoder"]="-data_shape encoder_output[1,1024,32][1,1024,64]"
shape_options["quartznet-encoder"]="-data_shape audio_signal[1,64,64][1,64,128]"
shape_options["retinanet"]="-data_shape input_1[1,666,666,3][1,1333,1333,3]"
shape_options["rnnt_encoder"]=""
shape_options["rnnt_joint"]="-data_shape 0[1,1,1024],1[1,1,320]"
shape_options["rnnt_prediction"]="-data_shape input.1[1,1],1[2,1,320],2[2,1,320]"
shape_options["roberta-base-cola"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["roberta-base-mrpc"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["roberta-base-sst2"]="-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]"
shape_options["sbert-base-mean-tokens"]="-data_shape input_ids[1,64][1,128],attention_mask[1,64][1,128],token_type_ids[1,64][1,128] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?]"
shape_options["tacotron_2_decoder"]="-data_shape decoder_input[1,11][1,22],attention_hidden[1,400][1,800],attention_cell[1,400][1,800],decoder_hidden[1,400][1,800],decoder_cell[1,400][1,800],attention_weights[1,14][1,29],attention_weights_cum[1,14][1,29],attention_context[1,255][1,512],encoder_outputs[1,14,255][1,29,512]"
shape_options["tacotron_2_encoder"]="-data_shape text_encoder_outputs[1,29,384][1,29,384],domain[1][1],f0s[1,14][1,29],bert_embedding[1,4,384][1,8,768]"
shape_options["tacotron_2_postnet"]="-data_shape mel_outputs[1,22,60][1,22,30]"
shape_options["text-to-speech-en-0001-generation"]="-data_shape mel[1,80,64][1,80,128]"
shape_options["text-to-speech-en-multi-0001-generation"]="-data_shape mel[1,80,64][1,80,128]"
shape_options["tinybert_6layer_768dim_cola"]="-data_shape input_ids[1,64][1,128],segment_ids[1,64][1,128],input_mask[1,64][1,128] -shape input_ids[1,?],segment_ids[1,?],input_mask[1,?]"
shape_options["wav2vec2-base"]="-data_shape input[1,15240][1,30480]"
shape_options["wavernn-upsampler"]="-data_shape mels[1,183,80][[1,366,80]"

num_models=${#models[@]}
if [ ${num_models} -ne ${#shape_options[@]} ]; then
    echo "Number of models and the number of shape options are different."
    exit 1
fi

touch ${result_file}

pushd ${openvino_path}
commit=$(git log --pretty=oneline | head -n 1)
popd

run_model()
{
    precision=$1
    device=$2
 
    for i in $(seq 0 $((num_models-1))); do
        if [[ "${precision}" = "INT8" ]]; then
            model_file=${model_path}/${models[i]}/${frameworks[${models[i]}]/FP16/INT8/1/dldt/optimized/${models[i]}.xml
        else
            model_file=${model_path}/${models[i]}/${frameworks[${models[i]}]/${precision}/1/dldt/${models[i]}.xml
        fi

        echo "${device} ${precision} ${model_file}"

        if [[ -f "${model_file}" ]]; then
            benchmark_app_command="${openvino_path}/benchmark_app -m ${model_file} ${shape_options[${models[i]}]} -hint none -inference_only=false -t 10 -nstreams 2 -nireq 4 -b 1"
            benchmark_app_command+=" -d ${device}"
            if [[ "${precision}" != "INT8" ]]; then
                benchmark_app_command+=" -infer_precision ${precision}"
            fi

            result=$(${benchmark_app_command} 2>&1 | grep Throughput | tr -dc '0-9.')
            if [[ -n "${result}" ]]; then
                echo "${models[i]},${device},${precision},${result}" >> ${result_file}
            else
                echo "${models[i]},${device},${precision},fail" >> ${result_file}
            fi
        else
            echo "${models[i]},${device},${precision},no_model" >> ${result_file}
        fi
    done
}

run_model FP16 GPU.0
run_model FP32 GPU.0
#run_model INT8 GPU.0
#run_model FP16 GPU.1
#run_model FP32 GPU.1
#run_model INT8 GPU.1

python3 make_dynamic_model_coverage_table.py -i ${result_file} -o ${result_table_file} -c ${commit}

