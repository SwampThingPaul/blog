---
title: "Geospatial data analysis in #rstats. Part 1"


date: "January 20, 2019"
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> kriging, geostatistics, ArcGIS, R, soil science</p>
<hr />
<p>Many (many) years ago after graduating from undergrad I was introduced to geographical information systems (GIS) at the time, ArcInfo developed by <a href="https://www.esri.com/en-us/home">ESRI</a> was the leading software to develop, visualize and analyse geospatial data (and generally still is). I quickly took to learning the “ins” and “outs” of this software burrowing and begging for licenses to feed my desire to learn GIS. Eventually I moved onto my masters degree where I was able to apply a lot of what I learned. Throughout my career I have had an ESRI icon on my desktop. But it wasn’t until I started to learn <a href="https://cran.r-project.org/">R</a> that I began to see some of the downfalls of the this iconic software. Yes, ArcGIS and its cousins (<a href="https://grass.osgeo.org/">GRASS</a> and <a href="https://qgis.org/en/site/">QGIS</a>) are valuable, powerful and irreplaceable analytical tools…no question. Something you learn with R is reproducibility and easily tracking what you have done. In spreadsheets (i.e. excel) it tough to find out what cells are calculated and how, in R its all in front of you. In ArcGIS there are countless steps (and clicks) to read in data, project, transform, clip, interpolate, reformat, export, plot, extract data etc. Unless you are a <a href="https://www.python.org/">python</a> wizard, most of this is reliant on your ability to remember/document the steps necessary to go from raw data to final product in ArcGIS. Reproducibility in data analysis is essential which is why I turned to conducting geospatial analyses in R. Additionally, typing and executing commands in the R console, in many cases is faster and more efficient than pointing-and-clicking around the graphical user interface (GUI) of a desktop GIS.</p>
<p>Thankfully, the R community has contributed tremendously to expand R’s ability to conduct spatial analyses by integrating tools from geography, geoinformatics, geocomputation and spatial statistics. R’s wide range of spatial capabilities would never have evolved without people willing to share what they were creating or adapting (<a href="https://geocompr.robinlovelace.net/" target="_blank">Lovelace et al 2019</a>). There are countless other books r-connect pages, blogs, white papers, etc. dedicated to analyzing, modeling and visualizing geospatial data. I implore you to explore the web for these resources as this blog post is not the one stop shop for info.</p>
<div id="brass-tacks" class="section level1">
<h1><a href="https://en.wiktionary.org/wiki/get_down_to_brass_tacks" target="_blank">Brass Tacks</a></h1>
<p>Geospatial analysis may sound daunting but I will walk you through reading, writing, plotting and analyzing geospatial data. In a prior <a href="https://swampthingpaul.github.io/blog/mapping-in-rstats/" target="_blank">blog post</a> I outlined some basic mapping in R using the <a href="https://github.com/mtennekes/tmap" target="_blank"><code>tmap</code></a> package. I will continue to use <code>tmap</code> to visualize the data spatially.</p>
<p>Let start by loading the necessary (and some unnecessary) R-packages. If you missing any of the “GIS Libraries” identified below use this <a href="https://gist.github.com/SwampThingPaul/d37b222e4fa0f9b72d247c9c79e5b7fd" target="_blank">script</a> to install them, if a package is already installed it will skip and move to next.</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" data-line-number="1"><span class="co">#Libraries</span></a>
<a class="sourceLine" id="cb1-2" data-line-number="2"><span class="kw">library</span>(plyr)</a>
<a class="sourceLine" id="cb1-3" data-line-number="3"><span class="kw">library</span>(reshape)</a>
<a class="sourceLine" id="cb1-4" data-line-number="4"><span class="kw">library</span>(openxlsx)</a>
<a class="sourceLine" id="cb1-5" data-line-number="5"><span class="kw">library</span>(vegan)</a>
<a class="sourceLine" id="cb1-6" data-line-number="6"><span class="kw">library</span>(goeveg);</a>
<a class="sourceLine" id="cb1-7" data-line-number="7"><span class="kw">library</span>(MASS)</a>
<a class="sourceLine" id="cb1-8" data-line-number="8"></a>
<a class="sourceLine" id="cb1-9" data-line-number="9">##GIS Libraries</a>
<a class="sourceLine" id="cb1-10" data-line-number="10"><span class="kw">library</span>(sp)</a>
<a class="sourceLine" id="cb1-11" data-line-number="11"><span class="kw">library</span>(rgdal)</a>
<a class="sourceLine" id="cb1-12" data-line-number="12"><span class="kw">library</span>(gstat)</a>
<a class="sourceLine" id="cb1-13" data-line-number="13"><span class="kw">library</span>(raster)</a>
<a class="sourceLine" id="cb1-14" data-line-number="14"><span class="kw">library</span>(spatstat)</a>
<a class="sourceLine" id="cb1-15" data-line-number="15"><span class="kw">library</span>(maptools)</a>
<a class="sourceLine" id="cb1-16" data-line-number="16"><span class="kw">library</span>(rgeos)</a>
<a class="sourceLine" id="cb1-17" data-line-number="17"><span class="kw">library</span>(spdep)</a>
<a class="sourceLine" id="cb1-18" data-line-number="18"><span class="kw">library</span>(spsurvey)</a>
<a class="sourceLine" id="cb1-19" data-line-number="19"></a>
<a class="sourceLine" id="cb1-20" data-line-number="20"><span class="kw">library</span>(tmap)</a>
<a class="sourceLine" id="cb1-21" data-line-number="21"><span class="kw">library</span>(GISTools)</a>
<a class="sourceLine" id="cb1-22" data-line-number="22"><span class="kw">library</span>(rasterVis)</a></code></pre></div>
<p><strong><em>For purposes of this exercise I will be using real stations but fake data randomly generated with an imposed spatial gradient for demonstration purposes.</em></strong></p>
<div id="reading" class="section level2">
<h2>Reading</h2>
<p>To read shapefiles such as ESRI <code>.shp</code> files into R you can use the <code>readOGR</code> function in the <code>rgdal</code> library. Feel free to get familiar with with function by typing <code>?readOGR</code> into the R console. Every time I read a spatial dataset into R I also check the projection using <code>attributes(sp.data)$proj4string</code> to make sure all my spatial data is in the same project. If necessary re-projection of the data is easy.</p>
<div class="sourceCode" id="cb2"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb2-1" data-line-number="1">sp.dat=<span class="kw">readOGR</span>(<span class="dt">dsn=</span><span class="st">&quot;.../data path/spatial data&quot;</span>,<span class="dt">layer=</span><span class="st">&quot;SampleSites&quot;</span>)</a>
<a class="sourceLine" id="cb2-2" data-line-number="2"><span class="kw">attributes</span>(sp.data)<span class="op">$</span>proj4string</a></code></pre></div>
<p>If you have raw data file, like say from a GPS or a random excel file with lat/longs read in the file like you normally do using <code>read.csv()</code> or <code>openxlsx::read.xlsx()</code> and apply the necessary projection. Here is a great lesson on coordinate reference system with some R-code (<a href="https://www.earthdatascience.org/courses/earth-analytics/spatial-data-r/intro-to-coordinate-reference-systems/" target="_blank">link</a>) and some additional <a href="https://rspatial.org/spatial/6-crs.html?highlight=coordinates#" target="_blank">information</a> in-case you are unfamiliar with CRS and how it applies.</p>
<div class="sourceCode" id="cb3"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb3-1" data-line-number="1">loc.dat.raw=<span class="kw">read.csv</span>(loc_data.csv)</a></code></pre></div>
<div class="sourceCode" id="cb4"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb4-1" data-line-number="1"><span class="kw">head</span>(loc.dat.raw,2L)</a></code></pre></div>
<pre><code>##       UTMX    UTMY
## 1 541130.5 2813700
## 2 541149.1 2813224</code></pre>
<div class="sourceCode" id="cb6"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb6-1" data-line-number="1">proj.data=<span class="kw">CRS</span>(<span class="st">&quot;+proj=utm +zone=17 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0&quot;</span>) </a>
<a class="sourceLine" id="cb6-2" data-line-number="2"></a>
<a class="sourceLine" id="cb6-3" data-line-number="3">loc.dat.raw=<span class="kw">SpatialPointsDataFrame</span>(<span class="dt">coords=</span>loc.dat.raw[,<span class="kw">c</span>(<span class="st">&quot;UTMX&quot;</span>,<span class="st">&quot;UTMY&quot;</span>)],</a>
<a class="sourceLine" id="cb6-4" data-line-number="4">                                   <span class="dt">data=</span>loc.dat.raw,</a>
<a class="sourceLine" id="cb6-5" data-line-number="5">                                   <span class="dt">proj4string =</span> proj.data)</a></code></pre></div>
<p>It always good to take a look at the data spatially before moving forward to ensure the data is correct. You can use the <code>plot</code> function for a quick look at the data.</p>
<div class="sourceCode" id="cb7"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb7-1" data-line-number="1"><span class="kw">plot</span>(sp.dat,<span class="dt">pch=</span><span class="dv">21</span>)</a></code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/quick%20plot-1.png" style="display: block; margin: auto;" /></p>
</div>
<div id="interpolations" class="section level2">
<h2>Interpolations</h2>
<p><strong><em>This section is modeled from <a href="https://mgimond.github.io/Spatial/spatial-interpolation.html" target="_blank">Chapter 14</a> of <a href="https://mgimond.github.io/Spatial/index.html" target="_blank">Gimond (2018)</a>.</em></strong></p>
<div id="proximity-thessian" class="section level3">
<h3>Proximity (Thessian)</h3>
<p>The most basic and simplest interpolation is proximity interpolation, where thiessen polygons are drawn based on the existing monitoring network to approximate all unsampled locations. This process generates a tessellated surface whereby lines that split the midpoint between each sampled location are connected. One obvious issue with this approach is that values can change abruptly between tessellated boundaries and may not accurately represent <em>in-situ</em> conditions.</p>
<p>Despite these downfalls, lets create a thessian polygon and see how the data looks. Using the <code>dirichlet()</code> function, we can create a tessellated surface very easily unfortunately it is not spatially explicit (i.e. doesn’t have a CRS). Also the surface extends beyond the study area, so it will need to be clipped to the extent of the study area (a separate shapefile). R-scripts can be found at this <a href="https://gist.github.com/SwampThingPaul/0398073092ba337bf86862a6e1d6d45d" target="_blank">link</a>.</p>
<div class="sourceCode" id="cb8"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb8-1" data-line-number="1"><span class="co"># Generate Thessian polygon and assign CRS</span></a>
<a class="sourceLine" id="cb8-2" data-line-number="2">th=<span class="kw">as</span>(<span class="kw">dirichlet</span>(<span class="kw">as.ppp</span>(sp.dat)),<span class="st">&quot;SpatialPolygons&quot;</span>)</a>
<a class="sourceLine" id="cb8-3" data-line-number="3"><span class="kw">proj4string</span>(th)=<span class="kw">proj4string</span>(sp.dat)</a>
<a class="sourceLine" id="cb8-4" data-line-number="4"></a>
<a class="sourceLine" id="cb8-5" data-line-number="5"><span class="co"># Join thessian polygon with actual data</span></a>
<a class="sourceLine" id="cb8-6" data-line-number="6">th.z=<span class="kw">over</span>(th,sp.dat)</a>
<a class="sourceLine" id="cb8-7" data-line-number="7"></a>
<a class="sourceLine" id="cb8-8" data-line-number="8"><span class="co"># Convert to a spatial polygon</span></a>
<a class="sourceLine" id="cb8-9" data-line-number="9">th.spdf=<span class="kw">SpatialPolygonsDataFrame</span>(th,th.z)</a>
<a class="sourceLine" id="cb8-10" data-line-number="10"></a>
<a class="sourceLine" id="cb8-11" data-line-number="11"><span class="co"># Clip to study area</span></a>
<a class="sourceLine" id="cb8-12" data-line-number="12">th.clp=raster<span class="op">::</span><span class="kw">intersect</span>(study.area,th.spdf)</a></code></pre></div>
<div class="sourceCode" id="cb9"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb9-1" data-line-number="1">## Alternative method </a>
<a class="sourceLine" id="cb9-2" data-line-number="2">## some have run into issues with dirichlet()</a>
<a class="sourceLine" id="cb9-3" data-line-number="3">bbox.study.area=<span class="kw">bbox</span>(study.area)</a>
<a class="sourceLine" id="cb9-4" data-line-number="4"></a>
<a class="sourceLine" id="cb9-5" data-line-number="5">bbox.da=<span class="kw">c</span>(bbox.study.area[<span class="dv">1</span>,<span class="dv">1</span><span class="op">:</span><span class="dv">2</span>],bbox.study.area[<span class="dv">2</span>,<span class="dv">1</span><span class="op">:</span><span class="dv">2</span>])</a>
<a class="sourceLine" id="cb9-6" data-line-number="6">th=dismo<span class="op">::</span><span class="kw">voronoi</span>(sp.dat,<span class="dt">ext=</span>bbox.da)</a>
<a class="sourceLine" id="cb9-7" data-line-number="7">th.z=sp<span class="op">::</span><span class="kw">over</span>(th,sp.dat)</a>
<a class="sourceLine" id="cb9-8" data-line-number="8">th.z.spdf=sp<span class="op">::</span><span class="kw">SpatialPolygonsDataFrame</span>(th,th.z)</a>
<a class="sourceLine" id="cb9-9" data-line-number="9">th.clp=raster<span class="op">::</span><span class="kw">intersect</span>(study.area,th.z.spdf)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/thessian%20plot-1.png" alt="**Left:** All sampling points within the study area. **Middle:** Thessian polyon for all sampling locations. **Right:** Thessian polygons clipped to study area."  />
<p class="caption">
<strong>Left:</strong> All sampling points within the study area. <strong>Middle:</strong> Thessian polyon for all sampling locations. <strong>Right:</strong> Thessian polygons clipped to study area.
</p>
</div>
<p>As you can see sampling density can significantly affect how the thessian plots an thus representation of the data. Sampling density can also affect other spatial analyses (i.e. spatial auto-correlation) as well.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/thessian%20data%20plot-1.png" alt="Soil Total Phosphorus concentration (**NOT REAL DATA**)"  />
<p class="caption">
Soil Total Phosphorus concentration (<strong>NOT REAL DATA</strong>)
</p>
</div>
<p>Ok, so now you have a spatial estimate of data across your sampling area/study site, now what? We can determine how much of the area is above or below a particular threshold by constructing a cumulative distribution function (cdf) with the data. Using the <code>cont.analysis</code> function in the <code>spsurvey</code> package we can generate the cdf.</p>
<div class="sourceCode" id="cb10"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb10-1" data-line-number="1"><span class="co"># Determine the area for each polygon </span></a>
<a class="sourceLine" id="cb10-2" data-line-number="2"><span class="co">#(double check coordinate system, the data is currently in UTM measured in meters)</span></a>
<a class="sourceLine" id="cb10-3" data-line-number="3">th.clp<span class="op">$</span>area_sqkm=rgeos<span class="op">::</span><span class="kw">gArea</span>(th.clp,<span class="dt">byid=</span>T)<span class="op">*</span><span class="fl">1e-6</span></a>
<a class="sourceLine" id="cb10-4" data-line-number="4"></a>
<a class="sourceLine" id="cb10-5" data-line-number="5"><span class="co">#remove any NA&#39;s in the data</span></a>
<a class="sourceLine" id="cb10-6" data-line-number="6">th.clp=<span class="st"> </span><span class="kw">subset</span>(th.clp,<span class="kw">is.na</span>(TP_mgkg)<span class="op">==</span>F)</a>
<a class="sourceLine" id="cb10-7" data-line-number="7"></a>
<a class="sourceLine" id="cb10-8" data-line-number="8"><span class="co">#extracts data frame from the spatial data</span></a>
<a class="sourceLine" id="cb10-9" data-line-number="9">cdf.area=<span class="kw">data.frame</span>(th.clp<span class="op">@</span>data)</a>
<a class="sourceLine" id="cb10-10" data-line-number="10"></a>
<a class="sourceLine" id="cb10-11" data-line-number="11">Sites=<span class="kw">data.frame</span>(<span class="dt">siteID=</span>cdf.area<span class="op">$</span>Site,<span class="dt">Use=</span><span class="kw">rep</span>(<span class="ot">TRUE</span>, <span class="kw">nrow</span>(cdf.area)))</a>
<a class="sourceLine" id="cb10-12" data-line-number="12">Subpop=<span class="kw">data.frame</span>(<span class="dt">siteID=</span>cdf.area<span class="op">$</span>Site,<span class="dt">Area=</span>cdf.area<span class="op">$</span>area_sqkm)</a>
<a class="sourceLine" id="cb10-13" data-line-number="13">Design=<span class="kw">data.frame</span>(<span class="dt">siteID=</span>cdf.area<span class="op">$</span>Site,<span class="dt">wgt=</span>cdf.area<span class="op">$</span>area_sqkm)</a>
<a class="sourceLine" id="cb10-14" data-line-number="14">Data.TP=<span class="kw">data.frame</span>(<span class="dt">siteID=</span>cdf.area<span class="op">$</span>Site,<span class="dt">TP=</span>cdf.area<span class="op">$</span>TP_mgkg)</a>
<a class="sourceLine" id="cb10-15" data-line-number="15"></a>
<a class="sourceLine" id="cb10-16" data-line-number="16">cdf.estimate=<span class="kw">cont.analysis</span>(<span class="dt">sites=</span>Sites,</a>
<a class="sourceLine" id="cb10-17" data-line-number="17">                           <span class="dt">design=</span>Design,</a>
<a class="sourceLine" id="cb10-18" data-line-number="18">                           <span class="dt">data.cont=</span>Data.TP,</a>
<a class="sourceLine" id="cb10-19" data-line-number="19">                           <span class="dt">vartype=</span><span class="st">&#39;SRS&#39;</span>,</a>
<a class="sourceLine" id="cb10-20" data-line-number="20">                           <span class="dt">pctval =</span> <span class="kw">seq</span>(<span class="dv">0</span>,<span class="dv">100</span>,<span class="fl">0.5</span>));</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/cdf%20plot-1.png" alt="Cumulative distribution function (± 95% CI) of soil total phosphorus concentration (**NOT REAL DATA**) across the study area"  />
<p class="caption">
Cumulative distribution function (± 95% CI) of soil total phosphorus concentration (<strong>NOT REAL DATA</strong>) across the study area
</p>
</div>
<p>Now we can determine how much area is above/below a particular concentration.</p>
<div class="sourceCode" id="cb11"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb11-1" data-line-number="1">cdf.data=cdf.estimate<span class="op">$</span>CDF</a>
<a class="sourceLine" id="cb11-2" data-line-number="2"></a>
<a class="sourceLine" id="cb11-3" data-line-number="3">threshold=<span class="dv">500</span>; <span class="co">#Soil TP threshold in mg/kg</span></a>
<a class="sourceLine" id="cb11-4" data-line-number="4"></a>
<a class="sourceLine" id="cb11-5" data-line-number="5">result=<span class="kw">min</span>(<span class="kw">subset</span>(cdf.data,Value<span class="op">&gt;</span><span class="dv">500</span>)<span class="op">$</span>Estimate.P)</a>
<a class="sourceLine" id="cb11-6" data-line-number="6">low.CI=<span class="kw">min</span>(<span class="kw">subset</span>(cdf.data,Value<span class="op">&gt;</span><span class="dv">500</span>)<span class="op">$</span>LCB95Pct.P)</a>
<a class="sourceLine" id="cb11-7" data-line-number="7">up.CI=<span class="kw">min</span>(<span class="kw">subset</span>(cdf.data,Value<span class="op">&gt;</span><span class="dv">500</span>)<span class="op">$</span>UCB95Pct.P)</a></code></pre></div>
<ul>
<li>Using the code above we have determined that approximately 88.8% (Lower 95% CI: 84% and Upper 95% CI: 93.6%) of the study area is equal to or less than 500 mg TP kg<sup>-1</sup>.</li>
</ul>
<p>We can also ask at what concentration is 50% of the area?</p>
<div class="sourceCode" id="cb12"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb12-1" data-line-number="1">threshold=<span class="dv">50</span>; <span class="co">#Percent area</span></a>
<a class="sourceLine" id="cb12-2" data-line-number="2"></a>
<a class="sourceLine" id="cb12-3" data-line-number="3">result=<span class="kw">max</span>(<span class="kw">subset</span>(cdf.data,Estimate.P<span class="op">&lt;</span>threshold)<span class="op">$</span>Value)</a></code></pre></div>
<ul>
<li>Using the code above we can say that 50% of the area is equal to or less than 388 mg TP kg<sup>-1</sup>.</li>
</ul>
<hr />
</div>
<div id="kriging" class="section level3">
<h3>Kriging</h3>
<p>As computer technology has advanced so has the ability to conduct more advance methods of interpolation. A common advanced interpolation technique is <a href="https://en.wikipedia.org/wiki/Kriging" target="_blank">Kriging</a>. Generally, kriging typically gives the best linear unbiased prediction of the intermediate values. There are several types of kriging that can be applied such as <em>Ordinary</em>, <em>Simple</em>, <em>Universal</em>, etc which depend on the stochastic properties of the random field and the various degrees of stationary assumed. In the following section I will demonstrate <em>Ordinary Kriging</em>.</p>
<p>Kriging takes generally 4-steps:</p>
<ol style="list-style-type: decimal">
<li><p>Remove any spatial trend in the data (if present).</p></li>
<li><p>Compute the experimental variogram, measures of spatial auto-correlation.</p></li>
<li><p>Define the experimental variogram model that is best characterized the spatial autcorrelation in the data.</p></li>
<li><p>Interpolate the surface using the experimental variogram.</p>
<ul>
<li>add the kriged interpolated surface to the trend interpolated surface to produce the final output.</li>
</ul></li>
</ol>
<p><strong>Easy Right?</strong></p>
<p>Actually the steps are very limited, fine tuning (i.e. optimizing) is the hard part.</p>
<p>One major assumption of kriging is that the mean and variation of the data across the study area is constant. This is also referred to as no-global trend or drift. This assumptions is rarely met in environmental data and clearly not met with our data in this study. Therefore the trend in the data needs to be removed. Checking for a spatial trend can be done by plotting the data versus X and Y using <code>plot(Y~Var1,data)</code> and <code>plot(X~Var1,data)</code>.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/dataplot_regression-1.png" alt="Scatter plot of fake-TP data versus longitude (as meters in UTM) with prediction interval"  />
<p class="caption">
Scatter plot of fake-TP data versus longitude (as meters in UTM) with prediction interval
</p>
</div>
<p>Detrending the data can be done by fitting a first order model to the data given by: <span class="math display">\[Z = a + bX + cY\]</span></p>
<p>This is what it looks like in R.</p>
<div class="sourceCode" id="cb13"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb13-1" data-line-number="1"><span class="co">#Make grid</span></a>
<a class="sourceLine" id="cb13-2" data-line-number="2">grd=<span class="kw">as.data.frame</span>(<span class="kw">spsample</span>(sp.dat,<span class="st">&quot;regular&quot;</span>,<span class="dt">n=</span><span class="dv">12000</span>))</a>
<a class="sourceLine" id="cb13-3" data-line-number="3"><span class="kw">names</span>(grd)       =<span class="st"> </span><span class="kw">c</span>(<span class="st">&quot;UTMX&quot;</span>, <span class="st">&quot;UTMY&quot;</span>)</a>
<a class="sourceLine" id="cb13-4" data-line-number="4"><span class="kw">coordinates</span>(grd) =<span class="st"> </span><span class="kw">c</span>(<span class="st">&quot;UTMX&quot;</span>, <span class="st">&quot;UTMY&quot;</span>)</a>
<a class="sourceLine" id="cb13-5" data-line-number="5"></a>
<a class="sourceLine" id="cb13-6" data-line-number="6"><span class="co">#grd=spsample(sp.dat,&quot;regular&quot;,n=10000)</span></a>
<a class="sourceLine" id="cb13-7" data-line-number="7"><span class="kw">gridded</span>(grd)=T;<span class="kw">fullgrid</span>(grd)=T</a>
<a class="sourceLine" id="cb13-8" data-line-number="8"><span class="kw">proj4string</span>(grd)=<span class="kw">proj4string</span>(study.area)</a>
<a class="sourceLine" id="cb13-9" data-line-number="9"><span class="co">#plot(grd)</span></a>
<a class="sourceLine" id="cb13-10" data-line-number="10"><span class="co">#summary(grd)</span></a>
<a class="sourceLine" id="cb13-11" data-line-number="11"></a>
<a class="sourceLine" id="cb13-12" data-line-number="12"><span class="co"># Define the 1st order polynomial equation</span></a>
<a class="sourceLine" id="cb13-13" data-line-number="13">f<span class="fl">.1</span> =<span class="st"> </span><span class="kw">as.formula</span>(TP_mgkg <span class="op">~</span><span class="st"> </span>UTMX <span class="op">+</span><span class="st"> </span>UTMY) </a>
<a class="sourceLine" id="cb13-14" data-line-number="14"></a>
<a class="sourceLine" id="cb13-15" data-line-number="15"><span class="co"># Run the regression model</span></a>
<a class="sourceLine" id="cb13-16" data-line-number="16">lm<span class="fl">.1</span> =<span class="st"> </span><span class="kw">lm</span>( f<span class="fl">.1</span>, <span class="dt">data=</span>sp.dat)</a>
<a class="sourceLine" id="cb13-17" data-line-number="17"></a>
<a class="sourceLine" id="cb13-18" data-line-number="18"><span class="co"># Extract the residual values</span></a>
<a class="sourceLine" id="cb13-19" data-line-number="19">sp.dat<span class="op">$</span>res=lm<span class="fl">.1</span><span class="op">$</span>residuals</a>
<a class="sourceLine" id="cb13-20" data-line-number="20"></a>
<a class="sourceLine" id="cb13-21" data-line-number="21"><span class="co"># Use the regression model output to interpolate the surface</span></a>
<a class="sourceLine" id="cb13-22" data-line-number="22">dat<span class="fl">.1</span>st =<span class="st"> </span><span class="kw">SpatialGridDataFrame</span>(grd, <span class="kw">data.frame</span>(<span class="dt">var1.pred =</span> <span class="kw">predict</span>(lm<span class="fl">.1</span>, <span class="dt">newdata=</span>grd))) </a>
<a class="sourceLine" id="cb13-23" data-line-number="23"></a>
<a class="sourceLine" id="cb13-24" data-line-number="24"><span class="co"># Clip the interpolated raster to Texas</span></a>
<a class="sourceLine" id="cb13-25" data-line-number="25">r.dat<span class="fl">.1</span>st   =<span class="st"> </span><span class="kw">raster</span>(dat<span class="fl">.1</span>st)</a>
<a class="sourceLine" id="cb13-26" data-line-number="26">r.m.dat<span class="fl">.1</span>st =<span class="st"> </span><span class="kw">mask</span>(r.dat<span class="fl">.1</span>st, study.area)</a>
<a class="sourceLine" id="cb13-27" data-line-number="27"></a>
<a class="sourceLine" id="cb13-28" data-line-number="28"><span class="co"># Plot the map</span></a>
<a class="sourceLine" id="cb13-29" data-line-number="29"><span class="kw">tm_shape</span>(r.m.dat<span class="fl">.1</span>st) <span class="op">+</span><span class="st"> </span></a>
<a class="sourceLine" id="cb13-30" data-line-number="30"><span class="st">  </span><span class="kw">tm_raster</span>(<span class="dt">n=</span><span class="dv">10</span>, <span class="dt">palette=</span><span class="st">&quot;RdBu&quot;</span>,</a>
<a class="sourceLine" id="cb13-31" data-line-number="31">            <span class="dt">title=</span><span class="st">&quot;First Order Poly </span><span class="ch">\n</span><span class="st">Soil Total Phosphorus </span><span class="ch">\n</span><span class="st">(mg kg \u207B\u00B9)&quot;</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb13-32" data-line-number="32"><span class="st">  </span><span class="kw">tm_shape</span>(sp.dat) <span class="op">+</span><span class="st"> </span><span class="kw">tm_dots</span>(<span class="dt">size=</span><span class="fl">0.2</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb13-33" data-line-number="33"><span class="st">  </span><span class="kw">tm_legend</span>(<span class="dt">legend.outside=</span><span class="ot">TRUE</span>)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/1stOrder-1.png" alt="Result of a first order interpolation."  />
<p class="caption">
Result of a first order interpolation.
</p>
</div>
<p>Since the 1<sup>st</sup> order model uses least squared linear modeling, the <a href="https://www.statisticssolutions.com/assumptions-of-linear-regression/" target="_blank">assumptions of linear models</a> also applies. You can check to see if the model fits the general assumptions by <code>plot(lm.1)</code> to inspect the residual versus fitted plot, residual distribution and others. You can also use more advanced techniques such as <a href="https://cran.r-project.org/web/packages/gvlma/index.html">Global Validation of Linear Models</a> by <a href="http://amstat.tandfonline.com/doi/abs/10.1198/016214505000000637" target="_blank">Peña and Slate (2006)</a>.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/1stOrder_diag-1.png" alt="Linear model diagonistic plots"  />
<p class="caption">
Linear model diagonistic plots
</p>
</div>
<p>For this example lets assume the model fits all assumptions of least square linear models.</p>
<p>Ultimately Kriging is a spatial analysis of data that focuses on how the data vary as the distance between sampling locations pairing increases. This is done through the construction of a <a href="https://vsp.pnnl.gov/help/vsample/Kriging_Variogram_Model.htm" target="_blank">semivariogram</a> and fitting a mathematical model to the resulting variogram. The variability (or difference) of the data between all point pairs is computed as <span class="math inline">\(\gamma\)</span> as follows:</p>
<p><span class="math display">\[\gamma = \frac{(Z_2-Z_1)^2}{2}\]</span></p>
<p>Lets compare <span class="math inline">\(\gamma\)</span> for all point pairs and plot them versus distance between points.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/variogram-1.png" alt="Experimental variogram plot of residual soil total phosphorus values from the 1^st^ order model."  />
<p class="caption">
Experimental variogram plot of residual soil total phosphorus values from the 1<sup>st</sup> order model.
</p>
</div>
<p>The resulting semivariogram is a cloud of point essentially comparing the variability between all points within the modeling space. If you have a lot of sampling points or a really small area, these semivariogram point clouds can be meaningless given the sheer number of point. In this case, we have 12647 points from 202 sampling locations. To reduce the point-cloud to a more reasonable representation of the data, the data can placed into “bins” or intervals called lags.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/variogram2-1.png" alt="Experimental variogram plot of residual soil total phosphorus values from the 1^st^ order model with lags interval (red hashed lines) and sample variogram estimate each lag (red point) depicted."  />
<p class="caption">
Experimental variogram plot of residual soil total phosphorus values from the 1<sup>st</sup> order model with lags interval (red hashed lines) and sample variogram estimate each lag (red point) depicted.
</p>
</div>
<p>Now its time to fit a model to the sample variogram estimate. A slew of models are available in the <code>gstat</code> package, check out the <code>vgm()</code> function. Ultimately the goal is to apply the best fitting model, this is the fine tuning I talked about earlier. Each model uses partial sill, range and nugget parameters to fit the model to the sample variogram estimate. The nugget is distance between zero and the variogram’s model intercept with the y-axis. The partial sill is the vertical distance between the nugget and the curve asymptote. Finally the range is the distance along the x-axis and the partial sill.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/model-explained-1.png" alt="Example of an ideal variogram with fit model depicting the range, sill and nugget parameters in a variogram model (Source Gimond 2018)."  />
<p class="caption">
Example of an ideal variogram with fit model depicting the range, sill and nugget parameters in a variogram model (Source Gimond 2018).
</p>
</div>
<p>In the hypothetical soil total phosphorus (TP) spatial model, the semivariogram is less than ideal. Here I fit a linear model and set the range to zero give the linear nature to the data. You see how this variogram differs from the example above where the model (red line) doesn’t fit the data (blue points) very well. This is where the <em>“rubber meet the road”</em> with Kriging and model fitting to produce a strong spatial model. Additional information regarding the spatial structure of the dataset can be gleaned from the sample variogram estimate. Maybe we will save that for another time?</p>
<div class="sourceCode" id="cb14"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb14-1" data-line-number="1"><span class="co">#sampled variogram estimate</span></a>
<a class="sourceLine" id="cb14-2" data-line-number="2">var.smpl  =<span class="st"> </span><span class="kw">variogram</span>(res <span class="op">~</span><span class="st"> </span><span class="dv">1</span>, sp.dat, <span class="dt">cloud =</span> F)</a>
<a class="sourceLine" id="cb14-3" data-line-number="3"></a>
<a class="sourceLine" id="cb14-4" data-line-number="4"><span class="co"># Compute the variogram model by passing the nugget, sill and range values</span></a>
<a class="sourceLine" id="cb14-5" data-line-number="5"><span class="co"># to fit.variogram() via the vgm() function.</span></a>
<a class="sourceLine" id="cb14-6" data-line-number="6">var.fit  =<span class="st"> </span><span class="kw">fit.variogram</span>(var.smpl,<span class="kw">vgm</span>(<span class="dt">model=</span><span class="st">&quot;Lin&quot;</span>,<span class="dt">range=</span><span class="dv">0</span>))</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/var_model_plot-1.png" alt="Linear model fit to residual variogram"  />
<p class="caption">
Linear model fit to residual variogram
</p>
</div>
<p>Like I said, not the best model but for the sake of the work-flow, lets assume the model fit the sampled variogram estimates like the example above from Gimond (2018).</p>
<p>Now that the variogram model has been estimated we can move onto Kriging. The variogram model provides localized weighted parameters to interpolate values across space. Ultimately, Kriging is letting the localized pattern produced by the sample points define the spatial weights.</p>
<div class="sourceCode" id="cb15"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb15-1" data-line-number="1"><span class="co"># Perform the krige interpolation (note the use of the variogram model</span></a>
<a class="sourceLine" id="cb15-2" data-line-number="2"><span class="co"># created in the earlier step)</span></a>
<a class="sourceLine" id="cb15-3" data-line-number="3">res.dat.krg =<span class="st"> </span><span class="kw">krige</span>( res<span class="op">~</span><span class="dv">1</span>, sp.dat, grd, var.fit)</a>
<a class="sourceLine" id="cb15-4" data-line-number="4"></a>
<a class="sourceLine" id="cb15-5" data-line-number="5"><span class="co">#Convert surface to a raster </span></a>
<a class="sourceLine" id="cb15-6" data-line-number="6">res.r=<span class="kw">raster</span>(res.dat.krg)</a>
<a class="sourceLine" id="cb15-7" data-line-number="7"></a>
<a class="sourceLine" id="cb15-8" data-line-number="8"><span class="co">#clip raster to study area</span></a>
<a class="sourceLine" id="cb15-9" data-line-number="9">res.r.m=<span class="kw">mask</span>(res.r,study.area)</a>
<a class="sourceLine" id="cb15-10" data-line-number="10"></a>
<a class="sourceLine" id="cb15-11" data-line-number="11"><span class="co"># Plot the raster and the sampled points</span></a>
<a class="sourceLine" id="cb15-12" data-line-number="12"><span class="kw">tm_shape</span>(res.r.m) <span class="op">+</span><span class="st"> </span></a>
<a class="sourceLine" id="cb15-13" data-line-number="13"><span class="st">  </span><span class="kw">tm_raster</span>(<span class="dt">n=</span><span class="dv">10</span>, <span class="dt">palette=</span><span class="st">&quot;RdBu&quot;</span>,</a>
<a class="sourceLine" id="cb15-14" data-line-number="14">            <span class="dt">title=</span><span class="st">&quot;Predicted residual</span><span class="ch">\n</span><span class="st">Soil Total Phosphorus </span><span class="ch">\n</span><span class="st">(mg kg \u207B\u00B9)&quot;</span>,<span class="dt">midpoint =</span> <span class="ot">NA</span>,<span class="dt">breaks=</span><span class="kw">c</span>(<span class="kw">seq</span>(<span class="op">-</span><span class="dv">160</span>,<span class="dv">0</span>,<span class="dv">80</span>),<span class="kw">seq</span>(<span class="dv">0</span>,<span class="dv">160</span>,<span class="dv">80</span>))) <span class="op">+</span></a>
<a class="sourceLine" id="cb15-15" data-line-number="15"><span class="st">  </span><span class="kw">tm_shape</span>(sp.dat) <span class="op">+</span><span class="st"> </span><span class="kw">tm_dots</span>(<span class="dt">size=</span><span class="fl">0.2</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb15-16" data-line-number="16"><span class="st">  </span><span class="kw">tm_legend</span>(<span class="dt">legend.outside=</span><span class="ot">TRUE</span>)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/res_krig-1.png" alt="Krige interpolation of the residual (fake) soil total phosphorus values across the study area."  />
<p class="caption">
Krige interpolation of the residual (fake) soil total phosphorus values across the study area.
</p>
</div>
<p>As you can see some areas are under or over estimating soil total phosphorus concentrations. Depending on the resolution of the data and the method detection limit these might be significant over or under representation of the data. Its up to you to decide the validity of the spatial model relative to variogram model fit and the data utilized. Remember the main assumption of kriging is <em>“…that the mean and variation of the data across the study area is constant…”</em> therefore we detrended the data by fitting a first order model (hence the residuals above).</p>
<div class="sourceCode" id="cb16"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb16-1" data-line-number="1"><span class="co"># Define the 1st order polynomial equation (same as eailer)</span></a>
<a class="sourceLine" id="cb16-2" data-line-number="2">f<span class="fl">.1</span> =<span class="st"> </span><span class="kw">as.formula</span>(TP_mgkg <span class="op">~</span><span class="st"> </span>UTMX <span class="op">+</span><span class="st"> </span>UTMY) </a>
<a class="sourceLine" id="cb16-3" data-line-number="3"></a>
<a class="sourceLine" id="cb16-4" data-line-number="4"><span class="co">#sampled variogram estimate </span></a>
<a class="sourceLine" id="cb16-5" data-line-number="5">var.smpl  =<span class="st"> </span><span class="kw">variogram</span>(f<span class="fl">.1</span>, sp.dat, <span class="dt">cloud =</span> F)</a>
<a class="sourceLine" id="cb16-6" data-line-number="6"></a>
<a class="sourceLine" id="cb16-7" data-line-number="7"><span class="co"># Compute the variogram model by passing the nugget, sill and range values</span></a>
<a class="sourceLine" id="cb16-8" data-line-number="8"><span class="co"># to fit.variogram() via the vgm() function.</span></a>
<a class="sourceLine" id="cb16-9" data-line-number="9">var.fit  =<span class="st"> </span><span class="kw">fit.variogram</span>(var.smpl,<span class="kw">vgm</span>(<span class="dt">model=</span><span class="st">&quot;Lin&quot;</span>,<span class="dt">range=</span><span class="dv">0</span>))</a>
<a class="sourceLine" id="cb16-10" data-line-number="10"></a>
<a class="sourceLine" id="cb16-11" data-line-number="11"><span class="co"># Perform the krige interpolation using 1st order model. </span></a>
<a class="sourceLine" id="cb16-12" data-line-number="12">dat.krg &lt;-<span class="st"> </span><span class="kw">krige</span>(f<span class="fl">.1</span>, sp.dat, grd, var.fit)</a>
<a class="sourceLine" id="cb16-13" data-line-number="13"></a>
<a class="sourceLine" id="cb16-14" data-line-number="14"><span class="co"># Convert kriged surface to a raster object</span></a>
<a class="sourceLine" id="cb16-15" data-line-number="15">data.r &lt;-<span class="st"> </span><span class="kw">raster</span>(dat.krg)</a>
<a class="sourceLine" id="cb16-16" data-line-number="16">data.r.m &lt;-<span class="st"> </span><span class="kw">mask</span>(data.r, study.area)</a>
<a class="sourceLine" id="cb16-17" data-line-number="17"></a>
<a class="sourceLine" id="cb16-18" data-line-number="18"><span class="co"># Plot the map</span></a>
<a class="sourceLine" id="cb16-19" data-line-number="19"><span class="kw">tm_shape</span>(data.r.m) <span class="op">+</span><span class="st"> </span></a>
<a class="sourceLine" id="cb16-20" data-line-number="20"><span class="st">  </span><span class="kw">tm_raster</span>(<span class="dt">n=</span><span class="dv">10</span>, <span class="dt">palette=</span><span class="st">&quot;RdBu&quot;</span>,</a>
<a class="sourceLine" id="cb16-21" data-line-number="21">            <span class="dt">title=</span><span class="st">&quot;Soil Total Phosphorus </span><span class="ch">\n</span><span class="st">(mg kg \u207B\u00B9)&quot;</span>,</a>
<a class="sourceLine" id="cb16-22" data-line-number="22">              <span class="dt">breaks=</span><span class="kw">seq</span>(<span class="dv">200</span>,<span class="dv">700</span>,<span class="dv">50</span>)) <span class="op">+</span></a>
<a class="sourceLine" id="cb16-23" data-line-number="23"><span class="st">  </span><span class="kw">tm_shape</span>(sp.dat) <span class="op">+</span><span class="st"> </span><span class="kw">tm_dots</span>(<span class="dt">size=</span><span class="fl">0.2</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb16-24" data-line-number="24"><span class="st">  </span><span class="kw">tm_legend</span>(<span class="dt">legend.outside=</span><span class="ot">TRUE</span>)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/data_krig-1.png" alt="Final kriged interpolation of the detrended (fake) soil total phosphorus values across the study area."  />
<p class="caption">
Final kriged interpolation of the detrended (fake) soil total phosphorus values across the study area.
</p>
</div>
<p>Now that a spatial model has been developed, much like the the CDF analysis using the thessian spatial weighted data. A percentage of area by concentration can be estimated, but we might have to save that for another post.</p>
<p>In addition to the residual map, a variance map is also helpful to provide a measure of uncertainty in the interpolated values. Generally smaller the variance the better the model fits (<strong>Note:</strong> <em>the variance values are in square units</em>).</p>
<div class="sourceCode" id="cb17"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb17-1" data-line-number="1"><span class="co"># The dat.krg object stores not just the interpolated values, but the </span></a>
<a class="sourceLine" id="cb17-2" data-line-number="2"><span class="co"># variance values as well. </span></a>
<a class="sourceLine" id="cb17-3" data-line-number="3"></a>
<a class="sourceLine" id="cb17-4" data-line-number="4">var.r &lt;-<span class="st"> </span><span class="kw">raster</span>(dat.krg, <span class="dt">layer=</span><span class="st">&quot;var1.var&quot;</span>)</a>
<a class="sourceLine" id="cb17-5" data-line-number="5">var.r.m &lt;-<span class="st"> </span><span class="kw">mask</span>(var.r, study.area)</a>
<a class="sourceLine" id="cb17-6" data-line-number="6"></a>
<a class="sourceLine" id="cb17-7" data-line-number="7"><span class="co">#Plot the map</span></a>
<a class="sourceLine" id="cb17-8" data-line-number="8"><span class="kw">tm_shape</span>(var.r.m) <span class="op">+</span><span class="st"> </span></a>
<a class="sourceLine" id="cb17-9" data-line-number="9"><span class="st">  </span><span class="kw">tm_raster</span>(<span class="dt">n=</span><span class="dv">7</span>, <span class="dt">palette =</span><span class="st">&quot;Reds&quot;</span>,</a>
<a class="sourceLine" id="cb17-10" data-line-number="10">            <span class="dt">title=</span><span class="st">&quot;Variance map </span><span class="ch">\n</span><span class="st">(in squared meters)&quot;</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb17-11" data-line-number="11"><span class="st">  </span><span class="kw">tm_shape</span>(sp.dat) <span class="op">+</span><span class="st"> </span><span class="kw">tm_dots</span>(<span class="dt">size=</span><span class="fl">0.2</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb17-12" data-line-number="12"><span class="st">  </span><span class="kw">tm_legend</span>(<span class="dt">legend.outside=</span><span class="ot">TRUE</span>)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/data_krig_var-1.png" alt="Variance map of final kriged interpolation of the detrended (fake) soil total phosphorus values across the study area."  />
<p class="caption">
Variance map of final kriged interpolation of the detrended (fake) soil total phosphorus values across the study area.
</p>
</div>
<p>With units in area units, the variance map is less easily interpreted other than high-versus-low. A more readily interpretable map is the 95% confidence interval map which can be calculated from the variance data stored in <code>dat.krg</code>. Both maps provide an estimate of uncertainty in the spatial distribution of the data.</p>
<div class="sourceCode" id="cb18"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb18-1" data-line-number="1">r.ci   &lt;-<span class="st"> </span><span class="kw">sqrt</span>(<span class="kw">raster</span>(dat.krg, <span class="dt">layer=</span><span class="st">&quot;var1.var&quot;</span>)) <span class="op">*</span><span class="st"> </span><span class="fl">1.96</span></a>
<a class="sourceLine" id="cb18-2" data-line-number="2">r.m.ci &lt;-<span class="st"> </span><span class="kw">mask</span>(r.ci, study.area)</a>
<a class="sourceLine" id="cb18-3" data-line-number="3"></a>
<a class="sourceLine" id="cb18-4" data-line-number="4"><span class="co">#Plot the map</span></a>
<a class="sourceLine" id="cb18-5" data-line-number="5"><span class="kw">tm_shape</span>(r.m.ci) <span class="op">+</span><span class="st"> </span></a>
<a class="sourceLine" id="cb18-6" data-line-number="6"><span class="st">  </span><span class="kw">tm_raster</span>(<span class="dt">n=</span><span class="dv">7</span>, <span class="dt">palette =</span><span class="st">&quot;Blues&quot;</span>,</a>
<a class="sourceLine" id="cb18-7" data-line-number="7">            <span class="dt">title=</span><span class="st">&quot;95% CI map </span><span class="ch">\n</span><span class="st">(in meters)&quot;</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb18-8" data-line-number="8"><span class="st">  </span><span class="kw">tm_shape</span>(sp.dat) <span class="op">+</span><span class="st">  </span><span class="kw">tm_dots</span>(<span class="dt">size=</span><span class="fl">0.2</span>) <span class="op">+</span></a>
<a class="sourceLine" id="cb18-9" data-line-number="9"><span class="st">  </span><span class="kw">tm_legend</span>(<span class="dt">legend.outside=</span><span class="ot">TRUE</span>)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-01-20-RGeostat_files/figure-html/data_krig_CI-1.png" alt="95% Confidence Interval map of final kriged interpolation of the detrended (fake) soil total phosphorus values across the study area."  />
<p class="caption">
95% Confidence Interval map of final kriged interpolation of the detrended (fake) soil total phosphorus values across the study area.
</p>
</div>
<p>I hope that this post has provided a better appreciation of spatial interpolation and spatial analysis in R. This is by no means a comprehensive workflow of spatial interpolation and lots of factors need to be considered during this type of analysis.</p>
<p>In the future I will cover spatial statistics (i.e. auto-correlation), other interpolation methods, working with array oriented spatial data (i.e. NetCDF) and others.</p>
<p>Now go forth and interpolate.</p>
<center>
Happy Kriging!!
</center>
<hr />
</div>
</div>
<div id="references" class="section level2">
<h2>References</h2>
<ul>
<li><p>Gimond M (2018) Intro to GIS and Spatial Analysis.</p></li>
<li><p>Lovelace R, Nowosad J, Muenchow J (2019) Geocomputation with R, 1st edn. CRC Press, Boca Raton, FL</p></li>
<li><p>Peña EA, Slate EH (2006) Global Validation of Linear Model Assumptions. Journal of the American Statistical Association 101:341–354.</p></li>
</ul>
<hr />
</div>
</div>
</section>
