---
title: "Hot Spot Analysis - Geospatial data analysis in #rstats. Part 3"


date: "September 18,2020"
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> geostatistics, R, hot-spot, Getis-Ord</p>
<hr />
<p>Continuing our series on geospatial analysis we are diving deeper into spatial statistics Hot-spot analysis. In my prior posts I presented spatial interpolation techniques such as <a href="https://swampthingpaul.github.io/blog/geospatial-data-analysis-in-rstats.-part-1/" target="_blank">kriging</a> and spatial auto-correlation with <a href="https://swampthingpaul.github.io/blog/geospatial-data-analysis-in-rstats.-part-2/" target="_blank">Moran’s <em>I</em></a>.</p>
<p>Kriging is a value tool to detect spatial structure and patterns across a particular area. These spatial models rely on understanding the spatial correction and auto-correlation. A common component of spatial correlation/auto-correlation analyses is they are applied on a global scale (entire dataset). In some cases, it may be warranted to examine patterns at a more local (fine) scale. The Getis-Ord <em>G</em> statistic provides information on local spatial structures and can identify areas of high (or low) clustering. This clustering is operationally defined as <strong>hotspots</strong> and is done by comparing the sum in a particular variable within a local neighborhood network relative to the global sum of the area-of-interest extent <span class="citation">(Getis and Ord <a href="#ref-getis_analysis_2010" role="doc-biblioref">2010</a>)</span>.</p>
<p><span class="citation">Getis and Ord (<a href="#ref-getis_analysis_2010" role="doc-biblioref">2010</a>)</span> introduced a family of measures of spatial associated called <em>G</em> statistics. When used with spatial auto-correlation statistics such as Moran’s <em>I</em>, the <em>G</em> family of statistics can expand our understanding of processes that give rise to spatial association, in detecting local hotspots (in their original paper they used the term “pockets”). The Getis-Ord statistic can be used in the global (<span class="math inline">\(G\)</span>) and local (<span class="math inline">\(G_{i}^{*}\)</span>) scales. The global statistic (<span class="math inline">\(G\)</span>) identifies high or low values across the entire study area (i.e. forest, wetland, city, etc.), meanwhile the local (<span class="math inline">\(G_{i}^{*}\)</span>) statistic evaluates the data for each feature within the dataset and determining where features with high or low values (“pockets” or hot/cold) cluster spatially.</p>
<p>At this point I would probably throw some equations around and give you the mathematical nitty gritty. Given I am not a maths wiz and <span class="citation">Getis and Ord (<a href="#ref-getis_analysis_2010" role="doc-biblioref">2010</a>)</span> provides all the detail (lots of nitty and a little gritty) in such an eloquent fashion I’ll leave it up to you if you want to peruse the manuscript. The Getis-Ord statistic has been applied across several different fields including crime analysis, epidemiology and a couple of forays into biogeochemistry and ecology.</p>
<div id="play-time" class="section level2">
<h2>Play Time</h2>
<p>For this example I will be using a dataset from the United States Environmental Protection Agency (USEPA) as part of the Everglades Regional Environmental Monitoring Program (<a href="https://www.epa.gov/everglades/environmental-monitoring-everglades" target="_blank">R-EMAP</a>).</p>
<div id="some-on-the-dataset" class="section level3">
<h3>Some on the dataset</h3>
<p>The Everglades R-EMAP program has been monitoring the Everglades ecosystem since 1993 in a probability-based sampling approach covering ~5000 km<sup>2</sup> from a multi-media aspect (water, sediment, fish, etc.). This large scale sampling has occurred in four phases, Phase I (1995 - 1996), Phase II (1999), Phase III (2005) and Phase IV (2013 - 2014). For the purposes of this post, we will be focusing on sediment/soil total phosphorus concentrations collected during the wet-season sampling during Phase I (April 1995 &amp; May 1996).</p>
</div>
<div id="analysis-time" class="section level3">
<h3>Analysis time!!</h3>
<p>Here are the necessary packages.</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" title="1"><span class="co">## Libraries</span></a>
<a class="sourceLine" id="cb1-2" title="2"><span class="co"># read xlsx files</span></a>
<a class="sourceLine" id="cb1-3" title="3"><span class="kw">library</span>(readxl)</a>
<a class="sourceLine" id="cb1-4" title="4"></a>
<a class="sourceLine" id="cb1-5" title="5"><span class="co"># Geospatial </span></a>
<a class="sourceLine" id="cb1-6" title="6"><span class="kw">library</span>(rgdal)</a>
<a class="sourceLine" id="cb1-7" title="7"><span class="kw">library</span>(rgeos)</a>
<a class="sourceLine" id="cb1-8" title="8"><span class="kw">library</span>(raster)</a>
<a class="sourceLine" id="cb1-9" title="9"><span class="kw">library</span>(spdep)</a></code></pre></div>
<p>Incase you are not sure if you have these packages installed here is a quick function that will check for the packages and install if needed from CRAN.</p>
<div class="sourceCode" id="cb2"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb2-1" title="1"><span class="co"># Function</span></a>
<a class="sourceLine" id="cb2-2" title="2">check.packages &lt;-<span class="st"> </span><span class="cf">function</span>(pkg){</a>
<a class="sourceLine" id="cb2-3" title="3">  new.pkg &lt;-<span class="st"> </span>pkg[<span class="op">!</span>(pkg <span class="op">%in%</span><span class="st"> </span><span class="kw">installed.packages</span>()[, <span class="st">&quot;Package&quot;</span>])]</a>
<a class="sourceLine" id="cb2-4" title="4">  <span class="cf">if</span> (<span class="kw">length</span>(new.pkg)) </a>
<a class="sourceLine" id="cb2-5" title="5">    <span class="kw">install.packages</span>(new.pkg, <span class="dt">dependencies =</span> <span class="ot">TRUE</span>)</a>
<a class="sourceLine" id="cb2-6" title="6">  <span class="kw">sapply</span>(pkg, require, <span class="dt">character.only =</span> <span class="ot">TRUE</span>)</a>
<a class="sourceLine" id="cb2-7" title="7">}</a>
<a class="sourceLine" id="cb2-8" title="8"></a>
<a class="sourceLine" id="cb2-9" title="9">pkg&lt;-<span class="kw">c</span>(<span class="st">&quot;openxlsx&quot;</span>,<span class="st">&quot;readxl&quot;</span>,<span class="st">&quot;rgdal&quot;</span>,<span class="st">&quot;rgeos&quot;</span>,<span class="st">&quot;raster&quot;</span>,<span class="st">&quot;spdep&quot;</span>)</a>
<a class="sourceLine" id="cb2-10" title="10"><span class="kw">check.packages</span>(pkg)</a></code></pre></div>
<p>Download the data (as a zip file) <a href="https://www.epa.gov/sites/production/files/2014-03/sf1data.zip" target="_blank">here</a>!</p>
<p>Download the Water Conservation Area shapefile <a href="%22https://www.swampthingecology.org/blog/data/hotspot/WCAs.zip%22" target="&quot;_blank">here</a>!</p>
<div class="sourceCode" id="cb3"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb3-1" title="1"><span class="co"># Read shapefile</span></a>
<a class="sourceLine" id="cb3-2" title="2">wcas&lt;-<span class="kw">readOGR</span>(GISdata,<span class="st">&quot;WCAs&quot;</span>)</a>
<a class="sourceLine" id="cb3-3" title="3">wcas&lt;-<span class="kw">spTransform</span>(wcas,utm17)</a>
<a class="sourceLine" id="cb3-4" title="4"></a>
<a class="sourceLine" id="cb3-5" title="5"><span class="co"># Read the spreadsheet</span></a>
<a class="sourceLine" id="cb3-6" title="6">p12&lt;-readxl<span class="op">::</span><span class="kw">read_xls</span>(<span class="st">&quot;data/P12join7FINAL.xls&quot;</span>,<span class="dt">sheet=</span><span class="dv">2</span>)</a>
<a class="sourceLine" id="cb3-7" title="7"></a>
<a class="sourceLine" id="cb3-8" title="8"><span class="co"># Clean up the headers</span></a>
<a class="sourceLine" id="cb3-9" title="9"><span class="kw">colnames</span>(p12)&lt;-<span class="kw">sapply</span>(<span class="kw">strsplit</span>(<span class="kw">names</span>(p12),<span class="st">&quot;</span><span class="ch">\\</span><span class="st">$&quot;</span>),<span class="st">&quot;[&quot;</span>,<span class="dv">1</span>)</a>
<a class="sourceLine" id="cb3-10" title="10">p12&lt;-<span class="kw">data.frame</span>(p12)</a>
<a class="sourceLine" id="cb3-11" title="11">p12[p12<span class="op">==-</span><span class="dv">9999</span>]&lt;-<span class="ot">NA</span></a>
<a class="sourceLine" id="cb3-12" title="12">p12[p12<span class="op">==-</span><span class="fl">3047.6952</span>]&lt;-<span class="ot">NA</span></a>
<a class="sourceLine" id="cb3-13" title="13"></a>
<a class="sourceLine" id="cb3-14" title="14"><span class="co"># Convert the data.frame() to SpatialPointsDataFrame</span></a>
<a class="sourceLine" id="cb3-15" title="15">vars&lt;-<span class="kw">c</span>(<span class="st">&quot;STA_ID&quot;</span>,<span class="st">&quot;CYCLE&quot;</span>,<span class="st">&quot;SUBAREA&quot;</span>,<span class="st">&quot;DECLONG&quot;</span>,<span class="st">&quot;DECLAT&quot;</span>,<span class="st">&quot;DATE&quot;</span>,<span class="st">&quot;TPSDF&quot;</span>)</a>
<a class="sourceLine" id="cb3-16" title="16">p12.shp&lt;-<span class="kw">SpatialPointsDataFrame</span>(<span class="dt">coords=</span>p12[,<span class="kw">c</span>(<span class="st">&quot;DECLONG&quot;</span>,<span class="st">&quot;DECLAT&quot;</span>)],</a>
<a class="sourceLine" id="cb3-17" title="17">                               <span class="dt">data=</span>p12[,vars],<span class="dt">proj4string =</span>wgs84)</a>
<a class="sourceLine" id="cb3-18" title="18"><span class="co"># transform to UTM (something I like to do...but not necessary)</span></a>
<a class="sourceLine" id="cb3-19" title="19">p12.shp&lt;-<span class="kw">spTransform</span>(p12.shp,utm17)</a>
<a class="sourceLine" id="cb3-20" title="20"></a>
<a class="sourceLine" id="cb3-21" title="21"><span class="co"># Subset the data for wet season data only</span></a>
<a class="sourceLine" id="cb3-22" title="22">p12.shp.wca2&lt;-<span class="kw">subset</span>(p12.shp,CYCLE<span class="op">%in%</span><span class="kw">c</span>(<span class="dv">0</span>,<span class="dv">2</span>))</a>
<a class="sourceLine" id="cb3-23" title="23">p12.shp.wca2&lt;-p12.shp.wca2[<span class="kw">subset</span>(wcas,Name<span class="op">==</span><span class="st">&quot;WCA 2A&quot;</span>),]</a></code></pre></div>
<p>Here is a quick map the of data</p>
<div class="sourceCode" id="cb4"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb4-1" title="1"><span class="kw">par</span>(<span class="dt">mar=</span><span class="kw">c</span>(<span class="fl">0.1</span>,<span class="fl">0.1</span>,<span class="fl">0.1</span>,<span class="fl">0.1</span>),<span class="dt">oma=</span><span class="kw">c</span>(<span class="dv">0</span>,<span class="dv">0</span>,<span class="dv">0</span>,<span class="dv">0</span>))</a>
<a class="sourceLine" id="cb4-2" title="2"><span class="kw">plot</span>(p12.shp,<span class="dt">pch=</span><span class="dv">21</span>,<span class="dt">bg=</span><span class="st">&quot;grey&quot;</span>,<span class="dt">cex=</span><span class="fl">0.5</span>)</a>
<a class="sourceLine" id="cb4-3" title="3"><span class="kw">plot</span>(wcas,<span class="dt">add=</span>T)</a></code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-09-17-HotSpot_files/figure-html/unnamed-chunk-4-1.png" style="display: block; margin: auto;" /></p>
<p>Much like other spatial statistics (i.e. Moran’s <em>I</em>) the <em>G</em> statistics relies on spatially weighting the data. In my last <a href="https://swampthingpaul.github.io/blog/geospatial-data-analysis-in-rstats.-part-2/" target="_blank">post</a> we discussed average nearest neighbor (ANN). Average nearest neighbor analysis measures the average distance from each point in the area of interest to it nearest point. As a reminder here is changes in ANN versus the degree of clustering. Here is a quick reminder.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-09-17-HotSpot_files/figure-html/f11-diff-patterns-1.png" alt="Three different point patterns: a single cluster (top left), a dual cluster (top center) and a randomly scattered pattern (top right). Three different ANN vs. neighbor order plots. The black ANN line is for the first point pattern (single cluster); the blue line is for the second point pattern (double cluster) and the red line is for the third point pattern."  />
<p class="caption">
Three different point patterns: a single cluster (top left), a dual cluster (top center) and a randomly scattered pattern (top right). Three different ANN vs. neighbor order plots. The black ANN line is for the first point pattern (single cluster); the blue line is for the second point pattern (double cluster) and the red line is for the third point pattern.
</p>
</div>
<p>For demonstration purposes we are going to look at a subset of the entire datsaset. We are going to look at data within Water Conservation Area 2A.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-09-17-HotSpot_files/figure-html/unnamed-chunk-5-1.png" alt="Soil total phosphorus concentration within Water Conservation Area 2A during Phase I sampling."  />
<p class="caption">
Soil total phosphorus concentration within Water Conservation Area 2A during Phase I sampling.
</p>
</div>
<p>Most examples of Getis-Ord analysis across the interest looks at polygon type data (i.e. city block, counties, watersheds, etc.). For this example, we are evaluating the data based on point data.</p>
<p>Let’s determine the spatial weight (nearest neighbor distances). Since we are looking at point data, we are going to need to do something slightly different than what was done with Moran’s <em>I</em> in the prior post. The <code>dnearneigh()</code> uses a matrix of point coordinates combined with distance thresholds. To work with the function coordinates will need to be extracted from the data using <code>coordinates()</code>. To find the distance range in the data we can use <code>pointDistance()</code> function. We don’t want to include all possible connections so setting the upper distance bound in the <code>dnearneigh()</code> to the mean distance across the site.</p>
<div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb5-1" title="1"><span class="co"># Find distance range</span></a>
<a class="sourceLine" id="cb5-2" title="2">ptdist=<span class="kw">pointDistance</span>(p12.shp.wca2)</a>
<a class="sourceLine" id="cb5-3" title="3"></a>
<a class="sourceLine" id="cb5-4" title="4">min.dist&lt;-<span class="kw">min</span>(ptdist); <span class="co"># Minimum</span></a>
<a class="sourceLine" id="cb5-5" title="5">mean.dist&lt;-<span class="kw">mean</span>(ptdist); <span class="co"># Max</span></a>
<a class="sourceLine" id="cb5-6" title="6"></a>
<a class="sourceLine" id="cb5-7" title="7">nb&lt;-<span class="kw">dnearneigh</span>(<span class="kw">coordinates</span>(p12.shp.wca2),min.dist,mean.dist)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-09-17-HotSpot_files/figure-html/unnamed-chunk-7-1.png" alt="Neighborhood network for WCA-2A sites"  />
<p class="caption">
Neighborhood network for WCA-2A sites
</p>
</div>
<p>Another spatial weights approach could be to apply k-nearest neighbor distances and could be used in the <code>nb2listw()</code>. In general there are minor differences in how these spatial weights are calculated and can be data specific. For purposes of our example we will be using euclidean distance (above) but for completeness below is the k-nearest neighbor approach.</p>
<div class="sourceCode" id="cb6"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb6-1" title="1">k1&lt;-<span class="kw">knn2nb</span>(<span class="kw">knearneigh</span>(p12.shp.wca2))</a></code></pre></div>
<div id="global-g" class="section level4">
<h4>Global <em>G</em></h4>
<p>Now that we have the nearest neighbor values we need to convert the data into a list for both the global and local <em>G</em> statistics. For the global <em>G</em> (<code>globalG.test(...)</code>), it is recommended that the spatial weights be binary, therefore in the <code>nb2listw()</code> function we need to use the <code>style="B"</code>.</p>
<div class="sourceCode" id="cb7"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb7-1" title="1">nb_lw&lt;-<span class="kw">nb2listw</span>(nb,<span class="dt">style=</span><span class="st">&quot;B&quot;</span>)</a></code></pre></div>
<p>Now to evaluate the dataset from the Global <em>G</em> statistic.</p>
<div class="sourceCode" id="cb8"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb8-1" title="1"><span class="kw">globalG.test</span>(p12.shp.wca2<span class="op">$</span>TPSDF,nb_lw,<span class="dt">alternative=</span><span class="st">&quot;two.sided&quot;</span>)</a></code></pre></div>
<pre><code>## 
##  Getis-Ord global G statistic
## 
## data:  p12.shp.wca2$TPSDF 
## weights: nb_lw 
## 
## standard deviate = 0.092001, p-value = 0.9267
## alternative hypothesis: two.sided
## sample estimates:
## Global G statistic        Expectation           Variance 
##         0.48775147         0.48333333         0.00230619</code></pre>
<p>In the output it <code>standard deviate</code> is the standard deviation of Moran’s <em>I</em> or the <span class="math inline">\(z_{G}\)</span>-score and <span class="math inline">\(\rho\)</span>-value of the test. Other information in the output include the observed statistic, its expectation and variance.</p>
<p>Based on the Global <em>G</em> results it suggests that there is no high/low clustering globally across the dataset.</p>
<p>If you want more information on the Global test, <a href="https://www.esri.com/en-us/home" target="_blank">ESRI</a> provides a <a href="https://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-how-high-low-clustering-getis-ord-general-g-spat.htm" target="_blank">robust review</a> including all the additional <a href="https://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-general-g-additional-math.htm" target="_blank">maths</a> that is behind the statistic.</p>
</div>
<div id="local-g" class="section level4">
<h4>Local <em>G</em></h4>
<p>Similar to the Global test, the local <em>G</em> test uses nearest neighbors. Unlike the Global test, the nearest neighbor can be row standardized (default setting).</p>
<div class="sourceCode" id="cb10"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb10-1" title="1">nb_lw&lt;-<span class="kw">nb2listw</span>(nb)</a>
<a class="sourceLine" id="cb10-2" title="2"></a>
<a class="sourceLine" id="cb10-3" title="3"><span class="co"># local G</span></a>
<a class="sourceLine" id="cb10-4" title="4">local_g&lt;-<span class="kw">localG</span>(p12.shp.wca2<span class="op">$</span>TPSDF,nb_lw)</a></code></pre></div>
<p>The output of the function is a list of <span class="math inline">\(z_{G_{i}^{*}}\)</span>-scores for each site. A little extra coding to determine <span class="math inline">\(\rho\)</span>-values and hot/cold spots. Essentially values need to be extracted from the <code>local_g</code> object and <span class="math inline">\(\rho\)</span>-value based on the z-score.</p>
<div class="sourceCode" id="cb11"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb11-1" title="1"><span class="co"># convert to matrix</span></a>
<a class="sourceLine" id="cb11-2" title="2">local_g.ma=<span class="kw">as.matrix</span>(local_g)</a>
<a class="sourceLine" id="cb11-3" title="3"></a>
<a class="sourceLine" id="cb11-4" title="4"><span class="co"># column-bind the local_g data</span></a>
<a class="sourceLine" id="cb11-5" title="5">p12.shp.wca2&lt;-<span class="kw">cbind</span>(p12.shp.wca2,local_g.ma)</a>
<a class="sourceLine" id="cb11-6" title="6"></a>
<a class="sourceLine" id="cb11-7" title="7"><span class="co"># change the names of the new column</span></a>
<a class="sourceLine" id="cb11-8" title="8"><span class="kw">names</span>(p12.shp.wca2)[<span class="kw">ncol</span>(p12.shp.wca2)]=<span class="st">&quot;localg&quot;</span></a></code></pre></div>
<p>Lets determine the <code>two.side</code> <span class="math inline">\(\rho\)</span>-value.</p>
<div class="sourceCode" id="cb12"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb12-1" title="1">p12.shp.wca2<span class="op">$</span>pval&lt;-<span class="st"> </span><span class="dv">2</span><span class="op">*</span><span class="kw">pnorm</span>(<span class="op">-</span><span class="kw">abs</span>(p12.shp.wca2<span class="op">$</span>localg))</a></code></pre></div>
<p>Based on the <span class="math inline">\(z_{G_{i}^{*}}\)</span>-scores and <span class="math inline">\(\rho\)</span>-value we operationally define a hotspot as <span class="math inline">\(z_{G_{i}^{*}}\)</span>-scores &gt; 0 and <span class="math inline">\(\rho\)</span>-value &lt; <span class="math inline">\(\alpha\)</span> (usually 0.05). Let see if we have hotspots.</p>
<div class="sourceCode" id="cb13"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb13-1" title="1"><span class="kw">subset</span>(p12.shp.wca2<span class="op">@</span>data,localg<span class="op">&gt;</span><span class="dv">0</span><span class="op">&amp;</span>pval<span class="op">&lt;</span><span class="fl">0.05</span>)<span class="op">$</span>STA_ID</a></code></pre></div>
<pre><code>## [1] &quot;M258&quot;</code></pre>
<p>We have one site identified as a hotspot. Lets maps it out too.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-09-17-HotSpot_files/figure-html/unnamed-chunk-15-1.png" alt="Soil total phosphorus hotspots identified using the Getis-Ord $G_{i}^{*}$ spatial statistic."  />
<p class="caption">
Soil total phosphorus hotspots identified using the Getis-Ord <span class="math inline">\(G_{i}^{*}\)</span> spatial statistic.
</p>
</div>
<p>For context, this soil TP hotspot occurs near discharge locations into Water Conservation Area 2A. Historically run-off from the upstream agricultural area would be diverted to the area to protection both the agricultural area and the downstream urban areas. Currently restoration activities has eliminated these direct discharge and water quality has improved. However, we still see the legacy affect from past water management. If your interested in how the system is responding check out the <a href="https://www.sfwmd.gov/science-data/scientific-publications-sfer" target="_blank">South Florida Environmental Report</a> here is last years <a href="https://apps.sfwmd.gov/sfwmd/SFER/2020_sfer_final/v1/chapters/v1_ch3a.pdf" target="_blank">Everglades Water Quality</a> chapter.</p>
<p>If you would like more background on hotspot analysis, ESRI produces a pretty good resource on <a href="https://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-how-hot-spot-analysis-getis-ord-gi-spatial-stati.htm" target="_blank">Getis-Ord <span class="math inline">\(G_{i}^{*}\)</span></a>.</p>
<p>This analysis can also be spatially aggregated (from ESRI) in the R by creating a grid, aggregating the data, estimate the nearest neighbor and evaluating on a local or global scale (maybe we will get to that another time).</p>
<p><img src="https://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/GUID-D66FFAA9-4DA8-4883-960F-A807F32CF89D-web.png" width="75%" style="display: block; margin: auto;" /></p>
<hr />
<div id="refs" class="references">
<div id="ref-getis_analysis_2010">
<p>Getis, Arthur, and J. K. Ord. 2010. “The Analysis of Spatial Association by Use of Distance Statistics.” <em>Geographical Analysis</em> 24 (3): 189–206. <a href="https://doi.org/10.1111/j.1538-4632.1992.tb00261.x">https://doi.org/10.1111/j.1538-4632.1992.tb00261.x</a>.</p>
</div>
</div>
</div>
</div>
</div>
</section>
