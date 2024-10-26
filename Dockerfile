# Base image
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04
# Set the working directory
WORKDIR /app
# Install necessary packages, including nginx and supervisor
RUN apt-get update && apt-get install -y --no-install-recommends \
    passwd \
    libgl1 libglib2.0-0 \
    python3 python3-venv python3-pip \
    libgoogle-perftools-dev nvidia-container-toolkit \
    git \
    wget \
    curl \
    vim \
    nginx \
    inetutils-ping \
    sudo \
    net-tools \
    iproute2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Set the root password
ENV ROOT_PASSWORD=toor
RUN echo "root:$ROOT_PASSWORD" | chpasswd
# Clone the application repository and install Python dependencies
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /app
RUN pip install --upgrade pip
RUN pip install fastapi diffusers transformers scipy xformers clip openai-clip huggingface_hub
RUN pip install torchmetrics==0.6.0
RUN pip install pytorch-lightning==1.4.9
RUN pip install pydantic==1.10.7
RUN pip install --no-cache-dir -r /app/requirements.txt
RUN python3 -m venv venv
# Apply the necessary patch
RUN sed -i 's/torch\.cuda\.amp\.custom_fwd(cast_inputs=torch\.float32)/torch.amp.custom_fwd(device_type='"'"'cuda'"'"',cast_inputs=torch.float32)/' /usr/local/lib/python3.10/dist-packages/kornia/feature/lightglue.py
# Copy the nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf
# Expose the necessary port
EXPOSE 7860
# Create a non-root user, set permissions, and switch to that user for the Python process
RUN useradd -m sd && \
    chmod +x /app/webui.sh && \
    chown -R sd:sd /app

CMD nginx && runuser -u sd -- python3 /app/launch.py --xformers
