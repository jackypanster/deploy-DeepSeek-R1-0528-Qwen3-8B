# Testing the Deployed DeepSeek Model API

This document provides `curl` commands to test the functionality of the deployed DeepSeek model via its OpenAI-compatible API. The API server is expected to be running on `http://localhost:8000`.

## 1. List Available Models

This command checks if the model is correctly loaded and served.

```bash
curl http://localhost:8000/v1/models | jq
```

Expected output (will vary slightly, but should list the "coder" model):
```json
{
  "object": "list",
  "data": [
    {
      "id": "coder",
      "object": "model",
      "created": 1677664637,
      "owned_by": "vllm",
      "root": "coder",
      "parent": null,
      "permission": [
        {
          "id": "modelperm-coder",
          "object": "model_permission",
          "created": 1677664637,
          "allow_create_engine": false,
          "allow_sampling": true,
          "allow_logprobs": true,
          "allow_search_indices": false,
          "allow_view": true,
          "allow_fine_tuning": false,
          "organization": "*",
          "group": null,
          "is_blocking": false
        }
      ]
    }
  ]
}
```

## 2. Text Completion (Simple Prompt)

Test basic text generation.

```bash
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coder",
    "prompt": "San Francisco is a",
    "max_tokens": 50,
    "temperature": 0.7
  }' | jq
```

## 3. Text Completion (Longer Context & More Tokens)

Test with a slightly longer prompt and request more tokens.

```bash
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coder",
    "prompt": "The DALL·E 2 paper, titled \"Hierarchical Text-Conditional Image Generation with CLIP Latents,\" was first published on arXiv on April 13, 2022. It describes a system that can generate realistic images and art from a description in natural language. The system builds upon the work of DALL·E and CLIP, previous models developed by OpenAI. Explain the key innovations of DALL·E 2 compared to its predecessor DALL·E, focusing on image quality and generation diversity.",
    "max_tokens": 200,
    "temperature": 0.5
  }' | jq
```

## 4. Chat Completion (Basic)

Test the chat completion endpoint.

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coder",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "What is the capital of France?"}
    ],
    "max_tokens": 50,
    "temperature": 0.7
  }'
```

## 5. Chat Completion (Multi-turn Conversation)

Test a conversation with history.

```bash
curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coder",
    "messages": [
      {"role": "system", "content": "You are a helpful AI coding assistant."},
      {"role": "user", "content": "Write a simple Python function to add two numbers."},
      {"role": "assistant", "content": "```python\ndef add_numbers(a, b):\n  return a + b\n```"},
      {"role": "user", "content": "Can you add type hints to that function?"}
    ],
    "max_tokens": 100,
    "temperature": 0.3
  }'
```

## 6. Text Completion with Stop Sequences

Test using stop sequences to control generation.

```bash
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "coder",
    "prompt": "Write a list of three common fruits:\n1. Apple\n2.",
    "max_tokens": 30,
    "temperature": 0.2,
    "stop": ["\n4.", "\n\n"]
  }'
```

## Notes on Testing Long Context (64k tokens)

- The model is configured with `--max-model-len 65536`.
- Directly sending 64k tokens in a single `curl` prompt can be cumbersome and might hit client-side or intermediate proxy limits if any.
- For thorough long-context testing, it's often better to use a client library (e.g., OpenAI's Python library pointed to this local endpoint) or a dedicated benchmarking tool that can handle very large inputs more robustly.
- You can still test with progressively larger prompts via `curl` to observe performance and memory usage. Ensure your input prompt is properly JSON escaped if it contains special characters.

Example of how to use OpenAI Python client (install with `pip install openai`):
```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:8000/v1",
    api_key="YOUR_API_KEY" # Can be any string, vLLM doesn't enforce it by default
)

# Example for completion
# prompt_text = "Your very long prompt here..."
# completion = client.completions.create(
#   model="coder",
#   prompt=prompt_text,
#   max_tokens=500
# )
# print(completion.choices[0].text)

# Example for chat completion
# messages_payload = [
#    {"role": "system", "content": "You are a helpful assistant."},
#    {"role": "user", "content": "Your very long user message here..."}
# ]
# chat_completion = client.chat.completions.create(
#   model="coder",
#   messages=messages_payload,
#   max_tokens=500
# )
# print(chat_completion.choices[0].message.content)
```
Remember to replace `"YOUR_API_KEY"` with any non-empty string if you haven't configured an API key in vLLM (by default, it's not required).
