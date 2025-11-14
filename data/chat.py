# -*- coding: utf-8 -*-
import streamlit as st
import requests

OLLAMA_MODEL = "llama3.1:8b"
OLLAMA_URL = "http://localhost:11434/api/generate"

def prompt_json(prompt: str) -> dict:
    return {"model": OLLAMA_MODEL, "prompt": prompt, "stream": False}

st.title("🧠 Chat with Local Ollama")

prompt = st.text_area("Enter your prompt:", height=150)

if st.button("Send") and prompt.strip():
    with st.spinner("Thinking..."):
        response = requests.post(OLLAMA_URL, json=prompt_json(prompt))

        if response.ok:
            result = response.json()
            st.markdown("### 💬 Response")
            st.write(result.get("response", "No response received."))
        else:
            st.error(f"Error: {response.status_code} - {response.text}")
