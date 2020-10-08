---
title: "Nearest Neighbor and Hot Spot Analysis - Geospatial data analysis in #rstats. Part 3b"


date: "October 8,2020"
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> geostatistics, R, nearest neighbor, Getis-Ord</p>
<p>As promised here is another follow-up to our Geospatial data analysis blog series. So far we have covered interpolaiton, spatial auto-correlation and the basics of Hot-Spot (Getis-Ord) analysis.</p>
<ul>
<li><p>Part I: <a href="https://swampthingecology.org/blog/geospatial-data-analysis-in-rstats.-part-1/" target="_blank">Interpolation</a></p></li>
<li><p>Part 2: <a href="https://swampthingecology.org/blog/geospatial-data-analysis-in-rstats.-part-2/" target="_blank">Spatial Autocorrelation</a></p></li>
<li><p>Part 3: <a href="https://swampthingecology.org/blog/hot-spot-analysis-geospatial-data-analysis-in-rstats.-part-3/" target="_blank">Hot Spot Analysis</a></p></li>
</ul>
<p>In this post we will discuss nearest neighbor estimates and how it can affect hot spot detection. In essence this is <strong>“Getis-Ord Strikes Back”</strong> (sorry my Star Wars nerd is showing).</p>
<hr />
<p>Let’s take a step back before jumping back into nearest neighbor (see my post on <a href="https://swampthingecology.org/blog/geospatial-data-analysis-in-rstats.-part-2/" target="_blank">Moran’s <em>I</em></a>). Most spatial statistics compare a test statistic estimated from the data then compared to an expected value given the null hypothesis of complete spatial randomness (CSR; <span class="citation">Fortin and Dale (<a href="#ref-fortin_spatial_2005" role="doc-biblioref">2005</a>)</span>; <em>not to be confused with <code>CRS(...)</code> coordinate reference system</em>). This is a point process model that can be estimated from a particular distribution, in most cases a Poisson <span class="citation">(Diggle <a href="#ref-diggle_spatio-temporal_2006" role="doc-biblioref">2006</a>)</span>. A theme in the analysis of spatial point patterns such as Moran’s <em>I</em>, Getis-Ord <em>G</em> or Ripley’s <em>K</em> provides a distinction between spatial patterns where CSR is a dividing hypothesis <span class="citation">(Cox <a href="#ref-cox_role_1977" role="doc-biblioref">1977</a>)</span>, which leads to classification of random (complete spatial randomness), under-dispersed (clumped or aggregated), or over-dispersed (spaced or regular) patterns.</p>
<!-- resource: 
https://joparga3.github.io/spatial_point_pattern/ 
https://www.seas.upenn.edu/~ese502/NOTEBOOK/Part_I/2_Models_of_Spatial_Randomness.pdf
https://training.fws.gov/courses/references/tutorials/geospatial/CSP7304/documents/PointPatterTutorial.pdf

### Models of Spatial Randomness

The _Principle of Insufficient Reason_ or Laplace Principle asserts that if there is no information to indicate that either of two events is more likely than others, then they should be treated as equally likely. Translating this into a graphical explanation, if we have an area divided in equal areas, there is no reason to believe that this point is more likely to appear in either left half or the (identical) right half.  If we look at the image below, for the first case, any given point should have the same probability (1/2) of appearing in either half of the area. If we divide the areas again by half, then points should have the same probability (1/4) of appearing in any of the 4 squares and so on. 

<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-10-08-NN_HotSpot_files/figure-html/Laplace-1.png" style="display: block; margin: auto;" />

Therefore the assumptions of spatially random models are: 

1. Without any given information on the likelihood of events occurring being different across the dataset (study area), the probability should be the same for all events across the study area (Laplace Principal).

2. Locations of points have no influence on one another (i.e. spatial autocorrelation)

