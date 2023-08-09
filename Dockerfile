FROM espressif/idf-rust:esp32c3_latest
USER root:root
RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python3
RUN ln -s python3 /usr/bin/python
USER esp:esp
WORKDIR /home/esp
RUN git clone -b release/v5.1 https://github.com/espressif/esp-idf.git /home/esp/esp-idf
COPY tools.json /home/esp/esp-idf/tools/
RUN /home/esp/esp-idf/tools/idf_tools.py install all

RUN mkdir /home/esp/issue231
COPY build.rs Cargo.toml Cargo.lock rustfmt.toml sdkconfig.defaults /home/esp/issue231/
RUN mkdir /home/esp/issue231/src
COPY src/main.rs /home/esp/issue231/src/
RUN mkdir /home/esp/issue231/.cargo
COPY .cargo/config.toml /home/esp/issue231/.cargo/

WORKDIR /home/esp/issue231
# RUN idf.py add-dependency "esp_tinyusb^1.0.0"
# RUN idf.py add-dependency "tinyusb~0.15.1"

# From export-esp.sh
ENV LIBCLANG_PATH="/home/esp/.rustup/toolchains/esp/xtensa-esp32-elf-clang/esp-16.0.0-20230516/esp-clang/lib"
ENV PATH="/home/esp/.rustup/toolchains/esp/riscv32-esp-elf/esp-12.2.0_20230208/riscv32-esp-elf/bin:$PATH"
ENV IDF_PATH="/home/esp/esp-idf"

RUN cargo build --target riscv32imc-esp-espidf
