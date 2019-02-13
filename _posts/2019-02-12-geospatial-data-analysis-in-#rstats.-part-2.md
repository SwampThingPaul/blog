---
title: "Geospatial data analysis in #rstats. Part 2"


date: "February 12, 2019"
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> geostatistics, R, autocorrelation, Moran, soil science</p>
<hr />
<p>Continuing our series on geospatial analysis we are doing to dive into spatial statistics expanding analyses of spatial patterns. In my <a href="https://swampthingpaul.github.io/blog/geospatial-data-analysis-in-rstats.-part-1/" target="_blank">prior post</a> I presented spatial interpolation techniques including kriging. Just like in the last post I will be using <a href="https://swampthingpaul.github.io/blog/mapping-in-rstats/" target="_blank">tmap</a> to display our geospatial data. Also like in the last post I will be using a “fake” dataset from real stations with a randomly generated imposed spatial gradient for demonstration purposes.</p>
<p>First lets load the necessary R-packages/libraries.</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" data-line-number="1"><span class="co"># Libraries</span></a>
<a class="sourceLine" id="cb1-2" data-line-number="2"><span class="kw">library</span>(sp)</a>
<a class="sourceLine" id="cb1-3" data-line-number="3"><span class="kw">library</span>(rgdal)</a>
<a class="sourceLine" id="cb1-4" data-line-number="4"><span class="kw">library</span>(rgeos)</a>
<a class="sourceLine" id="cb1-5" data-line-number="5"><span class="kw">library</span>(maptools)</a>
<a class="sourceLine" id="cb1-6" data-line-number="6"><span class="kw">library</span>(raster)</a>
<a class="sourceLine" id="cb1-7" data-line-number="7"><span class="kw">library</span>(spdep)</a>
<a class="sourceLine" id="cb1-8" data-line-number="8"><span class="kw">library</span>(spatstat)</a>
<a class="sourceLine" id="cb1-9" data-line-number="9"><span class="kw">library</span>(tmap)</a>
<a class="sourceLine" id="cb1-10" data-line-number="10"><span class="kw">library</span>(tmaptools)</a></code></pre></div>
<p>Here is our data from the <a href="https://swampthingpaul.github.io/blog/geospatial-data-analysis-in-rstats.-part-1/" target="_blank">prior post</a>…remember?</p>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/quick%20plot-1.png" style="display: block; margin: auto;" /></p>
<div id="average-nearest-neighbor" class="section level2">
<h2>Average Nearest-Neighbor</h2>
<p>An average nearest neighbor (ANN) analysis measures the average distance from each point in the study area to its nearest point. Average nearest neighbor is exactly what is says it is, the average distance between points (or neighbors) the ultimate analysis involves determining a matrix of distances between points. When plotting ANN as a function of neighbor order it provides some insight into the spatial structure of the data (Gimond 2018).</p>
<p>Here we have three examples a single cluster, dual cluster and a randomly scattering of points.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/f11-diff-patterns-1.png" alt="Three different point patterns: a single cluster (left), a dual cluster (center) and a randomly scattered pattern (right)."  />
<p class="caption">
Three different point patterns: a single cluster (left), a dual cluster (center) and a randomly scattered pattern (right).
</p>
</div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/f11-diff-ANN-plots-1.png" alt="Three different ANN vs. neighbor order plots. The black ANN line is for the first point pattern (single cluster); the blue line is for the second point pattern (double cluster) and the red line is for the third point pattern."  />
<p class="caption">
Three different ANN vs. neighbor order plots. The black ANN line is for the first point pattern (single cluster); the blue line is for the second point pattern (double cluster) and the red line is for the third point pattern.
</p>
</div>
<p>As you can see the more clustered the points the consistent the distance between neighbors. As points become more dispersed, the distances vary from neighbor-to-neighbor, the abrupt change in ANN observed in the clustered points is an indicator of groups/clusters of points and the gradual increase in ANN indicates more-or-less random distribution of points.</p>
<p>What does the ANN network look like for our data? Remember our thessian polygon of the monitoring network from the last <a href="https://swampthingpaul.github.io/blog/geospatial-data-analysis-in-rstats.-part-1/" target="_blank">post</a>?</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/Thessian-plots-1.png" alt="Thessian polygons clipped to study area."  />
<p class="caption">
Thessian polygons clipped to study area.
</p>
</div>
<div class="sourceCode" id="cb2"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb2-1" data-line-number="1"><span class="co">#th.dat is the thessian polygons above. </span></a>
<a class="sourceLine" id="cb2-2" data-line-number="2">w=<span class="kw">poly2nb</span>(th.dat, <span class="dt">row.names=</span>th.dat<span class="op">$</span>Site);<span class="co">#construct the neighbours list.</span></a>
<a class="sourceLine" id="cb2-3" data-line-number="3"></a>
<a class="sourceLine" id="cb2-4" data-line-number="4"><span class="kw">par</span>(<span class="dt">mar=</span><span class="kw">rep</span>(<span class="fl">0.5</span>,<span class="dv">4</span>),<span class="dt">oma=</span><span class="kw">rep</span>(<span class="dv">0</span>,<span class="dv">4</span>));</a>
<a class="sourceLine" id="cb2-5" data-line-number="5"><span class="kw">plot</span>(th.dat)</a>
<a class="sourceLine" id="cb2-6" data-line-number="6"><span class="kw">plot</span>(w,<span class="kw">coordinates</span>(th.dat), <span class="dt">col=</span><span class="st">&#39;red&#39;</span>, <span class="dt">lwd=</span><span class="fl">0.5</span>,<span class="dt">add=</span>T)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/ANN-1.png" alt="Thessian polygons clipped to the study area with neighborhood network."  />
<p class="caption">
Thessian polygons clipped to the study area with neighborhood network.
</p>
</div>
<p>The <code>poly2nb()</code> function builds a neighbors list based on regions with a contiguous boundary that is sharing one or more boundary point. However, this same concept can be applied for points as well. Much like the <code>poly2nb()</code> function builds the neighbors list, the <code>knearneigh()</code> function also builds a list using a specified number of neighbors to consider (i.e k). As k increases (i.e. data points), more neighbors are considered and thereby influencing the estimated mean distance between nearest neighbors. As a demonstration here is what the network looks like with only six neighbors considered.</p>
<div class="sourceCode" id="cb3"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb3-1" data-line-number="1"><span class="co">#th.dat is the thessian polygons above. </span></a>
<a class="sourceLine" id="cb3-2" data-line-number="2"></a>
<a class="sourceLine" id="cb3-3" data-line-number="3">w2=<span class="kw">knn2nb</span>(<span class="kw">knearneigh</span>(sp.dat,<span class="dt">k=</span><span class="dv">6</span>))</a>
<a class="sourceLine" id="cb3-4" data-line-number="4">w2=<span class="kw">nb2listw</span>(w2)</a>
<a class="sourceLine" id="cb3-5" data-line-number="5"></a>
<a class="sourceLine" id="cb3-6" data-line-number="6"><span class="kw">par</span>(<span class="dt">mar=</span><span class="kw">rep</span>(<span class="fl">0.5</span>,<span class="dv">4</span>),<span class="dt">oma=</span><span class="kw">rep</span>(<span class="dv">0</span>,<span class="dv">4</span>));</a>
<a class="sourceLine" id="cb3-7" data-line-number="7"><span class="kw">plot</span>(w2,<span class="kw">coordinates</span>(sp.dat),<span class="dt">col=</span><span class="st">&quot;red&quot;</span>)</a>
<a class="sourceLine" id="cb3-8" data-line-number="8"><span class="kw">plot</span>(study.area,<span class="dt">add=</span>T)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/ANN-points-1.png" alt="Thessian polygons clipped to the study area with neighborhood network."  />
<p class="caption">
Thessian polygons clipped to the study area with neighborhood network.
</p>
</div>
<p>As you can see the point-based ANN with only six neighbors considered results in a different network. But what affect does the k number have on ANN?</p>
<div class="sourceCode" id="cb4"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb4-1" data-line-number="1">ANN=<span class="kw">apply</span>(<span class="kw">nndist</span>(<span class="kw">as</span>(sp.dat,<span class="st">&quot;ppp&quot;</span>), <span class="dt">k=</span><span class="dv">1</span><span class="op">:</span><span class="dv">202</span>),<span class="dv">2</span>,<span class="dt">FUN=</span>mean)</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/ANN-point2-1.png" alt="Average Nearest Neighbour as a function of neighbor included."  />
<p class="caption">
Average Nearest Neighbour as a function of neighbor included.
</p>
</div>
<p>Selection of a K value can also be corrected for various edge corrections, some of you may be heard of <em>Ripley’s K</em>-function (Ripley 1977). For purposes of this post we will not delve into this aspect of spatial analysis however if your interested and eager to learn Gimond (2018) introduces some of these concepts in detail.</p>
<p>For purposes of this post we are going with a very simple neighbor list (i.e. <code>w</code> variable above) using the thessian polygons to estimate a spatial weight within the network. This neighbor list comes into play in a little bit. Maybe we can dig into the <em>Ripley’s K</em>-function in a future post.</p>
</div>
<div id="spatial-autocorrelation" class="section level2">
<h2>Spatial Autocorrelation</h2>
<p>Most if not all field data can be characterized as spatial data, especially in ecology. If something is sampled at a particular location there is a spatial component to the data. As such there are some spatial specific statistics that be applied to spatial data to explain how the data relates to the world. One such statistic is spatial autocorrelation.</p>
<p>Spatial autocorrelation measures the degree to which a phenomenon of interest is correlated to itself in space. This statistical analysis evaluates whether the observed value of a variable at one location is independent of values of that variability at neighboring locations.</p>
<ul>
<li><p>Positive spatial autocorrelation indicates similar values appear close to each other (i.e. clustered in space).</p></li>
<li><p>Negative spatial autocorrelation indicates that neighboring values are dissimilar (i.e. dispersed in space).</p></li>
<li><p>No spatial autocorrelation indicates that the spatial pattern is completely random.</p></li>
</ul>
<p>Moran’s <em>I</em> is the most common spatial autocorrelation test however other tests are available (i.e. <a href="https://en.wikipedia.org/wiki/Geary%27s_C" target="_blank">Geary’s C</a>, <a href="https://mltconsecol.github.io/TU_LandscapeAnalysis_Documents/Assignments_web/Assignment06_Autocorrelation.pdf" target="_blank">Join-Count</a>, etc.) each have a specific application much like the different correlation analyses (i.e. Pearson’s, Spearman, Kendall, etc.). Moreover the spatial autocorrelation analysis of spatial data is relatively straight forward.</p>
<p>Spatial analyses can be expressed in a <em>“Global”</em> or <em>“Local”</em> context. Spatial autocorrelation is no different. Global spatial analysis evaluates the data across the entire dataset (i.e. study area) and assumes homogeneity across the dataset. If the data is spatially heterogeneous or also referred to as inhomogeneous local analyses can be applied. For instance if no global spatial autocorrelation is detected autocorrelation can be tested at the local (i.e. individual spatial units). Moran’s <em>I</em> uses local indicators of spatial association to evaluate data at the local and global levels where the global analysis is the sum of local <em>I</em> values.</p>
<p><a href="https://mgimond.github.io/Spatial/point-pattern-analysis-in-r.html" target="_blank">Gimond (2018)</a> and <a href="https://training.fws.gov/courses/references/tutorials/geospatial/CSP7304/documents/PointPatterTutorial.pdf" target="_blank">Baddeley (2008)</a> provides an excellent step-by-step tutorial on point pattern analysis, the basis of spatial homogeneity. I highly recommend taking a look!!</p>
<p>Moran’s <em>I</em> can be calculated long-hand or using the <code>spdep</code> r-package.</p>
<p>Local Moran’s <em>I</em> spatial autocorrelation statistic (<span class="math inline">\(I_i\)</span>), also sometimes referred to as Anselin Local Moran’s <em>I</em> (Anselin 1995) and is calculated by:</p>
<p><span class="math display">\[ I_{i} = \frac{n}{\sum_{i=1}^n (y_i - \bar{y})^2} \times \frac{\sum_{i=1}^n \sum_{j=1}^n w_{ij}(y_i - \bar{y})(y_j - \bar{y})}{\sum_{i=1}^n \sum_{j=1}^n w_{ij}} \]</span> Where <span class="math inline">\(y_{i}\)</span> is the attribute feature (i.e. soil total phosphorus in our case), <span class="math inline">\(\bar{y}\)</span> is the arithmetic mean across the entire study area/spatial unit, <span class="math inline">\(w_{ij}\)</span> is the spatial weight between <span class="math inline">\(i\)</span> and <span class="math inline">\(j\)</span> and <span class="math inline">\(n\)</span> is the total number of features.</p>
<p>As alluded to early in addition to a local statistic we also have a Global metric. Global Moran’s <em>I</em> is merely the sum of the local values divided by the total number of features (<span class="math inline">\(n\)</span>)</p>
<p><span class="math display">\[I = \sum_{i=1} \frac{I_{i}}{n} \]</span></p>
<p>As introduced above, if the Moran’s <em>I</em> statistic is positive indicates that a feature has neighboring features with similarly high or low attribute values; this feature is part of a cluster at the local level. Alternatively if the Moran’s <em>I</em> statistic is negative it indicates that a feature has neighboring features with dissimilar values.Moran’s <em>I</em> statistic is a relative metric and therefore a <span class="math inline">\(z\)</span>score and <span class="math inline">\(\rho\)</span>-value can also be calculated to determine statistical significance.</p>
<p>Enough talk, lets jump into <code>R</code>!!</p>
<p>Lets first calculate Moran’s <em>I</em> statistic by hand to understand the nuts and bolts of the calculate. I often find this is the best way to fully appreciate and understand the statistic. This code has been adapted from <a href="https://rspatial.org/analysis/3-spauto.html" target="_blank">rspatial.org</a>…another fantastic resource well worth bookmarking (<strong>HINT!! HINT!!</strong>).</p>
<div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb5-1" data-line-number="1">wm=<span class="kw">nb2mat</span>(w, <span class="dt">style=</span><span class="st">&#39;B&#39;</span>);<span class="co">#spatial weights matrix</span></a>
<a class="sourceLine" id="cb5-2" data-line-number="2"></a>
<a class="sourceLine" id="cb5-3" data-line-number="3">n=<span class="kw">length</span>(th.dat<span class="op">$</span>TP_mgkg);<span class="co"># total number of features</span></a>
<a class="sourceLine" id="cb5-4" data-line-number="4">y=th.dat<span class="op">$</span>TP_mgkg;<span class="co"># attribute feature</span></a>
<a class="sourceLine" id="cb5-5" data-line-number="5">ybar=<span class="kw">mean</span>(th.dat<span class="op">$</span>TP_mgkg);<span class="co"># mean attribute feature across project area</span></a>
<a class="sourceLine" id="cb5-6" data-line-number="6">dy=y <span class="op">-</span><span class="st"> </span>ybar;<span class="co"># residual value</span></a>
<a class="sourceLine" id="cb5-7" data-line-number="7"></a>
<a class="sourceLine" id="cb5-8" data-line-number="8">yi=<span class="kw">rep</span>(dy, <span class="dt">each=</span>n);<span class="co"># a list of yi</span></a>
<a class="sourceLine" id="cb5-9" data-line-number="9">yj=<span class="kw">rep</span>(dy);<span class="co"># a list of yj</span></a>
<a class="sourceLine" id="cb5-10" data-line-number="10">yiyj=<span class="st"> </span>yi <span class="op">*</span><span class="st"> </span>yj;<span class="co"># cross product of yi and yj</span></a>
<a class="sourceLine" id="cb5-11" data-line-number="11"></a>
<a class="sourceLine" id="cb5-12" data-line-number="12">pm=<span class="kw">matrix</span>(yiyj,<span class="dt">ncol=</span>n);<span class="co"># a matrix of cross products</span></a>
<a class="sourceLine" id="cb5-13" data-line-number="13">pmw=pm <span class="op">*</span><span class="st"> </span>wm;<span class="co"># cross products with spatial weights (w value from above)</span></a>
<a class="sourceLine" id="cb5-14" data-line-number="14">           <span class="co"># set to zero the value for the pairs that are not adjacent</span></a>
<a class="sourceLine" id="cb5-15" data-line-number="15"></a>
<a class="sourceLine" id="cb5-16" data-line-number="16">spmw=<span class="kw">sum</span>(pmw,<span class="dt">na.rm=</span>T);<span class="co"># </span></a>
<a class="sourceLine" id="cb5-17" data-line-number="17">smw=<span class="kw">sum</span>(wm); <span class="co">#Sum of spatial weights</span></a>
<a class="sourceLine" id="cb5-18" data-line-number="18">sw=spmw <span class="op">/</span><span class="st"> </span>smw</a>
<a class="sourceLine" id="cb5-19" data-line-number="19"></a>
<a class="sourceLine" id="cb5-20" data-line-number="20">var=n <span class="op">/</span><span class="st"> </span><span class="kw">sum</span>(dy<span class="op">^</span><span class="dv">2</span>);<span class="co"># variance in y</span></a>
<a class="sourceLine" id="cb5-21" data-line-number="21"></a>
<a class="sourceLine" id="cb5-22" data-line-number="22">MI=var <span class="op">*</span><span class="st"> </span>sw;<span class="co"># Moran&#39;s I </span></a>
<a class="sourceLine" id="cb5-23" data-line-number="23">MI</a></code></pre></div>
<pre><code>## [1] 0.5790256</code></pre>
<p>Now remember the calculated Moran’s <em>I</em> value of 0.579 as we are going to now use the functions in the <code>spdep</code> package to calculate this value and test for significance.</p>
<p>First we need to prep the spatial weights, this time in the form of a list rather than a matrix.</p>
<div class="sourceCode" id="cb7"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb7-1" data-line-number="1">ww &lt;-<span class="st">  </span><span class="kw">nb2listw</span>(w, <span class="dt">style=</span><span class="st">&#39;B&#39;</span>);<span class="co"># puts w in a list rather than a matrix</span></a>
<a class="sourceLine" id="cb7-2" data-line-number="2">ww</a></code></pre></div>
<pre><code>## Characteristics of weights list object:
## Neighbour list object:
## Number of regions: 194 
## Number of nonzero links: 1052 
## Percentage nonzero weights: 2.795196 
## Average number of links: 5.42268 
## 
## Weights style: B 
## Weights constants summary:
##     n    nn   S0   S1    S2
## B 194 37636 1052 2104 24592</code></pre>
<p>Now we can use the <code>moran()</code> function in the <code>spdep</code> package. In this function we plug in the data, number of features (i.e. n) and the global spatial weights <span class="math inline">\(S_0\)</span> (<code>smw</code> variable in the long hand example above).</p>
<div class="sourceCode" id="cb9"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb9-1" data-line-number="1">MI2=<span class="kw">moran</span>(th.dat<span class="op">$</span>TP_mgkg, ww, <span class="dt">n=</span><span class="kw">length</span>(ww<span class="op">$</span>neighbours), <span class="dt">S0=</span><span class="kw">Szero</span>(ww))</a>
<a class="sourceLine" id="cb9-2" data-line-number="2">MI2</a></code></pre></div>
<pre><code>## $I
## [1] 0.5790256
## 
## $K
## [1] 3.243009</code></pre>
<p>The <code>moran()</code> function provides the Moran’s <em>I</em> value (looks similar to the long hand version right?) and the sample kurtosis (K, not to be confused with the K discussed with ANN). Alright, so now we need to determine if the value is statistically significant. We can go about this in two ways. The first is a parametric evaluation of statistical significance the other is a Monte Carlo simulation. The Monte Carlo approach evaluated the observed value of Moran’s I compared with a simulated distribution to see how likely it is that the observed values could be considered a random draw. Let walk through both shall we.</p>
<p>The parametric approach which uses linear regression based logic and assumptions is pretty straight forward.</p>
<div class="sourceCode" id="cb11"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb11-1" data-line-number="1"><span class="kw">moran.test</span>(th.dat<span class="op">$</span>TP_mgkg, ww,<span class="dt">randomisation=</span>F)</a></code></pre></div>
<pre><code>## 
##  Moran I test under normality
## 
## data:  th.dat$TP_mgkg  
## weights: ww    
## 
## Moran I statistic standard deviate = 13.621, p-value &lt; 2.2e-16
## alternative hypothesis: greater
## sample estimates:
## Moran I statistic       Expectation          Variance 
##       0.579025628      -0.005181347       0.001839514</code></pre>
<p>The biggest assumption of this analysis is if the data is normally distributed.</p>
<div class="sourceCode" id="cb13"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb13-1" data-line-number="1"><span class="kw">shapiro.test</span>(th.dat<span class="op">$</span>TP_mgkg)</a></code></pre></div>
<pre><code>## 
##  Shapiro-Wilk normality test
## 
## data:  th.dat$TP_mgkg
## W = 0.97771, p-value = 0.003475</code></pre>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/hist-1.png" alt="Histogram of (fake) soil total phosphorus concnetrations across the study area."  />
<p class="caption">
Histogram of (fake) soil total phosphorus concnetrations across the study area.
</p>
</div>
<p>As you can see the data is not normally distributed, however if the data is log-transformed it becomes normally distributed. Using the <code>moran.test()</code> function with log-transformed data also results in a statistically significant test. Now lets look at the Monte Carlo simulation approach. It is very similar to the above test, except you can specify the number of simulations.</p>
<div class="sourceCode" id="cb15"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb15-1" data-line-number="1">mc.rslt=<span class="kw">moran.mc</span>(th.dat<span class="op">$</span>TP_mgkg, ww,<span class="dt">nsim=</span><span class="dv">200</span>)</a>
<a class="sourceLine" id="cb15-2" data-line-number="2">mc.rslt</a></code></pre></div>
<pre><code>## 
##  Monte-Carlo simulation of Moran I
## 
## data:  th.dat$TP_mgkg 
## weights: ww  
## number of simulations + 1: 201 
## 
## statistic = 0.57903, observed rank = 201, p-value = 0.004975
## alternative hypothesis: greater</code></pre>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/unnamed-chunk-5-1.png" alt="Monte Carlo simulated values versus actual Moran's *I* value. Shaded region indicates density of simulated Moran's *I* versus the actual value (red-line)."  />
<p class="caption">
Monte Carlo simulated values versus actual Moran’s <em>I</em> value. Shaded region indicates density of simulated Moran’s <em>I</em> versus the actual value (red-line).
</p>
</div>
<p>As you can see the actual Moran’s <em>I</em> (i.e. red line) is far outside the simulated data (shaded range) indicating a statistically significantly relationship.</p>
<p>To visualize the spatial autocorrleation in the dataset we can construct a “Moran scatter plot”. This plot displays the spatial data against its spatially lagged values. Much like everything in the R-universe (in a booming voice) “You have the Power…”, as in there are several ways to do something. Below is the most straight forward way I have found to construct a Moran Scatter plot. Also you can identify the data points that have a high influence on the linear relationship between the data and the lag. This plot can easily be done using the <code>moran.plot()</code> function, but learning what goes into the plot helps us appreciate the code behind it…also it allows from customization, think of it as “pimp-my-plot”.</p>
<div class="sourceCode" id="cb17"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb17-1" data-line-number="1"><span class="co">#build a dataframe with scaled and lagged data</span></a>
<a class="sourceLine" id="cb17-2" data-line-number="2">scatter.dat=<span class="kw">data.frame</span>(<span class="dt">SITE=</span>th.dat<span class="op">$</span>Site,</a>
<a class="sourceLine" id="cb17-3" data-line-number="3">                       <span class="dt">sc=</span><span class="kw">scale</span>(th.dat<span class="op">$</span>TP_mgkg),</a>
<a class="sourceLine" id="cb17-4" data-line-number="4">                       <span class="dt">lag_sc=</span><span class="kw">lag.listw</span>(ww,<span class="kw">scale</span>(th.dat<span class="op">$</span>TP_mgkg)));</a>
<a class="sourceLine" id="cb17-5" data-line-number="5"><span class="co">#Linear relationship between scaled and lagged data</span></a>
<a class="sourceLine" id="cb17-6" data-line-number="6">xwx.lm=<span class="kw">lm</span>(lag_sc <span class="op">~</span><span class="st"> </span>sc,scatter.dat)</a>
<a class="sourceLine" id="cb17-7" data-line-number="7"><span class="co">#Predicted line (and prediction/confidence interval)</span></a>
<a class="sourceLine" id="cb17-8" data-line-number="8">xwx.lm.pred=<span class="kw">data.frame</span>(<span class="dt">x.val=</span><span class="kw">seq</span>(<span class="op">-</span><span class="dv">2</span>,<span class="dv">3</span>,<span class="fl">0.5</span>),</a>
<a class="sourceLine" id="cb17-9" data-line-number="9">                       <span class="kw">predict</span>(xwx.lm,<span class="kw">data.frame</span>(<span class="dt">sc=</span><span class="kw">seq</span>(<span class="op">-</span><span class="dv">2</span>,<span class="dv">3</span>,<span class="fl">0.5</span>)),<span class="dt">interval=</span><span class="st">&quot;confidence&quot;</span>))</a>
<a class="sourceLine" id="cb17-10" data-line-number="10"></a>
<a class="sourceLine" id="cb17-11" data-line-number="11"><span class="co">#Identify data points of high influence.</span></a>
<a class="sourceLine" id="cb17-12" data-line-number="12">infl.xwx=<span class="kw">influence.measures</span>(xwx.lm)</a>
<a class="sourceLine" id="cb17-13" data-line-number="13">infl.xwx.pt=<span class="kw">which</span>(<span class="kw">apply</span>(infl.xwx<span class="op">$</span>is.inf, <span class="dv">1</span>, any))</a>
<a class="sourceLine" id="cb17-14" data-line-number="14"><span class="co">#scatter.dat[infl.xwx.pt,]</span></a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/unnamed-chunk-7-1.png" alt="Moran's Scatter Plot with points of high influence (red-diamonds) and linear relationship (red line) identified. "  />
<p class="caption">
Moran’s Scatter Plot with points of high influence (red-diamonds) and linear relationship (red line) identified.
</p>
</div>
<p>Based on this global evaluation of the dataset we can conclude that based on the significantly positive Moran’s <em>I</em> value that similar values appear close to each other (i.e. clustered in space). This is where we can dive into the data and evaluate areas of clustering possibly alluding to a hotspot.</p>
<p>Similarly to the global analysis (above) local Moran’s <em>I</em> relays on spatial weights of objects to calculate the test statistic (see equations above).</p>
<div class="sourceCode" id="cb18"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb18-1" data-line-number="1">locali=<span class="kw">localmoran</span>(th.dat<span class="op">$</span>TP_mgkg,ww)</a>
<a class="sourceLine" id="cb18-2" data-line-number="2"></a>
<a class="sourceLine" id="cb18-3" data-line-number="3"><span class="co">#Store test statistic results</span></a>
<a class="sourceLine" id="cb18-4" data-line-number="4">th.dat<span class="op">$</span>locali.val=locali[,<span class="dv">1</span>]</a>
<a class="sourceLine" id="cb18-5" data-line-number="5">th.dat<span class="op">$</span>locali.pval=locali[,<span class="dv">5</span>]</a></code></pre></div>
<p>To identify potential clusters of data we must identify attribute features that are both statistically significant (<span class="math inline">\(\rho&lt;0.05\)</span>) and positive Moran’s <span class="math inline">\(I_i\)</span>.</p>
<div class="sourceCode" id="cb19"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb19-1" data-line-number="1">th.dat<span class="op">$</span>cluster=<span class="kw">with</span>(th.dat<span class="op">@</span>data,</a>
<a class="sourceLine" id="cb19-2" data-line-number="2">                    <span class="kw">as.factor</span>(<span class="kw">ifelse</span>(locali.val<span class="op">&gt;</span><span class="dv">0</span><span class="op">&amp;</span>locali.pval<span class="op">&lt;=</span><span class="fl">0.05</span>,</a>
<a class="sourceLine" id="cb19-3" data-line-number="3">                                     <span class="st">&quot;Clustered&quot;</span>,<span class="st">&quot;Not Clustered&quot;</span>)))</a></code></pre></div>
<p>Now lets look at what we have.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-02-12-RGeostat2_files/figure-html/unnamed-chunk-10-1.png" alt="Left: Local Moran's Clusters as indicated with positive Moran's $I_i$ and a $\rho$ value equal to or less-than 0.05. Right: Soil total phosphorus data (fictious data)."  />
<p class="caption">
Left: Local Moran’s Clusters as indicated with positive Moran’s <span class="math inline">\(I_i\)</span> and a <span class="math inline">\(\rho\)</span> value equal to or less-than 0.05. Right: Soil total phosphorus data (fictious data).
</p>
</div>
<p>In our (fake) example data we have Here we see two distinct clusters of data (red areas). When we look at the soil TP concentration data we see an area of high concentration to the north and an area of low concentration to the south. Therefore, we can conclude we have two potential clusters of data representing a high and low cluster of values.</p>
<p>Hope this has provided some insight to geospatial statistical analysis.Much like the last blog post, this is by no means a comprehensive workflow of spatial autocorrelation. Other types of spatial autocorrelation analyses are available with each having their own limitation and application. Feel free to explore the world-wide web and don’t be afraid to use <code>?</code>. Originally I was also going to delve into hot-spot detection using Getis Ord statistics but I think it would be better to reserve that for the next post.</p>
<hr />
</div>
<div id="references" class="section level2">
<h2>References</h2>
<ul>
<li><p>Anselin L (1995) Local Indicators of Spatial Association—LISA. Geographical Analysis 27:93–115.</p></li>
<li><p>Baddeley A (2008) Analysing spatial point patterns in R. CSIRO. 171.</p></li>
<li><p>Gimond M (2018) Intro to GIS and Spatial Analysis.</p></li>
<li><p>Ripley BD (1977) Modelling Spatial Patterns. Journal of the Royal Statistical Society: Series B (Methodological) 39:172–192.</p></li>
</ul>
<hr />
</div>
</section>
