docker stop coder
docker rm coder

docker run \
  -d \
  --gpus all \
  --name coder \
  --shm-size 16g \
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
  --gpu-memory-utilization 0.92 \
  --dtype float16 \
  --max-model-len 65536 \
  --trust-remote-code \
  --load-format safetensors \
  --disable-custom-all-reduce

docker logs -f coder