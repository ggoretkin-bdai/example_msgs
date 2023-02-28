VERSION 0.6
FROM ubuntu:18.04

# Run with `-i` flag, (e.g. `earthly --platform=linux/arm64 -i +BUILD_TARGET_NAME`) to drop into bash at any error
# Put `RUN false` to inject an error

install-buildtools-and-sourcecode:
    RUN apt-get update
    RUN apt-get -y install dpkg-dev debhelper
    RUN apt-get -y install fakeroot
    RUN apt-get -y install python3-pip
    RUN python3 -m pip install -U rosdep
    RUN python3 -m pip install -U bloom
    RUN rosdep init
    RUN rosdep update --rosdistro=eloquent

    # install ROS Eloquent
    # https://docs.ros.org/en/eloquent/Installation/Linux-Install-Debians.html
    RUN apt-get -y install curl gnupg2 lsb-release
    RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
    RUN sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
    RUN apt-get update
    RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata # Install separately, because it prompts during install.
    RUN apt-get -y install ros-eloquent-ros-base


    # This is only necessary for building with `colcon`, but not for packaging with .deb
    RUN apt-get -y install python3-colcon-common-extensions

    WORKDIR /workdir/pkg_in_question

    # copy this ROS package over
    # first only the necessary files to allow `rosdep` to install dependencies (better caching in Earthly)
    COPY --dir ./package.xml ./
    RUN rosdep install --rosdistro eloquent --from-paths .

    # copy the rest of the ROS package
    COPY --dir ./msg ./
    COPY --dir ./CMakeLists.txt ./


build-bloom-container-native:
    FROM +install-buildtools-and-sourcecode
    RUN bloom-generate rosdebian --os-name ubuntu --os-version bionic --ros-distro eloquent

    # actually trigger the build, which, for 1200 messages, takes multiple hours on qemu
    RUN fakeroot debian/rules binary
    
    WORKDIR /workdir
    
    # a way to not need to refer to a name like /workdir/ros-eloquent-mypkg-msgs_0.0.0-0bionic_arm64.deb
    RUN mkdir -p artifacts
    RUN mv *.deb artifacts/
    SAVE ARTIFACT artifacts/* AS LOCAL build/


build-colcon:
    FROM +install-buildtools-and-sourcecode
    WORKDIR /workdir/pkg_in_question
    # this took 3 hours on my laptop.
    # it is faster if compiling not for aarch64.
    # The flags are to show all output immediately on the console, and be verbose
    # `source` in bash is a synonym for `.`  in POSIX shell, which this is by default
    RUN . /opt/ros/eloquent/setup.sh && colcon --log-level info build --event-handlers console_direct+
