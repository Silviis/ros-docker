FROM osrf/ros:noetic-desktop-full
ENV USERNAME docker

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

RUN echo "source /opt/ros/noetic/setup.bash" >> /home/docker/.bashrc  # Source ROS installation
RUN echo "export NO_AT_BRIDGE=1" >> /home/docker/.bashrc
RUN echo "cd /home/docker/" >> /home/docker/.bashrc  # Change default directory to home directory
RUN apt update -y && apt install nano net-tools python3-catkin-tools -y 
RUN runuser -l docker -c 'rosdep update'
