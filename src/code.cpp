#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
List filter_centroids(const NumericVector& ms2ch, const NumericVector& ms2mz,
                      const NumericVector& ms2rt,
                      const List& ms1, double mz_tol, double rt_range) {
    
    // split ms1 data into individual vectors
    std::vector<double> mz = ms1["mz"];
    std::vector<int> charge = ms1["charge"];
    std::vector<double> retention_time = ms1["retention_time"];
    std::vector<int> acquisition_num = ms1["acquisition_num"];
    std::vector<int> scan_order = ms1["scan_order"];
    std::vector<double> intensity = ms1["intensity"];
    std::vector<int> uid = ms1["uid"];
    std::vector<std::string> ms1file = ms1["ms1file"];
    
    // iterate over ms2 data and add filtered ms1 data into List "out"
    
    List out;
    
    for (int i = 0; i < ms2ch.size(); ++i) {
        
        // conditions
        double mz_min = ms2mz[i] - mz_tol * ms2mz[i] / 1e6;
        double mz_max = ms2mz[i] + mz_tol * ms2mz[i] / 1e6;
        double rt_min = ms2rt[i] - rt_range;
        double rt_max = ms2rt[i] + rt_range;
        
        // loop through ms1 vectors and constructing new vectors with filtered data
        int data_size = charge.size();
        
        std::vector<double> mzf; mzf.reserve(data_size); 
        std::vector<int> chargef; chargef.reserve(data_size); 
        std::vector<double> retention_timef; retention_timef.reserve(data_size); 
        std::vector<int> acquisition_numf; acquisition_numf.reserve(data_size); 
        std::vector<int> scan_orderf; scan_orderf.reserve(data_size); 
        std::vector<double> intensityf; intensityf.reserve(data_size); 
        std::vector<int> uidf; uidf.reserve(data_size); 
        std::vector<std::string> ms1filef; ms1filef.reserve(data_size);
        
        for (int j = 0; j < data_size; ++j) {
            
            if (charge[j] == ms2ch[i] && mz[j] > mz_min && mz[j] < mz_max &&
                retention_time[j] > rt_min && retention_time[j] < rt_max) {
                
                mzf.emplace_back(mz[j]);
                chargef.emplace_back(charge[j]);
                retention_timef.emplace_back(retention_time[j]);
                acquisition_numf.emplace_back(acquisition_num[j]);
                scan_orderf.emplace_back(scan_order[j]);
                intensityf.emplace_back(intensity[j]);
                uidf.emplace_back(uid[j]);
                ms1filef.emplace_back(ms1file[j]);
            }
        }
        
        out.push_back(List::create(_["mz"] = mzf,
                                   _["charge"] = chargef,
                                   _["retention_time"] = retention_timef,
                                   _["acquisition_num"] = acquisition_numf,
                                   _["scan_order"] = scan_orderf,
                                   _["intensity"] = intensityf,
                                   _["uid"] = uidf,
                                   _["ms1file"] = ms1filef));
    }
    
    return out;
}