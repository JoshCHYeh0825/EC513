#!/bin/bash -l

#$ -l h_rt=72:00:00      
#$ -N EC513_benchmarks   
#$ -pe omp 10
#$ -o /projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/output.log
#$ -e /projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/output.log                  
#$ -m ea                 


# === Set Benchmark Names ===
BENCHMARKS=("500.perlbench_r" "502.gcc_r" "503.bwaves_r" "527.cam4_r" "505.mcf_r")

# Loop over benchmarks and run them simultaneously
for BENCHMARK in "${BENCHMARKS[@]}"; do
    OUTPUT_DIR="/projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/output_${BENCHMARK}"
    mkdir -p "$OUTPUT_DIR"

    # Running gem5
    /projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/build/X86/gem5.opt \
    --outdir="$OUTPUT_DIR" \
    /projectnb/ec513/students/jy0825/HW2/spec-2017/gem5/configs/example/gem5_library/x86-spec-cpu2017-benchmarks.py \
    --image /projectnb/ec513/students/jy0825/HW2/spec-2017/disk-image/spec-2017/spec-2017-image/spec-2017 \
    --partition 1 \
    --benchmark "$BENCHMARK" \
    --size test \
    > "$OUTPUT_DIR/gem5_output.log" 2> "$OUTPUT_DIR/gem5_error.log" &

done
