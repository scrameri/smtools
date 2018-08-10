plot.simmatrix <- function(speciesDAoutput, summarized.tree = NULL, labelfile = NULL,
                           ownorder = NULL, ownlines = NULL, PP.thresh = 0.05, 
                           mar = c(0,10,10,1), label.size = 1, legendlabel.size = 1,
                           cols = c("blue", "orange", "white"), border.col = NULL, legend = TRUE, 
                           plot.phylo = FALSE, save.pdf = FALSE, pdf.name = "SimMatrix.pdf") {
  
  # -------------------------------------------------------------------------- #
  ### R funciton for displaying the SpeciesDA.jar pairwise similarity matrix ###
  # -------------------------------------------------------------------------- #
  
  ## Authors
  # Core code taken from http://www.indriid.com/2014/species-delim-paper-SuppIinfo-v8.pdf
  # by Graham Jones, art@gjones.name, Feb 2014
  
  # Code modified for automatized pairwise distance matrix sorting, labelling, and line drawing 
  # by Simon Crameri, simon.crameri@env.ethz.ch, Oct 2017
  
  
  ## Usage
  '
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
  '
  
  ### Install dependencies if needed ###
  # Needed packages
  load.pkgs <- c("ape")
  need.pkgs <- load.pkgs[which(!load.pkgs %in% installed.packages())]
  if (length(need.pkgs) > 0) {
    for (i in need.pkgs) install.pakcages(i)
  }
  
  # Display package version of loaded packages
  for (i in load.pkgs) {
    suppressWarnings(suppressPackageStartupMessages(do.call(library, list(i))))
    cat(i)
    cat(paste0(" v", packageVersion(i)))
    cat("\n")
  }
  
  
  ###--------------------------------------- Read and Check Input --------------------------------------------###
  
  # Check required <speciesDAoutput> file
  stopifnot(is.character(speciesDAoutput), file.exists(speciesDAoutput))
  
  # Read in the table of clusterings
  x <- read.table(speciesDAoutput, header = TRUE, check.names = FALSE)
  
  # Check spaciesDA.jar output format
  if (!identical(names(x)[1:4], c("count", "fraction", "similarity", "nclusters"))) {
    warning("<speciesDAoutput> file does not seem to be a valid speciesDA.jar output text file.")
  }
  
  ### Sanity-check input arguments ###
  # Validity of colors
  areColors <- function(x) {
    sapply(x, function(X) {
      tryCatch(is.matrix(col2rgb(X)), 
               error = function(e) FALSE)
    })
  }
  
  # Check required arguments
  stopifnot(
    
    # cols must be a valid color vector of length >= 2
    length(cols) >=2,
    areColors(cols),
    
    # checks other specifications
    is.logical(save.pdf),
    is.logical(legend),
    is.logical(plot.phylo),
    is.numeric(mar),
    length(mar) == 4,
    label.size >= 0,
    mar >= 0
  )
  
  # Check optional arguments
  if (is.null(summarized.tree) & plot.phylo) message("no <summarized.tree> specified, so no phylogram will be plotted.")
  if (!is.null(labelfile)) stopifnot(is.character(labelfile), file.exists(labelfile))
  if (save.pdf) stopifnot(is.character(pdf.name), substring(pdf.name, nchar(pdf.name)-3, nchar(pdf.name)) == ".pdf")
  
  if (is.null(ownlines)) {
    stopifnot(is.numeric(PP.thresh), PP.thresh >= 0, PP.thresh <=1) 
  } else {
    if (!is.null(PP.thresh)) message("no automatic line drawing since <ownlines> is not NULL, so <PP.thresh> specification is not used.")
  }  
  
  if (!is.null(summarized.tree)) {
    # Check file
    stopifnot(is.character(summarized.tree), file.exists(summarized.tree))
    
    # Read summarized tree
    sumtree <- read.nexus(summarized.tree)
    if (plot.phylo) plot.phylo(sumtree)
    
    # Get tip label order as in the tree topology
    is_tip <- sumtree$edge[,2] <= length(sumtree$tip.label)
    ordered_tips <- sumtree$edge[is_tip, 2]
    labs <- sumtree$tip.label[ordered_tips]
    stopifnot(labs %in% names(x)[-c(1:4)])
  } else {
    labs <- names(x)[-c(1:4)]
  }
  
  # Check plot margins
  if (mar[4] < 2.5 & legend) warning("Right plot margin might be too small for the legend to be displayed. Consider increasing mar[4].")
  
  # Check ownorder and ownlines specifications
  nInd <- length(labs)
  if (! is.null(ownorder)) stopifnot(is.numeric(ownorder), min(ownorder) >= 1, max(ownorder) <= nInd, length(ownorder) == nInd, !any(duplicated(ownorder)))
  if (! is.null(ownlines)) stopifnot(is.numeric(ownlines), min(ownlines) >= 0, max(ownlines) <= nInd, !any(duplicated(ownlines)))
  
  # Check <speciesDAoutput> minimal cluster columns
  if (any(! labs %in% names(x))) {
    stop("Column names in <speciesDAoutput> do not match tip labels in <summarized.tree>.")
  }
  
  # Check labelfile
  if (!is.null(labelfile)) {
    labels <- read.table(labelfile, header = TRUE, row.names = 1)
    if (any(labs %in% rownames(labels)) == FALSE) {
      labelcheck <- labs[which(! labs %in% rownames(labels))]
      check <- labelcheck[1]
      for (i in 2:length(labelcheck)) {
        ls <- labelcheck[i]
        check <- paste(check, ls, sep = ", ")
      }
      stop(paste0("The following tips were not found in the first <labelfile> column:\n", check, "\nPlease check <labelfile> ", labelfile, "."))
    }
  }
  
  ###--------------------------------------- Done Reading and Checking Input -----------------------------------------###
  
  
  # Reorder <speciesDAoutput> minimal cluster columns
  if (is.null(ownorder)) {
    # Reorder x columns such that columns match <summarized.tree> topology
    x <- x[,c(names(x)[1:4], labs)]
  } else {
    # Reorder x columns according to <ownorder>
    x <- x[,c(names(x)[1:4], names(x)[-c(1:4)][ownorder])]
  }
  
  # Abbreviations for display
  ids <- names(x)[-c(1:4)]
  renames <- matrix(rep(ids, each = 2), nrow = length(ids), ncol = 2, byrow = TRUE)
  
  # Use user-specified labels
  if (!is.null(labelfile)) {
    labels <- cbind(labels, rep(NA, nrow(labels)))
    labels <- labels[renames[,1], ]
    renames[,2] <- as.character(labels[, 1])
  }
  
  # Make the similarity matrix
  displaynames <- renames[,2]
  nmincls <- length(displaynames) # similarity matrix labels
  sim <- matrix(0, ncol=nmincls, nrow=nmincls, dimnames=list(displaynames, displaynames))
  for (i in 1:nmincls) {
    for (j in 1:nmincls) {
      coli <- x[,ids[i]]
      colj <- x[,ids[j]]
      w <- coli == colj
      sim[i,j] <- sum(x[w,"fraction"])
    }
  }
  
  # Ensure rounding errors don't make probabilities sum to more than 1.
  sim <- pmin(sim,1)
  
  # Plot lines 
  if (is.null(ownlines)) {
    # Plot lines according to PP threshold
    draw <- numeric()
    for (i in 1:(nrow(sim))-1) {
      ls <- ifelse(sim[i,i+1] <= PP.thresh, 1, 0)
      draw <- c(draw, ls)
      rm(ls)
    }
    dividers <- c(0, which(draw == 1), nrow(sim))
  } else {
    # Plot lines according to <ownlines>
    dividers <- c(0, ownlines, nrow(sim))
    if (any(duplicated(dividers))) dividers <- dividers[-which(duplicated(dividers))]
  }
  
  # Currently recognised groups
  plot.rectangle <- function(v1,v2,...)
  {
    polygon(c(v1[1],v2[1],v2[1],v1[1]), c(v1[2],v1[2],v2[2],v2[2]), ...)
  }
  
  # Map values [0,1] in sim to user-specified color palette
  map2color<-function(x, palette, limits = NULL){
    if(is.null(limits)) limits = range(x)
    palette[findInterval(x, seq(limits[1], limits[2], length.out = length(palette) + 1), all.inside = TRUE)]
  }
  
  # Main plotting routine
  plot.simmatrix <- function() {
    
    # Set plot margins
    par(mar= mar)
    
    ## Plot pairwise similarity matrix ##
    # Create empty plot 
    if (legend) {
      add <- 1 # leave some space for the legend
      plot(NULL, xlim=c(0,nmincls+add), ylim=c(nmincls,0), axes=FALSE, ylab="", xlab="")
      
    } else {
      plot(NULL, xlim=c(0,nmincls-1), ylim=c(nmincls,0), axes=FALSE, ylab="", xlab="")
      
    }
    
    # Plot labels
    axis(side=3, at=(1:nmincls)-.5, labels=displaynames, tick=FALSE, las=2, line=-1, cex.axis = label.size) # column labels
    axis(side=2, at=(1:nmincls)-.5, labels=displaynames, tick=FALSE, las=2, line=-1, cex.axis = label.size) # row labels
    
    # Plot rectangles
    for (i in 1:nmincls) { # for all tip columns
      for (j in 1:nmincls) { # for all tip rows
        d <- 1 - sim[i,j] # similarity value mapped to color
        n <- 100 # number of color intervals: the higher n, the higher the resolution, the longer it takes for plotting
        col <- map2color(x = d, pal = colorRampPalette(cols, space = "rgb") (n), limits = c(0,1))
        colorlegend <- map2color(x = seq(1, 0, length.out = n), pal = colorRampPalette(cols, space = "rgb") (n), limits = c(0,1))
        if (is.null(border.col)) bordercol <- col else bordercol <- border.col
        plot.rectangle(c(i-1,j-1), c(i,j), col = col, border = bordercol)
      }
    }
    
    # Plot lines around clusters
    for (b in dividers) {
      lines(x=c(-.5,nmincls), y=c(b,b))
      lines(x=c(b,b), y=c(-.5,nmincls))
    }
    
    ## Plot color legend ##
    if (legend) {
      levels <- seq(0, nmincls, length.out = n)
      rect(nmincls+.5, levels[-length(levels)], nmincls+.5+add, levels[-1L], col = colorlegend, border = NA, xpd = TRUE)
      axis(4, at = seq(0, nmincls, length.out = 11), labels = seq(0, 1, length.out = 11), las = 1, pos = c(nmincls+1.5,0), 
           cex.axis = legendlabel.size)
      lines(x=c(nmincls+.5,nmincls+.5), y=c(0,nmincls))
      lines(x=c(nmincls+.5,nmincls+1.5), y=c(nmincls,nmincls), xpd = TRUE)
      lines(x=c(nmincls+.5,nmincls+1.5), y=c(0,0), xpd = TRUE)
    }
    
    # Reset default plotting parameters
    par(mar= c(5, 4, 4, 2) + 0.1) 
    par(mfrow=c(1,1))
  }
  
  # Plot similarity matrix on plot device
  plot.simmatrix()
  
  # Safe similarity matrix to PDF
  if (save.pdf) {
    pdf(file = pdf.name)
    plot.simmatrix()
    dev.off()
  }
  
  # Return similarity matrix
  return(sim)
}
