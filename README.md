Sure! Here's your README modified according to the recommendations, with improved structure, clarity, and visual enhancements:

---

# Stable Diffusion Web UI in Docker with NVIDIA GPU 🖥️🚀

*A comprehensive guide to running **Stable Diffusion** with **Automatic1111’s Web UI** in a Docker container on a host equipped with an **NVIDIA GPU**.*

[![Docker Build](https://img.shields.io/docker/cloud/build/yourusername/yourrepository)](https://hub.docker.com/r/yourusername/yourrepository)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Table of Contents

- [Problem](#problem)
- [Solution](#solution)
- [Prerequisites](#prerequisites)
- [Installation Process](#installation-process)
  - [Step 1: Install NVIDIA Drivers (if necessary)](#step-1-install-nvidia-drivers-if-necessary)
  - [Step 2: Install Docker](#step-2-install-docker)
  - [Step 3: Install NVIDIA Docker Toolkit](#step-3-install-nvidia-docker-toolkit)
  - [Step 4: Docker Image Setup](#step-4-docker-image-setup)
- [Accessing the Web UI](#accessing-the-web-ui)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

---

## 🚧 Problem

When installing the **Stable Diffusion Web UI** (Automatic1111) in Docker, we encounter a limitation: the Web UI listens only on `127.0.0.1:7860`, which restricts access to localhost. Adding the `--listen` argument when starting the Web UI makes it listen on `0.0.0.0:7860`, allowing connections from any source. However, this can block certain extensions during installation.

## 💡 Solution

To enable external access without restricting extensions:

1. **Install Nginx within the Docker container.**
2. **Configure Nginx to redirect traffic from port `3002` to `127.0.0.1:7860`.**

### This setup will:

- Have **Nginx** listen on port `3002` within the container and forward requests to the Web UI on `127.0.0.1:7860`.
- Allow you to access the Web UI externally via `http://localhost:3002`, routing traffic through **Nginx** on port `3002` to the Web UI inside the container.

---

## 📝 Prerequisites

- **NVIDIA Drivers**: Ensure NVIDIA drivers are installed on your host system. This guide assumes **Pop!_OS** (with pre-installed NVIDIA drivers). If you're using a different OS, [install NVIDIA drivers](https://docs.nvidia.com/) as needed.
- **Docker**: Installed on your host system.
- **NVIDIA Docker Toolkit**: Installed and configured.

---

## 🛠️ Installation Process

### Step 1: Install NVIDIA Drivers (if necessary)

Refer to the [NVIDIA driver installation guide](https://docs.nvidia.com/).

### Step 2: Install Docker

Follow the official [Docker installation guide](https://docs.docker.com/engine/install/).

### Step 3: Install NVIDIA Docker Toolkit

Complete instructions are available in the [NVIDIA Container Toolkit installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html). Below are key steps:

#### NVIDIA Toolkit Installation Commands

**Add the NVIDIA GPG Key and Repository**

```bash
# Add the NVIDIA GPG key
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
```

*Purpose*: Downloads the NVIDIA GPG key, converts it to binary, and saves it to `/usr/share/keyrings/`.

```bash
# Add the NVIDIA package list with the signed GPG key
curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

*Purpose*: Adds the NVIDIA repository with the signed GPG key to the system’s package list.

**Enable Experimental Packages in the NVIDIA Repo**

```bash
sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

*Purpose*: Uncomments lines containing `experimental` in the NVIDIA repository to enable additional packages.

**Install NVIDIA Container Toolkit**

```bash
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

*Purpose*: Installs the NVIDIA Container Toolkit, enabling Docker to use NVIDIA GPUs.

**Configure NVIDIA Runtime for Docker**

```bash
sudo nvidia-ctk runtime configure --runtime=docker
```

*Purpose*: Configures Docker to use the NVIDIA runtime.

```bash
sudo systemctl restart docker
```

*Purpose*: Restarts Docker to apply changes.

**Optional configuration for user-specific `daemon.json`**

```bash
nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
```

**Verify Installation**

```bash
nvidia-ctk -v
```

Expected output: `NVIDIA Container Toolkit CLI version 1.12.1`

### Step 4: Docker Image Setup

#### Prepare Files

- Create a project directory:
  ```bash
  mkdir stable-diffusion-docker
  cd stable-diffusion-docker
  ```
- Place your `Dockerfile` and `nginx.conf` inside this folder.

#### Build Docker Image

```bash
sudo docker build -t <imagename> .
```

Replace `<imagename>` with your desired image name.

#### Run the Docker Image

```bash
sudo docker run -d \
  --add-host=host.docker.internal:host-gateway \
  --gpus all \
  --name <containername> \
  --restart always \
  -p 3002:3002 \
  <imagename>:latest
```

Replace `<containername>` with your desired container name.

**Explanation of the command:**

- `-d`: Run container in detached mode (in the background).
- `--add-host=host.docker.internal:host-gateway`: Allows the container to access the host machine.
- `--gpus all`: Grants the container access to all GPUs.
- `--name <containername>`: Assigns a name to the container.
- `--restart always`: Automatically restarts the container if it stops.
- `-p 3002:3002`: Maps port 3002 of the host to port 3002 of the container.

---

## 🌐 Accessing the Web UI

You can now access the **Stable Diffusion Web UI** at:

```
http://localhost:3002 
```
**WARNING** First Time Starting Web UI Take Som time because its Downloading Base SD 1.5 Image


This routes traffic through **Nginx** on port `3002` to `127.0.0.1:7860` inside the container.

---

## 📄 Usage

### Common Command-Line Arguments for Automatic1111

Here are some useful command-line arguments you might use when running the Web UI:

| **Argument**            | **Description**                                                                                     |
|-------------------------|-----------------------------------------------------------------------------------------------------|
| `--listen`              | Makes the Web UI accessible from any IP address.                                                    |
| `--port <PORT>`         | Sets the port for the Web UI (default is `7860`).                                                   |
| `--xformers`            | Enables memory-efficient attention using the `xformers` library.                                    |
| `--api`                 | Enables the API, allowing programmatic access to the Web UI.                                        |
| `--ckpt <path>`         | Specifies the checkpoint model to use.                                                              |
| `--gradio-auth <username:password>` | Enables authentication for the Web UI.                                |
| `--medvram`             | Optimizes VRAM usage for GPUs with limited memory.                                                  |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to open issues, submit pull requests, or suggest improvements.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Note**: Replace placeholders like `<imagename>` and `<containername>` with your actual image and container names. Also, update the badge links at the top with your actual Docker Hub username and repository, and ensure the `LICENSE` file is included in your repository.

### Additional Enhancements

- **Badges**: The badges at the top provide quick visual information about your project's build status and license.
- **Table of Contents**: Helps users navigate through the README quickly.
- **Clear Steps with Headings**: Each installation step is clearly marked and explained.
- **Command Syntax Highlighting**: Improves readability of command-line instructions.
- **Usage Examples**: Provides helpful command-line arguments for users to customize their experience.
- **Contributing Section**: Encourages community involvement.
- **License Section**: Clearly states the licensing of your project.

Let me know if you'd like to add anything else or make further adjustments!
