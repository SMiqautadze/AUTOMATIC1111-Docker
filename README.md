

---

# Stable Diffusion in Docker with NVIDIA GPU 🖥️ 🚀

A comprehensive guide to running **Stable Diffusion** with **Automatic1111’s Web UI** in a Docker container on a host equipped with an **NVIDIA GPU**.

---

## 🚧 Problem

When Installing Stabble Diffusion Web UI Automatic1111 in Docekr, we have some limitation The Web UI for **Automatic1111** listening only `127.0.0.1:7860`, 
which limits access to localhost only. 
Solution is  adding the `--listen` attribute When Starting Web UI. after This Automatic1111 is runing on 0.0.0.0:7860 and allows connection from any source.
But Here it can block certain extensions during installation.

## 💡 Solution

To enable external access without restricting extensions:
1. Install **Nginx** within the Docker container.
2. Configure **Nginx** to redirect traffic from port `3002` to `127.0.0.1:7860`.

### This setup will:

- Have **Nginx** listen on port `3002` within the container and forward requests to the Web UI on `127.0.0.1:7860`.
- Allow you to access the Web UI externally via `http://localhost:3002`, routing traffic through **Nginx** on port `3002` to the Web UI inside the container.

---

## 🛠️ Installation Process

### Prerequisites

Ensure **NVIDIA drivers** are installed on your host system. This guide assumes **PopOS** (with pre-installed NVIDIA drivers), but if you’re on a different OS, [install NVIDIA drivers](https://docs.nvidia.com/) as needed.

### Steps

### 1️⃣ Install NVIDIA Drivers (if necessary)

Refer to the [NVIDIA driver installation guide](https://docs.nvidia.com/).

### 2️⃣ Install Docker

Follow the official [Docker installation guide](https://docs.docker.com/engine/install/).

### 3️⃣ Install NVIDIA Docker Toolkit

Complete instructions are available in the [NVIDIA Container Toolkit installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). Below are key steps:

#### NVIDIA Toolkit Installation Commands

- **Add the NVIDIA GPG Key and Repository**

   ```bash
   # Add the NVIDIA GPG key
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
   ```
   *Purpose*: Downloads the NVIDIA GPG key, converts it to binary, and saves it to `/usr/share/keyrings/`.

   ```bash
   # Add the NVIDIA package list with the signed GPG key
   curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
   sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
   sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```
   *Purpose*: Adds the NVIDIA repository with the signed GPG key to the system’s package list.

- **Enable Experimental Packages in the NVIDIA Repo**

   ```bash
   sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```
   *Purpose*: Uncomments lines containing `experimental` in the NVIDIA repository to enable additional packages.

- **Install NVIDIA Container Toolkit**

   ```bash
   sudo apt-get install -y nvidia-container-toolkit
   ```
   *Purpose*: Installs the NVIDIA Container Toolkit, enabling Docker to use NVIDIA GPUs.

- **Configure NVIDIA Runtime for Docker**

   ```bash
   sudo nvidia-ctk runtime configure --runtime=docker
   ```
   *Purpose*: Configures Docker to use the NVIDIA runtime.

   ```bash
   # Optional configuration for user-specific daemon.json
   nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
   ```

- **Verify Installation**

   ```bash
   nvidia-ctk -v
   ```
   Expected output: "NVIDIA Container Toolkit CLI version 1.12.1"

### 4️⃣ Docker Image Setup

- **Prepare Files**:  
   Create a folder and place your `Dockerfile` and `nginx.conf` inside this folder.

- **Build Docker Image**:
   ```bash
   sudo docker build -t <imagename> .
   ```

- **Run the Docker Image**:
   ```bash
   sudo docker run -d --add-host=host.docker.internal:host-gateway --gpus all --name <containername> --restart always -p 3002:3002 <imagename>:latest
   ```

---

### Accessing the Web UI

Now you can access **Stable Diffusion** at `http://localhost:3002` on your host machine, with traffic routed through **Nginx** on port `3002` to `127.0.0.1:7860` inside the container.

---
