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

RUN echo "source /ros_entrypoint.sh" >> /home/docker/.bashrc
RUN echo "export NO_AT_BRIDGE=1" >> /home/docker/.bashrc
RUN apt update -y && apt install nano net-tools python3-catkin-tools -y 
