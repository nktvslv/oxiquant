#include <Rcpp.h>

using namespace Rcpp;

// [[Rcpp::export]]
List filter_centroids(int ms2ch, double ms2mz, double ms2rt,
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
    
    // conditions
    double mz_min = ms2mz - mz_tol * ms2mz / 1e6;
    double mz_max = ms2mz + mz_tol * ms2mz / 1e6;
    double rt_min = ms2rt - rt_range;
    double rt_max = ms2rt + rt_range;
    
    // looping through vectors and constructing new vectors with filtered data
    int data_size = charge.size();
    
    std::vector<double> mzf; mzf.reserve(data_size); 
    std::vector<int> chargef; chargef.reserve(data_size); 
    std::vector<double> retention_timef; retention_timef.reserve(data_size); 
    std::vector<int> acquisition_numf; acquisition_numf.reserve(data_size); 
    std::vector<int> scan_orderf; scan_orderf.reserve(data_size); 
    std::vector<double> intensityf; intensityf.reserve(data_size); 
    std::vector<int> uidf; uidf.reserve(data_size); 
    std::vector<std::string> ms1filef; ms1filef.reserve(data_size);
    
    for (int i = 0; i < data_size; ++i) {
        
        if (charge[i] == ms2ch & mz[i] > mz_min & mz[i] < mz_max &
            retention_time[i] > rt_min & retention_time[i] < rt_max) {
            
            mzf.emplace_back(mz[i]);
            chargef.emplace_back(charge[i]);
            retention_timef.emplace_back(retention_time[i]);
            acquisition_numf.emplace_back(acquisition_num[i]);
            scan_orderf.emplace_back(scan_order[i]);
            intensityf.emplace_back(intensity[i]);
            uidf.emplace_back(uid[i]);
            ms1filef.emplace_back(ms1file[i]);
        }
    }
    
    return List::create(_["mz"] = mzf,
                        _["charge"] = chargef,
                        _["retention_time"] = retention_timef,
                        _["acquisition_num"] = acquisition_numf,
                        _["scan_order"] = scan_orderf,
                        _["intensity"] = intensityf,
                        _["uid"] = uidf,
                        _["ms1file"] = ms1filef);
}