FROM ubuntu:20.04
# 维护者信息
LABEL maintainer="suntao.hn@gmail.com"
ENV DEBIAN_FRONTEND=noninteractive TZ=Asia/Shanghai
ARG user=suntao usergroup=biorobotics
ENV user=${user}
ENV AMBOT=/home/${user}/workspace/ambot
ENV PYENV_ROOT ${HOME}/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH


RUN echo "deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \ deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \ deb-src http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse \deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \ deb-src http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse \ deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \ deb-src http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse \ deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse \ deb-src http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse \ deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse \ deb-src http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && apt-get update -y && apt-get upgrade -y


# 添加普通用户组
RUN groupadd -g 1000 ${usergroup} && \
# 添加普通用户
    useradd --system --create-home --no-log-init --uid 1000 --groups ${usergroup} --shell /bin/bash ${user} && \
    adduser ${user} sudo && \
# 给创建的用户设置密码，密码为: l
    echo "${user}:l" | chpasswd && \
    apt-get install -y ca-certificates && update-ca-certificates

    # 安装常见软件库
RUN apt-get update && apt-get install -y sudo vim curl pkg-config build-essential ninja-build automake autoconf libtool wget curl git gcc libssl-dev bc slib squashfs-tools  tree python3-dev python3-pip device-tree-compiler ssh cpio fakeroot libncurses5 libncurses5-dev genext2fs rsync unzip mtools tclsh ssh-client  && \
    apt-get install -y vim gcc g++ cmake libgsl-dev make git && \
    apt-get install libgsl-dev

# install qpOASES and egein
#RUN cd ${HOME} && git clone https://github.com/coin-or/qpOASES.git && cd qpOASES && \
#mkdir build && cd build && cmake .. && make && sudo make install && cd ${HOME} && rm -rf qpOASES && \
#cd ${HOME} && git clone https://github.com/eigenteam/eigen-git-mirror && cd eigen-git-mirror && \
#mkdir build && cd build && cmake .. && make && sudo make install && cd ${HOME} && rm -rf eigen-git-mirror

# install osg
#RUN apt-get update -y && apt-get upgrade -y && apt-get install -y openscenegraph  &&  sudo apt-get install -y build-dep openscenegraph && \
#cd ${HOME} && git clone https://github.com/openscenegraph/OpenSceneGraph.git && cd OpenSceneGraph && \
#mkdir build && cd build && cmake .. && make && sudo make install && cd ${HOME} && rm -rf OpenSceneGraph

# make workspace dir
RUN mkdir -p /home/${user}/workspace
WORKDIR /home/${user}/workspace

# install ros and ros package
RUN cd ${HOME} && git clone https://github.com/sunzhon/ambot_install.git && \
cd ${HOME}/ambot_install && pwd | echo && sh ./install_ros.sh

#### Install pyenv and pyenv-virtual 
RUN git clone https://github.com/pyenv/pyenv.git ${HOME}/.pyenv && \
cd ${HOME}/.pyenv && src/configure && make -C src && \
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ${HOME}/.bashrc && \
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ${HOME}/.bashrc && \
sh ${HOME}/.bashrc  && \
eval "$(~/.pyenv/bin/pyenv init -)" && \
git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv && \
eval "$(~/.pyenv/bin/pyenv virtualenv-init -)"

# change to use china source pip
#RUN touch ~/.pip/.pip.conf
#RUN  cd ~ && mkdir .pip  && echo "[global] \ index-url = https://pypi.tuna.tsinghua.edu.cn/simple \ [install] \ trusted-host=mirrors.aliyun.com" >> ~/.pip/pip.conf && pip config list
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple


# install python interpret and creat DRL env
RUN wget https://registry.npmmirror.com/-/binary/python/3.8.16/Python-3.8.16.tar.xz -P ~/.pyenv/cache/ && \
~/.pyenv/bin/pyenv install 3.8.16
RUN ~/.pyenv/bin/pyenv virtualenv 3.8.16 DRL && ~/.pyenv/bin/pyenv global DRL && pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple 

# Install other popular packages used for machinelearning
RUN pip install torchmetrics thop numpy pandas matplotlib termcolor pyyaml scikit-learn scipy statannotations gnureadline brokenaxes scikit-kinematics jupyterlab-vim configargparse install h5py scikit-kinematics transforms3d tensorboard install optuna neptune neptune_optuna -i https://pypi.tuna.tsinghua.edu.cn/simple

#RUN pyenv local DRL
#COPY torch-1.10.0+cu113-cp38-cp38-linux_x86_64.whl .
#ADD torchaudio-0.10.0+cu113-cp38-cp38-linux_x86_64.whl .
#ADD torchvision-0.11.1+cu113-cp38-cp38-linux_x86_64.whl .

#RUN pip install pillow numpy==1.23.5 -i https://pypi.tuna.tsinghua.edu.cn/simple

#RUN pip install ./torch-1.10.0+cu113-cp38-cp38-linux_x86_64.whl && pip install ./torchvision-0.11.1+cu113-cp38-cp38-linux_x86_64.whl && pip install ./torchaudio-0.10.0+cu113-cp38-cp38-linux_x86_64.whl -i https://pypi.tuna.tsinghua.edu.cn/simple
#RUN pip3 install torch-1.10.0+cu113 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu113
#RUN pip3 install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html

#-f https://download.pytorch.org/whl/cu113/torch_stable.html
#-i https://pytorch.bj.bcebos.com/torch-latest.whl

# install isaac gym
COPY IsaacGym_Preview_4_Package.tar.gz /home/${user}/workspace/ 
#RUN cd /home/${user}/workspace/ && tar -xvzf IsaacGym_Preview_4_Package.tar.gz && cd isaacgym/python && pip install -e .


# install nvcc which is nvidia compile for build CUDA code to run on GPU
#RUN sudo apt install nvidia-cuda-toolkit


RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

 # 拷贝主机的目录内容 ambot
#COPY . ./ambot/
# 容器创建后，默认登陆以bash作为登陆环境
RUN apt-get clean

USER suntao
CMD ["/bin/bash"]