-->
<p>Below we are going to import some data, use different techniques to estimate nearest neighbor and see how that affects Hot spot detection.</p>
<div id="lets-get-started" class="section level3">
<h3>Let’s get started</h3>
<p>Before we get too deep into things here are the necessary packages we will be using.</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" title="1"><span class="co">## Libraries</span></a>
<a class="sourceLine" id="cb1-2" title="2"><span class="co"># read xlsx files</span></a>
<a class="sourceLine" id="cb1-3" title="3"><span class="kw">library</span>(readxl)</a>
<a class="sourceLine" id="cb1-4" title="4"></a>
<a class="sourceLine" id="cb1-5" title="5"><span class="co"># Geospatial </span></a>
<a class="sourceLine" id="cb1-6" title="6"><span class="kw">library</span>(rgdal)</a>
<a class="sourceLine" id="cb1-7" title="7"><span class="kw">library</span>(rgeos)</a>
<a class="sourceLine" id="cb1-8" title="8"><span class="kw">library</span>(raster)</a>
<a class="sourceLine" id="cb1-9" title="9"><span class="kw">library</span>(spdep)</a></code></pre></div>
<p>Same data and links from last post.</p>
<ul>
<li><p>Download the data (as a zip file) <a href="https://www.epa.gov/sites/production/files/2014-03/sf1data.zip" target="_blank">here</a>!</p></li>
<li><p>Download the Water Conservation Areas shapefile <a href="%22https://www.swampthingecology.org/blog/data/hotspot/WCAs.zip%22" target="&quot;_blank">here</a>!</p></li>
</ul>
<div class="sourceCode" id="cb2"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb2-1" title="1"><span class="co"># Define spatial datum</span></a>
<a class="sourceLine" id="cb2-2" title="2">utm17&lt;-<span class="kw">CRS</span>(<span class="st">&quot;+proj=utm +zone=17 +datum=WGS84 +units=m&quot;</span>)</a>
<a class="sourceLine" id="cb2-3" title="3">wgs84&lt;-<span class="kw">CRS</span>(<span class="st">&quot;+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0&quot;</span>)</a>
<a class="sourceLine" id="cb2-4" title="4"></a>
<a class="sourceLine" id="cb2-5" title="5"><span class="co"># Read shapefile</span></a>
<a class="sourceLine" id="cb2-6" title="6">wcas&lt;-<span class="kw">readOGR</span>(GISdata,<span class="st">&quot;WCAs&quot;</span>)</a>
<a class="sourceLine" id="cb2-7" title="7">wcas&lt;-<span class="kw">spTransform</span>(wcas,utm17)</a>
<a class="sourceLine" id="cb2-8" title="8"></a>
<a class="sourceLine" id="cb2-9" title="9"><span class="co"># Read the spreadsheet</span></a>
<a class="sourceLine" id="cb2-10" title="10">p12&lt;-readxl<span class="op">::</span><span class="kw">read_xls</span>(<span class="st">&quot;data/P12join7FINAL.xls&quot;</span>,<span class="dt">sheet=</span><span class="dv">2</span>)</a>
<a class="sourceLine" id="cb2-11" title="11"></a>
<a class="sourceLine" id="cb2-12" title="12"><span class="co"># Clean up the headers</span></a>
<a class="sourceLine" id="cb2-13" title="13"><span class="kw">colnames</span>(p12)&lt;-<span class="kw">sapply</span>(<span class="kw">strsplit</span>(<span class="kw">names</span>(p12),<span class="st">&quot;</span><span class="ch">\\</span><span class="st">$&quot;</span>),<span class="st">&quot;[&quot;</span>,<span class="dv">1</span>)</a>
<a class="sourceLine" id="cb2-14" title="14">p12&lt;-<span class="kw">data.frame</span>(p12)</a>
<a class="sourceLine" id="cb2-15" title="15">p12[p12<span class="op">==-</span><span class="dv">9999</span>]&lt;-<span class="ot">NA</span></a>
<a class="sourceLine" id="cb2-16" title="16">p12[p12<span class="op">==-</span><span class="fl">3047.6952</span>]&lt;-<span class="ot">NA</span></a>
<a class="sourceLine" id="cb2-17" title="17"></a>
<a class="sourceLine" id="cb2-18" title="18"><span class="co"># Convert the data.frame() to SpatialPointsDataFrame</span></a>
<a class="sourceLine" id="cb2-19" title="19">vars&lt;-<span class="kw">c</span>(<span class="st">&quot;STA_ID&quot;</span>,<span class="st">&quot;CYCLE&quot;</span>,<span class="st">&quot;SUBAREA&quot;</span>,<span class="st">&quot;DECLONG&quot;</span>,<span class="st">&quot;DECLAT&quot;</span>,<span class="st">&quot;DATE&quot;</span>,<span class="st">&quot;TPSDF&quot;</span>)</a>
<a class="sourceLine" id="cb2-20" title="20">p12.shp&lt;-<span class="kw">SpatialPointsDataFrame</span>(<span class="dt">coords=</span>p12[,<span class="kw">c</span>(<span class="st">&quot;DECLONG&quot;</span>,<span class="st">&quot;DECLAT&quot;</span>)],</a>
<a class="sourceLine" id="cb2-21" title="21">                               <span class="dt">data=</span>p12[,vars],<span class="dt">proj4string =</span>wgs84)</a>
<a class="sourceLine" id="cb2-22" title="22"><span class="co"># transform to UTM (something I like to do...but not necessary)</span></a>
<a class="sourceLine" id="cb2-23" title="23">p12.shp&lt;-<span class="kw">spTransform</span>(p12.shp,utm17)</a>
<a class="sourceLine" id="cb2-24" title="24"></a>
<a class="sourceLine" id="cb2-25" title="25"><span class="co"># Subset the data for wet season data only and only WCA sites</span></a>
<a class="sourceLine" id="cb2-26" title="26">p12.shp2&lt;-<span class="kw">subset</span>(p12.shp,CYCLE<span class="op">%in%</span><span class="kw">c</span>(<span class="dv">0</span>,<span class="dv">2</span>))</a>
<a class="sourceLine" id="cb2-27" title="27">p12.shp.wca&lt;-p12.shp2[wcas,]</a>
<a class="sourceLine" id="cb2-28" title="28"></a>
<a class="sourceLine" id="cb2-29" title="29"><span class="co"># Double check for NAs in the dataset</span></a>
<a class="sourceLine" id="cb2-30" title="30"><span class="kw">subset</span>(p12.shp.wca<span class="op">@</span>data,<span class="kw">is.na</span>(TPSDF)<span class="op">==</span>T)</a>
<a class="sourceLine" id="cb2-31" title="31"></a>
<a class="sourceLine" id="cb2-32" title="32"><span class="co"># Remove NA sample</span></a>
<a class="sourceLine" id="cb2-33" title="33">p12.shp.wca&lt;-<span class="kw">subset</span>(p12.shp.wca,<span class="kw">is.na</span>(TPSDF)<span class="op">==</span>F)</a></code></pre></div>
<p>Here is a quick map the of the subsetted data</p>
<div class="sourceCode" id="cb3"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb3-1" title="1"><span class="kw">par</span>(<span class="dt">mar=</span><span class="kw">c</span>(<span class="fl">0.1</span>,<span class="fl">0.1</span>,<span class="fl">0.1</span>,<span class="fl">0.1</span>),<span class="dt">oma=</span><span class="kw">c</span>(<span class="dv">0</span>,<span class="dv">0</span>,<span class="dv">0</span>,<span class="dv">0</span>))</a>
<a class="sourceLine" id="cb3-2" title="2"><span class="kw">plot</span>(wcas)</a>
<a class="sourceLine" id="cb3-3" title="3"><span class="kw">plot</span>(p12.shp.wca,<span class="dt">pch=</span><span class="dv">21</span>,<span class="dt">bg=</span><span class="kw">adjustcolor</span>(<span class="st">&quot;dodgerblue1&quot;</span>,<span class="fl">0.5</span>),<span class="dt">cex=</span><span class="dv">1</span>,<span class="dt">add=</span>T)</a>
<a class="sourceLine" id="cb3-4" title="4">mapmisc<span class="op">::</span><span class="kw">scaleBar</span>(utm17,<span class="st">&quot;bottomright&quot;</span>,<span class="dt">bty=</span><span class="st">&quot;n&quot;</span>,<span class="dt">cex=</span><span class="dv">1</span>,<span class="dt">seg.len=</span><span class="dv">4</span>)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-10-08-NN_HotSpot_files/figure-html/unnamed-chunk-3-1.png" alt="Monitoring location from R-EMAP Phase I, wet season sampling (cycles 0 and 2) within the Water Conservation Areas."  />
<p class="caption">
Monitoring location from R-EMAP Phase I, wet season sampling (cycles 0 and 2) within the Water Conservation Areas.
</p>
</div>
</div>
<div id="nearest-neighbor" class="section level3">
<h3>Nearest Neighbor</h3>
<p>As discussed in our prior blog post, average nearest neighbor (ANN) analysis measures the average distance from each point in the study area to its nearest point. In some cases, this methods can be sensitive to which distance bands are identified and can therefore be carried forward into other analyses that rely on nearest neighbor spatial weighting. However, ANN statistic is one of many distance based point pattern analysis statistics that can be used to spatially weight the dataset necessary for spatial statistical evaluation. Others include K, L and pair correlation function (g; not to confused with Getis-Ord <em>G</em>) <span class="citation">(Gimond <a href="#ref-gimond_intro_2020" role="doc-biblioref">2020</a>)</span>.</p>
<!-- https://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-how-average-nearest-neighbor-distance-spatial-st.htm#:~:text=The%20average%20nearest%20neighbor%20ratio,covering%20the%20same%20total%20area). -->
<p>One way to spatially weight the data is by using the <code>dnearneigh()</code> function which identifies neighbors within the lower and upper bounds (provided in the function) by Euclidean distance. Here is where selection of “distance bands” matter. This function was used in the initial <a href="https://swampthingecology.org/blog/hot-spot-analysis-geospatial-data-analysis-in-rstats.-part-3/" target="_blank">Hot-Spot</a> blog post. Lets see how changing the upper bounds in the <code>dnearneigh()</code> can affect the outcome.</p>
<div class="sourceCode" id="cb4"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb4-1" title="1"><span class="co"># Find distance range</span></a>
<a class="sourceLine" id="cb4-2" title="2">ptdist=<span class="kw">pointDistance</span>(p12.shp.wca)</a>
<a class="sourceLine" id="cb4-3" title="3"></a>
<a class="sourceLine" id="cb4-4" title="4">min.dist&lt;-<span class="kw">min</span>(ptdist); <span class="co"># Minimum</span></a>
<a class="sourceLine" id="cb4-5" title="5"></a>
<a class="sourceLine" id="cb4-6" title="6">q10.dist&lt;-<span class="kw">as.numeric</span>(<span class="kw">quantile</span>(ptdist,<span class="dt">probs=</span><span class="fl">0.10</span>)); <span class="co"># Q10</span></a>
<a class="sourceLine" id="cb4-7" title="7">q25.dist&lt;-<span class="kw">as.numeric</span>(<span class="kw">quantile</span>(ptdist,<span class="dt">probs=</span><span class="fl">0.25</span>)); <span class="co"># Q25</span></a>
<a class="sourceLine" id="cb4-8" title="8">q75.dist&lt;-<span class="kw">as.numeric</span>(<span class="kw">quantile</span>(ptdist,<span class="dt">probs=</span><span class="fl">0.75</span>)); <span class="co"># Q75</span></a>
<a class="sourceLine" id="cb4-9" title="9"></a>
<a class="sourceLine" id="cb4-10" title="10"><span class="co"># Using 25th percentile distance for upper bound</span></a>
<a class="sourceLine" id="cb4-11" title="11">nb.q10&lt;-<span class="kw">dnearneigh</span>(<span class="kw">coordinates</span>(p12.shp.wca),min.dist,q10.dist)</a>
<a class="sourceLine" id="cb4-12" title="12"></a>
<a class="sourceLine" id="cb4-13" title="13"><span class="co"># Using 25th percentile distance for upper bound</span></a>
<a class="sourceLine" id="cb4-14" title="14">nb.q25&lt;-<span class="kw">dnearneigh</span>(<span class="kw">coordinates</span>(p12.shp.wca),min.dist,q25.dist)</a>
<a class="sourceLine" id="cb4-15" title="15"></a>
<a class="sourceLine" id="cb4-16" title="16"><span class="co"># Using 75th percentile distance for upper bound</span></a>
<a class="sourceLine" id="cb4-17" title="17">nb.q75&lt;-<span class="kw">dnearneigh</span>(<span class="kw">coordinates</span>(p12.shp.wca),min.dist,q75.dist)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-10-08-NN_HotSpot_files/figure-html/unnamed-chunk-5-1.png" alt="Neighborhood network with different upper bound values"  />
<p class="caption">
Neighborhood network with different upper bound values
</p>
</div>
<p>As you can see the number of links between locations increases as the upper bound is expanded thereby increasing the average number of links within the network. How would this potentially influence the detection of clusters within the data set. Remember the last <a href="https://swampthingecology.org/blog/hot-spot-analysis-geospatial-data-analysis-in-rstats.-part-3/" target="_blank">Hot-Spot</a> blog post? Well lets run through the code, below is using the 10th quantile as the upper bound as an example.</p>
<div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb5-1" title="1"><span class="co"># Convert nearest neighbor to a list</span></a>
<a class="sourceLine" id="cb5-2" title="2">nb_lw&lt;-<span class="kw">nb2listw</span>(nb.q10)</a>
<a class="sourceLine" id="cb5-3" title="3"></a>
<a class="sourceLine" id="cb5-4" title="4"><span class="co"># local G</span></a>
<a class="sourceLine" id="cb5-5" title="5">local_g&lt;-<span class="kw">localG</span>(p12.shp.wca<span class="op">$</span>TPSDF,nb_lw)</a>
<a class="sourceLine" id="cb5-6" title="6"></a>
<a class="sourceLine" id="cb5-7" title="7"><span class="co"># convert to matrix</span></a>
<a class="sourceLine" id="cb5-8" title="8">local_g.ma=<span class="kw">as.matrix</span>(local_g)</a>
<a class="sourceLine" id="cb5-9" title="9"></a>
<a class="sourceLine" id="cb5-10" title="10"><span class="co"># column-bind the local_g data</span></a>
<a class="sourceLine" id="cb5-11" title="11">p12.shp.wca&lt;-<span class="kw">cbind</span>(p12.shp.wca,local_g.ma)</a>
<a class="sourceLine" id="cb5-12" title="12"></a>
<a class="sourceLine" id="cb5-13" title="13"><span class="co"># change the names of the new column</span></a>
<a class="sourceLine" id="cb5-14" title="14"><span class="kw">names</span>(p12.shp.wca)[<span class="kw">ncol</span>(p12.shp.wca)]=<span class="st">&quot;localg.Q10&quot;</span></a>
<a class="sourceLine" id="cb5-15" title="15"></a>
<a class="sourceLine" id="cb5-16" title="16"><span class="co"># determine p-value of z-score</span></a>
<a class="sourceLine" id="cb5-17" title="17">p12.shp.wca<span class="op">$</span>pval.q10&lt;-<span class="st"> </span><span class="dv">2</span><span class="op">*</span><span class="kw">pnorm</span>(<span class="op">-</span><span class="kw">abs</span>(p12.shp.wca<span class="op">$</span>localg.Q10))</a>
<a class="sourceLine" id="cb5-18" title="18"></a>
<a class="sourceLine" id="cb5-19" title="19"><span class="co"># See if any site is a &quot;Hot-Spot&quot;</span></a>
<a class="sourceLine" id="cb5-20" title="20"><span class="kw">subset</span>(p12.shp.wca<span class="op">@</span>data,localg.Q10<span class="op">&gt;</span><span class="dv">0</span><span class="op">&amp;</span>pval.q10<span class="op">&lt;</span><span class="fl">0.05</span>)<span class="op">$</span>STA_ID</a></code></pre></div>
<pre><code>##  [1] &quot;M009&quot; &quot;M011&quot; &quot;M012&quot; &quot;M014&quot; &quot;M015&quot; &quot;M024&quot; &quot;M025&quot; &quot;M027&quot; &quot;M028&quot; &quot;M029&quot;
## [11] &quot;M032&quot; &quot;M033&quot; &quot;M034&quot; &quot;M260&quot; &quot;M261&quot; &quot;M262&quot; &quot;M274&quot; &quot;M276&quot; &quot;M278&quot; &quot;M280&quot;
## [21] &quot;M282&quot;</code></pre>
<p>Looks like a couple of sites are considered Hot-Spots. Now do that same thing for <code>nb.q25</code> and <code>nb.q75</code> and this is what you get.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-10-08-NN_HotSpot_files/figure-html/unnamed-chunk-8-1.png" alt="Soil total phosphorus hot-spots identified using the Getis-Ord $G_{i}^{*}$ spatial statistic based on different nearest neighbor bands."  />
<p class="caption">
Soil total phosphorus hot-spots identified using the Getis-Ord <span class="math inline">\(G_{i}^{*}\)</span> spatial statistic based on different nearest neighbor bands.
</p>
</div>
<p>Hot-Spots are identified with <span class="math inline">\(G_{i}^{*}\)</span> &gt; 0 and associated with significant <span class="math inline">\(\rho\)</span> values (in this cast our <span class="math inline">\(\alpha\)</span> is 0.05). Alternatively “Cold-Spots”, or areas associated with clustering of relatively low values are identified with <span class="math inline">\(G_{i}^{*}\)</span> &lt; 0 (and significant <span class="math inline">\(\rho\)</span> values). Across the three different distance bands, you can see a potential shift in Hot-Spots and the occurrence (and shift) of Cold-Spots across the study area.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-10-08-NN_HotSpot_files/figure-html/unnamed-chunk-9-1.png" alt="Number of sites identified as Hot-Spots across the study by Nearest Neigbhor upper bound band."  />
<p class="caption">
Number of sites identified as Hot-Spots across the study by Nearest Neigbhor upper bound band.
</p>
</div>
<p>An alternative to selecting distance bands is to use a different approach such as K-function or K nearest neighbors. K-function summarizes the distance between points for <em>all</em> distances <span class="citation">(Gimond <a href="#ref-gimond_intro_2020" role="doc-biblioref">2020</a>)</span>. This method can also be sensitive to distance bands but less so than above. In k-function nearest neighbor using <code>knearneigh()</code>, the function will eventually give a warning letting you know but will still compute the values anyways.</p>
<pre><code>Warning messages:
1: In knearneigh(p12.shp.wca, k = 45) :
  k greater than one-third of the number of data points</code></pre>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-10-08-NN_HotSpot_files/figure-html/unnamed-chunk-10-1.png" alt="The affect of the number of nearest neighbors on average nearest neighbor distance."  />
<p class="caption">
The affect of the number of nearest neighbors on average nearest neighbor distance.
</p>
</div>
<p>Based on the plot above, a <code>k=6</code> seems to be conservative enough. As suggested in the last blog post this could be done by…</p>
<div class="sourceCode" id="cb8"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb8-1" title="1">k1&lt;-<span class="kw">knn2nb</span>(<span class="kw">knearneigh</span>(p12.shp.wca,<span class="dt">k=</span><span class="dv">6</span>))</a></code></pre></div>
<!-- Some resources
https://daviddalpiaz.github.io/r4sl/knn-class.html
-->
<div class="sourceCode" id="cb9"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb9-1" title="1"><span class="co"># Convert nearest neighbor to a list</span></a>
<a class="sourceLine" id="cb9-2" title="2">nb_lw&lt;-<span class="kw">nb2listw</span>(k1)</a>
<a class="sourceLine" id="cb9-3" title="3"></a>
<a class="sourceLine" id="cb9-4" title="4"><span class="co"># local G</span></a>
<a class="sourceLine" id="cb9-5" title="5">local_g&lt;-<span class="kw">localG</span>(p12.shp.wca<span class="op">$</span>TPSDF,nb_lw)</a>
<a class="sourceLine" id="cb9-6" title="6"></a>
<a class="sourceLine" id="cb9-7" title="7"><span class="co"># convert to matrix</span></a>
<a class="sourceLine" id="cb9-8" title="8">local_g.ma=<span class="kw">as.matrix</span>(local_g)</a>
<a class="sourceLine" id="cb9-9" title="9"></a>
<a class="sourceLine" id="cb9-10" title="10"><span class="co"># column-bind the local_g data</span></a>
<a class="sourceLine" id="cb9-11" title="11">p12.shp.wca&lt;-<span class="kw">cbind</span>(p12.shp.wca,local_g.ma)</a>
<a class="sourceLine" id="cb9-12" title="12"></a>
<a class="sourceLine" id="cb9-13" title="13"><span class="co"># change the names of the new column</span></a>
<a class="sourceLine" id="cb9-14" title="14"><span class="kw">names</span>(p12.shp.wca)[<span class="kw">ncol</span>(p12.shp.wca)]=<span class="st">&quot;localg.k&quot;</span></a>
<a class="sourceLine" id="cb9-15" title="15"></a>
<a class="sourceLine" id="cb9-16" title="16"><span class="co"># determine p-value of z-score</span></a>
<a class="sourceLine" id="cb9-17" title="17">p12.shp.wca<span class="op">$</span>pval.k&lt;-<span class="st"> </span><span class="dv">2</span><span class="op">*</span><span class="kw">pnorm</span>(<span class="op">-</span><span class="kw">abs</span>(p12.shp.wca<span class="op">$</span>localg.k))</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-10-08-NN_HotSpot_files/figure-html/unnamed-chunk-13-1.png" alt="Soil total phosphorus hot-spots identified using the Getis-Ord $G_{i}^{*}$ spatial statistic with k-function nearest neighbor spatial weighting."  />
<p class="caption">
Soil total phosphorus hot-spots identified using the Getis-Ord <span class="math inline">\(G_{i}^{*}\)</span> spatial statistic with k-function nearest neighbor spatial weighting.
</p>
</div>
<p>using K-function nearest neighbor we have the occurrence of Hot-Spots in the general area of the other evaluations presented above. As suggested in the original Hot-Spot blog, the selection of spatial weights is important and the test is sensitive to the weights assigned.</p>
<p>The next post will cover how spatial aggregation can play a role in Hot-Spot detection. Until then I’ll leave you with this quote that helps put spatial statistical analysis into perspective.</p>
<blockquote>
<p>“The first law of geography: Everything is related to everything else, but near things are more related than distant things.” <span class="citation">(Tobler <a href="#ref-tobler_computer_1970" role="doc-biblioref">1970</a>)</span></p>
</blockquote>
<hr />
<div id="refs" class="references">
<div id="ref-cox_role_1977">
<p>Cox, D. R. 1977. “The Role of Significance Tests.” <em>Scandinavian Journal of Statistics</em> 4 (2): 49–63. <a href="https://www.jstor.org/stable/4615652">https://www.jstor.org/stable/4615652</a>.</p>
</div>
<div id="ref-diggle_spatio-temporal_2006">
<p>Diggle, Peter J. 2006. “Spatio-Temporal Point Processes: Methods and Applications.” <em>Monographs on Statistics and Applied Probability</em> 107: 1–45.</p>
</div>
<div id="ref-fortin_spatial_2005">
<p>Fortin, Marie-Josée, and Mark R. T. Dale. 2005. <em>Spatial Analysis: A Guide for Ecologists</em>. Cambridge University Press.</p>
</div>
<div id="ref-gimond_intro_2020">
<p>Gimond, Manuel. 2020. <em>Intro to GIS and Spatial Analysis</em>. <a href="https://mgimond.github.io/Spatial/index.html">https://mgimond.github.io/Spatial/index.html</a>.</p>
</div>
<div id="ref-tobler_computer_1970">
<p>Tobler, W. R. 1970. “A Computer Movie Simulating Urban Growth in the Detroit Region.” <em>Economic Geography</em> 46 (June): 234. <a href="https://doi.org/10.2307/143141">https://doi.org/10.2307/143141</a>.</p>
</div>
</div>
</div>
</section>
