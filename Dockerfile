FROM espressif/idf-rust:esp32s3_latest
USER root:root
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nano python3 unzip
RUN ln -s python3 /usr/bin/python

USER esp:esp
WORKDIR /home/esp
RUN git clone -b release/v5.1 https://github.com/espressif/esp-idf.git /home/esp/esp-idf

WORKDIR /home/esp/esp-idf
RUN git submodule update --init

WORKDIR /home/esp
COPY --chown=esp:esp tools.json /home/esp/esp-idf/tools/
RUN /home/esp/esp-idf/tools/idf_tools.py install all
RUN /home/esp/esp-idf/tools/idf_tools.py install-python-env

RUN mkdir /home/esp/issue231
COPY --chown=esp:esp build.rs Cargo.toml Cargo.lock rustfmt.toml sdkconfig.defaults /home/esp/issue231/
RUN mkdir /home/esp/issue231/src
COPY --chown=esp:esp src/main.rs /home/esp/issue231/src/
RUN mkdir /home/esp/issue231/.cargo
COPY --chown=esp:esp .cargo/config.toml /home/esp/issue231/.cargo/

COPY --chown=esp:esp espressif_esp_tinyusb_1.3.1.zip espressif_tinyusb_0.15.0_2.zip /tmp/

RUN mkdir -p /home/esp/issue231/vendor/espressif_esp_tinyusb_1.3.1
WORKDIR /home/esp/issue231/vendor/espressif_esp_tinyusb_1.3.1
RUN unzip -q /tmp/espressif_esp_tinyusb_1.3.1.zip

RUN mkdir -p /home/esp/issue231/vendor/espressif_tinyusb_0.15.0_2
WORKDIR /home/esp/issue231/vendor/espressif_tinyusb_0.15.0_2
RUN unzip -q /tmp/espressif_tinyusb_0.15.0_2.zip

# Hack to work around tusb_config.h not found
RUN ln -s ../espressif_esp_tinyusb_1.3.1/include/tusb_config.h .

WORKDIR /home/esp/issue231

# From export-esp.sh
ENV LIBCLANG_PATH="/home/esp/.rustup/toolchains/esp/xtensa-esp32-elf-clang/esp-16.0.0-20230516/esp-clang/lib"
ENV PATH="/home/esp/.rustup/toolchains/esp/riscv32-esp-elf/esp-12.2.0_20230208/riscv32-esp-elf/bin:$PATH"
ENV IDF_PATH="/home/esp/esp-idf"

# RUN cargo build -j 32 --target xtensa-esp32s3-espidf
