#!/usr/bin/env bash

#set -x
set -e -o pipefail


SCRIPT_DIR="$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]:-$0}")"; )" &> /dev/null && pwd 2> /dev/null; )";
source "$SCRIPT_DIR/paths.sh"


mainImpl() {
    echo "run"

    # BEGIN CONFIG
    local toolsDir="$WC_ROOT/tools"
    local cmakeBin="$toolsDir/cmake/bin/cmake" # 4.5 RC
    local ninjaBin="$toolsDir/ninja/ninja"
    local llvmRoot="$toolsDir/llvm"
    
    #############
    # libcxx,compilerRt are built as standalone
    # sysroot specific location
    #local sysroot="/home/user2/src/compilerLib/sysroot"
    #local gccInstallDir="$sysroot/usr/lib/gcc/x86_64-linux-gnu/12"
    #local resourceDir="/home/user2/src/compilerLib/compilerRt"
    #local llvmLibCxxRoot="/home/user2/src/compilerLib/libcxx"
    #local llvmLibCxxLib="$llvmLibCxxRoot/lib"
    #local llvmLibCxxIncludeCppV1="$llvmLibCxxRoot/include/c++/v1"
    #local llvmLibCxxIncludeConfigSite="$llvmLibCxxIncludeCppV1"

    #############
    # libcxx,compilerRt are from downloaded llvm
    # sysroot from host system
    local sysroot="/"
    local gccInstallDir="$sysroot/usr/lib/gcc/x86_64-linux-gnu/14"
    local resourceDir="$llvmRoot/lib/clang/23"
    local llvmLibCxxLib="$llvmRoot/lib/x86_64-unknown-linux-gnu"
    local llvmLibCxxIncludeConfigSite="$llvmRoot/include/x86_64-unknown-linux-gnu/c++/v1"
    local llvmLibCxxIncludeCppV1="$llvmRoot/include/c++/v1"
    #############
    
    # END CONFIG

    if [[ ! -d "$resourceDir" ]];then
        echo "Not a directory: $resourceDir"
        exit 1
    fi
    if [[ ! -d "$llvmLibCxxLib" ]];then
        echo "Not a directory: $llvmLibCxxLib"
        exit 1
    fi
    if [[ ! -d "$llvmLibCxxIncludeCppV1" ]];then
        echo "Not a directory: $llvmLibCxxLib"
        exit 1
    fi

    local target="x86_64-unknown-linux-gnu"

    local llvmBin="$llvmRoot/bin"
    local sourceRoot="$WC_ROOT/src"
    local cmakeBuildOut="$OUT_DIR/build"
    rm -rf "$cmakeBuildOut"
    
    local commonFlags=()

    commonFlags+=(--target="$target")
    commonFlags+=(--sysroot="$sysroot")
    commonFlags+=(-march=x86-64-v2)
    commonFlags+=(-fpic)
    commonFlags+=(--gcc-install-dir="$gccInstallDir")
    commonFlags+=(-g)
    commonFlags+=(-gdwarf-5)
    commonFlags+=(-resource-dir="$resourceDir")
    commonFlags+=(-nostdinc++)
    commonFlags+=(-nostdlib++)
    commonFlags+=(-funwind-tables)
    commonFlags+=(-fvisibility=hidden)
    commonFlags+=(-fvisibility-inlines-hidden)
    commonFlags+=(-ffunction-sections)
    commonFlags+=(-fstack-protector-strong)
    commonFlags+=(-fstack-clash-protection)

    local compileFlags=()
    compileFlags+=(-std=gnu2y)
    compileFlags+=(-Werror=division-by-zero)
    compileFlags+=(-Wundef)
    compileFlags+=(-Werror=undef)
    compileFlags+=(-O0)
    compileFlags+=(-fno-omit-frame-pointer)
    compileFlags+=(-fstrict-flex-arrays=3)
    #compileFlags+=(--start-no-unused-arguments)
    compileFlags+=("-isystem$llvmLibCxxIncludeConfigSite")
    compileFlags+=("-isystem$llvmLibCxxIncludeCppV1")
    compileFlags+=("-isystem$llvmRoot/lib/clang/23/include")
    #compileFlags+=(--end-no-unused-arguments)

    local cxxFlags=("${commonFlags[@]}" "${compileFlags[@]}")
    cxxFlags+=(-std=gnu++2c)

    local cFlags=("${commonFlags[@]}" "${compileFlags[@]}")

    
    local exeLinkerFlags=("${commonFlags[@]}")
    exeLinkerFlags+=(-fuse-ld=lld)
    exeLinkerFlags+=(-rtlib=compiler-rt)
    exeLinkerFlags+=(-Wl,-rpath=\$ORIGIN/stdlib)
    exeLinkerFlags+=(-Wl,--push-state)
    exeLinkerFlags+=(-Wl,-lc++)
    exeLinkerFlags+=(-Wl,-lc++abi)
    exeLinkerFlags+=(-Wl,-lunwind)
    exeLinkerFlags+=(-Wl,--pop-state)
    exeLinkerFlags+=(-Wl,--fatal-warnings)
    exeLinkerFlags+=(-Wl,--build-id=uuid)
    exeLinkerFlags+=(-Wl,--hash-style=gnu)
    exeLinkerFlags+=(-Wl,--gc-sections)
    exeLinkerFlags+=(-Wl,-z,noexecstack)
    exeLinkerFlags+=(-Wl,-z,relro)
    exeLinkerFlags+=(-Wl,-z,now)
    exeLinkerFlags+=(-Wl,--as-needed)
    exeLinkerFlags+=(-Wl,--no-copy-dt-needed-entries)
    exeLinkerFlags+=(-Wl,-L$llvmLibCxxLib)

    local exeLinkerFlags_str="${exeLinkerFlags[@]}"
    local cxxFlags_str="${cxxFlags[@]}"
    local cFlags_str="${cFlags[@]}"


    local params=()
    params+=("$cmakeBin")
    params+=(-S "$sourceRoot")
    params+=(-B "$cmakeBuildOut")
    params+=(-G Ninja)
    params+=(-DCMAKE_MAKE_PROGRAM="$ninjaBin")
    params+=(-DCMAKE_SYSTEM_NAME=Linux)
    params+=(-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER)
    params+=(-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY)
    params+=(-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY)
    params+=(-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY)
    params+=(-DCMAKE_EXPORT_COMPILE_COMMANDS=1)
    params+=(-DCMAKE_SYSROOT="$sysroot")
    params+=(-DCMAKE_AR="$llvmBin/llvm-ar")
    params+=(-DCMAKE_NM="$llvmBin/llvm-nm")
    params+=(-DCMAKE_RANLIB="$llvmBin/llvm-ranlib")
    params+=(-DCMAKE_C_COMPILER="$llvmBin/clang")
    params+=(-DCMAKE_C_COMPILER_TARGET="$target")
    params+=(-DCMAKE_C_FLAGS="$cFlags_str")
    params+=(-DCMAKE_C_FLAGS_RELWITHDEBINFO=)
    params+=(-DCMAKE_C_FLAGS_RELEASE=)
    params+=(-DCMAKE_C_FLAGS_DEBUG=)
    params+=(-DCMAKE_CXX_COMPILER="$llvmBin/clang++")
    params+=(-DCMAKE_CXX_COMPILER_TARGET="$target")
    params+=(-DCMAKE_CXX_FLAGS="$cxxFlags_str")
    params+=(-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=)
    params+=(-DCMAKE_CXX_FLAGS_RELEASE=)
    params+=(-DCMAKE_CXX_FLAGS_DEBUG=)
    params+=(-DCMAKE_ASM_COMPILER="$llvmBin/clang")
    params+=(-DCMAKE_ASM_COMPILER_TARGET="$target")
    params+=(-DCMAKE_ASM_FLAGS="$cFlags_str")
    params+=(-DCMAKE_EXE_LINKER_FLAGS="$exeLinkerFlags_str")
    params+=(-DCMAKE_SHARED_LINKER_FLAGS="$exeLinkerFlags_str")
    params+=(-DCMAKE_MODULE_LINKER_FLAGS="$exeLinkerFlags_str")
    params+=(-DCMAKE_CXX_STDLIB_MODULES_JSON="$llvmLibCxxLib/libc++.modules.json")

    params+=(-DWC_ROOT="$WC_ROOT")

    "${params[@]}"

    local params=()
    params+=(nice)
    params+=("$cmakeBin")
    params+=(--build "$cmakeBuildOut")
    params+=(--target mexample)
    "${params[@]}"
    
    echo "run SUCCESS"
}

main() {
    if [[ "$1" == "insideSystemd" ]];then
        shift;
        mainImpl "$@"
        return
    fi
    local runBuildTaskUnit="runBuildTaskUnit_b77d25e2-7ccb-4345-8804-635096387d86"
    "$SCRIPT_DIR/systemdKill.sh" "$runBuildTaskUnit"
    local params=()
    source "$SCRIPT_DIR/systemdRun.sh"
    params+=(--property MemoryAccounting=true)
    params+=(--property MemorySwapMax=0)
    params+=(--property MemoryZSwapMax=0)
    local memAvailMB=$(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024)))
    memAvailMB=$((memAvailMB-4000))
    params+=(--property MemoryMax=${memAvailMB}M)
    params+=(--quiet)
    params+=(--unit "$runBuildTaskUnit")
    if [[ -e "$OUT_DIR/out.log" ]];then
        mv -f "$OUT_DIR/out.log" "$OUT_DIR/outPrev.log"
    fi

    local exitCode=0
    local startTime=$(date +%s.%N)
    "${params[@]}" "$0" insideSystemd "$@" |& tee -i "$OUT_DIR/out.log" || exitCode=$?
    if [[ "$exitCode" != "0" ]];then
        exit 1
    fi
}

main "$@"
