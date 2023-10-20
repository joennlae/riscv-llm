
TEST_DIR = $(HOME)/test/src/intrinsics

test-intrinsic-matmul:
	$(COPY) $(TEST_DIR)/common.h
	$(COPY) $(TEST_DIR)/rvv_matmul.c
	$(RUN) "gcc-13 -O3 -march=rv64gcv_zba -o rvv_matmul rvv_matmul.c -lm && ./rvv_matmul" | grep "pass" && echo "✅ TEST PASSED" || echo "❌ TEST FAILED"

test-intrinsic-sgemm:
	$(COPY) $(TEST_DIR)/common.h
	$(COPY) $(TEST_DIR)/rvv_sgemm.c
	$(RUN) "gcc-13 -O3 -march=rv64gcv_zba -o rvv_sgemm rvv_sgemm.c -lm && ./rvv_sgemm" | grep "pass" && echo "✅ TEST PASSED" || echo "❌ TEST FAILED"

test-intrinsics: test-intrinsic-matmul test-intrinsic-sgemm
	echo "✅ ALL TESTS PASSED"