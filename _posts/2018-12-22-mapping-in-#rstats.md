---
title: "Mapping in #rstats"


date: "December 22, 2018"
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> tmap, rstats, R, GIS</p>
<hr />
<p>This post was originally hosted on at my <a href="https://github.com/SwampThingPaul/rstat_mapping" target="_blank">rstat_mapping</a> GitHub repository. Where an example geodatabase with geospatial data, summary statistis (i.e. site specific annual mean total nitrogen concentration) and associated #rstats code is housed.</p>
<p><em>This post is slightly edited from the original post in the GitHub repo</em></p>
<hr />
<div id="basic-mapping-in-r" class="section level1">
<h1>Basic Mapping In R</h1>
<p>To date mapping in R has been very limited and frustrating. As many people have noted that R is not a mapping software. Its not really a geospatial analysis software however with the develope of more and more packages and the evolution of R it is quickly becoming a tool to conduct geospatial statistics and analysis. Regardless the first step in GIS is typically to produce a map.</p>
<p><a href="https://github.com/SwampThingPaul/rstat_mapping" target="_blank">This repository</a> houses a geospatial database (.gdb) assembled in ArcGIS, several comma-seperated files (.csv) and a basic R script developed for this repositiory to develop the map below.</p>
<img src="{{ site.url }}{{ site.baseurl }}\images\20181222_rstatmap\example_map.png" width="75%" style="display: block; margin: auto;" />
<center>
Map of annual mean total nitrogen concentrations from sites within the Everglades Protection Area (Southern Florida).
</center>
<p>The R-script utilizes several packages including <code>library(tmap)</code> <a href="https://github.com/mtennekes/tmap" target="_blank">github page</a> and <code>library(HatchedPolygons)</code> <a href="https://github.com/statnmap/HatchedPolygons" target="_blank">github page</a>.</p>
<p>Here is a list of libraries called for this effort (some may not be used).</p>
<pre><code>library(maptools)
library(classInt)
library(GISTools)
library(rgdal)
library(sp)
library(tmap)
library(raster)
library(spatstat)
library(sf)
library(HatchedPolygons)

library(plyr)</code></pre>
<center>
Raw code can be downloaded <a href="https://gist.githubusercontent.com/SwampThingPaul/1edf626a6a4588df62c011f2e98769f4/raw/639259006875b622f4fe9b6d2eb92ccc28de748f/rstats_mapping_libraries.r" target="_blank">here</a>.
</center>
<p>Unfortunatly at this time, the <code>tmap</code> library does not have a pattern filled option for polygons as discussed <a href="https://github.com/mtennekes/tmap/issues/49" target="_blank">here</a>. Therefore a workaround is needed, leveraging the functions in the <code>HatchedPolygons</code> library, I developed a custom helper function to make a patterned fill. The motivation of the custom function is that the <code>hatched.SpatialPolygons()</code> function does not produce a spatial data frame with a projection, therefore I added the <code>proj4string()</code> function into the custom function.</p>
<pre><code>hatched.SP=function(x,density=0.001,angle=45,fillOddEven = FALSE){
  require(HatchedPolygons)
  tmp=hatched.SpatialPolygons(x,density=density,angle=angle,fillOddEven = fillOddEven)
  proj4string(tmp)=proj4string(x)
  return(tmp)
}</code></pre>
<center>
Raw code can be downloaded <a href="https://gist.githubusercontent.com/SwampThingPaul/1edf626a6a4588df62c011f2e98769f4/raw/639259006875b622f4fe9b6d2eb92ccc28de748f/hatched_polygon.r" target="_blank">here</a>.
</center>
<hr />
<p>Since the original post/development of the GitHub repo another workaround has been developed <a href="https://github.com/mtennekes/tmap/issues/49#issuecomment-448692646" target="_blank">link</a>. <strong>Caveat:</strong> I have not tried this alternative workaround.</p>
<hr />
<p>So far after endless hours of searching I found the <code>tmap</code> library, so far the easiest I have explored for producing reproducible maps in the R-environment beyond the base package (which is equally a viable option as well). After importing and adjusting data as needed a basemap can be put together very easily using the <code>tmap</code> functionality. After setting your bounding box or “Area of Interest” you are off to the races specifying where the layers sit (like in ArcGIS), what color, line type, point type, etc. Below is from the r-script (<a href="https://github.com/SwampThingPaul/rstat_mapping/blob/6cb5b478149678830c7e9d5e09de66918623ce94/X_rstat_map.R" target="_blank">link</a>), some layers are called twice for effect.</p>
<pre><code>bbox=raster::extent(473714,587635,2748300,2960854);#Bounding box for our Area of Interest (AOI)
base.map=tm_shape(shore,bbox=bbox)+tm_polygons(col=cols[1])+
  tm_shape(eaa)+tm_fill(&quot;olivedrab1&quot;)+tm_borders(&quot;grey&quot;,lwd=1.5,lty=1.75)+
  tm_shape(spsample(eaa,&quot;random&quot;,n=500,pretty=F))+
  tm_dots(col=&quot;grey80&quot;,size=0.005)+
  tm_shape(c139)+tm_fill(&quot;grey&quot;)+
  tm_shape(sta)+tm_polygons(&quot;skyblue&quot;)+
  tm_shape(rs.feat)+tm_polygons(&quot;steelblue3&quot;)+
  tm_shape(rs.feat.hatch)+tm_lines(col=&quot;grey&quot;)+
  tm_shape(wma)+tm_borders(&quot;grey50&quot;,lwd=1.5,lty=2)+tm_fill(cols[3])+
  tm_shape(wma.hatch)+
  tm_lines(col=cols[5],lwd=2)+tm_shape(wma)+
  tm_borders(&quot;grey50&quot;,lwd=2,lty=1)+
  tm_shape(wca)+tm_fill(&quot;white&quot;)+
  tm_shape(bcnp)+tm_fill(cols[4])+
  tm_shape(enp.shore)+tm_fill(&quot;white&quot;)+tm_borders(&quot;dodgerblue3&quot;,lwd=1)+
  tm_shape(canal)+tm_lines(&quot;dodgerblue3&quot;,lwd=2)+
  tm_shape(canal)+tm_lines(cols[2],lwd=1)+
  tm_shape(evpa)+tm_borders(col=&quot;red&quot;,lwd=1.5);</code></pre>
