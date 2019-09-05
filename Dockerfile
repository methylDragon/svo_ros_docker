FROM ros:kinetic-perception

# Make overlay workspace and add symbolic link to example package
RUN mkdir /home/svo_ws && mkdir /home/svo_ws/src

# Install catkin tools
RUN apt-get update && apt-get install python-pip nano -y
RUN pip install catkin-tools==0.3.1

# Add binaries and fix paths
ADD svo_binaries_1604_kinetic /svo_binaries_1604_kinetic
RUN /bin/bash -c "cd /svo_binaries_1604_kinetic/svo_install_ws && ./fix_path.sh"

# Add symbolic links
RUN ln -s /svo_binaries_1604_kinetic/svo_install_ws /home/svo_install_ws
RUN ln -s /svo_binaries_1604_kinetic/rpg_svo_example /home/svo_ws/src/rpg_svo_example

# Set TERM environment variable to avoid ugly warnings, and build overlay
ENV TERM=xterm
RUN /bin/bash -c ". /opt/ros/kinetic/setup.bash && \
                  . /home/svo_install_ws/install/setup.bash && \
                  cd /home/svo_ws && \
                  catkin config --init --mkdirs --cmake-args -DCMAKE_BUILD_TYPE=Release && \
                  catkin build"

ENV ROS_MASTER_URI=http://127.0.0.1:11311

# Add entrypoint
ADD svo_entrypoint.sh /svo_entrypoint.sh
WORKDIR /home
ENTRYPOINT ["/svo_entrypoint.sh"]
