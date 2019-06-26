# Snakemake file to import fasta and tax files to generate and classify database for use in QIIME2
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
PRIMER_F = config["primerF"]
PRIMER_R = config["primerR"]
REGION = config["db_region"]
#----DEFINE RULES----#

rule all:
  input:
    dbartifact = expand("{base}/pr2-db/{info}.qza", base = SCRATCHDIR, info = VERSION),
    dbtaxartifact = expand("{base}/pr2-db/{info}_tax.qza", base = SCRATCHDIR, info = VERSION),
    select = expand("{base}/pr2-db/{region}-{info}.qza", base = SCRATCHDIR, region = REGION, info = VERSION),
    classifer = expand("{base}/pr2-db/{region}-{info}-classifier.qza", base = SCRATCHDIR, region = REGION, info = VERSION),
    tax	= expand("{base}/pr2-db/{region}-{info}-outputtax-TEST.qza", base = SCRATCHDIR, region = REGION, info = VERSION),
    taxviz = expand("{base}/pr2-db/{region}-{info}-outputtax-TEST.qzv", base = SCRATCHDIR, region = REGION, info = VERSION)

rule import_db:
  input:
    inputdb = INPUTDB
  output:
    dbartifact = expand("{base}/pr2-db/{info}.qza", base = SCRATCHDIR, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-import.log"
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
    dbtaxartifact = expand("{base}/pr2-db/{info}_tax.qza", base = SCRATCHDIR, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-import-tax.log"
  shell:
    """
    qiime tools import \
      --type 'FeatureData[Taxonomy]' \
      --input-format HeaderlessTSVTaxonomyFormat \
      --input-path {input.tax} \
      --output-path {output.dbtaxartifact}
    """

rule subset_region:
  input:
    dbartifact = expand("{base}/pr2-db/{info}.qza", base = SCRATCHDIR, info = VERSION)
  output:
    select = expand("{base}/pr2-db/{region}-{info}.qza", base = SCRATCHDIR, region = REGION, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-subset-region.log"
  shell:
    """
    qiime feature-classifier extract-reads \
      --i-sequences {input.dbartifact} \
      --p-f-primer CCAGCASCYGCGGTAATTCC \
      --p-r-primer ACTTTCGTTCTTGATYRA \
      --p-trunc-len 150 \
      --o-reads {output.select}
    """

rule classify:
  input:
    dbtaxartifact = expand("{base}/pr2-db/{info}_tax.qza", base = SCRATCHDIR, info = VERSION),
    select = expand("{base}/pr2-db/{region}-{info}.qza", base = SCRATCHDIR, region = REGION, info = VERSION)
  output:
    classifer = expand("{base}/pr2-db/{region}-{info}-classifier.qza", base = SCRATCHDIR, region = REGION, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-subset-region-classifier.log"
  shell:
    """
    qiime feature-classifier fit-classifier-naive-bayes \
      --i-reference-reads {input.select} \
      --i-reference-taxonomy {input.dbtaxartifact} \
      --o-classifier {output.classifier}
    """

rule qc_check:
  input:
    classifer = expand("{base}/pr2-db/{region}-{info}-classifier.qza", base = SCRATCHDIR, region = REGION, info = VERSION),
    dbartifact = expand("{base}/pr2-db/{info}.qza", base = SCRATCHDIR, info = VERSION)
  output:
    tax = expand("{base}/pr2-db/{region}-{info}-outputtax-TEST.qza", base = SCRATCHDIR, region = REGION, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-subset-region-testclassifier.log"
  shell:
    """
    qiime feature-classifier classify-sklearn \
      --i-classifier {input.classifier} \
      --i-reads {input.dbartifact} \
      --o-classification {output.tax}
    """

rule gen_taxviz:
  input:
    tax = expand("{base}/pr2-db/{region}-{info}-outputtax-TEST.qza", base = SCRATCHDIR, region = REGION, info = VERSION)
  output:
    taxviz = expand("{base}/pr2-db/{region}-{info}-outputtax-TEST.qzv", base = SCRATCHDIR, region = REGION, info = VERSION)
  log:
    SCRATCHDIR + "/pr2-db/logs/db-subset-region-testclassifierViz.log"
  shell:
    """
    qiime metadata tabulate \
      --m-input-file {input.tax} \
      --o-visualization {output.taxviz}
    """
