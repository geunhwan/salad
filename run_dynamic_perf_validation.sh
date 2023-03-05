#!/bin/bash

openvino_path="/home/geunhwan/work/repo/openvino/bin/intel64/RelWithDebInfo"
model_path="/home/geunhwan/work/val_model/23ww08_dynamic_23.0.0-9729-c62be51cc1e-API2.0"
result_file="./dynamic_perf_validation/"$(date +%y%m%d_%H%M%S)

models=(\
        "bert-base-ner" \
        "bert-base-uncased-cola" \
        "bert-base-uncased-mrpc" \
        "bert-base-uncased-qqp" \
        "bert-base-uncased-sst2" \
        "bert-large-uncased-whole-word-masking-squad-0001" \
        "bert-large-uncased-whole-word-masking-squad-emb-0001" \
        "bert-small-uncased-whole-word-masking-squad-0002" \
        "bert-small-uncased-whole-word-masking-squad-emb-int8-0001" \
        "bert-small-uncased-whole-word-masking-squad-int8-0002" \
        "distilbert-base-uncased-cola" \
        "distilbert-base-uncased-mrpc" \
        "electra-base-cola" \
        "electra-base-mrpc" \
        "electra-base-qqp" \
        "electra-base-sst2" \
        "GNMT" \
        "GPT-2" \
        "mobilebert" \
        "roberta-base-cola" \
        "roberta-base-mrpc" \
        "roberta-base-sst2" \
        "sbert-base-mean-tokens" \
        "tinybert_6layer_768dim_cola" \
        "xlnetx" \
        )

shape_options=(\
        "-data_shape input_ids[1,64][1,128],attention_mask[1,64][1,128],token_type_ids[1,64][1,128] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128],input_mask[1,64][1,128],segment_ids[1,64][1,128] -shape input_ids[1,?],input_mask[1,?],segment_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,192][1,384],attention_mask[1,192][1,384],token_type_ids[1,192][1,384] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?]" \
        "-data_shape input_ids[1,16][1,32],attention_mask[1,16][1,32],token_type_ids[1,16][1,32],position_ids[1,16][1,32] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]" \
        "-data_shape input_ids[1,192][1,384],attention_mask[1,192][1,384],token_type_ids[1,192][1,384],position_ids[1,192][1,384] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]" \
        "-data_shape input_ids[1,16][1,32],attention_mask[1,16][1,32],token_type_ids[1,16][1,32],position_ids[1,16][1,32] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]" \
        "-data_shape input_ids[1,192][1,384],attention_mask[1,192][1,384],token_type_ids[1,192][1,384],position_ids[1,192][1,384] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?],position_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "" \
        "" \
        "-data_shape result.1[1,192][1,384],result.2[1,192][1,384],result.3[1,192][1,384] -shape result.1[1,?],result.2[1,?],result.3[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128] -shape input_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128],attention_mask[1,64][1,128],token_type_ids[1,64][1,128] -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?]" \
        "-data_shape input_ids[1,64][1,128],segment_ids[1,64][1,128],input_mask[1,64][1,128] -shape input_ids[1,?],segment_ids[1,?],input_mask[1,?]" \
        "" \
        )

num_models=${#models[@]}
if [ ${num_models} -ne ${#shape_options[@]} ]; then
    echo "Number of models and the number of shape options are different."
    exit 1
fi

touch ${result_file}

run_model()
{
    precision=$1
    device=$2
 
    for i in $(seq 0 $((num_models-1))); do
        if [[ "${precision}" = "INT8" ]]; then
            model_file=${model_path}/${models[i]}/onnx/onnx/FP16/INT8/1/dldt/optimized/${models[i]}.xml
        else
            model_file=${model_path}/${models[i]}/onnx/onnx/${precision}/1/dldt/${models[i]}.xml
        fi

        echo "${device} ${precision} ${model_file}"

        if [[ -f "${model_file}" ]]; then
            benchmark_app_command="${openvino_path}/benchmark_app -m ${model_file} ${shape_options[i]} -hint none -inference_only=false -t 30 -nstreams 2 -nireq 4 -b 1"
            benchmark_app_command+=" -d ${device}"
            if [[ "${precision}" != "INT8" ]]; then
                benchmark_app_command+=" -infer_precision ${precision}"
            fi

            result=$(${benchmark_app_command} 2>&1 | grep Throughput | tr -dc '0-9.')
            if [[ -n "${result}" ]]; then
                echo "${device} ${precision} ${models[i]}: ${result}fps" >> ${result_file}
            else
                echo "${device} ${precision} ${models[i]}: failed" >> ${result_file}
            fi
        else
            echo "${device} ${precision} ${models[i]}: no model file" >> ${result_file}
        fi
    done

    echo "" >> ${result_file}
}

run_model FP16 GPU.0
run_model FP32 GPU.0
run_model INT8 GPU.0
run_model FP16 GPU.1
run_model FP32 GPU.1
run_model INT8 GPU.1
