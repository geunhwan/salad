#!/bin/bash

openvino_path="/home/geunhwan/work/repo/openvino/bin/intel64/RelWithDebInfo"
result_file="./perf_tracking/"$(date +%y%m%d_%H%M%S)

models=(\
        "swin transformer b1       " \
        "twins transformer b1      " \
        "vision transformer b1     " \
        "stylegan2 b1              " \
        "bert-large b1             " \
        "bert-large b16            " \
        "bert-base b1              " \
        "bert-base b128            " \
        "albert b1                 " \
        "resnet-50 b256            " \
        "yolov5m b1                " \
        "yolov5m b8                " \
        "yolov7 b1                 " \
        "yolov7 b32                " \
        "yolov8s b1                " \
        "yolov8s b16               " \
        "yolov8m b1                " \
        "yolov8m b16               " \
        "dbnet b1                  " \
        "sd-1.4                    " \
        "sd-1.4 igpu               " \
        "sd-1.5 int8               " \
        "sd-1.5 int8 igpu          " \
        "sd-2.1                    " \
        "sd-2.1 igpu               " \
        "sam_encoder               " \
        "sam_encoder int8          " \
        "sam_predictor             " \
        "sam_predictor int8        " \
        "whisper tiny decoder      " \
        "whisper tiny decoder igpu " \
        )

commands=(\
        "-m /home/geunhwan/work/model/dgpu_customer/swin_fp16/end2end.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/twin_fp16/end2end.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/vit_fp16/end2end.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/stylegan2/tf/tf_frozen/FP16/1/dldt/stylegan2.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/bert-large-uncased/onnx/onnx/FP16/1/dldt/bert-large-uncased.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1 -shape [1,384]" \
        "-m /home/geunhwan/work/model/dgpu_customer/bert-large-uncased/onnx/onnx/FP16/1/dldt/bert-large-uncased.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 16 -use_device_mem -d GPU.1 -shape [1,384]" \
        "-m /home/geunhwan/work/model/dgpu_customer/bert-base-uncased/onnx/onnx/FP16/1/dldt/bert-base-uncased.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1 -shape [1,128]" \
        "-m /home/geunhwan/work/model/dgpu_customer/bert-base-uncased/onnx/onnx/FP16/1/dldt/bert-base-uncased.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 128 -use_device_mem -d GPU.1 -shape [1,128]" \
        "-m /home/geunhwan/work/model/dgpu_customer/albert/tf/tf_frozen/FP16/1/dldt/albert.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/resnet-50-pytorch/onnx/onnx/FP16/1/dldt/resnet-50-pytorch.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 256 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov5/yolov5m.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov5/yolov5m.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 8 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov7/yolov7_static.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov7/yolov7_static.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 32 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov8/yolov8s-dynamic.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1 -shape [1,3,640,640]" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov8/yolov8s-dynamic.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 16 -use_device_mem -d GPU.1 -shape [1,3,640,640]" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov8/yolov8m-dynamic.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1 -shape [1,3,640,640]" \
        "-m /home/geunhwan/work/model/dgpu_customer/yolov8/yolov8m-dynamic.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 16 -use_device_mem -d GPU.1 -shape [1,3,640,640]" \
        "-m /home/geunhwan/work/model/dgpu_customer/dbnet/static/dbnet-fp32.xml -t 20 -hint none -nstreams 4 -nireq 8 -b 1 -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/large_models/stable_diffusion/1.4/unet.xml -t 20 -hint latency -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/large_models/stable_diffusion/1.4/unet.xml -t 20 -hint latency -d GPU.0" \
        "-m /home/geunhwan/work/model/large_models/stable_diffusion/sd1.5-int8/unet.xml -t 20 -hint latency -use_device_mem -d GPU.1 -shape sample[2,4,64,64],encoder_hidden_states[2,77,768]" \
        "-m /home/geunhwan/work/model/large_models/stable_diffusion/sd1.5-int8/unet.xml -t 20 -hint latency -d GPU.0 -shape sample[2,4,64,64],encoder_hidden_states[2,77,768]" \
        "-m /home/geunhwan/work/model/large_models/stable_diffusion/sd2.1/sd2.1-fp32/unet.xml -t 20 -hint latency -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/large_models/stable_diffusion/sd2.1/sd2.1-fp32/unet.xml -t 20 -hint latency -use_device_mem -d GPU.0" \
        "-m /home/geunhwan/work/model/large_models/SAM/sam_image_encoder.xml -t 20 -hint latency -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/large_models/SAM/sam_image_encoder_int8.xml -t 20 -hint latency -use_device_mem -d GPU.1" \
        "-m /home/geunhwan/work/model/large_models/SAM/sam_mask_predictor.xml -t 20 -hint latency -use_device_mem -d GPU.1 -shape point_coords[1,6,2],point_labels[1,6]" \
        "-m /home/geunhwan/work/model/large_models/SAM/sam_mask_predictor_int8.xml -t 20 -hint latency -use_device_mem -d GPU.1 -shape point_coords[1,6,2],point_labels[1,6]" \
        "-m /home/geunhwan/work/model/whisper_tiny/decoder/decoder_model.onnx -t 20 -hint none -nstreams 4 -nireq 8 -d GPU.1 -data_shape input_ids[1,128],1100[1,64,384]"
        "-m /home/geunhwan/work/model/whisper_tiny/decoder/decoder_model.onnx -t 20 -hint none -nstreams 2 -nireq 4 -d GPU.0 -data_shape input_ids[1,128],1100[1,64,384]"
        )

num_models=${#models[@]}
if [ ${num_models} -ne ${#commands[@]} ]; then
    echo "Number of models and the number of shape options are different."
    exit 1
fi

touch ${result_file}

if [[ ! -z "$OPENVINO_PATH" ]]; then
    openvino_path=$OPENVINO_PATH
fi

echo "${openvino_path}" >> ${result_file}

pushd ${openvino_path}
commit=$(git log --pretty=oneline | head -n 1)
popd

echo "${commit}" >> ${result_file}

run_model()
{
    for i in $(seq 0 $((num_models-1))); do
        benchmark_app_command="${openvino_path}/benchmark_app ${commands[i]}"
        echo "${benchmark_app_command}"

        #result=$(${benchmark_app_command} 2>&1 | grep Throughput | tr -dc '0-9.')
        result=$(${benchmark_app_command} 2>&1)
        result_tput=$(echo "${result}" | grep Throughput | tr -dc '0-9.')
        result_latency=$(echo "${result}" | grep Median | tr -dc '0-9.')
        if [[ -n "${result_tput}" ]]; then
            echo "${models[i]}: ${result_tput}fps, ${result_latency}ms" >> ${result_file}
        else
            echo "${device} ${precision} ${models[i]}: failed" >> ${result_file}
        fi
    done
}

run_model

