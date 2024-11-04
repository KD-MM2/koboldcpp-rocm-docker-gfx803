FROM ubuntu:22.04

# Set Timezone
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy files
WORKDIR /app
COPY ./koboldcpp-rocm /app/koboldcpp-rocm
COPY ./amdgpu-install_5.5.50500-1_all.deb /app/amdgpu-install_5.5.50500-1_all.deb

# Install essential packages
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -yq \
    sudo \
    wget \
    vim \
    tree \
    curl \
    radeontop \
    bzip2 \
    build-essential \
    locales-all \
    libclblast-dev \
    libopenblas-dev && \
    # libclang-dev && \
    rm -rf /var/lib/apt/lists/*


# Install ROCm
RUN dpkg -i /app/amdgpu-install_5.5.50500-1_all.deb
RUN amdgpu-install --usecase=hip,rocm,mllib,mlsdk --no-dkms -yq

# Build koboldcpp-rocm
RUN cd /app/koboldcpp-rocm && \
    make LLAMA_OPENBLAS=1 LLAMA_CLBLAST=1 LLAMA_HIPBLAS=1 clean && \
    make LLAMA_OPENBLAS=1 LLAMA_CLBLAST=1 LLAMA_HIPBLAS=1 -j $(nproc)

RUN mkdir /models

# Setup entrypoint
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
CMD "/docker-entrypoint.sh"
