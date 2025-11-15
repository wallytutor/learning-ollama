# -*- coding: utf-8 -*-
import streamlit as st
import ollama

OLLAMA_MODEL = "llama3.1:8b"
OLLAMA_ALIVE = 600


def chat(prompt: str) -> str:
    """ Wraps the Ollama model and returns the response. """
    config = {
        "model": OLLAMA_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "options": {"keep_alive": OLLAMA_ALIVE}
    }
    response = ollama.chat(**config)

    if 'message' in response and 'content' in response['message']:
        return response['message']['content']

    return "Sorry, I couldn't get a response."


st.title("🧠 Chat with Local Ollama")
prompt = st.text_area("Enter your prompt:", height=150)

if st.button("Send") and prompt.strip():
    with st.spinner("Thinking..."):
        response = chat(prompt)

        st.markdown("### 💬 Response")
        st.write(response)
