#FROM ubuntu:latest
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:16 as build

WORKDIR /tmp

ARG JAVA_VERSION=11
# See https://developer.android.com/studio/index.html#command-tools
ARG ANDROID_SDK_VERSION=9477386
# See https://androidsdkmanager.azurewebsites.net/Buildtools
ARG ANDROID_BUILD_TOOLS_VERSION=33.0.0
# See https://developer.android.com/studio/releases/platforms
ARG ANDROID_PLATFORMS_VERSION=32
# See https://gradle.org/releases/
ARG GRADLE_VERSION=7.4.2
# See https://www.npmjs.com/package/@ionic/cli
ARG IONIC_VERSION=6.20.8
# See https://www.npmjs.com/package/@capacitor/cli
ARG CAPACITOR_VERSION=4.6.1

ENV ZSH=~/.oh-my-zsh
RUN \
	apt-get update \
	&& apt-get -y upgrade \
	&& apt-get -y install --no-install-recommends \
		ca-certificates \
		git \
		openjdk-${JAVA_VERSION}-jre \
    	openjdk-${JAVA_VERSION}-jdk \
		sudo \
		wget \
		zsh \
    #cleanup \
	&& apt-get clean \
    && rm -fr /var/lib/apt/lists/* \
    && find /usr/local \( -type d -a -name test -o -name tests -o -name '__pycache__' \) -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' \; \
    && rm -fr /tmp/* /var/{cache,log}/* /root/.cache

# install ZSH Shell
RUN \
	wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O oh-my-zsh-install.sh \
	&& rm -rf /root/.oh-my-zsh \
	&& chmod +x ./oh-my-zsh-install.sh \
	&& sudo ./oh-my-zsh-install.sh --unattended \
	&& rm -f ./oh-my-zsh-install.sh

# install Gradle
ENV GRADLE_HOME=/opt/gradle

RUN \
	wget https://downloads.gradle-dn.com/distributions/gradle-${GRADLE_VERSION}-bin.zip -O gradle-${GRADLE_VERSION}-bin.zip \
	&& unzip -d $GRADLE_HOME gradle-${GRADLE_VERSION}-bin.zip \
	&& rm gradle-${GRADLE_VERSION}-bin.zip

ENV PATH=$PATH:/opt/gradle/gradle-${GRADLE_VERSION}/bin


# install android
ENV ANDROID_HOME=/opt/android-sdk
RUN \
	wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -O commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
	&& mkdir $ANDROID_HOME \
	&& unzip commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -d $ANDROID_HOME \
	&& rm commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
    && yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses \
    && $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" "platforms;android-${ANDROID_PLATFORMS_VERSION}"

ENV PATH=$PATH:${ANDROID_HOME}/cmdline-tools:${ANDROID_HOME}/platform-tools

# configure node js
ENV NPM_CONFIG_PREFIX=${HOME}/.npm-global

# Install Ionic CLI and Capacitor CLI
# (TODO: try to remove it, after first android build was successful!)
RUN \
	npm install -g @ionic/cli@${IONIC_VERSION} \
    && npm install -g @capacitor/cli@${CAPACITOR_VERSION}

COPY docker_root/ /

WORKDIR /root

#CMD ["/usr/bin/zsh", "-c", "/workspace/build.sh"]
CMD [ "/usr/bin/zsh" ]

