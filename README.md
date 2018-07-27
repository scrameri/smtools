**smtools** is my repository for molecular sequence manipulation tools (more tools will be added in the future)

## Author
* Simon Crameri (simon.crameri@env.ethz.ch)



# get.LSC.IR.SSC.from.chloroplast.genome.sh

## Overview
This .bash script allows for excision of the three parts of plant chloroplast genomes: the **large single-copy (LSC)**, **small single-copy (SSC)** and **inverted repeat (IR)** regions, respectively. The script takes advantage of the fact that most plant chloroplast genomes have two copies of the IR (leading to a quadripartite architechture, Jansen & Ruhlmann 2012), and that therefore, the boundaries between the LSC, IR and SSC can be easily determined using an alignment tool. 

## How it works
The script uses *BLAST+* (Camacho *et al.* 2009) to align the complete chloroplast sequence against itself. *BLAST+* returns the alignment coordinates for the two IR regions and thereby determines the IR boundaires. Subsequently, the script uses the IR boundaries to individually excise the LSC, IR (just the first copy) and SSC regions, using *samtools* (Li *et al.* 2009). The LSC, IR and SSC regions are then saved as separate regions in the output .LSC.IR.SSC.fasta file. A .blast output is also produced and may be used to inspect the *BLAST+* hits. The script also checks the .fasta input (needs to be a single-region .fasta file) and output (combined lengths of LSC, 2xIR and SSC must match the total chloroplast genome length).

## Input Sequence Requirements
There are three conditions that must be met in order for the process to work:

* the chloroplast genome must be complete/circular
* the chloroplast genome sequence must start with the first base of the LSC region and end with the last base of the second IR (this follows the standard representation of chloroplast genomes). The program will run but issue a warning message if the combined lengths of LSC, 2xIR and SSC do not match the total chloroplast genome length.
* the chloroplast genome sequence must contain two copies of the IR region. For instance, legume plants of the inverted-repeat-lacking-clade (IRLC) have just one copy (Lavin *et al.* 1990). The program will exit with a warning message if it could not identify two copies of the IR.

## Software Requirements
Besides basic unix/bash functions, the script uses the following software tools internally:

* awk (Aho *et al.* 1987)
* BLAST+ (Camacho *et al.* 2009)
* samtools (Li *et al.* 2009)
* sed (used for in-place replacement of ':', ',' or ' ' characters in .fasta headers)

## Usage Example
The script takes just one (unnamed) argument, namely the input .fasta file.

`get.LSC.IR.SSC.from.chloroplast.genome.sh chloroplast.genome.fasta`

## References
* Aho AV, Kernighan BW, Weinberger PJ (1987) The AWK programming language. Addison-Wesley Longman Publishing Co., Inc., Boston, MA, USA
* Camacho C, Coulouris G, Avagyan V et al. (2009) BLAST+: architecture and applications. BMC Bioinformatics, 10, doi:10.1186–1471–2105–10–421.
* Jansen RK, Ruhlman TA (2012) Plastid Genomes of Seed Plants. In: Genomics of Chloroplasts and Mitochondria: Advances in Photosynthesis and Respiration. Edited by Bock R, Knoop V, vol. 35: Springer Science and Business Media: 103–126.
* Lavin M, Doyle JJ, Palmer JD (1990) Evolutionary significance of the loss of the chloroplast-DNA inverted repeat in the Leguminosae subfamily Papilionoideae. Evolution, 44, 390–402.
* Li H, Handsaker B, Wysoker A *et al.* (2009) The Sequence Alignment/Map format and SAMtools. Bioinformatics, 25, 2078–2079.
