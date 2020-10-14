#' \code{oxiquant} package
#' 
#' Automated analysis of mass spectrometry data collected during hydroxyl
#' radical footprinting experiment
#' 
#' @docType package
#' @name oxiquant
#' @import Rcpp
#' @useDynLib oxiquant
#' 
#' 
utils::globalVariables(c("uid","ms1file","psms_all","isdecoy","modification",
                         "ms-gf:qvalue","ms2ioncurrent","isotopeerror",
                         "experimentalmasstocharge","calculatedmasstocharge",
                         "chargestate",".",
                         "median","weighted.mean","scan start time","accession",
                         "description","start","end","pepseq","n_oxi","ms2mz",
                         "charge","mz","retention_time","intensity","ms2rt",
                         "mz_err","peptides_all","ms1left_gap","ms1right_gap",
                         "scan_order","cumint","cumfrc","int_rank","ms1peak"))