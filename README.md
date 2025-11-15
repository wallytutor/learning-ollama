# Learning Ollama

Testing [Ollama](https://ollama.com/) for local deployment.

## References

Platforms:

- [Ollama](https://ollama.com/)
- [HuggingFace](https://huggingface.co/)

Models:

- [llama3.1](https://ollama.com/library/llama3.1).
- [mistral-nemo](https://ollama.com/library/mistral-nemo)

Packages:

- [ollama](https://github.com/ollama/ollama-python)
- [haystack](https://docs.haystack.deepset.ai/docs/intro)
- [weaviate](https://docs.weaviate.io/weaviate/quickstart)

## Deploying in RHEL

```bash
# https://developer.nvidia.com/cuda-downloads

# Identify NVIDIA driver
nvidia-smi

# Identify RHEL version
cat /etc/redhat-release
# or rpm -q redhat-release

# Add corresponding repo/toolkit
dnf config-manager --add-repo=https://developer.download.nvidia.com/compute/cuda/repos/rhel9/x86_64/cuda-rhel9.repo
dnf clean all

dnf -y install cuda-toolkit-13-0
dnf install -y cuda-toolkit-13-0

dnf install -y cuda-driver-devel-12-8
dnf install -y cuda-toolkit-12-8
```