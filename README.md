# Stable Diffusion in Docker

This guide helps users run **Stable Diffusion** in a Docker container on a host with an installed NVIDIA GPU.

### Problem
When setting up **Automatic1111's Stable Diffusion Web UI**, it defaults to listening on `127.0.0.1:7860`, which limits access to localhost only. Running the Web UI with the `--listen` attribute allows external connections, but it may restrict the installation of certain extensions.

### Solution
To work around this limitation:
1. Install **Nginx** within the Docker container.
2. Configure **Nginx** to redirect traffic from `3002` to `127.0.0.1:7860`.

This setup enables:
- **Nginx** to listen on port `3002` within the container and forward requests to the Web UI on `127.0.0.1:7860`.
- Accessing the Web UI externally via `http://localhost:3001`.

---

## Installation Process

### Prerequisites
This guide assumes you're using **PopOS** (with pre-installed NVIDIA drivers). If not, install NVIDIA drivers before proceeding.

### Steps

1. **Install NVIDIA Drivers (if necessary)**:
   - Follow the [NVIDIA driver installation guide](https://docs.nvidia.com/).

2. **Install Docker**:
   - Follow the official [Docker installation guide](https://docs.docker.com/engine/install/).

3. **Install NVIDIA Docker Toolkit**:
   - Follow the [NVIDIA Container Toolkit installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

#### NVIDIA Toolkit Installation Commands

1. **Add the NVIDIA GPG Key and Repository**:
   ```bash
   # Add the NVIDIA GPG key
   curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
   ```
   - *Purpose*: Downloads the NVIDIA GPG key, converts it to binary, and saves it to `/usr/share/keyrings/`.

   ```bash
   # Add the NVIDIA package list with the signed GPG key
   curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```
   - *Purpose*: Adds the NVIDIA repository with the signed GPG key to the system's package list.

2. **Enable Experimental Packages in the NVIDIA Repo**:
   ```bash
   sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
   ```
   - *Purpose*: Uncomments lines containing `experimental` in the NVIDIA repository to enable additional packages.

3. **Install NVIDIA Container Toolkit**:
   ```bash
   sudo apt-get install -y nvidia-container-toolkit
   ```
   - *Purpose*: Installs the NVIDIA Container Toolkit, enabling Docker to use NVIDIA GPUs.

4. **Configure NVIDIA Runtime for Docker**:
   ```bash
   sudo nvidia-ctk runtime configure --runtime=docker
   ```
   - *Purpose*: Configures Docker to use the NVIDIA runtime.

   ```bash
   # Optional configuration for user-specific daemon.json
   nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
   ```

5. **Verify Installation**:
   ```bash
   nvidia-ctk -v
   ```
   - Expected output: "NVIDIA Container Toolkit CLI version 1.12.1"

### Docker Image Setup

4. **Prepare Files**:
   - Create a folder and place your `Dockerfile` and `nginx.conf` inside this folder.

5. **Build Docker Image**:
   ```bash
   sudo docker build -t <imagename> .
   ```

6. **Run the Docker Image**:
   ```bash
   sudo docker run -d -p 3002:3002 --gpus all <imagename>
   ```

Now you can access **Stable Diffusion** at `http://localhost:3001` on your host machine, with traffic routed through **Nginx** on port `3002` to `127.0.0.1:7860` inside the container.

--- 

This format enhances readability and provides a clean layout for users to follow each step easily. Let me know if you'd like any further refinements!
