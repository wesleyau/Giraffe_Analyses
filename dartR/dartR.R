# Load required packages
library(gplots)
library(dartRverse)
library(vcfR)
library(dartR)
library(reshape2)

# Read the VCF file
vcf <- read.vcfR("final_pruned_data.vcf.gz")

# Convert VCF to genlight object
gl <- vcfR2genlight(vcf)

# Check compliance of the genlight object
gl <- gl.compliance.check(gl)

# Recalculate metrics for the genlight object
gl <- gl.recalc.metrics(gl)

# Retrieve the current individual names
current_names <- indNames(gl)
print(current_names)

# Modify the names by removing the part after the underscore
new_names <- sub("_[^_]+$", "", current_names)

# Assign the new names back to the genlight object
indNames(gl) <- new_names

# Verify the change
print(indNames(gl))

# Define the new population assignments
admixed_k4pops <- c(
  #array of assigned population according to admixture anaylsis, redacted here for anonymity 
)

# Assign the new poulations to the genlight object
pop(gl) <- admixed_k4pops

# Verify the change
print(pop(gl))

# Define the default palettes
discrete_palette <- function(n) {
  colors <- c("#f8766d", "#2b946f", "#5a8ed6", "#84689f", "#00bfc4", '#7cae00',"#c77cff")
  rep_len(colors, n)
}

# Custom convergent palette
convergent_palette <- function(n) {
  n_half <- (n - 1) / 2
  colors_pos <- colorRampPalette(c("#fffc00", "#ff7e00", "#ff0500"))(n_half)
  colors_neg <- colorRampPalette(c("#0005ff", "#007fff", "#00fcff"))(n_half)
  c(colors_neg, "#aaff53", colors_pos)
}

# Calculate the Genetic Relationship Matrix (GRM)
grm <- gl.grm(gl, plotheatmap = FALSE)

# Using default palettes for the heatmap
colors_pops <- discrete_palette(length(levels(pop(gl))))

# Plot heatmap with custom colors
heatmap.2(
  as.matrix(grm),
  dendrogram = "both",
  trace = "none",
  col = convergent_palette(255),
  margins = c(5, 15),
  labRow = indNames(gl),
  labCol = indNames(gl),
  ColSideColors = colors_pops[as.numeric(pop(gl))],
  RowSideColors = colors_pops[as.numeric(pop(gl))],
  key.title = "Color Key",
  key.xlab = "Value",
  key.ylab = "",
  density.info = "none",
  cexRow = 0.5,
  cexCol = 1,
  main = "Genomic Relationship Matrix",
  symm = TRUE  # Ensures the heatmap is symmetric
)

# Add legend for populations at bottom left
legend("topright", legend = levels(pop(gl)), fill = colors_pops, title = "Populations", cex = 0.75)

