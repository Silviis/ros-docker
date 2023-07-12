FROM stereolabs/zed:4.0-devel-cuda12.1-ubuntu22.04
ENV USERNAME docker

# Set your ZSH theme here
ARG ZSH_THEME=agnoster
RUN apt update && apt install sudo -y
# Add new user as a sudoer.
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME

# ROS installation
RUN apt update && apt install locales software-properties-common curl -y
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN add-apt-repository universe -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install ros-humble-desktop ros-dev-tools -y

# Change python dist-packages permissions so that docker user is able to use them
#RUN find /usr/local/lib/python3.10/dist-packages/ -type d -exec chmod 755 {} +
#RUN find /usr/local/lib/python3.10/dist-packages/ -type f -exec chmod 644 {} +

# Install ws dependencies
RUN rosdep init
RUN runuser -l docker -c 'rosdep update'
ADD colcon_ws/src /tmp/colcon_ws/src
RUN runuser -l docker -c 'cd /tmp/colcon_ws/ && rosdep install --from-paths src --ignore-src --rosdistro humble -r -y'

# Install libs for vicon receiver
RUN cp /tmp/colcon_ws/src/ros2-vicon-receiver/DataStreamSDK_10.1/libViconDataStreamSDK_CPP.so /usr/lib
RUN cp /tmp/colcon_ws/src/ros2-vicon-receiver/DataStreamSDK_10.1/libboost_system-mt.so.1.58.0 /usr/lib
RUN cp /tmp/colcon_ws/src/ros2-vicon-receiver/DataStreamSDK_10.1/libboost_thread-mt.so.1.58.0 /usr/lib
RUN cp /tmp/colcon_ws/src/ros2-vicon-receiver/DataStreamSDK_10.1/libboost_timer-mt.so.1.58.0 /usr/lib
RUN cp /tmp/colcon_ws/src/ros2-vicon-receiver/DataStreamSDK_10.1/libboost_chrono-mt.so.1.58.0 /usr/lib
RUN chmod 0755 /usr/lib/libViconDataStreamSDK_CPP.so /usr/lib/libboost_system-mt.so.1.58.0 /usr/lib/libboost_thread-mt.so.1.58.0 /usr/lib/libboost_timer-mt.so.1.58.0 /usr/lib/libboost_chrono-mt.so.1.58.0
RUN ldconfig

# ZSH 
RUN apt update -y && apt install nano net-tools zsh git curl openssh-server -y
RUN runuser -l docker -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
RUN sed -i "s!robbyrussell!${ZSH_THEME}!g" /home/docker/.zshrc  # Replace default theme
RUN echo "source /opt/ros/humble/setup.zsh" >> /home/docker/.zshrc  # Source ROS installation
RUN echo "FILE=/home/docker/colcon_ws/install/setup.zsh && test -f \$FILE && source \$FILE" >> /home/docker/.zshrc  # Source ROS workspace
RUN echo "export NO_AT_BRIDGE=1" >> /home/docker/.zshrc  
RUN echo "# argcomplete for ros2 & colcon " >> /home/docker/.zshrc  
RUN echo 'eval "$(register-python-argcomplete3 ros2)"' >> /home/docker/.zshrc  
RUN echo 'eval "$(register-python-argcomplete3 colcon)"' >> /home/docker/.zshrc  
RUN echo "cd /home/docker/" >> /home/docker/.zshrc  # Change default directory to home directory

# Bash
RUN echo "source /opt/ros/noetic/setup.bash" >> /home/docker/.bashrc  # Source ROS installation
RUN echo "export NO_AT_BRIDGE=1" >> /home/docker/.bashrc
RUN echo "cd /home/docker/" >> /home/docker/.bashrc  # Change default directory to home directory

# Comment the next line out if you want to use bash
RUN chsh -s /bin/zsh docker
