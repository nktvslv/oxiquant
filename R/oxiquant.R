#' A pipeline to execute label-free based quantitation of intact and oxidized peptides
#'
#' @param msgf Run MS-GF+ MS2 search engine, logical, default = FALSE.
#' @param process_ms1 Run mzcharge for MS1 data processing, logical, default = FALSE.
#' @param extract_ion_current Extract ion current for intact and oxidized peptides, logical, default = TRUE.
#'
#' @return oxiquant saves tables in Global Environment for interactive use and
#' writes corresponding CVS files in working directory
#' @export
#' @import data.table
#' @import future
#' @import future.apply
#' @importFrom parallel detectCores
#'
oxiquant <- function(msgf = FALSE,
                     process_ms1 = FALSE,
                     extract_ion_current = TRUE) {

  # set multicore processing for data.table
  setDTthreads(threads = 0)
  
  # set multicore processing for future.apply
  plan(multisession, workers = parallel::detectCores())

  if (msgf) {

    # check if mzml files are in the directory
    mzml_files <- list.files(pattern = "\\.mzML$")
    if (length(mzml_files) == 0) {
      stop("No mzML files found in current directory")
    }

    # check if fasta files are present in the directory
    if (length(list.files(pattern = "\\.fasta$")) == 0) {
      stop("No fasta files found in current directory")
    }

    # remove _proteins files created with previous msgf run
    file.remove(list.files(pattern = "^\\_proteins"))

    # combine fasta files in current directory
    fasta_files <- list.files(pattern = "\\.fasta$")
    fasta_records <- paste0(unlist(mapply(FUN = readChar,
                                          fasta_files, file.size(fasta_files),
                                          SIMPLIFY = F)), collapse = "\n")
    writeChar(object = fasta_records, con = "_proteins.fasta")

    # make sure _modifications.txt file for msgf is present
    if (!file.exists("_modifications.txt")) {
      file.copy(from = file.path(path.package("oxiquant"), "_modifications.txt"),
                to = ".")
    }

    # run msgf with input mzml files
    lapply(X = mzml_files, FUN = run_msgf)
  }

  if (process_ms1) {

    # check if mzml files are in the directory
    mzml_files <- list.files(pattern = "\\.mzML$")
    if (length(mzml_files) == 0) {
      stop("No mzML files found in current directory")
    }

    # run mzcharge for mzml files
    lapply(X = mzml_files, FUN = extract_ms1)
  }

  if (extract_ion_current) {

    # read and process psms
    print("reading and filtering psms")
    psms_files <- list.files(pattern = "\\.mzid$")
    if (length(psms_files) == 0) {
      stop("No mzid files found in working directory")
    }
    psms <- rbindlist(future_lapply(X = psms_files, FUN = read_mzid))
    fwrite(x = psms, file = "psms_all.csv") # write all unfiltered psms
    .GlobalEnv$psms_all <- psms

    # filter psms and calculate mz for oxidized versions
    oxi_mass <- 15.99491
    qval <- getOption("psms.qval", 0.01)
    num_oxi <- getOption("psms.num_oxi", 3L)
    psms <- psms[!isdecoy & !grepl("15\\.99|31\\.98|47\\.98", modification) & `ms-gf:qvalue` < qval]
    psms[,`:=`(ms2ioncurrent = as.numeric(ms2ioncurrent),
               isotopeerror = as.numeric(isotopeerror))]
    psms[,experimentalmasstocharge := experimentalmasstocharge - isotopeerror / chargestate]
    psms <- psms[, .(ms2mz = median(experimentalmasstocharge),
                     ms2rt = weighted.mean(x = `scan start time`, w = ms2ioncurrent)),
                 by = .(accession, description, start, end, pepseq, chargestate, modification)]
    psms <- psms[rep(1:.N, each = num_oxi + 1)]
    psms[,n_oxi := 0:num_oxi,
         by = .(accession, description, start, end, pepseq, chargestate, modification)]
    psms[,ms2mz := ms2mz + n_oxi * oxi_mass / chargestate]

    # save psms to global env and on disk
    fwrite(x = psms, file = "psms.csv")
    .GlobalEnv$psms <- psms

    # extract ion current for psms from ms1.csv files
    ms1_files <- list.files(pattern = "\\.ms1\\.csv$")
    if (length(ms1_files) == 0) {
      stop("No ms1.csv files found in working directory")
    }

    # function to extract ms1 signal from .ms1.csv files
    find_ms1 <- function(ms1file) {

      print(paste("extracting ion current from", ms1file))

      # parameters for ms1 filtering
      min_charge <- getOption("xic.min_charge", 1L)
      max_charge <- getOption("xic.max_charge", 8L)
      mz_tol <- getOption("xic.mz_tol", 10.0)
      rt_range <- getOption("xic.rt_range", 6.0)

      # filter ms1 by charge and monoisotopic peak
      ms1 <- fread(ms1file)
      ms1 <- ms1[charge >= min_charge & charge <= max_charge] 

      # function to match psms charge, mz and rt to ms1 centroids
      # filter_centroids <- function(ms2ch, ms2mz, ms2rt, mz_tol, rt_range) {
      #   ms1[charge == ms2ch &
      #         abs(mz - ms2mz) / (mz + ms2mz) * 2e6 < mz_tol &
      #         abs(retention_time - ms2rt) < rt_range]
      # }

      # extract ion current for each psms
      # peptides <- psms[,intensity := future_mapply(FUN = filter_centroids,
      #                                       chargestate, ms2mz, ms2rt,
      #                                       MoreArgs = list(ms1, mz_tol, rt_range),
      #                                       USE.NAMES = T, SIMPLIFY = F)]
      
      peptides <- psms[,intensity := filter_centroids(chargestate,
                                                      ms2mz, ms2rt,
                                                      ms1, mz_tol, rt_range)]
      
      psms[,intensity := lapply(intensity, as.data.table)]

      # unnest ms1 data
      peptides <- tidyr::unnest(peptides, intensity)

      # return
      as.data.table(peptides)
    }

    # run find_ms1 for each .ms1.csv file in working directory
    peptides <- rbindlist(lapply(X = ms1_files, FUN = find_ms1))

    # calculated mz errors and remove duplicates
    peptides[,mz_err := abs(mz - ms2mz) / (mz + ms2mz) * 2e6]
    peptides <- peptides[peptides[,.I[which.min(mz_err)], by=.(uid, ms1file)]$V1]

    # save all found scans to global env
    .GlobalEnv$peptides_all <- peptides

    # filter by number of scans and max allowed gap
    min_scans <- getOption("xic.min_scans", 5L)
    max_gap <- getOption("xic.max_gap", 1L)
    peptides[,ms1left_gap := scan_order - shift(scan_order, type = "lag", fill = NA_real_) - 1,
             by = .(accession, description, start, end, pepseq, chargestate, modification, n_oxi, ms1file)]
    peptides[,ms1right_gap := shift(scan_order, type = "lead", fill = NA_real_) - scan_order - 1,
             by = .(accession, description, start, end, pepseq, chargestate, modification, n_oxi, ms1file)]
    peptides <- peptides[ms1left_gap <= max_gap | ms1right_gap <= max_gap]
    peptides <- peptides[peptides[,.I[.N >= min_scans],
                                  by = .(accession, description, start, end, pepseq, chargestate, modification, n_oxi, ms1file)]$V1]

    # find peak of elution for unoxidized peptides
    setorder(peptides, retention_time)

    peptides[n_oxi == 0, cumint := cumsum(intensity),
             by = .(accession, description, start, end, pepseq, chargestate, modification, n_oxi, ms1file)]

    peptides[n_oxi == 0, cumfrc := cumint / max(cumint, na.rm = TRUE),
             by = .(accession, description, start, end, pepseq, chargestate, modification, n_oxi, ms1file)]

    peptides[n_oxi == 0 & cumfrc > 0.2 & cumfrc < 0.8,
             int_rank := rank(x = -intensity),
             by = .(accession, description, start, end, pepseq, chargestate, modification, n_oxi, ms1file)]

    peptides[n_oxi == 0 & cumfrc > 0.2 & cumfrc < 0.8 & int_rank <= 5,
             ms1peak := weighted.mean(x = retention_time, y = intensity),
             by = .(accession, description, start, end, pepseq, chargestate, modification, n_oxi, ms1file)]

    peptides[, ms1peak := mean(ms1peak, na.rm = TRUE),
             by = .(accession, description, start, end, pepseq, chargestate, modification, ms1file)]

    # keep centroids around peak of elution -/+ left and right thresholds
    rt_left <- getOption("xic.rt_left", 0.5)
    rt_right <- getOption("xic.rt_right", 0.5)
    peptides <- peptides[(retention_time > (ms1peak - rt_left)) & (retention_time < (ms1peak + rt_right))]

    # save quantified peptides on disk and in global env
    fwrite(x = peptides, file = "peptides.csv")
    .GlobalEnv$peptides <- peptides

    # calculate fraction of oxidation for peptides
    fractions <- peptides[,.(intensity = sum(intensity)),
                          by = .(accession, description, start, end, pepseq, chargestate, n_oxi, modification, ms1file)]
    fractions <- fractions[,.(fraction = sum(intensity * n_oxi) / sum(intensity),
                              intensity = sum(intensity)),
                           by = .(accession, description, start, end, pepseq, chargestate, modification, ms1file)]

    # save fractions on disk and in global env
    fwrite(x = fractions, file = "fractions.csv")
    .GlobalEnv$fractions <- fractions

  }
}
