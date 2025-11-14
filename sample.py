# -*- coding: utf-8 -*-
import ollama

resp = ollama.chat(model="llama3.1:8b", messages=[
    {"role": "user", "content": "Explain quantum entanglement simply."}
])

print(resp["message"]["content"])
