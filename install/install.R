#~/user/bin/env Rscript

list.of.packages <- c("renv", "here", "devtools", "rmarkdown", "bitops", "caTools", "packrat")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos='http://cran.us.r-project.org')

# install tinytex #159
install.packages('tinytex', repos='http://cran.us.r-project.org')
tinytex::install_tinytex()
# to uninstall TinyTeX, run tinytex::uninstall_tinytex() 