<center>
Raw code can be downloaded <a href="https://gist.githubusercontent.com/SwampThingPaul/c272a1556f5104da5cdd9e51c8b4bca9/raw/302e2a66affa2ef9451707161e922453ef04dd1f/basemap.r" target="_blank">here</a>.
</center>
<p>Once the base map is put together to your liking, then you can layer on points, rasters, etc. very simply.</p>
<pre><code>base.map+tm_shape(TN.GM)+tm_symbol();</code></pre>
<p>Use the <code>png() ... dev.off()</code> function to write the plot to a file or use the <code>tmap_save()</code> function.</p>
<p>A complete script has been posted in this repository for your convience named <a href="https://github.com/SwampThingPaul/rstat_mapping/blob/6cb5b478149678830c7e9d5e09de66918623ce94/X_rstat_map.R">X_rstat_map.r</a>.</p>
</div>
<div id="adding-inset-maps" class="section level1">
<h1>Adding inset maps</h1>
<p>Adding an inset or regional map is sometime the go-to thing, expecially for ecological studies. This helps put the study in a regional or national context and orient people to your study area.</p>
<p>Using the exsisting <a href="https://github.com/SwampThingPaul/rstat_mapping/blob/f64c19d9c00d66986d969b4c7d2e02c9c88407fe/X_rstat_map.R" target="_blank">code</a> and data posted in this repository in conjunction with <code>Viewport()</code> in the <code>library(grid)</code> or <code>tmap_save()</code>.</p>
<img src="{{ site.url }}{{ site.baseurl }}\images\20181222_rstatmap\map_inset.png" width="75%" style="display: block; margin: auto;" />
<center>
Map of annual mean total nitrogen concentrations from sites within the Everglades Protection Area (Southern Florida) with an regional map identifying the area of interest.
</center>
<p><strong>Focused study site map.</strong></p>
<pre><code>map2=base.map+tm_shape(TN.GM)+
  tm_symbols(size=0.5,col=&quot;Geomean&quot;,breaks=c(-Inf,0.5,1,2,Inf),showNA=T,palette=cols.rmp,
             title.col=&quot;Annual Geometric \nMean TN \nConcentration (mg/L)&quot;,
             labels=c(&quot;\u003C 0.5&quot;,&quot;0.5 - 1.0&quot;,&quot;1.0 - 2.0&quot;, &quot;\u003E2.0&quot;),
             border.lwd=0.5,colorNA = &quot;white&quot;)+
  tm_compass(type=&quot;arrow&quot;,position=c(&quot;left&quot;,&quot;bottom&quot;))+
  tm_scale_bar(position=c(&quot;left&quot;,&quot;bottom&quot;))+
  tm_layout(bg.color=cols[2],fontfamily = &quot;serif&quot;,legend.outside=T,scale=1,asp=NA,
            outer.margins=c(0.005,0.01,0.005,0.01),inner.margins = 0,between.margin=0,
            legend.text.size=1,legend.title.size=1.25)</code></pre>
<p>Essentially a second regional map is needed for the inset and adding a polygon showing the extent of the larger map. To make the larger map extent polygon you can leverage the <code>bbox</code> of the larger map.</p>
<pre><code>bbox.poly=as(bbox,&quot;SpatialPolygons&quot;)#makes the polygon
proj4string(bbox.poly)=proj4string(evpa)#projects the polygon

#the smaller basic regional map
region.map=tm_shape(shore)+tm_polygons(col=cols[1])+
  tm_shape(bbox.poly)+tm_borders(lty=2,lwd=2.5,&quot;red&quot;)</code></pre>
<p>To view and see how things fits together you can use the <code>Viewport()</code> function, granted its tricky to move things around since the units Normalised Parent Coordinates“npc”.</p>
<pre><code>map2
print(region.map,vp=viewport(0.82,0.29,0.3,0.60,just=&quot;right&quot;))</code></pre>
<p>Once you are happy with the results, you need to use the <code>tmap_save()</code> function to write the map to a file.</p>
<pre><code>tmap_save(map2,&quot;example.png&quot;,width = 6.5,height=7,units=&quot;in&quot;,dpi=200,
  insets_tm=region.map,insets_vp =viewport(0.94,0.21,0.3,0.60,just=&quot;right&quot;) )</code></pre>
<hr />
<center>
Happy Mapping
</center>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}\images\20181222_rstatmap\gis-header-s.jpg" alt="image from [source](https://fra.me/gis)" width="25%" />
<p class="caption">
image from <a href="https://fra.me/gis">source</a>
</p>
</div>
<p><br></p>
</div>
</section>
