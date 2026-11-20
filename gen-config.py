#!/usr/bin/env python3
"""Write .opencode/auth.json and .opencode/opencode.json from .env."""

import json
import os
import subprocess
import sys

DEFAULT_MODEL = "deepseek-v4.1-flash-1017"


def load_env(path):
    env = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            value = value.strip()
            if len(value) > 1 and value[0] == value[-1] and value[0] in "\"'":
                value = value[1:-1]
            env[key.strip()] = value
    return env


def fetch_models(base_url, api_key):
    """One HTTP call: GET /models via curl. (so that we don't have requests as dep)"""
    try:
        result = subprocess.run(
            ["curl", "-s", f"{base_url}/models",
             "-H", f"Authorization: Bearer {api_key}"],
            capture_output=True, text=True,
        )
        return {m["id"]: {"name": m["id"]} for m in json.loads(result.stdout)["data"]}
    except Exception:
        return {}


def main():
    root = os.path.dirname(os.path.abspath(__file__))
    env_file = os.path.join(root, ".env")
    out_dir = os.path.join(root, ".opencode")

    if not os.path.isfile(env_file):
        sys.exit("no .env (cp .env.example .env)")

    env = load_env(env_file)
    provider = env.get("PROVIDER_NAME") or "gwdg"
    base_url = env.get("OPENAI_BASE_URL") or "https://chat-ai.academiccloud.de/v1"
    api_key = env.get("OPENAI_API_KEY") or env.get("OPENCODE_API_KEY")

    if not api_key:
        sys.exit("no API key in .env (set OPENCODE_API_KEY)")

    os.makedirs(out_dir, exist_ok=True)

    auth_file = os.path.join(out_dir, "auth.json")
    if not os.path.exists(auth_file):
        with open(auth_file, "w") as f:
            json.dump({provider: {"type": "api", "key": api_key}}, f, indent=2)
            f.write("\n")

    config_file = os.path.join(out_dir, "opencode.json")
    if not os.path.exists(config_file):
        models = fetch_models(base_url, api_key)
        if not models:
            print(f"could not fetch models from {base_url}/models; "
                  f"using {DEFAULT_MODEL}", file=sys.stderr)
            models = {DEFAULT_MODEL: {"name": DEFAULT_MODEL}}

        model = env.get("MODEL") or DEFAULT_MODEL
        small = env.get("SMALL_MODEL") or model
        prefix = f"{provider}/"
        model = f"{provider}/{model.removeprefix(prefix)}"
        small = f"{provider}/{small.removeprefix(prefix)}"

        config = {
            "$schema": "https://opencode.ai/config.json",
            "provider": {
                provider: {
                    "npm": "@ai-sdk/openai-compatible",
                    "name": provider,
                    "options": {"baseURL": base_url, "apiKey": api_key},
                    "models": models,
                }
            },
            "model": model,
            "small_model": small,
            "share": "disabled",
        }
        with open(config_file, "w") as f:
            json.dump(config, f, indent=2)
            f.write("\n")


if __name__ == "__main__":
    main()
