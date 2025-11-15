# Learning Ollama

Testing [Ollama](https://ollama.com/) for local deployment.

Currently using [llama3.1](https://ollama.com/library/llama3.1).

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