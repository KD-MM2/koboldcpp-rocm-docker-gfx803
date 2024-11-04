#!/bin/bash
cd /app/koboldcpp-rocm
python3 koboldcpp.py \
    --model $MODEL_PATH \
    --gpulayers $GPU_LAYERS \
    --host $HOST \
    --port $CONTAINER_PORT