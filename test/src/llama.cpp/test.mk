
TEST_DIR = $(HOME)/test/src/llama

test-llama:
# download llama.cpp
	$(RUN) "git clone https://github.com/ggerganov/llama.cpp.git"
# building llama.cpp
	$(RUN) "cd llama.cpp && CC=gcc-13 CXX=g++-13 make -j 2"
# download Llama 7B chat model Q4_K_M https://huggingface.co/TheBloke/Llama-2-7b-Chat-GGUF
	$(RUN) "cd llama.cpp/models/ && wget https://huggingface.co/TheBloke/Llama-2-7b-Chat-GGUF/resolve/main/llama-2-7b-chat.Q4_K_M.gguf"
# run an inference on RISC-V
	$(RUN) "cd llama.cpp && ./main -m models/llama-2-7b-chat.Q4_K_M.gguf -p \"What do you think about RISC-V?\" -n 100 -e"

test-llama-clean:
	$(RUN) "rm -rf llama.cpp"