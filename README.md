This Guide is for users Who want run Stabble diffusion in dokcer image on Host Where installed Nvidia GPU.
When i Try Install i get Problem if i wnat connect to image from Host computer i ger error because Autimatic1111 listen only 127.0.0.1:7860 
Solutiin Was Run Web-ui With --listen attribute and after That i able connect webui But still get problem installation some extentions are blocked when web-ui Runing with --listen attribute
and i figure out Workeround in image i install nginx and configured Traffic redirection now : 
  This setup will:
      Make nginx inside the container listen on 3001 and forward requests to the application running on 127.0.0.1:7860.
      Allow you to access the application on the host at http://localhost:3001. 
      The traffic will go through nginx on port 3001 and reach the application at 127.0.0.1:7860 within the container.

now Start installation Process : 

I Use PopOS witch Preintalled nvidia Driver. if you Dont Hawe install nvidia Drivers first you must install That.
1. Step One if you Dont Hawe install nvidia Driver.
2. step two install doker - https://docs.docker.com/engine/install/
3. install Nvidia Docker Toolkit : Official Link - https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
   
   1. Add the NVIDIA GPG Key and Repository

# curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
Purpose: Downloads the NVIDIA GPG key, de-armors (converts it to binary format), and saves it to /usr/share/keyrings/.

# curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
Purpose: Downloads NVIDIA’s package list for the container toolkit and updates it to use the signed GPG key, then adds it to the package sources.

# sudo sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
Purpose: Uncomments lines with the term experimental in the NVIDIA repository file.

# sudo apt-get install -y nvidia-container-toolkit
Purpose: Installs the NVIDIA Container Toolkit from the newly added repository.

# sudo nvidia-ctk runtime configure --runtime=docker
Purpose: Configures the NVIDIA runtime specifically for Docker using nvidia-ctk (NVIDIA Container Toolkit).

# nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json
Purpose: Configures the NVIDIA runtime for Docker, but this time explicitly setting the configuration file to $HOME/.config/docker/daemon.json.

# sudo nvidia-ctk runtime configure --runtime=crio
Purpose: Configures the NVIDIA runtime for CRI-O, an alternative container runtime often used with Kubernetes.

# nvidia-ctk -v
you must get output someting like this
 "NVIDIA Container Toolkit CLI version 1.12.1

 4. step 4  Create folder and copy Dockerfile & nginx.conf in this folder
 5. step 5 build docker image witch comand : sudo docker build -t imagename .
 6. and then Run image 
