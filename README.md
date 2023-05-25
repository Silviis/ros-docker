# ros-docker
This repository contains required files to run ROS noetic (or any other version of ROS) inside a docker container (with GUI support as well). User "docker" is created inside the container without password and with sudo privileges. The default branch (`master`) uses `bash` as default shell, but `zsh` branch can be used if you prefer `zsh` as your shell instead.


### Prerequisites

Only Docker is needed to run the container. If you use older versions of docker, you will have to install Docker Compose as well (as it doesn't come with the Docker package by default). To install Docker Compose, follow the instructions [here](https://docs.docker.com/compose/install/).

## Getting Started

Clone this repository with
```sh
git clone https://github.com/Silviis/ros-docker.git
```

Then place your ROS workspace folder inside the cloned repository. The workspace should be named `catkin_ws` (can be edited in `docker-compose.yml`). 

If you have your workspace folder in version control, the easiest way to utilize this repository is to fork this repository and then add your catkin workspace as a submodule to that repository. To do so, first remove the `catkin_ws` folder from the repository with:
```sh
cd ros-docker
rmdir catkin_ws
```

Then add your workspace as a submodule with:
```sh
git submodule add https://github.com/yourusername/your_catkin_ws.git catkin_ws
```



### Running the container

**Note that if you are running older versions of Docker, you might need to use `docker-compose` instead of `docker compose`.**
1. First make the repository folder your current working directory (in host system):
   ```sh
   cd ros-docker
   ```


2. To pull, build and run the container use:
   ```sh
   docker compose up -d
   ```

   This will pull the base image from Docker Hub, make some changes to it (see `Dockerfile`) and run it in detached mode.

3. To attach a shell to the running container run the following command:
   ```sh
   docker compose exec ros bash
   ```
   This will attach a bash shell to the running container. Use the `zsh` branch if you desire using `zsh` instead of `bash`.
   

4. Now you should be able to use the ROS tools inside the container. For example:
   ```sh
    rostopic list
   ```

5. To build the workspace inside the container, first enter the workspace folder (inside the container environment) with:
   ```sh
   cd /home/docker/catkin_ws
   ```
   and build the workspace with
   ```sh
   catkin build # Or catkin_make if it is preferred
   ```

6. Then access your ros packages inside the container, first source the workspace with:
   ```sh
    source /home/docker/catkin_ws/devel/setup.bash
   ```
   or 
   ```sh
    source /home/docker/catkin_ws/devel/setup.zsh
   ```  
    if you are using `zsh` as your shell.

7. Now you should be able to run your ROS packages inside the container as you would normally do. For example:
   ```sh
    rosrun yourpkg yournode
   ```

8. To exit the container, simply type `exit` in the terminal (or press `ctrl + d`). To shut down the container use:
   ```sh
   docker compose down
   ```
   This will stop and remove the container. Notice that this command will remove all the changes made to the container (installed packages etc.) excluding the changes made to the workspace folder (and its subfolders) as it is mounted to the host system. You can add more mounted directories (even multiple workspaces) to the container in `docker-compose.yml` file if needed.

9. The environment variables (ROS_IP & ROS_MASTER_URI) in `.env` file should be edited according to your needs. The default values point to localhost. You can also set these variables inside the container environment if you prefer (e.g. by running `export ROS_IP=your_ip` inside the container).
