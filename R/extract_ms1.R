extract_ms1 <- function(mzml_file) {
    
    # print current file
    print(paste("processing ms1 spectra from", mzml_file))
    prefix <- gsub(pattern = "\\.mz[Mm][Ll]$", replacement = "", x = mzml_file)
    
    # get options
    min_width <- getOption("mzcharge.min_width", 5L)
    min_intensity <- getOption("mzcharge.min_intensity", 0.0)
    mz_tol <- getOption("mzcharge.mz_tol", 10.0)
    intensity_tol <- getOption("mzcharge.intensity_tol", 1.0)
    max_charge <- getOption("mzcharge.max_charge", 8L)
    num_iso <- getOption("mzcharge.num_iso", 12L)
    min_iso <- getOption("mzcharge.min_iso", 2L)
    scan_tol <- getOption("mzcharge.scan_tol", 3L)
    
    # centroiding and charge assignment
    out <- mzcharge::charge_spectrafile(mzml_file, min_width, min_intensity,
                                        mz_tol, intensity_tol, max_charge,
                                        num_iso)
    
    # correct charges
    out <- mzcharge::charge_corr(out, mz_tol, scan_tol, min_iso)
    
    # add id to each centroid
    out[,uid:=1:.N]
    
    # add file prefix
    out[,ms1file := prefix]
    
    # write results to disk
    fwrite(x = out, file = paste(prefix, ".ms1.csv", sep = ""))
}
