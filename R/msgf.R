#' @importFrom utils download.file unzip
run_msgf <- function(mzml) {
  
    # check if MS-GF+ is available; download/install if it is not available
    if (!file.exists(file.path(path.package("oxiquant"), "java/msgf/MSGFPlus.jar"))) {
        temp <- tempfile()
        download.file("https://github.com/MSGFPlus/msgfplus/releases/download/v2020.03.14/MSGFPlus_v20200314.zip",
                      temp)
        unzip(temp, exdir = file.path(path.package("oxiquant"), "java/msgf"))
        unlink(temp)
    }
  
    # get options for MS-GF+
    path_to_msgf <- file.path(path.package("oxiquant"), "java/msgf/MSGFPlus.jar")
    d <- getOption("msgf.d", "_proteins.fasta")
    mod <- getOption("msgf.mod", "_modifications.txt")
    t <- getOption("msgf.t", "10ppm")
    ti <- getOption("msgf.ti", "0,1")
    tda <- getOption("msgf.tda", "1")
    e <- getOption("msgf.e", "1")
    ntt <- getOption("msgf.ntt", "2")
    minLength <- getOption("msgf.minLength", "6")
    maxLength <- getOption("msgf.maxLength", "40")
    minCharge <- getOption("msgf.minCharge", "2") 
    maxCharge <- getOption("msgf.maxCharge", "3")
    addFeatures <- getOption("msgf.addFeatures", "1")
    maxMissedCleavages <- getOption("msgf.maxMissedCleavages", "-1")
    numMods <- getOption("msgf.numMods", "3")
  
    # compile command for system call
    command <- paste("java", "-jar", path_to_msgf,
                     "-s", mzml,
                     "-d", d,
                     "-mod", mod,
                     "-t", t,
                     "-ti", ti,
                     "-tda", tda,
                     "-e", e,
                     "-ntt", ntt,
                     "-minLength", minLength,
                     "-maxLength", maxLength,
                     "-minCharge", minCharge,
                     "-maxCharge", maxCharge,
                     "-addFeatures", addFeatures,
                     "-maxMissedCleavages", maxMissedCleavages,
                     "-numMods", numMods,
                     sep = " ")
    
    # run command
    system(command)
}

read_mzid <- function(mzid_file) {
    mzid <- mzID::mzID(mzid_file)
    mzID::flatten(mzid)
}
