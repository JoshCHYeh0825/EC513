#!/bin/bash -l

#$ -l h_rt=72:00:00      
#$ -N gcc_r    
#$ -pe omp 10             
#$ -m ea                 

# Enable debugging
set -x

# Load SCC environment
source /projectnb/ec513/materials/HW2/spec-2017/sourceme

# Build gem5 only once per node
LOCKFILE="/tmp/gem5_build.lock"

if [ ! -f "$LOCKFILE" ]; then
    touch "$LOCKFILE"

    # Build m5
    cd "/projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/util/m5/"
    scons build/x86/out/m5 || { echo "m5 build failed"; exit 1; }

    # Build gem5
    cd "/projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/"
    scons build/X86/gem5.opt -j8 || echo "Warning: gem5 build may have issues, but continuing..."

    # Ensure gem5.opt was actually created
    if [ ! -f "/projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/build/X86/gem5.opt" ]; then
        echo "ERROR: gem5.opt not found after build! Exiting..." 
        exit 1
    fi

    echo "Build complete"
fi

# === Set Benchmark Name ===
BENCHMARK="502.gcc_r"
OUTPUT_DIR="/projectnb/ec513/students/jy0825/HW2/Tests/$BENCHMARK/"

# Create output directory if missing
mkdir -p "$OUTPUT_DIR"

# Verify gem5 is built before running simulation
if [ ! -f "/projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/build/X86/gem5.opt" ]; then
    echo "ERROR: gem5.opt not found! Check build logs." > "$OUTPUT_DIR/error_summary.txt"
    exit 1
fi

# Run gem5 simulation
/projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/build/X86/gem5.opt \
    /projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/configs/example/gem5_library/x86-spec-cpu2017-benchmarks.py \
    --image /projectnb/ec513/students/jy0825/HW2/spec-2017/disk-image/spec-2017/spec-2017-image/spec-2017 \
    --partition 1 \
    --benchmark "$BENCHMARK" \
    --size test \
    > "$OUTPUT_DIR/gem5_output.log" 2> "$OUTPUT_DIR/gem5_error.log"

# Extract stats after simulation
STATS_FILE="$OUTPUT_DIR/m5out/stats.txt"

if [ -f "$STATS_FILE" ]; then
    echo "===== Simulation Stats for $BENCHMARK =====" > "$OUTPUT_DIR/summary.txt"
    grep "sim_insts" "$STATS_FILE" >> "$OUTPUT_DIR/summary.txt"
    grep "sim_cycles" "$STATS_FILE" >> "$OUTPUT_DIR/summary.txt"
    grep "CPI" "$STATS_FILE" >> "$OUTPUT_DIR/summary.txt"
    grep -E "num_int_|num_fp_|num_load_|num_store_|num_control_|num_mem_|num_other_" "$STATS_FILE" >> "$OUTPUT_DIR/summary.txt"
else
    echo "ERROR: stats.txt missing for $BENCHMARK!" > "$OUTPUT_DIR/error_summary.txt"
    echo "Check gem5_error.log for possible issues." >> "$OUTPUT_DIR/error_summary.txt"
fi

