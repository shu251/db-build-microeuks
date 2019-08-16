### Draft snakemake pipeline to build database for 18S tag-seq

_Workflow_
1. Download recent version of PR2
2. Set up working conda environment
3. Modify config.yaml file (location of relevant files, primers to target region of interest, output location)
4. Run snakefile
  * Import fasta and tax files as qiime2 artifacts
  * Subsets V4 hypervariable region (or other amplicon)
  * train classifer (Naive Bayes classifier)
  * check output
  * log version, etc.


### (1) Set up your database working directory
I recommend the [Protist Ribosomal 2 - PR2 database](https://github.com/pr2database/pr2database) for 18S tag-sequencing.

```
# Clone this repo
git clone https://github.com/shu251/db-build-microeuks.git
cd db-build-microeuks # migrate to repo directory

# Download PR2 database (or database of choice)
wget "https://github.com/pr2database/pr2database/releases/download/4.11.1/pr2_version_4.11.1_mothur.tax.gz"
wget "https://github.com/pr2database/pr2database/releases/download/4.11.1/pr2_version_4.11.1_mothur.fasta.gz"
gunzip *mothur*.gz
```

### (2) Install conda environment

The conda environment (or Anaconda environment) here will contain all the required programs to run the database prep and ASV pipeline in QIIME2. For more information, see this [blog post](https://alexanderlabwhoi.github.io/post/anaconda-r-sarah/) on how I set up R environments using anaconda.  
There is an 'environment' file (```snake-18S-env.yaml```) in this repo that you can use to create a conda environment that will have *Snakemake*, *QIIME2*, and *R*. [More on using conda environments](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html).  

##### _Why snakemake?_
[Snakemake](https://snakemake.readthedocs.io/en/stable/index.html) is a tool to manage your bioinformatic pipeline. Using the snakemake framework, we can build complex workflows that are more robust, scalable, and reproducible. This is highly recommended if you are working with HPC, as it plays very nicely with slurm. There is a learning curve when diving into snakemake, but there are many helpful tutorials online and already build (snakemake wrappers or rules)[https://snakemake-wrappers.readthedocs.io/en/stable/index.html] that you can use.

```
conda env create -f /envs/snake-18S-env.yaml --name snake-18S 

# Enter environment
source activate snake-18S

# Check versions and correct environment set up
snakemake --version
qiime info
```
Output from snakemake should be ```5.4.0```, and the qiime info will list installed plugins and system versions for python and qiime. Python version should be >3.6 and QIIME2 release should be at least 2019.4 (as of writing this README).

#### (2.1) Option to set up snakemake to run with slurm
Cookiecutter should already be installed, if not, [follow these instructions](https://cookiecutter.readthedocs.io/en/latest/installation.html) to install within the snake-18S environment.   
Then follow these instructions to [enable snakemake to run with slurm](https://github.com/Snakemake-Profiles/generic).
_need additional clarifiation on how this needs to be set up to run on your machine, alternate option is to select the number of threads to use..., right?_

### (3) Modify config.yaml


Enter your preferred text editor to modify ```config.yaml```. _An explanation of how mine is structured is below_.

```
# Contents of config.yaml with annotation
## Location of the PR2 database (fasta and taxonomy file)
ref_db: /vortexfs1/omics/huber/shu/db/pr2_version_4.11.1_mothur.fasta
ref_tax: /vortexfs1/omics/huber/shu/db/pr2_version_4.11.1_mothur.tax

## version information of your database
version: pr2_4.11.1

## I'm using a HPC with a scratch directory that will be my output directory
scratch: /vortexfs1/scratch/sarahhu

## Primer sequences for Forward and Reverse
primerF: CCAGCASCYGCGGTAATTCC
primerR: ACTTTCGTTCTTGATYRA
db_region: V4 # Region of the barcode that these primers highlight
```

### (4) Snakemake dry run

```
snakemake -n -r
```

### (5) Run snakemake
Snakemake will automatically detect 'Snakefile'. ```snake-18S``` conda environment has both snakemake and qiime2 dependencies, so no need to use ```--use-conda``` in this command.
```
snakemake
```

### (6) Run snakemake with SLURM

[Read about executing snakemake on a cluster](https://snakemake.readthedocs.io/en/stable/executable.html) and another explanation on how to execute with a submit script can be found [here](https://hpc-carpentry.github.io/hpc-python/17-cluster/).    
Review the submit scripts available in ```submitscripts```. Files in this directory include another config file called ```cluster.yaml```, and two scripts to submit your snakemake pipeline to the cluster with and without the dry run option.   
First, open and modify the ```cluster.yaml``` to fit your machine. Then test run using the provided submit scripts.
```
# Make sure you are still in the snake-tagseq conda environment
bash submitscripts/submit-slurm-dry.sh
```
Outputs should all be green and will report how many jobs and rules snakemake plans to run. This will allow you to evaluate any error and syntax messages.  

Once ready, use the submit-slurm.sh script to submit the jobs to slurm. Run with screen, tmux, or nohup.
```
bash submitscripts/submit-slurm.sh
# This will print jobs submitted as it runs. Monitor these jobs using ```squeue```

```

### (7) Next steps
See this [snakemake pipeline to run QIIME2](https://github.com/shu251/tagseq-qiime2-snakemake) to use these newly created databases.
