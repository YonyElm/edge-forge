{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "lmstudio": {
      "name": "LM Studio",
      "npm": "@ai-sdk/openai-compatible",
      "options": {
        "baseURL": "http://127.0.0.1:1234/v1"
      },
      "models": {
        "YOUR_MODEL_ID": {
          "name": "Local Model"
        }
      }
    }
  },
  "model": "lmstudio/YOUR_MODEL_ID"
}
