######## Common ########

SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(SELF_DIR)/common.mk

######## Meta ########

STATIC_LIB ?= lib$(ENCLAVE_NAME).a
SHARED_LIB ?= lib$(ENCLAVE_NAME).so
SIGNED_SHARED_LIB ?= lib$(ENCLAVE_NAME).signed.so

######## SGX SDK Settings ########

ifeq ($(SGX_DEBUG), 1)
	TARGET_DIR = ./target/debug
else
	CARGO_ARGS += --release
	TARGET_DIR = ./target/release
endif

ifneq ($(SGX_MODE), HW)
	Trts_Library_Name := sgx_trts_sim
	Service_Library_Name := sgx_tservice_sim
else
	Trts_Library_Name := sgx_trts
	Service_Library_Name := sgx_tservice
endif

Crypto_Library_Name := sgx_tcrypto
COMPILER_RT_PATCH := $(SGX_RUST)/compiler-rt/libcompiler-rt-patch.a
RustEnclave_Link_Libs := $(COMPILER_RT_PATCH) $(TARGET_DIR)/$(STATIC_LIB)

RustEnclave_Link_Flags := $(SGX_COMMON_CFLAGS) -Wl,--no-undefined -nostdlib -nodefaultlibs -nostartfiles -L$(SGX_LIBRARY_PATH) \
	-Wl,--whole-archive -l$(Trts_Library_Name) -Wl,--no-whole-archive \
	-Wl,--start-group -lsgx_tstdc -l$(Service_Library_Name) -l$(Crypto_Library_Name) $(RustEnclave_Link_Libs) -Wl,--end-group \
	-Wl,-Bstatic -Wl,-Bsymbolic -Wl,--no-undefined \
	-Wl,-pie,-eenclave_entry -Wl,--export-dynamic  \
	-Wl,--defsym,__ImageBase=0 \
	-Wl,--gc-sections \
	-Wl,--version-script=Enclave.lds

######## Custom ########

$(COMPILER_RT_PATCH):
	$(MAKE) -C $(SGX_RUST)/compiler-rt

ENCLAVE_FILES := src/Enclave_t.c src/Enclave_t.h

$(ENCLAVE_FILES): $(SGX_EDGER8R) Enclave.edl Enclave.lds
	$(SGX_EDGER8R) --trusted Enclave.edl --search-path $(SGX_SDK)/include --search-path $(SGX_RUST)/edl --trusted-dir src

$(TARGET_DIR)/$(STATIC_LIB): $(ENCLAVE_FILES)
	cargo build $(CARGO_ARGS)

$(TARGET_DIR)/$(SHARED_LIB): $(TARGET_DIR)/$(STATIC_LIB) $(COMPILER_RT_PATCH)
	$(CXX) -o $@ $(RustEnclave_Link_Flags)

$(TARGET_DIR)/$(SIGNED_SHARED_LIB): $(TARGET_DIR)/$(SHARED_LIB) Enclave.config.xml Enclave_private.pem
	$(SGX_ENCLAVE_SIGNER) sign -key Enclave_private.pem -enclave $< -out $@ -config Enclave.config.xml

UNTRUSTED_DIR := ../../$(ENCLAVE_NAME)/src
UNTRUSTED_FILES := $(UNTRUSTED_DIR)/Enclave_u.c $(UNTRUSTED_DIR)/Enclave_u.h

$(UNTRUSTED_FILES): $(SGX_EDGER8R) Enclave.edl Enclave.lds
	$(SGX_EDGER8R) --untrusted Enclave.edl --search-path $(SGX_SDK)/include --search-path $(SGX_RUST)/edl --untrusted-dir $(UNTRUSTED_DIR)

.PHONY: all
all: $(TARGET_DIR)/$(SIGNED_SHARED_LIB) $(UNTRUSTED_FILES)
