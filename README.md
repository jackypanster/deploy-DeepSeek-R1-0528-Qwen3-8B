# DeepSeek Model Deployment with vLLM and Docker

This project deploys the DeepSeek-R1-0528-Qwen3-8B model using the vLLM engine, served via an OpenAI-compatible API within a Docker container.

## Prerequisites

- NVIDIA Docker installed and configured.
- NVIDIA drivers compatible with CUDA version used by the vLLM image.
- The DeepSeek model files downloaded to `/home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B` on the host machine.

## Deployment

The deployment is managed by the `deploy.sh` script. This script first stops and removes any existing container named `coder`, then starts a new container with the specified parameters, and finally tails the logs of the new container.

To deploy, simply run:
```bash
bash deploy.sh
```

## Docker Command Explanation

The core of the `deploy.sh` script is the `docker run` command:

```bash
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
  --gpu-memory-utilization 0.93 \
  --dtype float16 \
  --max-model-len 65536 \
  --trust-remote-code \
  --load-format safetensors \
  --disable-custom-all-reduce
```

### Docker Options:

-   `-d`: Run the container in detached mode (in the background).
-   `--gpus all`: Make all available GPUs accessible to the container.
-   `--name coder`: Assign the name "coder" to the container for easy reference.
-   `--shm-size 16g`: Set the size of `/dev/shm` (shared memory) to 16 gigabytes. This is often crucial for large models and parallel processing.
-   `--ulimit memlock=-1`: Set the memlock ulimit to unlimited. This allows the container to lock more memory, which can be beneficial for performance.
-   `--restart always`: Configure the container to always restart if it stops (e.g., on system reboot or if the process crashes).
-   `--ipc=host`: Use the host's IPC (Inter-Process Communication) namespace. This can improve performance for processes communicating within the container or with the host.
-   `-v /home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B:/models`: Mount the host directory containing the model files (`/home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B`) to the `/models` directory inside the container. This makes the model accessible to vLLM.
-   `-p 8000:8000`: Map port 8000 on the host to port 8000 in the container. This exposes the vLLM API server.
-   `-e CUDA_MODULE_LOADING=LAZY`: Set the environment variable `CUDA_MODULE_LOADING` to `LAZY`. This can help reduce GPU memory usage at startup by loading CUDA modules only when they are needed.
-   `vllm/vllm-openai:v0.8.5`: Specifies the Docker image to use. This is an official vLLM image that includes an OpenAI-compatible server.

### vLLM Parameters (passed after the image name):

-   `--model /models`: Path inside the container where the model files are located (corresponds to the volume mount).
-   `--served-model-name coder`: The name under which the model will be served by the API. This is used in API requests.
-   `--tensor-parallel-size 4`: Distribute the model across 4 GPUs using tensor parallelism. This should match the number of GPUs intended for use (4x RTX 2080 Ti in this case).
-   `--gpu-memory-utilization 0.92`: Instructs vLLM to try to use 92% of the available GPU memory. This value has been tuned for the current setup.
-   `--dtype float16`: Use float16 (half-precision) for model computations. This offers a good balance of speed and memory efficiency on compatible GPUs like the RTX 2080 Ti.
-   `--max-model-len 65536`: Set the maximum model context length to 65,536 tokens, matching the capability of the DeepSeek-R1-0528-Qwen3-8B model.
-   `--trust-remote-code`: Allow vLLM to execute custom code that might be part of the model's repository. This is often required for specific model architectures.
-   `--load-format safetensors`: Specify that the model weights are in the SafeTensors format.
-   `--disable-custom-all-reduce`: Disable vLLM's custom all-reduce implementation. This was added to silence warnings and ensure compatibility, as the custom all-reduce might not be supported or optimal on configurations with multiple PCIe-only GPUs.

## Monitoring

After running `deploy.sh`, the script will automatically attach to the container's logs:
```bash
docker logs -f coder
```
This allows for real-time monitoring of the vLLM server.
