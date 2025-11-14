# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Script parameters
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

param ()

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Global configuration
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

$OLLAMA_PROJECT_DIR    = "$PsScriptRoot"
$OLLAMA_BIN_DIR        = "$OLLAMA_PROJECT_DIR\bin"
$OLLAMA_TMP_DIR        = "$OLLAMA_PROJECT_DIR\tmp"
$OLLAMA_EXECUTABLE_URL = "https://github.com/ollama/ollama/releases/download/v0.12.11/ollama-windows-amd64.zip"
$OLLAMA_EXECUTABLE_ZIP = "$OLLAMA_TMP_DIR\ollama.zip"
$OLLAMA_MODEL_PULL     = "llama3.1:8b"

$env:OLLAMA_MODELS     = "$OLLAMA_PROJECT_DIR\models"

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

function Main {
    ####
    # Ensure required directories exist:
    ####

    if (!(Test-Path -Path $OLLAMA_BIN_DIR)) {
        New-Item -ItemType Directory -Path $OLLAMA_BIN_DIR
    }

    if (!(Test-Path -Path $OLLAMA_TMP_DIR)) {
        New-Item -ItemType Directory -Path $OLLAMA_TMP_DIR
    }

    if (!(Test-Path -Path $env:OLLAMA_MODELS)) {
        New-Item -ItemType Directory -Path $env:OLLAMA_MODELS
    }

    ####
    # Download and extract as required:
    ####

    if (!(Test-Path -Path $OLLAMA_EXECUTABLE_ZIP)) {
        Start-BitsTransfer `
            -Source      $OLLAMA_EXECUTABLE_URL `
            -Destination $OLLAMA_EXECUTABLE_ZIP `
            -ErrorAction Stop
    }

    if (!(Test-Path -Path "$OLLAMA_BIN_DIR\ollama.exe")) {
        Expand-Archive `
            -Path            $OLLAMA_EXECUTABLE_ZIP `
            -DestinationPath $OLLAMA_BIN_DIR
    }

    ####
    # Start server:
    ####

    if (Get-Process -Name "ollama" -ErrorAction SilentlyContinue) {
        Write-Output "Ollama is already running..."
    } else {
        Start-Process `
            -FilePath "$OLLAMA_BIN_DIR\ollama.exe" `
            -ArgumentList "serve" `
            -NoNewWindow
    }

    ####
    # Pull model as required:
    ####

    $models = & "$OLLAMA_BIN_DIR\ollama.exe" "list"

    if ($models | Select-String "$OLLAMA_MODEL_PULL") {
        Write-Output "Model is present"
    } else {
        Write-Output "Model not found"
        Start-Process `
            -FilePath "$OLLAMA_BIN_DIR\ollama.exe" `
            -ArgumentList "pull", $OLLAMA_MODEL_PULL `
            -NoNewWindow -Wait
    }

    # ollama run llama3.1:8b
    # As usual the Ollama API will be served on http://localhost:11434
}

Main

# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
#
# -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+