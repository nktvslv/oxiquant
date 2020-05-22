# oxiquant
Automated analysis of mass spectrometry data collected during hydroxyl radical footprinting experiment

## Description
`oxiquant` is a pipeline for quantitative proteomics that executes 
[MS-GF+](https://github.com/MSGFPlus/msgfplus) 
MS2 search engine for peptides identification, 
[`mzcharge`](https://github.com/nktvslv/mzcharge) to extract 
intensity signal from MS1 spectra and maps identified peptides and their possible oxidated variants to extracted ion current.

## Installation
To run MS-GF+ [Java](https://www.java.com/en/download/manual.jsp)
runtime has to be installed.

R dependencies from CRAN and Bioconductor
```R
# CRAN packages
install.packages(c("data.table","future","future.apply","tidyr"))

# Bioconductor packages
if (!requireNamespace("BiocManager", quietly=TRUE))
    install.packages("BiocManager")
BiocManager::install(c("mzID","mzR"))
```
On Windows install Rtools from [CRAN](https://cran.r-project.org) to 
compile C++ code in `mzcharge`

Install `mzcharge`
```R
if (!requireNamespace("devtools", quietly=TRUE))
    install.packages("devtools")
devtools::install_github("https://github.com/nktvslv/mzcharge.git")
```

Install `oxiquant`
```R
if (!requireNamespace("devtools", quietly=TRUE))
    install.packages("devtools")
devtools::install_github("https://github.com/nktvslv/oxiquant.git")
```

`oxiquant` is bundled with MS-GF+ release 2020.03.14 that will be downloaded
during first execution of the pipeline and installed in package directory.