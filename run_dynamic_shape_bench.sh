#!/bin/bash

openvino_path='/home/geunhwan/work/repo/openvino-fork/bin/intel64/RelWithDebInfo'
report_path='./_report'
cache_path='./_cache'
bert_small_path='/home/geunhwan/work/model/bert-small-uncased-whole-word-masking-squad-0001/onnx/onnx/FP16/1/dldt/bert-small-uncased-whole-word-masking-squad-0001.xml'
bert_base_path='/home/geunhwan/work/model/bert-base-uncased/onnx/onnx/FP16/1/dldt/bert-base-uncased.xml'
bert_large_path='/home/geunhwan/work/model/bert-large-uncased-whole-word-masking-squad-0001/onnx/onnx/FP16/1/dldt/bert-large-uncased-whole-word-masking-squad-0001.xml'
date=`date +%y%m%d_%H%M%S`

usage() {
    echo "Following variables can be set."
    echo ""
    echo "OPENVINO_PATH: $openvino_path"
    echo "BERT_SMALL_PATH: $bert_small_path"
    echo "BERT_BASE_PATH: $bert_base_path"
    echo "BERT_LARGE_PATH: $bert_large_path"
    echo ""
    echo "cache path: $cache_path"
    echo "report path: $report_path/YYMMDD_HHMMSS"

    exit 0
}

while getopts h opts; do
    case $opts in
        h) usage
            ;;
        ?) usage
            ;;
    esac
done

report_path=${report_path}/${date}
mkdir -p $report_path

if [[ ! -d $cache_path ]]; then
    mkdir -p $cache_path
fi

if [[ ! -z "$OPENVINO_PATH" ]]; then
    openvino_path=$OPENVINO_PATH
fi

if [[ ! -z "$BERT_SMALL_PATH" ]]; then
    bert_small_path = $BERT_SMALL_PATH
fi

if [[ ! -z "$BERT_BASE_PATH" ]]; then
    bert_base_path = $BERT_BASE_PATH
fi

if [[ ! -z "$BERT_LARGE_PATH" ]]; then
    bert_large_path = $BERT_LARGE_PATH
fi

run_model() {
    model_name=$1
    model_path=$2

    ### run static performance total processing time ###
    rm -rf $cache_path/*

    $openvino_path/benchmark_app -d GPU -niter 10833 -m $model_path -shape input_ids[1,384],attention_mask[1,384],token_type_ids[1,384] -hint none -nstreams 1 -nireq 1 -cache_dir $cache_path -report_type no_counters -report_folder .
    if [[ -f ./benchmark_report.csv ]]; then
        mv ./benchmark_report.csv ${report_path}/${model_name}_static.csv
    else
        echo "failed to run static performance: total processing time"
    fi

    ### run dynamic performance total processing time ###
    rm -rf $cache_path/*

    $openvino_path/benchmark_app -d GPU -niter 10833 -m $model_path -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?] -data_shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?] -hint none -nstreams 1 -nireq 1 -cache_dir $cache_path -report_type no_counters -report_folder .
    if [[ -f ./benchmark_report.csv ]]; then
        mv ./benchmark_report.csv ${report_path}/${model_name}_dynamic.csv
    else
        echo "failed to run dynamic performance: total processing time"
    fi

    ### run dynamic performance 100 infer iteration ###
    rm -rf $cache_path/*

    for ((iter=0; iter<10; iter++)); do
        $openvino_path/benchmark_app -d GPU -niter 100 -m $model_path -shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?] -data_shape input_ids[1,?],attention_mask[1,?],token_type_ids[1,?] -hint none -nstreams 1 -nireq 1 -cache_dir $cache_path -report_type no_counters -report_folder .
        if [[ -f ./benchmark_report.csv ]]; then
            mv ./benchmark_report.csv ${report_path}/${model_name}_dynamic_${iter}.csv
        else
            echo "failed to run dynamic performance: iteration"
        fi
    done
}

run_model bert_small $bert_small_path
run_model bert_base $bert_base_path
run_model bert_large $bert_large_path

python3 ./make_dynamic_shape_bench_summary.py -p $report_path

cd $report_path; cd ..
if [[ -h latest ]]; then
    rm latest
fi
ln -s $date latest
cd ..

