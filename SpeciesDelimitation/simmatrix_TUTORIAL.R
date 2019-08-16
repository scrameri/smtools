############################################################
### TUTORIAL on how to use the plot.simmatrix() function ###
############################################################

## First, make sure that your R working directory is located at this script's location:
# setwd("~/YourName/YourProject/smtools-master/SpeciesDelimitation")

## Specify your input data
# this is the example data (have a look at how these files look like), replace with your own data
# paths are relative to your R working directory
speciesDAoutput <- "STACEY/speciesDAoutput.txt"
summarized.tree <- "STACEY/species.sumtree"
labelfile <- "STACEY/labels.txt"

###############################################

## Check that input files exist
stopifnot(file.exists("plot.simmatrix.R")) # required
stopifnot(file.exists(speciesDAoutput))    # required
file.exists(summarized.tree)               # semi-optional (see below)
file.exists(labelfile)                     # optional (see below)

## Load R function into environment
source("plot.simmatrix.R")

## Inspect R funciton
args(plot.simmatrix) # arguments allow for a lot of fine-tuning
plot.simmatrix # read the Usage section if unsure about the arguments

## Some examples
# automatic ordering [according to <summarized.tree> topology] and line drawing [according to PP.thresh = 0.0]
# with original labels as in <speciesDAoutput> and <summarized.tree> [no labelfile needed here] and black-and-white plotting
# save similarity matrix plot to file "SimMatrix.pdf"
plot.simmatrix(speciesDAoutput = speciesDAoutput, summarized.tree = summarized.tree, labelfile = NULL,
               ownorder = NULL, ownlines = NULL, PP.thresh = 0.0, 
               mar = c(0,4,4,0), 
               cols = c("black", "white"), border.col = "white", legend = FALSE, 
               plot.phylo = FALSE, save.pdf = TRUE, pdf.name = "SimMatrix.pdf")

# automatic ordering [according to >summarized.tree> topology] and line drawing [according to PP.thresh = 0.05] 
# with labels as in SECOND column of <labels.txt> and with colourful plotting with legend
plot.simmatrix(speciesDAoutput = speciesDAoutput, summarized.tree = summarized.tree, labelfile = labelfile,
               ownorder = NULL, ownlines = NULL, PP.thresh = 0.05, 
               mar = c(0,11,11,2.5), label.size = 1, legendlabel.size = 0.5,
               cols = c("blue", "orange", "white"), border.col = NULL, legend = TRUE, 
               plot.phylo = FALSE, save.pdf = FALSE, pdf.name = "SimMatrix.pdf")

# note that the actual delimitation of distinct clusters separated by black lines depend on your choice of PP.thresh
plot.simmatrix(speciesDAoutput = speciesDAoutput, summarized.tree = summarized.tree, labelfile = labelfile,
               ownorder = NULL, ownlines = NULL, PP.thresh = 0.025, 
               mar = c(0,11,11,2.5), label.size = 1, legendlabel.size = 0.5,
               cols = c("blue", "orange", "white"), border.col = NULL, legend = TRUE, 
               plot.phylo = FALSE, save.pdf = FALSE, pdf.name = "SimMatrix.pdf")

# own specification for order and lines [no <summarized.tree> needed]
# output can be redirected to an R object and printed
ownorder = c(28, 10, 5, 21, 16, 19, 3, 7, 22, 26, 13, 9, 11, 8, 18, 15, 17, 20, 2, 4, 1, 14, 27, 6, 25, 24, 23, 12) 
'(28+4)th column in <speciesDAoutput> is set as the first individual [top left in similarity matrix plot],
(10+4)th column in <speciesDAoutput> is set as the second individual, 
etc.'

ownlines = c(1, 7, 8, 11, 14, 18, 19, 21) 
'a line will be drawn separating the 1st individual (after sorting) from the rest, 
a second line will be drawn separating the 7th individual (after sorting) from the following individuals, 
etc.'

res <- plot.simmatrix(speciesDAoutput = speciesDAoutput, labelfile = labelfile,
                      ownorder = ownorder, ownlines = ownlines, PP.thresh = NULL, 
                      mar = c(0,11,11,2.5), 
                      cols = c("blue", "orange", "white"), border.col = NULL, legend = TRUE, 
                      plot.phylo = FALSE, save.pdf = FALSE, pdf.name = "SimMatrix.pdf")
print(res, digits = 2) 

# the ordered matrix can be written to disk using write.table()
write.table(res, file = "ordered_simmatrix.txt", quote = FALSE, col.names = TRUE, row.names = TRUE, sep = "\t")

# the species tree can be read in, plotted and saved as a pdf within R like this
sumtree <- read.nexus(summarized.tree)
plot(sumtree)

pdf(file = "summary_tree.pdf")
plot(sumtree)
graphics.off()
