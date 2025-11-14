#!/usr/bin/env bash
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Script parameters
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

set -e

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Global configuration
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

OLLAMA_MODEL_PULL="llama3.1:8b"
# OLLAMA_MODEL_PULL="llama3.1:70b"
# OLLAMA_MODEL_PULL="llama3.1:405b"

OLLAMA_VERSION="v0.12.11"
OLLAMA_GITHUB_REL="https://github.com/ollama/ollama/releases/download/"

OLLAMA_PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLLAMA_BIN_DIR="$OLLAMA_PROJECT_DIR/bin"
OLLAMA_TMP_DIR="$OLLAMA_PROJECT_DIR/tmp"

OLLAMA_EXE_URL="$OLLAMA_GITHUB_REL/$OLLAMA_VERSION/ollama-linux-amd64.tgz"
OLLAMA_EXE_TAR="$OLLAMA_TMP_DIR/ollama.tgz"

export OLLAMA_VULKAN=false
export OLLAMA_LLM_LIBRARY=cuda
export CUDA_VISIBLE_DEVICES=0
export OLLAMA_MODELS="$OLLAMA_PROJECT_DIR/models"

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Helper functions
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

test_in_path() {
    local directory="$1"
    case ":$PATH:" in
        *":$directory:"*) return 0 ;;
        *) return 1 ;;
    esac
}

initialize_add_to_path() {
    local directory="$1"

    if [[ -d "$directory" ]]; then
        echo "Prepending missing path to environment: $directory"
        if ! test_in_path "$directory"; then
            export PATH="$directory:$PATH"
        fi
    else
        echo "Not prepending missing path to environment: $directory"
    fi
}

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Main script
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

main() {
    initialize_add_to_path "$OLLAMA_BIN_DIR/bin"
    export LD_LIBRARY_PATH="$OLLAMA_BIN_DIR/lib/ollama:$LD_LIBRARY_PATH"
    export LD_LIBRARY_PATH="$OLLAMA_BIN_DIR/lib/ollama/cuda_v12:$LD_LIBRARY_PATH"

    # Ensure required directories exist:
    [[ ! -d "$OLLAMA_BIN_DIR" ]] && mkdir -p "$OLLAMA_BIN_DIR"
    [[ ! -d "$OLLAMA_TMP_DIR" ]] && mkdir -p "$OLLAMA_TMP_DIR"
    [[ ! -d "$OLLAMA_MODELS"  ]] && mkdir -p "$OLLAMA_MODELS"

    # Download and extract if required:
    if [[ ! -f "$OLLAMA_EXE_TAR" ]]; then
        echo "Downloading Ollama..."
        curl -L -o "$OLLAMA_EXE_TAR" "$OLLAMA_EXE_URL"
    fi

    if [[ ! -f "$OLLAMA_BIN_DIR/bin/ollama" ]]; then
        echo "Extracting Ollama..."
        tar -xzf "$OLLAMA_EXE_TAR" -C "$OLLAMA_BIN_DIR"
        chmod +x "$OLLAMA_BIN_DIR/bin/ollama"
    fi

    # Start server if required:
    if pgrep -x "ollama" > /dev/null; then
        echo "Ollama is already running..."
    else
        echo "Starting Ollama server..."
        ollama serve &
        sleep 2  # Give the server a moment to start
    fi

    # Pull model if required:
    if ollama list | grep -q "$OLLAMA_MODEL_PULL"; then
        echo "$OLLAMA_MODEL_PULL model already pulled..."
    else
        echo "Pulling model $OLLAMA_MODEL_PULL..."
        ollama pull "$OLLAMA_MODEL_PULL"
    fi

    if [[ -d ".venv" ]]; then
        echo "Virtual environment already exists..."
    else
        echo "Creating virtual environment..."
        python -m venv .venv
        source .venv/bin/activate
        pip install -r requirements.txt
    fi

    # Ollama API is served on http://localhost:11434
    # ollama run $OLLAMA_MODEL_PULL
}

main

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
