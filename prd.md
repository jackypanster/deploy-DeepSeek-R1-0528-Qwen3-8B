# 需求概述

本项目旨在使用 Docker 容器，并通过 `vllm/vllm-openai:v0.8.5` 镜像在特定硬件配置上部署 Qwen3-8B 模型。

## 目标

*   在指定的软硬件环境下，成功部署 Qwen3-8B 模型。
*   确保模型可通过 vLLM OpenAI 兼容的 API 提供服务。
*   在确保稳定运行的前提下，致力于最大化模型支持的上下文 Token 长度，并充分压榨硬件性能。

## 部署环境

### 硬件配置

*   **GPU**: 4 x NVIDIA RTX 2080 Ti (每张 22GB显存，总计 88GB 显存)
    *   架构: Turing
    *   计算能力: 7.5
*   **CPU**: 56 核
*   **内存 (RAM)**: 512GB
*   **磁盘**: 2TB SSD

### 软件配置

*   **操作系统**: Ubuntu 24.04
*   **Docker 镜像**: `vllm/vllm-openai:v0.8.5`
*   **NVIDIA 驱动**:
    *   NVIDIA-SMI: 570.153.02
    *   Driver Version: 570.153.02
    *   CUDA Version: 12.8

## 模型信息

*   **模型名称**: Qwen3-8B (DeepSeek-R1-0528-Qwen3-8B)
*   **模型来源**: [ModelScope - DeepSeek-R1-0528-Qwen3-8B](https://www.modelscope.cn/models/deepseek-ai/DeepSeek-R1-0528-Qwen3-8B/summary)
*   **本地存储路径**: `/home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B`

### 本地模型文件详情

模型已下载至本地指定目录，文件列表如下：

```
(base) llm@llm-server:~/model/deepseek/DeepSeek-R1-0528-Qwen3-8B$ ls -al
总计 16004552
drwxrwxr-x 4 llm llm       4096  6月  7 15:12 .
drwxrwxr-x 3 llm llm       4096  6月  7 14:02 ..
-rw-rw-r-- 1 llm llm        859  6月  7 14:12 config.json
-rw-rw-r-- 1 llm llm         48  6月  7 14:12 configuration.json
-rwxrwxr-x 1 llm llm        450  6月  7 15:12 deploy.sh
drwxrwxr-x 2 llm llm       4096  6月  7 14:12 figures
-rw-rw-r-- 1 llm llm       1064  6月  7 14:12 LICENSE
-rw-rw-r-- 1 llm llm 8610202930  6月  7 14:58 model-00001-of-000002.safetensors
-rw-rw-r-- 1 llm llm 7771313866  6月  7 14:56 model-00002-of-000002.safetensors
-rw-rw-r-- 1 llm llm      33276  6月  7 14:12 model.safetensors.index.json
-rw------- 1 llm llm        765  6月  7 14:58 .msc
-rw-rw-r-- 1 llm llm         36  6月  7 14:58 .mv
-rw-rw-r-- 1 llm llm      14695  6月  7 14:12 README.md
drwxrwxr-x 3 llm llm       4096  6月  7 14:58 ._____temp
-rw-rw-r-- 1 llm llm       3957  6月  7 14:12 tokenizer_config.json
-rw-rw-r-- 1 llm llm    7032822  6月  7 14:12 tokenizer.json
```
