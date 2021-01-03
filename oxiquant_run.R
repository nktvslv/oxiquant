# install libraries if required
cran_packages <- c("Rcpp","RcppArmadillo","data.table","future",
                   "future.apply","devtools","BiocManager")
if (!requireNamespace(cran_packages, quietly = TRUE)) {
  lapply(X = cran_packages, FUN = install.packages)
}
bioconductor_packages <- c("mzR","mzID")
if (!requireNamespace(bioconductor_packages, quietly = TRUE)) {
  lapply(X = bioconductor_packages, FUN = BiocManager::install)
}
if (!requireNamespace(c("mzcharge","oxiquant"), quietly = TRUE)) {
  devtools::install_github("https://github.com/nktvslv/mzcharge.git")
  devtools::install_github("https://github.com/nktvslv/oxiquant.git")
}

# load oxiquant library
library(oxiquant)

# set oxiquant options
options(# selected parameters for MS-GF+. should always have quote around.
        # documented at https://msgfplus.github.io/msgfplus/MSGFPlus.html.
        "msgf.d" = "_proteins.fasta", # protein data base. if missing, will be made from fasta files in working directory.
        "msgf.mod" = "_modifications.txt", # modifications as described in . if missing, will be copied from oxiquant package.
        "msgf.t" = "10ppm", # precursor m/z tolerance.
        "msgf.ti" = "0,4", # isotope error.
        "msgf.tda" = "1", # 0 - do not run decoy search, 1 - run decoy search.
        "msgf.e" = "1", # enzyme id; 1 - trypsin.
        "msgf.ntt" = "2", # termini; 2 - fully specific.
        "msgf.minLength" = "5", # min peptide length.
        "msgf.maxLength" = "40", # max peptide length.
        "msgf.minCharge" = "1", # min precursor charge.
        "msgf.maxCharge" = "8", # max precursor charge.
        "msgf.addFeatures" = "1", # add ms2ioncurrent in output. needed for oxiquant.
        "msgf.maxMissedCleavages" = "-1", # -1 - no limit.
        "msgf.numMods" = "3", # max variable modifications per peptide.
        
        # parameters for mzcharge
        "mzcharge.min_width" = 5, # min number of points in peak before centroiding.
        "mzcharge.min_intensity" = 0.0, # min intensity to consider as a peak.
        "mzcharge.mz_tol" = 10.0, # m/z tolerance in ppm for charge assignment.
        "mzcharge.intensity_tol" = 2.0, # max deviation from averagine model, e.g. 0.0 - full conformance with averagine.
        "mzcharge.max_charge" = 8, # max charge to consider. min is always 1.
        "mzcharge.num_iso" = 12, # max number of isotopologues to consider.
        "mzcharge.min_iso" = 2, # min number of isotopologues for charge correction.
        "mzcharge.scan_tol" = 3, # max scan gap for charge correction.
        
        # parameters for psms filtering and ion current extraction
        "psms.qval" = 0.01, # max q-value to consider true identification.
        "psms.n_oxi" = 3, # max number of hydroxyl groups to consider.
        "xic.min_charge" = 1, # min charge for ion current extraction.
        "xic.max_charge" = 8, # max charge for ion current extraction.
        "xic.min_scans" = 5, # min number of scans in elution peak.
        "xis.max_gap" = 1, # max scans gap in elution peak.
        "xic.mz_tol" = 10.0, # m/z tolerance for ion current extraction.
        "xic.rt_range" = 5.0, # retention time range, -/+ minutes, to look for peak of elution of unmodified peptide. 
        "xic.rt_left" = 1.0, # size of left side of elution peak to include ion current.
        "xic.rt_right" = 1.0, # size of right side of elution peak to include ion current.
        
        # miscellaneous
        "future.rng.onMisuse" = "ignore")

# run oxiquant pipeline
oxiquant(msgf = TRUE, # TRUE - run MS-GF+; FALSE - don't run MS-GF+ if it was run before and mzid files were saved in working directory.
         process_ms1 = TRUE, # TRUE - run mzcharge; FALSE - don't run mzcharge if it was run before and ms1.csv files were saved in working directory.
         extract_ion_current = TRUE) # TRUE - extract ion current for identified peptides and their oxidized variants.