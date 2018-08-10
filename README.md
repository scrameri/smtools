# smtools

**smtools** is my repository for molecular **s**equence **m**anipulation **tools** and scripts related to genetic analysis. More tools will be added in the future.

## Contact
* Simon Crameri (simon.crameri@env.ethz.ch)


## cp_genome
The `bash` script `get.LSC.IR.SSC.from.chloroplast.genome.sh` allows for excision of the three parts of plant chloroplast genomes: the **large single-copy (LSC)**, **small single-copy (SSC)** and **inverted repeat (IR)** regions, respectively. The script takes advantage of the fact that most plant chloroplast genomes have two copies of the IR (leading to a quadripartite architecture, Jansen & Ruhlmann 2012), and that therefore, the boundaries between the LSC, IR and SSC can be easily determined using an alignment tool. 

### References
* Aho AV, Kernighan BW, Weinberger PJ (1987) The AWK programming language. Addison-Wesley Longman Publishing Co., Inc., Boston, MA, USA.
* Camacho C, Coulouris G, Avagyan V et al. (2009) BLAST+: architecture and applications. BMC Bioinformatics, 10, doi:10.1186–1471–2105–10–421.
* Jansen RK, Ruhlman TA (2012) Plastid Genomes of Seed Plants. In: Genomics of Chloroplasts and Mitochondria: Advances in Photosynthesis and Respiration. Edited by Bock R, Knoop V, vol. 35: Springer Science and Business Media: 103–126.
* Lavin M, Doyle JJ, Palmer JD (1990) Evolutionary significance of the loss of the chloroplast-DNA inverted repeat in the Leguminosae subfamily Papilionoideae. Evolution, 44, 390–402.
* Li H, Handsaker B, Wysoker A *et al.* (2009) The Sequence Alignment/Map format and SAMtools. Bioinformatics, 25, 2078–2079.

## pp_speciesDA
The `R` script `plot.simmatrix.R` may be used within the DISSECT workflow (Jones et al 2015) for species delimitation. After running BEAST (Drummond et al 2012) or STACEY (Jones 2017) for BEAST2 (Bouckaert et al 2014) to obtain a set of species tree topologies, one can "summarize the posterior frequencies of clusterings" using SpeciesDelimitationAnalyzer (speciesDA.jar, http://www.indriid.com/software.html). The similarity matrix can then be visualized using the R program plot.simmatrix.R, which is an improvement on Graham Jones' version of the code, and allows for automatized pairwise distance matrix sorting (using a summary tree topology in NEXUS format), labelling, and line drawing.

### References
* Bouckaert R, Heled J, Kühnert D, Vaughan T, Wu C-H, Xie D, Suchard, M.A., Rambaut A, Drummond A.J. (2014) BEAST 2: a software platform for Bayesian evolutionary analysis. PLoS Computational Biology, 10 (4), e1003537.
* Drummond, A.J. Marc A. Suchard, M.A., Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and the BEAST 1.7. Molecular Biology and Evolution, 29, 1969–1973.
* Jones G, Zeynep A, Oxelman B (2015) DISSECT: an assignment-free Bayesian discovery method for species delimitation under the multispecies coalescent. Bioinformatics, 31(7), 991-998.
* Jones G (2017) Algorithmic improvements to species delimitation and phylogeny estimation under the multispecies coalescent. Journal of Mathematical Biology, 74(1), 447-467.
