### Draft snakemake pipeline to build database for 18S tag-seq

_Workflow_
* Download recent version of PR2
* Set up working conda environment
* Option to set up to run snakemake with slurm
* Modify config.yaml file
* Import fasta and tax files as qiime2 artifacts
* subset V4 hypervariable region
* train classifer (Naive Bayes classifier)
* check output
* log version, etc.


### (1) Download database & this repo

# link to PR2 github
```
# git clone this repo
# command to download and unzip databases
```

### (2) Install conda environment

# Link to R stuff, install from conda environment I created "/envs/snake-18S-env.yaml"

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


### (3) Modify config.yaml

Enter your preferred text editor to modify ```config.yaml```. _An explanation of how mine is structured is below_.

```
# enter config file and explain
```



```
snakemake -n -r
```

#### Continue getting this error message
Likely issue with how snakemake executes qiime2? see l 34 in .py code?



```
RuleException:
CalledProcessError in line 34 of /vortexfs1/omics/huber/shu/db/Snakefile:
Command ' set -euo pipefail;  qiime tools import        --type 'FeatureData[Sequence]'$
  File "/vortexfs1/omics/huber/shu/db/Snakefile", line 34, in __rule_import_db
  File "/vortexfs1/home/sarahhu/.conda/envs/snakemake-tara-euk/lib/python3.6/concurren$
Shutting down, this might take some time.
Exiting because a job execution failed. Look above for error message
```
