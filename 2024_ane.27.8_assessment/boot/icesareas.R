# download ICES areas shapefiles
# taken from https://github.com/ices-taf/doc/wiki/Example-data-records

filename <- "ICES_areas.zip"
# download and unzip
download(paste0("http://gis.ices.dk/shapefiles/", filename))
unzip(filename)
# delete zip file
unlink(filename)