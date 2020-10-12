unnest_dt <- function(dt, col) {
    
    # check if only one column provided
    if (length(col) != 1L) {
        stop("unnest can work with only one column")
    }
    
    # check if column is list
    if (typeof(dt[[col]]) != "list") {
        stop("column ", col, " is not of a type list.")
    }
    
    cols <- setdiff(names(dt), col)
    
    rbindlist(mapply(cbind,
                     split(dt[,.SD, .SDcols = names(dt) %in% cols], by = cols),
                     lapply(dt[[col]], as.data.table),
                     SIMPLIFY = F),
              fill = TRUE)
}