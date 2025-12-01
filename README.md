# ReSkmer Data
Scripts for ReSkmer paper.
Data for ReSkmer is described here, but is found in this [Google Drive](https://drive.google.com/drive/folders/1ZEV9GtrLZyszui1nTkQKkjJYdT3dSju_?usp=drive_link)
## Simulations:
### Scripts:
| Script Title | Use |
|----|----|
| submit_skmer_simulations.slurm | runs main simulation pipeline: _make child genomes with many distances, generate Illumina skims with ART at target coverages, run Skmer on data_ |
| make_genomes.py | Helper script for _submit_skmer_simulations.slurm_ adding mutations to genome. |
| submit_simulate_and_assemble.slurm | Generates high coverage, pair-end ART simulations and runs megahit assembly. |

### Genomes Used in Simulations:
| **Species**                  | **Assembly**           | **Genome Size (bp)** | **UR** |
|-----------------------------|------------------------|------------------|--------|
| *Selaginella moellendorffii* | GCF_000143415.4        | 208,216,466      | 0.42   |
| *Chondrus crispus*          | GCF_000350225.1        | 103,988,016      | 0.51   |
| *Ostrea edulis*             | [GCF_947568905.1*](https://api.ncbi.nlm.nih.gov/datasets/v2/genome/accession/GCF_947568905.1/download?include_annotation_type=GENOME_FASTA&include_annotation_type=GENOME_GFF&include_annotation_type=RNA_FASTA&include_annotation_type=CDS_FASTA&include_annotation_type=PROT_FASTA&include_annotation_type=SEQUENCE_REPORT&hydrated=FULLY_HYDRATED)       | 98,251,904       | 0.64   |
| *Nemopilema nomurai*        | GCA_003864495.1        | 210,407,387      | 0.71   |
| *Brachionus plicatilis*     | GCA_010279815.1        | 101,125,688      | 0.85   |
| *Hirudo medicinalis*        | GCA_011800805.1        | 155,214,494      | 0.90   |

**Table**: **Assemblies used in simulations.** Only a single scaffold (NC_079166.1) of the *O. edulis* assembly is represented in our simulations to provide a uniqueness ratio in between other genomes.

### Population Distances Simulations:
Includes _genome skims_ , _distance matrices_ , and _parameter estimates_ generated for _one_ of the replicates used in the ReSkmer paper for all genomes (club moss, moss, oyster chromosome, nematode, rotifer, leech). (Distances from 0.1% to 2%)

### Phylogenetic-Level Distances:
Includes _genome skims_ , _distance matrices_ , and _parameter estimates_ generated for _one_ of the replicates used in the ReSkmer paper for two genomes (moss and rotifer). (Distances from 5% to 20%)

### Low-Quality Assembly Experiments:
Includes _re-assembled_ genomes (at 10X and 50X),  _distance matrices_ , and _parameter estimates_ used in the ReSkmer paper for all genomes. Skims used ReSkmer are the same ones used for the _Population Distance Simulations_.

### High-Error Experiments:
Includes _genome skims_ , _distance matrices_ , and _parameter estimates_ generated for _one_ of the replicates used in the ReSkmer paper for two genomes (moss and rotifer). (Distances from 0% and 1%, phred scores _25, 23, 20_).

---
## Biological Data:
The SLURM pipeline used to paralellize Skmer across nodes can be found here:
### Scripts:
| Script Title | Use |
|----|----|
| 1_run-bbmap.slurm | runs bbmap_pipeline.sh in ./other_scripts/ (_bbduk.sh_ and _dedupe.sh_ from the BBtools suite).|
| 2_run-consult.slurm | Archaea and Bactrial decontamination using Consult-II. **WoL: Reference Phylogeny for Microbes (bacteria and archaea) (18 Gb - lightweight and robust)** library recommended.|
| 3_run-kraken2.slurm| Human read removal using standard human library as described in Kraken2 manual. |
| 4_downsample-reads.slurm | Uses "reformat.sh" from BBtools to downsample reads given an estimated genome size and average read length. | 
| 5_run-skmer-query.slurm | Runs *skmer query* command to generate histograms, stats, and mash files for each sample|
| 6_skmer-distance.slurm  | Runs _skmer distance_ to generate distance matrix|

_Notes_
- You may have to change the paths where the scripts or libraries have been placed.
- Install kraken2 via anaconda (or export to PATH if installed via github).

### _Apis mellifera_:
[RefSeq Assembly](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_003254395.2/)

**Dataset Analyzed:** [Harpur et al., 2019](https://doi.org/10.1093/gbe/evz018)

ANGSD analysis script is found in **biological_data_analysis/ANGSD_script/**

Libraries, distance matrices, and Respect-estimated spectra for _Apis mellifera_ populations.

### _Drosophila melanogaster_:
[RefSeq Assembly](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001215.4/) *_Y chromosome and other non-chromosomal (except mitohondria) contigs were removed_

**Dataset Analyzed:** [Drosophila Genome Nexus](https://doi.org/10.1534/genetics.115.174664) *_a subset of samples were used in this analysis (only belonging to Langley and Pool labs)_

Libraries, distance matrices, and Respect-estimated spectra for _Drosophila melanogaster_ populations.
