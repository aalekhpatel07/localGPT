# syntax=docker/dockerfile:1
# Build as `docker build . -t localgpt`, requires BuildKit.
# Run as `docker run -it --mount src="$HOME/.cache",target=/root/.cache,type=bind --volume <path/to/data_root>:/data --gpus=all localgpt`, requires Nvidia container toolkit.

FROM nvidia/cuda:11.7.1-runtime-ubuntu22.04
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-get install -y \
  g++-11 make python3 python-is-python3 pip \
  libgl1-mesa-glx \
  poppler-utils \
  tesseract-ocr \
  libtesseract-dev
WORKDIR /app
RUN mkdir /data  # This is where the actual data files will be mounted.
# only copy what's needed at every step to optimize layer cache
COPY requirements.txt .
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# use BuildKit cache mount to drastically reduce redownloading from pip on repeated builds
ENV device_type=cpu
RUN --mount=type=cache,target=/root/.cache CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install --timeout 100 -r requirements.txt llama-cpp-python==0.1.83
COPY . .
ENV device_type=cuda
CMD ["/entrypoint.sh"]
