// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// filter_centroids
List filter_centroids(const NumericVector& ms2ch, const NumericVector& ms2mz, const NumericVector& ms2rt, const List& ms1, double mz_tol, double rt_range);
RcppExport SEXP _oxiquant_filter_centroids(SEXP ms2chSEXP, SEXP ms2mzSEXP, SEXP ms2rtSEXP, SEXP ms1SEXP, SEXP mz_tolSEXP, SEXP rt_rangeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const NumericVector& >::type ms2ch(ms2chSEXP);
    Rcpp::traits::input_parameter< const NumericVector& >::type ms2mz(ms2mzSEXP);
    Rcpp::traits::input_parameter< const NumericVector& >::type ms2rt(ms2rtSEXP);
    Rcpp::traits::input_parameter< const List& >::type ms1(ms1SEXP);
    Rcpp::traits::input_parameter< double >::type mz_tol(mz_tolSEXP);
    Rcpp::traits::input_parameter< double >::type rt_range(rt_rangeSEXP);
    rcpp_result_gen = Rcpp::wrap(filter_centroids(ms2ch, ms2mz, ms2rt, ms1, mz_tol, rt_range));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_oxiquant_filter_centroids", (DL_FUNC) &_oxiquant_filter_centroids, 6},
    {NULL, NULL, 0}
};

RcppExport void R_init_oxiquant(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
