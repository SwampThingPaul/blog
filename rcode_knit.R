#devtools::install_github("privefl/prettyjekyll")
setwd("D:/_GitHub/blog")
knit.clean=function(post.name){
  require(prettyjekyll)
  FormatPost(paste0("_knitr/",post.name,".Rmd"))
  file.remove(paste0("_knitr/",post.name,".html")) 
  unlink(paste0("_knitr/",post.name,"_files"),recursive=T)
  return(print(paste0("formatted ", post.name, " and cleaned")))
}


#prettyjekyll::FormatPost("_knitr/2017-06-14-old-inspiring-the-young.Rmd")
#file.remove("_knitr/2017-06-14-old-inspiring-the-young.html")

#prettyjekyll::FormatPost("_knitr/2017-08-20-TaylorSlough.Rmd")
#file.remove("_knitr/2017-08-20-TaylorSlough.html")

#prettyjekyll::FormatPost("_knitr/2017-08-23-TaylorSlough.Rmd")
#file.remove("_knitr/2017-08-23-TaylorSlough.html")

#prettyjekyll::FormatPost("_knitr/2017-09-01-Pyrite.Rmd")
#file.remove("_knitr/2017-09-01-Pyrite.html")

#prettyjekyll::FormatPost("_knitr/knitr-minimal.Rmd")
#file.remove("_knitr/knitr-minimal.html")
#knit.clean("knitr-minimal");#test new function

#prettyjekyll::FormatPost("_knitr/2018-12-21-sciart.Rmd")
#file.remove("_knitr/2018-12-21-sciart.html")

#prettyjekyll::FormatPost("_knitr/2018-12-22-rstat_map.Rmd")
#file.remove("_knitr/2018-12-22-rstat_map.html")

#prettyjekyll::FormatPost("_knitr/2019-01-04-NewYearOldMe.Rmd")
#file.remove("_knitr/2019-01-04-NewYearOldMe.html")
#knit.clean("2019-01-04-NewYearOldMe")

#prettyjekyll::FormatPost("_knitr/2019-01-16-FCELTER.Rmd")
#file.remove("_knitr/2019-01-16-FCELTER.html")

#prettyjekyll::FormatPost("_knitr/2019-01-20-RGeostat.Rmd")
#file.remove("_knitr/2019-01-20-RGeostat.html") 
#unlink("_knitr/2019-01-20-RGeostat_files",recursive=T)

#knit.clean("2019-02-12-RGeostat2")

#knit.clean("2019-05-15-NetCDF")

