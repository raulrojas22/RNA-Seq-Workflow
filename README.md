# RNA-Seq-Workflow
Pipeline general para metología RNA-Seq


**Pipeline del proceso**

![RNA-Seq Workflow](https://github.com/raulrojas22/public_scripts/blob/master/workflow_rna.png)

**El pipeline cuenta con 5 scripts (4 en Bash y 1 en R) los cuales son:**

  - [Descarga de archivos](https://github.com/raulrojas22/RNA-Seq-Workflow/blob/master/scripts/download_data.sh)
  - [Analisis de calidad](https://github.com/raulrojas22/RNA-Seq-Workflow/blob/master/scripts/analisis_calidad.sh)
  - [Trimming reads de mala calidad](https://github.com/raulrojas22/RNA-Seq-Workflow/blob/master/scripts/trimming.sh)
  - [Alineamiento de reads al genoma de referencia](https://github.com/raulrojas22/RNA-Seq-Workflow/blob/master/scripts/align_reads.sh)
  - [Conteo de reads a las características anotadas del genoma](https://github.com/raulrojas22/RNA-Seq-Workflow/blob/master/scripts/count_reads.sh)
  - [Análisis de expresión diferencial](https://github.com/raulrojas22/RNA-Seq-Workflow/blob/master/scripts/de_analysis.R)

**Dependencias a utilizar durante este pipeline**

  - [SRA-tools](https://github.com/ncbi/sra-tools)
  - [fastqc](https://github.com/s-andrews/FastQC)
  - [multiqc](https://github.com/MultiQC/MultiQC)
  - [trimmomatic](https://github.com/usadellab/Trimmomatic)
  - [hisat2](https://github.com/DaehwanKimLab/hisat2)
  - [samtools](https://github.com/samtools/samtools)
  - [featureCounts](https://subread.sourceforge.net)
  - [R](https://www.r-project.org)
  - [DESeq2](https://bioconductor.org/packages/release/bioc/html/DESeq2.html)

