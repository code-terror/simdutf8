# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl git-all build-essential binutils-dev libunwind-dev libblocksruntime-dev liblzma-dev
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install afl
RUN ${HOME}/.cargo/bin/cargo install honggfuzz
RUN ${HOME}/.cargo/bin/cargo install cargo-fuzz
RUN git clone https://github.com/rusticstuff/simdutf8.git
WORKDIR /simdutf8/fuzzing/afl/
RUN ${HOME}/.cargo/bin/cargo afl build
WORKDIR /simdutf8/fuzzing/honggfuzz/
RUN RUSTFLAGS="-Znew-llvm-pass-manager=no" HFUZZ_RUN_ARGS="--run_time $run_time --exit_upon_crash" ${HOME}/.cargo/bin/cargo hfuzz build
WORKDIR /simdutf8/fuzzing/fuzz/
RUN ${HOME}/.cargo/bin/cargo fuzz build
WORKDIR /Mayhem
COPY /Mayhem/ /Mayhem/

#FROM ubuntu:20.04

#COPY --from=builder /evm/fuzzer/hfuzz_target/x86_64-unknown-linux-gnu/release/* /
#COPY --from=builder /Mayhemfile /