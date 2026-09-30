FROM nvidia/cuda:12.3.2-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

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
    libssl-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

RUN python3 -m pip install --no-cache-dir --upgrade pip

WORKDIR /app

RUN git clone --depth 1 https://github.com/ggml-org/llama.cpp.git

WORKDIR /app/llama.cpp

# T4 = 7.5, L4 = 8.9
RUN cmake -S . -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DGGML_CUDA=ON \
    -DGGML_NATIVE=OFF \
    -DGGML_BACKEND_DL=ON \
    -DCMAKE_CUDA_ARCHITECTURES="75;89" \
    -DLLAMA_BUILD_TESTS=OFF \
    -DLLAMA_BUILD_EXAMPLES=OFF \
    && \
    cmake --build build --config Release -j2

RUN cp build/bin/llama-server /usr/local/bin/llama-server

WORKDIR /app

RUN pip install --no-cache-dir modal requests

EXPOSE 9090

CMD ["/usr/local/bin/llama-server"]

