import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

# Function to extract sample names from a VCF file
def extract_sample_names_from_vcf(vcf_file):
    name_mapping = {
        #array of original names to their aliases, redacted here for anonymity
    }
    with open(vcf_file, 'r') as f:
        for line in f:
            if line.startswith("#CHROM"):
                original_names = line.strip().split("\t")[9:]
                return [name_mapping.get(name, name) for name in original_names]

# Load the data (assuming it's a numpy array saved as '.npy')
data = np.load('output_ancestry.npy')

# Print the shape of the data
print("Shape of the data:", data.shape)

# Extract names from the VCF file
names = extract_sample_names_from_vcf('ex_situ.vcf')
print("Names of the individuals:", names)

# Trim the data to ensure it's divisible by the block size
block_size = 5000
num_snps = data.shape[1]
trim_size = num_snps % block_size
if trim_size > 0:
    data = data[:, :-trim_size]

# Reduce SNP resolution by averaging blocks of SNPs
reduced_data = np.mean(data.reshape(data.shape[0], -1, block_size), axis=2)

# Define a custom color map
colors = ['orange', 'purple', 'blue', 'green']
cmap = sns.color_palette(colors)

# Adjust yticklabels to place names between two rows
yticks = [(i*2 + 1) for i in range(len(names))]
yticklabels = names

# Plot the heatmap
plt.figure(figsize=(35, 20))
ax = sns.heatmap(reduced_data, cmap=cmap, yticklabels=yticklabels, cbar=False, xticklabels=False)

# Increase the font size of the x-axis and y-axis labels
plt.xlabel('SNP Blocks (5000 SNPs per block)', fontsize=24)
plt.ylabel('Individuals', fontsize=22)

# Increase the font size of the title
plt.title('Local Ancestry Inference', fontsize=30)

# Set x-axis labels to 0 and 29490094 or 1697801
ax.set_xticks([0, reduced_data.shape[1] - 1])
ax.set_xticklabels(['0', '1697801'], fontsize=22)

# Set y-ticks to place names between two rows and increase their font size
ax.set_yticks(yticks)
ax.set_yticklabels(yticklabels, fontsize=24)

# Custom legend
from matplotlib.patches import Patch
legend_labels = {
    'orange': 'Northern',
    'purple': 'Reticulated',
    'green': 'Masai',
    'blue': 'Southern'
}
legend_handles = [Patch(color=color, label=label) for color, label in legend_labels.items()]

# Increase the font size of the legend
ax.legend(handles=legend_handles, loc='center left', bbox_to_anchor=(1, 0.5), fontsize=20)

plt.savefig('ancestry_heatmap_alias.png', dpi=300)

