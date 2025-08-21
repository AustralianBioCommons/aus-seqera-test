# Testing Workflow

A simple worksflow to test Seqera platform integrations with several backends. 
The  workflow indexes alignment files (`.bam` or `.cram`), generates statistics with **samtools stats**, and produces a combined **MultiQC report**.

---

## Input

The workflow uses a **CSV samplesheet** with at least one column named `bam`, containing paths or URLs to BAM/CRAM files.  
Default input (already provided in `nextflow.config`):

```
https://github.com/AustralianBioCommons/aus-seqera-test/raw/refs/heads/main/data/samplesheet.csv
```

---

## Output

- Per-file index (`.bai`, `.csi`, or `.crai`)
- Per-file statistics (`.stats`)
- Combined `multiqc_report.html` summary

All outputs are organised under the directory specified with `--outdir`.

---

## Running the Workflow

### 1. AWS

Make sure you have Docker available. Then run:

```bash
nextflow run AustralianBioCommons/aus-seqera-test -profile aws   --outdir results_aws
```

---

### 2. Gadi (NCI)

Load Nextflow and Singularity on Gadi, then run:

```bash
module load nextflow
module load singularity

nextflow run AustralianBioCommons/aus-seqera-test   -profile gadi   --outdir results_gadi
```

This uses PBS Pro as the scheduler and submits jobs to the `normal` queue.

---

### 3. Pawsey (Setonix)

On Setonix, load Nextflow and run with the `setonix` profile:

```bash
module load nextflow
module load singularity

nextflow run AustralianBioCommons/aus-seqera-test   -profile setonix   --outdir results_setonix
```

This uses Slurm as the executor and sources the required environment script automatically.

---

## Notes

- Change `--outdir` to point to your preferred results directory.  
- Use `-resume` to continue a previous run without recomputing completed steps.  
- Software dependencies are managed automatically through Conda or containers, depending on the profile.  