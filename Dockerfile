FROM raspbian/stretch

RUN apt update && apt upgrade -y && apt install -y python3{,-pip,-numpy} libatlas-base-dev libwebp6 libtiff5 libjasper1 libilmbase12 libopenexr22 libgstreamer1.0-0 libavcodec57 libswscale4 libqt4-test libqtcore4 libqtgui4 libjpeg62-turbo libavformat57
RUN pip3 install opencv-python
