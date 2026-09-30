# Basis-Image mit CUDA 12.x Devel für die Kompilierung
FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# Umgebungsvariablen für non-interactive Installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# System-Abhängigkeiten, Python 3.11, CMake und Build-Tools installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    ninja-build \
    curl \
    python3.11 \
    python3.11-dev \
    python3.11-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Python 3.11 als Standard setzen
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

# Pip auf den neuesten Stand bringen
RUN python3 -m pip install --no-cache-dir --upgrade pip

# Arbeitsverzeichnis erstellen
WORKDIR /app

# llama.cpp klonen (oder Quellcode kopieren)
RUN git clone https://github.com/ggerganov/llama.cpp.git /app/llama.cpp

# llama.cpp mit CUDA-Architekturen 75;86;89;90 kompilieren
WORKDIR /app/llama.cpp/build
RUN cmake .. \
    -DGGML_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES="75;89" \
    -DCMAKE_BUILD_TYPE=Release \
    && cmake --build . --config Release -j$(nproc)

RUN cp /app/llama.cpp/build/bin/llama-server /usr/local/bin/llama-server

# Arbeitsverzeichnis zurücksetzen
WORKDIR /app

# Optional: Python-Pakete wie modal, requests etc. vorinstallieren
RUN pip install --no-cache-dir modal requests

EXPOSE 9090

CMD ["/bin/bash"]