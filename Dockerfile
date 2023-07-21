FROM ubuntu:22.04

ENV ANDROID_HOME /opt/android
ENV FLUTTER_HOME /opt/flutter

ENV PATH "${PATH}:${FLUTTER_HOME}/bin:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV JDK_HOME /usr/lib/jvm/openjdk-19

RUN apt-get update && \
    apt-get install -y bash file git unzip xz-utils zip wget openjdk-19-jdk clang cmake ninja-build pkg-config libgtk-3-dev

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.6-stable.tar.xz -O /tmp/flutter.tar.xz && \
    mkdir -p ${FLUTTER_HOME} && \
    tar xf /tmp/flutter.tar.xz -C ${FLUTTER_HOME} --strip-components=1 && \
    chown -R root ${FLUTTER_HOME}


RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/commandlinetools.zip && \
    mkdir -p ${ANDROID_HOME}/cmdline-tools/latest && \
    unzip /tmp/commandlinetools.zip -d /tmp/extract && \    
    mv /tmp/extract/cmdline-tools/* ${ANDROID_HOME}/cmdline-tools/latest && \ 
    chown -R root ${ANDROID_HOME}/cmdline-tools 

RUN wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2022.2.1.20/android-studio-2022.2.1.20-linux.tar.gz -O /tmp/android-studio.tar.gz && \
    mkdir -p /opt/android-studio && \
    tar xf /tmp/android-studio.tar.gz -C /opt/android-studio --strip-components=1 && \
    cp -r /opt/android-studio/jbr /opt/android-studio/jre

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb &&  \
    dpkg -i /tmp/chrome.deb || \
    apt-get install -fy 
 

#Accept licences
RUN yes | sdkmanager --licenses && yes | sdkmanager --update
RUN sdkmanager \
  "tools" \
  "platform-tools" \
  "emulator"

RUN sdkmanager "build-tools;29.0.2"
RUN sdkmanager "platforms;android-29"
RUN sdkmanager "system-images;android-29;google_apis;x86"


RUN flutter precache

RUN flutter doctor -v