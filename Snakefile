# Snakemake file to QC tag-sequence reads
configfile: "config.yaml"

import io 
import os
import pandas as pd
import pathlib
from snakemake.exceptions import print_exception, WorkflowError

#----SET VARIABLES----#

SCRATCHDIR = config["scratch"]
INPUTDB = config["ref_db"]
INPUTTAX = config["ref_tax"]
VERSION = config["version"]

#----DEFINE RULES----#

rule all:
  input:
    dbartifact = expand("{base}/pr2-db/{info}.qza", base = SCRATCHDIR, info = VERSION),
    dbtaxartifact = expand("{base}/{info}_tax.qza", base = SCRATCHDIR, info = VERSION),

rule import_db:
  input:
    inputdb = INPUTDB
  output:
    dbartifact = expand("{base}/pr2-db/{info}.qza", base = SCRATCHDIR, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-import.log"
  conda:
    "/vortexfs1/omics/huber/shu/18S_pipeline_V4/envs/qiime2-2019.4.yaml"
  shell:
   """
   qiime tools import \
      --type 'FeatureData[Sequence]' \
      --input-path {input.inputdb} \
      --output-path {output.dbartifact}
   """

rule import_tax:
  input:
    tax = INPUTTAX
  output:
    dbtaxartifact = expand("{base}/{info}_tax.qza", base = SCRATCHDIR, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-import-tax.log"
  conda:
    "/vortexfs1/omics/huber/shu/18S_pipeline_V4/envs/qiime2-2019.4.yaml"
  shell:
    """
    qiime tools import \
      --type 'FeatureData[Taxonomy]' \
      --input-format HeaderlessTSVTaxonomyFormat \
      --input-path {input.tax} \
      --output-path {output.dbtaxartifact}
    """



