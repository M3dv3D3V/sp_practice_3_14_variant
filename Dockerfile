FROM ubuntu
RUN apt update && apt upgrade && apt install -y build-essential nasm
COPY . .
