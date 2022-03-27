FROM ubuntu

RUN apt update && apt upgrade && apt install -y build-essential nasm
COPY . .

RUN chmod +x compile_asm.sh compile_module_asm.sh
