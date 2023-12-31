#!/usr/bin/env bash
set -x

# export MASTER_PORT=$((12000 + $RANDOM % 20000))
export OMP_NUM_THREADS=1

OUTPUT_DIR='YOUR_PATH/work_dir/vit_b_hybrid_pt_800e_k400_ft'
DATA_PATH='YOUR_PATH/data/k400'
MODEL_PATH='YOUR_PATH/model_zoo/vit_b_hybrid_pt_800e.pth'

JOB_NAME=$1
PARTITION=${PARTITION:-"video"}
# 8 for 1 node, 16 for 2 node, etc.
GPUS=1
#GPUS_PER_NODE=${GPUS_PER_NODE:-8}
#CPUS_PER_TASK=${CPUS_PER_TASK:-12}
CPUS_PER_TASK=4
#SRUN_ARGS=${SRUN_ARGS:-""}
PY_ARGS=${@:2}

# batch_size can be adjusted according to the graphics card
# srun -p $PARTITION \
#         --job-name=${JOB_NAME} \
#         --gres=gpu:${GPUS_PER_NODE} \
#         --ntasks=${GPUS} \
#         --ntasks-per-node=${GPUS_PER_NODE} \
#         --cpus-per-task=${CPUS_PER_TASK} \
#         --kill-on-bad-exit=1 \
#         --quotatype=auto \
#         --async \
#         ${SRUN_ARGS} \
        python run_class_finetuning.py \
        --model vit_base_patch16_224 \
        --data_path ${DATA_PATH} \
        --finetune ${MODEL_PATH} \
        --log_dir ${OUTPUT_DIR} \
        --output_dir ${OUTPUT_DIR} \
        --batch_size 1 \
        # --batch_size 16 \
        --input_size 224 \
        --short_side_size 224 \
        --save_ckpt_freq 10 \
        --num_frames 16 \
        --sampling_rate 4 \
        --num_workers 10 \
        --opt adamw \
        --lr 7e-4 \
        --opt_betas 0.9 0.999 \
        --weight_decay 0.05 \
        --layer_decay 0.75 \
        --test_num_segment 5 \
        --test_num_crop 3 \
        --epochs 90 \
        --dist_eval --enable_deepspeed \
        ${PY_ARGS}
