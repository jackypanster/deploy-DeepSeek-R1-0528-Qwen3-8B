# 使用 vLLM 和 Docker 部署 DeepSeek 模型

本项目使用 vLLM 引擎部署 DeepSeek-R1-0528-Qwen3-8B 模型，并通过 Docker 容器内一个与 OpenAI 兼容的 API 提供服务。

## 先决条件

-   已安装并配置 NVIDIA Docker。
-   NVIDIA 驱动程序与 vLLM 镜像所使用的 CUDA 版本兼容。
-   DeepSeek 模型文件已下载到宿主机的 `/home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B` 目录。

## 部署

部署通过 `deploy.sh` 脚本管理。该脚本首先会停止并移除任何名为 `coder` 的现有容器，然后使用指定的参数启动一个新容器，最后跟踪新容器的日志。

要进行部署，只需运行：
```bash
bash deploy.sh
```

## Docker 命令详解

`deploy.sh` 脚本的核心是 `docker run` 命令：

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

### Docker 选项：

-   `-d`: 以分离模式（在后台）运行容器。
-   `--gpus all`: 使所有可用的 GPU 对容器可见。
-   `--name coder`: 为容器分配名称 "coder"，方便引用。
-   `--shm-size 16g`: 设置 `/dev/shm` (共享内存) 的大小为 16 GB。这对于大型模型和并行处理通常至关重要。
-   `--ulimit memlock=-1`: 将内存锁定的 ulimit 设置为无限制。这允许容器锁定更多内存，有助于提升性能。
-   `--restart always`: 配置容器在停止时总是重启（例如，在系统重启或进程崩溃时）。
-   `--ipc=host`: 使用宿主机的 IPC (进程间通信) 命名空间。这可以提高容器内或与宿主机通信的进程的性能。
-   `-v /home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B:/models`: 将包含模型文件的宿主机目录 (`/home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B`) 挂载到容器内的 `/models` 目录。这使得模型可以被 vLLM 访问。
-   `-p 8000:8000`: 将宿主机的 8000 端口映射到容器的 8000 端口。这用于暴露 vLLM API 服务器。
-   `-e CUDA_MODULE_LOADING=LAZY`: 设置环境变量 `CUDA_MODULE_LOADING` 为 `LAZY`。这可以通过仅在需要时加载 CUDA 模块来帮助减少启动时的 GPU 内存使用。
-   `vllm/vllm-openai:v0.8.5`: 指定要使用的 Docker 镜像。这是一个官方的 vLLM 镜像，包含一个与 OpenAI 兼容的服务器。

### vLLM 参数 (在镜像名称后传递)：

-   `--model /models`: 容器内模型文件的路径 (对应于卷挂载)。
-   `--served-model-name coder`: API 服务模型的名称。在 API 请求中使用。
-   `--tensor-parallel-size 4`: 使用张量并行将模型分布在 4 个 GPU 上。这应与预期使用的 GPU 数量相匹配 (本例中为 4x RTX 2080 Ti)。
-   `--gpu-memory-utilization 0.93`: 指示 vLLM 尝试使用可用 GPU 内存的 93%。此值已针对当前设置进行了调整。
-   `--dtype float16`: 模型计算使用 float16 (半精度)。这在兼容的 GPU (如 RTX 2080 Ti) 上提供了速度和内存效率的良好平衡。
-   `--max-model-len 65536`: 设置最大模型上下文长度为 65,536 个 token，与 DeepSeek-R1-0528-Qwen3-8B 模型的能力相匹配。
-   `--trust-remote-code`: 允许 vLLM 执行可能属于模型仓库一部分的自定义代码。这对于特定的模型架构通常是必需的。
-   `--load-format safetensors`: 指定模型权重使用 SafeTensors 格式。
-   `--disable-custom-all-reduce`: 禁用 vLLM 的自定义 all-reduce 实现。添加此参数是为了消除警告并确保兼容性，因为自定义 all-reduce 可能在具有多个 PCIe-only GPU 的配置上不受支持或不是最优的。

## 监控

运行 `deploy.sh` 后，脚本将自动附加到容器的日志：
```bash
docker logs -f coder
```
这允许实时监控 vLLM 服务器。
