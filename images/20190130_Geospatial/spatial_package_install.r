
packs=c("sp","rgdal","gstat","raster","spatstat","maptools","rgeos","tmap","GISTools","rasterVis")

for(i in 1:length(packs)){
  test=packs[i] %in% rownames(installed.packages())
  if(test==T){print("package already installed")}else{install.packages(packs[i])}
}