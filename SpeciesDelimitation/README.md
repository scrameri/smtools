# Display the DISSECT/speciesDA.jar similarity matrix

## Authors
Core code, see http://www.indriid.com/2014/species-delim-paper-SuppIinfo-v8.pdf
* Graham Jones, art@gjones.name, Feb 2014

Modification for automatized pairwise distance matrix sorting, labelling, and line drawing 
* Simon Crameri, simon.crameri@env.ethz.ch, Aug 2018

## Usage
This script may be used within the DISSECT workflow (Jones *et al* 2015) for **species delimitation**. After running *BEAST* (Drummond *et al* 2012) or *STACEY* (Jones 2017) for *BEAST2* (Bouckaert *et al* 2014) to obtain a set of species tree topologies, one can "summarize the posterior frequencies of clusterings" using *SpeciesDelimitationAnalyzer* (speciesDA.jar, http://www.indriid.com/software.html). The **similarity matrix** can then be visualized using the `R` program `plot.simmatrix.R`, which is an improvement on Graham Jones' version of the code, and allows for automatized pairwise distance matrix sorting (using a summary tree topology in NEXUS format), labelling, and line drawing.

```
## Load R function
source("plot.simmatrix.R")

## Inspect R funciton
args(plot.simmatrix) # arguments
plot.simmatrix # usage
```

### Arguments
```
  speciesDAoutput  character     speciesDA.jar output file (.txt format). See http://www.indriid.com/software.html, Species Delimitation Analyzer. This program takes species trees as input, and outputs clustering solutions.
  summarized.tree  character     SEMI-OPTIONAL nexus-formatted tree file from with the topology is read, which is used to order the similarity matrix accordingly. File is read using the ape::read.nexus() function. This argument MUST be specified if <ownorder> is NULL.
  labelfile        character     OPTIONAL file where the labels used in <summarized.tree> [FIRST column in <labelfile>] are referenced to labels used for the similarity matrix plot [SECOND column in <labelfile>]. All tips need to be included in this table. Their order is not important (will be ordered according to <summarized.tree>). If <labelfile> is specified, uses the labels specified in the SECOND column of the <labelfile> for plotting.
  
  ownorder         numeric       If NULL, ordering will be performed automatically based on the topoplogy of <summarized.tree>. If a numeric vector of length equalling the number of tips, ordering will be performed using the manual ordering specification: the first index comes in the top left corner of the plot, etc.
  ownlines         numeric       If NULL, line drawing will be performed automatically based on the <PP.thresh> criterion. If a numeric vector of length equalling the number of lines, line drawing will be performed using the manual line specification: the first line is drawn below the the first index, etc.
  PP.thresh        numeric       Posterior probability threshold to draw a line between clades if <ownlines> = NULL. For each grid point along the diagonal in the pairwise distance matrix, it is assessed whether the posterior probability in the grid square below/to the right of that grid point is equal to or lower than PP.thresh. If yes, a line will be drawn to delineate species clades.
  
  mar              numeric       numeric vector of lenght 4 specifying the plot margins below (1), to the left (2), to the top (3) and to the right (4) of the plot.
  label.size       numeric       numeric giving the size of labels on x and y axes
  legendlabel.size numeric       numeric giving the size of labels next to the color legend
  
  cols             color vector  color vector of length >=2 containing valid R colors to which low and high similarity indices are mapped to.
  border.col       color vector  color vector of length 1 containing a valid R color specifying the border color of all plotted rectangles. If NULL, the borders will have the same color as the rectangles.
  legend           logical       If TRUE, the color legend will be plotted.
  
  plot.phylo       logical       If TRUE and <summarized.tree> is specified, a phylogram of <summarized.tree> will be plotted before the similarity matrix.
  save.pdf         logical       If TRUE, a .pdf file with the similarity matrix plot named <pdf.name> will be saved.
  pdf.name         character     File name for output file (should have extension ".pdf")
```

### Usage examples (example data in STACEY folder)
```
# automatic ordering [according to species.sumtree topology, which will be plotted] and line drawing [according to PP.thresh = 0.0]
# with labels as in <speciesDAoutput.txt> [no labelfile needed here] and black-and-white plotting
plot.simmatrix("STACEY/speciesDAoutput.txt", "STACEY/species.sumtree", labelfile = NULL,
               ownorder = NULL, ownlines = NULL, PP.thresh = 0.0, 
               mar = c(0,4,4,0), 
               cols = c("black", "white"), border.col = "white", legend = FALSE, 
               plot.phylo = TRUE, save.pdf = FALSE, pdf.name = "SimMatrix.pdf")

# automatic ordering [according to species.sumtree topology, which will not be plotted] and line drawing [according to PP.thresh = 0.05] 
# with labels as in <labels.txt> and with colourful plotting with legend
plot.simmatrix("STACEY/speciesDAoutput.txt", "STACEY/species.sumtree", labelfile = "labels.txt",
               ownorder = NULL, ownlines = NULL, PP.thresh = 0.05, 
               mar = c(0,11,11,2.5), label.size = 1, legendlabel.size = 0.5,
               cols = c("blue", "orange", "white"), border.col = NULL, legend = TRUE, 
               plot.phylo = FALSE, save.pdf = FALSE, pdf.name = "SimMatrix.pdf")

# own specification for order and lines [no species.sumtree needed. Output can be redirected to an R object and printed
ownorder = c(28, 10, 5, 21, 16, 19, 3, 7, 22, 26, 13, 9, 11, 8, 18, 15, 17, 20, 2, 4, 1, 14, 27, 6, 25, 24, 23, 12) 
'(28+4)th column in <speciesDAoutput.txt> is set as the first individual [top left in similarity matrix plot],
 (10+4)th column in <speciesDAoutput.txt> is set as the second individual, 
 etc.'

ownlines = c(1, 7, 8, 11, 14, 18, 19, 21) 
'a line will be drawn separating the 1st individual (after sorting) from the rest, 
 a second line will be drawn separating the 7th individual (after sorting) from the following individuals, 
 etc.'

res <- plot.simmatrix("STACEY/speciesDAoutput.txt", labelfile = "labels.txt",
               ownorder = ownorder, ownlines = ownlines, PP.thresh = NULL, 
               mar = c(0,11,11,2.5), 
               cols = c("blue", "orange", "white"), border.col = NULL, legend = TRUE, 
               plot.phylo = FALSE, save.pdf = FALSE, pdf.name = "SimMatrix.pdf")
print(res, digits = 2)
```

### References
* Bouckaert R, Heled J, Kühnert D, Vaughan T, Wu C-H, Xie D, Suchard, M.A., Rambaut A, Drummond A.J. (2014) BEAST 2: a software platform for Bayesian evolutionary analysis. PLoS Computational Biology, 10 (4), e1003537.
* Drummond, A.J. Marc A. Suchard, M.A., Xie D, Rambaut A (2012) Bayesian phylogenetics with BEAUti and the BEAST 1.7. Molecular Biology and Evolution, 29, 1969–1973.
* Jones G, Zeynep A, Oxelman B (2015) DISSECT: an assignment-free Bayesian discovery method for species delimitation under the multispecies coalescent. Bioinformatics, 31(7), 991-998.
* Jones G (2017) Algorithmic improvements to species delimitation and phylogeny estimation under the multispecies coalescent. Journal of Mathematical Biology, 74(1), 447-467.
