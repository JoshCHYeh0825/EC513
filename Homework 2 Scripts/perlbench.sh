#!/bin/bash -l

#$ -l h_rt=72:00:00      # Run for up to 72 hours
#$ -N perlbench  # Change this for each benchmark
#$ -pe omp 1
#$ -o /projectnb/ec513/students/jy0825/HW2/Tests/output_perlbench.log
#$ -e /projectnb/ec513/students/jy0825/HW2/Tests/error_perlbench.log                  
#$ -m ea                 

# Load SCC environment
source /projectnb/ec513/materials/HW2/spec-2017/sourceme

# === Set Benchmark Name ===
BENCHMARK="500.perlbench_r"
OUTPUT_DIR="/projectnb/ec513/students/jy0825/HW2/Tests/output_${BENCHMARK}"

# Create output directory if missing
mkdir -p "$OUTPUT_DIR"

echo "Starting gem5 for benchmark: $BENCHMARK"

# Run gem5
/projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/build/X86/gem5.opt \
    --outdir="$OUTPUT_DIR" \
    /projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/configs/example/gem5_library/x86-spec-cpu2017-benchmarks.py \
    --image /projectnb/ec513/students/jy0825/HW2/spec-2017/disk-image/spec-2017/spec-2017-image/spec-2017 \
    --partition 1 \
    --benchmark "$BENCHMARK" \
    --size test \
    > "$OUTPUT_DIR/gem5_output.log" 2> "$OUTPUT_DIR/gem5_error.log"

echo "Benchmark $BENCHMARK completed."


