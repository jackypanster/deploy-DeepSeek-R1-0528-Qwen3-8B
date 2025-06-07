需求：在上述硬件配置下，以容器方式通过vllm/vllm-openai:v0.8.5部署Qwen3-8B模型，机器软硬件环境如下：

ubuntu 24.04

vllm/vllm-openai:v0.8.5

NVIDIA-SMI 570.153.02             Driver Version: 570.153.02     CUDA Version: 12.8

4 RTX 2080 Ti, 每张22g显存，一共88g显存, Turing 架构（计算能力 7.5）

512GB RAM，56核CPU，2T SSD 磁盘

模型信息：https://www.modelscope.cn/models/deepseek-ai/DeepSeek-R1-0528-Qwen3-8B/summary

模型已经下载到本地：
pwd
/home/llm/model/deepseek/DeepSeek-R1-0528-Qwen3-8B
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
