### Draft snakemake pipeline to build database for 18S tag-seq

_Workflow_
* Download recent version of PR2
* Import fasta and tax files as qiime2 artifacts
* subset V4 hypervariable region
* train classifer (Naive Bayes classifier)
* check output
* log version, etc.

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
