#!/bin/bash

pushd ..

DIRS=`ls -d */`
#SKIP_LIST=("__old/" "accuracy-checker/" "model-zoo/" "model-zoo-models-intel/" "model-zoo-models-public/" "model-zoo-tools/")
SKIP_LIST=()
SKIP=0

for i in ${DIRS}; do
    SKIP=0
    for j in ${SKIP_LIST[@]}; do
        if [ ${i} == ${j} ]; then
            SKIP=1
        fi
    done

    if [ ${SKIP} -eq 0 ]; then
	    echo "----- Now pulling     $i -----"
	    cd $i
	    git pull --rebase; git submodule update --init --recursive
	    echo ""
	    cd ..
    fi

done

popd

