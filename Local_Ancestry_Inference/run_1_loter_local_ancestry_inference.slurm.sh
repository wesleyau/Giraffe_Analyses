#!/bin/bash
#SBATCH -n 8
#SBATCH --mem=50g
#SBATCH -p aces
#SBATCH -J loter
#SBATCH --time=150:00:00
#SBATCH --output=slurm_%A_%a.out
#SBATCH --error=slurm_%A_%a.err

module load Loter

echo "run loter_cli"
loter_cli -r northern.vcf reticulated.vcf masai.vcf southern.vcf -a ex_situ.vcf -f vcf -n 8 -o output_ancestry -v
echo "finished loter_cli"

echo "runing plot_ancestry"
python plot_ancestry.py
echo "finished"
