docker stop coder
docker rm coder

docker run \
  -d \
  --gpus all \
  --name coder \
  --shm-size 64g \
  --ulimit memlock=-1 \
  --restart always \
  --ipc=host \
  -v /home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B:/models \
  -p 8000:8000 \
  -e CUDA_MODULE_LOADING=LAZY \
  vllm/vllm-openai:v0.8.5 \
  --model /models \
  --served-model-name coder \
  --tensor-parallel-size 4 \
  --gpu-memory-utilization 0.93 \
  --dtype float16 \
  --max-model-len 65536 \
  --trust-remote-code \
  --load-format safetensors \
  --swap-space 32 \
  --enforce-eager \
  --max-num-batched-tokens 8192 \
  --chat-template /models/qwen3_programming.jinja

docker logs -f coder