---
title: "PCA basics in #Rstats"


date: "December 10, 2019"
layout: post
---

<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/htmlwidgets-1.3/htmlwidgets.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/jquery-1.12.4/jquery.min.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/leaflet-1.3.1/leaflet.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/Proj4Leaflet-1.0.1/proj4-compressed.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/Proj4Leaflet-1.0.1/proj4leaflet.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/leaflet-binding-2.0.2/leaflet.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/leaflet-providers-1.1.17/leaflet-providers.js"></script>
<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/leaflet-providers-plugin-2.0.2/leaflet-providers-plugin.js"></script>

<section class="main-content">
<p><strong>Keywords:</strong> ordination, R, PCA</p>
<hr />
<p>The masses have spoken!!</p>
<p><img src="{{ site.url }}{{ site.baseurl }}\images\20191210_PCA\twitterpoll.png" width="50%" style="display: block; margin: auto;" /></p>
<p>Also I got a wise piece of advice from <a href="https://twitter.com/coolbutuseless" target="_blank">mikefc</a> regarding <code>R</code> blog posts.</p>
<p><img src="{{ site.url }}{{ site.baseurl }}\images\20191210_PCA\GhostBuster_meme.png" width="75%" style="display: block; margin: auto;" /></p>
<hr />
<p>This post was partly motivated by an article by the <a href="https://medium.com/@bioturing" target="_blank">BioTuring Team</a> regarding <a href="https://medium.com/@bioturing/how-to-read-pca-biplots-and-scree-plots-186246aae063?" target="_blank">PCA</a>. In their article the authors provide the basic concepts behind interpreting a Principal Component Analysis (PCA) plot. Before rehashing PCA plots in <code>R</code> I would like to cover some basics.</p>
<p>Ordination analysis, which PCA is part of, is used to order (or ordinate…hence the name) multivariate data. Ultimately ordination makes new variables called principal axes along which samples are scored and/or ordered <span class="citation">(Gotelli and Ellison <a href="#ref-gotelli_primer_2004" role="doc-biblioref">2004</a>)</span>. There are at least five routinely used ordination analyses, here I intend to cover just PCA. Maybe in the future I cover the other four as it relates to ecological data analysis.</p>
<div id="principal-component-analysis" class="section level2">
<h2>Principal Component Analysis</h2>
<p>I have heard PCA call lots of things in my day including but not limiting to magic, statistical hand waving, mass plotting, statistical guesstimate, etc. When you have a multivariate dataset (data with more than one variable) it can be tough to figure out what matters. Think water quality data with a whole suite of nutrients or fish study with biological, habitat and water chemistry data for several sites along a stream/river. PCA is the best way to reduce the dimesionality of multivariate data to determine what <em>statistically</em> and practically matters. But its also beyond a data winnowing technique it can also be used to demonstrate similarity (or difference) between groups and relationships between variables. A major disadvantage of PCA is that it is a data hungry analysis (see assumptions below).</p>
<div id="assumptions-of-pca" class="section level3">
<h3>Assumptions of PCA</h3>
<p>Finding a single source related to the assumptions of PCA is rare. Below is combination of several sources including seminars, webpages, course notes, etc. Therefore this is not an exhaustive list of all assumptions and I could have missed some. I put this together for my benefit as well as your. Proceed with caution!!</p>
<ul>
<li><p><strong>Multiple Variables:</strong> This one is obvious. Ideally, given the nature of the analysis, multiple variables are required to perform the analysis. Moreover, variables should be measured at the continuous level, although ordinal variable are frequently used.</p></li>
<li><p><strong>Sample adequacy:</strong> Much like most (if not all) statistical analyses to produce a reliable result large enough sample sizes are required. Generally a minimum of 150 cases (i.e. rows), or 5 to 10 cases per variable is recommended for PCA analysis. Some have suggested to perform a sampling adequacy analysis such as Kaiser-Meyer-Olkin Measure (KMO) Measure of Sampling Adequacy. However, KMO is less a function of sample size adequacy as its a measure of the suitability of the data for factor analysis, which leads to the next point.</p></li>
<li><p><strong>Linearity relationships:</strong> It is assumed that the relationships between variables are linearly related. The basis of this assumption is rooted in the fact that PCA is based on Pearson correlation coefficients and therefore the assumptions of Pearson’s correlation also hold true. Generally, this assumption is somewhat relaxed…even though it shouldn’t be…with the use of ordinal data for variable.</p></li>
</ul>
<p>The <code>KMOS</code> and <code>bart_spher</code> functions in the <code>REdaS</code> <code>R</code> library can be used to check the measure of sampling adequacy and if the data is different from an identity matrix , below is a quick example.</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" title="1"><span class="kw">library</span>(REdaS)</a>
<a class="sourceLine" id="cb1-2" title="2"><span class="kw">library</span>(vegan)</a>
<a class="sourceLine" id="cb1-3" title="3"><span class="kw">library</span>(reshape)</a>
<a class="sourceLine" id="cb1-4" title="4"></a>
<a class="sourceLine" id="cb1-5" title="5"><span class="kw">data</span>(varechem);<span class="co">#from vegan package</span></a>
<a class="sourceLine" id="cb1-6" title="6"></a>
<a class="sourceLine" id="cb1-7" title="7"><span class="co"># KMO</span></a>
<a class="sourceLine" id="cb1-8" title="8"><span class="kw">KMOS</span>(varechem)</a></code></pre></div>
<pre><code>## 
## Kaiser-Meyer-Olkin Statistics
## 
## Call: KMOS(x = varechem)
## 
## Measures of Sampling Adequacy (MSA):
##         N         P         K        Ca        Mg         S        Al 
## 0.2770880 0.7943090 0.6772451 0.7344827 0.6002924 0.7193302 0.4727618 
##        Fe        Mn        Zn        Mo  Baresoil  Humdepth        pH 
## 0.5066961 0.6029551 0.6554475 0.4362350 0.7007942 0.5760349 0.4855293 
## 
## KMO-Criterion: 0.6119355</code></pre>
<div class="sourceCode" id="cb3"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb3-1" title="1"><span class="co"># Bartlett&#39;s Test Of Sphericity</span></a>
<a class="sourceLine" id="cb3-2" title="2"><span class="kw">bart_spher</span>(varechem)</a></code></pre></div>
<pre><code>##  Bartlett&#39;s Test of Sphericity
## 
## Call: bart_spher(x = varechem)
## 
##      X2 = 260.217
##      df = 91
## p-value &lt; 2.22e-16</code></pre>
<p>The <code>varechem</code> dataset appears to be suitable for factor analysis. The KMO value for the entire dataset is 0.61, above the suggested 0.5 threshold. Furthermore, the data is significantly different from an identity matrix (<em>H<sub>0</sub> :</em> all off-diagonal correlations are zero). <!--http://minato.sip21c.org/swtips/factor-in-R.pdf--></p>
<ul>
<li><strong>No significant outliers:</strong> Like most statistical analyses, outliers can skew any analysis/ In PCA, outliers can have a disproportionate influence on the resulting component computation. Since principal components are estimated by essentially re-scaling the data retaining the variance outlier could skew the estimate of each component within a PCA. Another way to visualize how PCA is performed is that it uses rotation of the original axes to derive a new axes, which maximizes the variance in the data set. In 2D this looks like this:</li>
</ul>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/figure-html/unnamed-chunk-4-1.png" style="display: block; margin: auto;" /></p>
<p>You would expect that if true outliers are present that the newly derived axes will be skewed. Outlier analysis and issues associated with identifying outliers is a whole other ball game that I will not cover here other than saying box-plots are not a suitable outlier identification analysis, see <span class="citation">Tukey (<a href="#ref-mosteller_exploratory_1977" role="doc-biblioref">1977</a>)</span> for more detail on boxplots (I have a manuscript <em>In Prep</em> focusing on this exact issue).</p>
</div>
</div>
<div id="terminology" class="section level2">
<h2>Terminology</h2>
<p>Before moving forward I wanted to dedicate some additional time to some terms specific to component analysis. By now we know the general gist of PCA … incase you were paying attention PCA is essentially a dimensionality reduction or data compression method to understand how multiple variable correlate in a given dataset. Typically when people discuss PCA they also use the terms loading, eigenvectors and eigenvalues.</p>
<ul>
<li><p><strong>Eigenvectors</strong> are unit-scaled loadings. Mathematically, they are the column sum of squared loadings for a factor. It conceptually represents the amount of variance accounted for by a given factor.</p></li>
<li><p><strong>Eigenvalues</strong> also called characteristic roots is the measure of variation in the total sample accounted for by each factor. Computationally, a factor’s eigenvalues are determined as the sum of its squared factor loadings for all the variables. The ratio of eigenvalues is the ratio of explanatory importance of the factors with respect to the variables (remember this for later).</p></li>
<li><p><strong>Factor Loadings</strong> is the correlation between the original variables and the factors. Analogous to Pearson’s r, the squared factor loadings is the percent of variance in that variable explained by the factor (…again remember this for later).</p></li>
</ul>
</div>
<div id="analysis" class="section level2">
<h2>Analysis</h2>
<p>Now that we have the basic terminology laid out and we know the general assumptions lets do an example analysis. Since I am an aquatic biogeochemist I am going to use some limnological data. Here we have a subset of long-term monitoring locations from six lakes within south Florida monitored by the <a href="https://www.sfwmd.gov/" target="_blank">South Florida Water Management District</a> (SFWMD). To retrieve the data we will use the <code>AnalystHelper</code> package (<a href="https://github.com/SwampThingPaul/AnalystHelper" target="_blank">link</a>), which has a function to retrieve data from the SFWMD online environmental database <a href="https://my.sfwmd.gov/dbhydroplsql/show_dbkey_info.main_menu" target="_blank">DBHYDRO</a>.</p>
<!--
Here is  a quick map of the sites. 



<div id="htmlwidget-797e4eb1d26f83a92458" style="width:100%;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-797e4eb1d26f83a92458">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["Esri.WorldImagery",null,"Esri.WorldImagery",{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":0.9,"zIndex":1,"detectRetina":false,"pane":"tilePane"}]},{"method":"createMapPane","args":["overlayPane01",401]},{"method":"addCircleMarkers","args":[[27.402596321192,26.9018100439508,28.2870827720898,28.1958880739981,28.0381131133281,27.8932745321714],[-81.3028497283324,-80.7889996146427,-81.3069727538396,-81.3903444000254,-81.4328368922772,-81.2284383459143],[4,4,4,4,4,4],["X1124","X1254","X731","X744","X854","X863"],"SFWMD WQ Monitoring (Active)",{"interactive":true,"className":"","pane":"overlayPane01","stroke":true,"color":"#666666","weight":1,"opacity":0.5,"fill":true,"fillColor":["#1E90FF","#1E90FF","#1E90FF","#1E90FF","#1E90FF","#1E90FF"],"fillOpacity":[1,1,1,1,1,1]},null,null,["<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><b>1124<\/b><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">OBJECTID<\/td><td>1124<\/td><\/tr><tr><td style=\"color: #888888;\">STATUS<\/td><td>Active<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_T<\/td><td>Chemistry<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_S<\/td><td>Surface Water Grab<\/td><\/tr><tr><td style=\"color: #888888;\">STATION<\/td><td>ISTK2S<\/td><\/tr><tr><td style=\"color: #888888;\">SITE<\/td><td>ISTK2S<\/td><\/tr><tr><td style=\"color: #888888;\">LAT<\/td><td>27.40<\/td><\/tr><tr><td style=\"color: #888888;\">LON<\/td><td>-81.303<\/td><\/tr><tr><td style=\"color: #888888;\">START_DATE<\/td><td>2005-03-21T10:12:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">END_DATE<\/td><td>2019-07-24T11:26:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">STATION_DE<\/td><td>IN LAKE ISTOKPOGA NORTHWEST QUADRANT<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_X<\/td><td>557,906<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_Y<\/td><td>1,115,642<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><b>1254<\/b><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">OBJECTID<\/td><td>1254<\/td><\/tr><tr><td style=\"color: #888888;\">STATUS<\/td><td>Active<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_T<\/td><td>Chemistry<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_S<\/td><td>Surface Water Grab<\/td><\/tr><tr><td style=\"color: #888888;\">STATION<\/td><td>LZ40<\/td><\/tr><tr><td style=\"color: #888888;\">SITE<\/td><td>LZ40<\/td><\/tr><tr><td style=\"color: #888888;\">LAT<\/td><td>26.90<\/td><\/tr><tr><td style=\"color: #888888;\">LON<\/td><td>-80.789<\/td><\/tr><tr><td style=\"color: #888888;\">START_DATE<\/td><td>1978-06-12T10:08:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">END_DATE<\/td><td>2019-07-09T11:34:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">STATION_DE<\/td><td>LZ40 WEATHER STATION ON LAKE OKEECHOBEE<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_X<\/td><td>724,932<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_Y<\/td><td>933,536<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><b>731<\/b><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">OBJECTID<\/td><td>731<\/td><\/tr><tr><td style=\"color: #888888;\">STATUS<\/td><td>Active<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_T<\/td><td>Chemistry<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_S<\/td><td>Surface Water Grab<\/td><\/tr><tr><td style=\"color: #888888;\">STATION<\/td><td>A03<\/td><\/tr><tr><td style=\"color: #888888;\">SITE<\/td><td>A03<\/td><\/tr><tr><td style=\"color: #888888;\">LAT<\/td><td>28.29<\/td><\/tr><tr><td style=\"color: #888888;\">LON<\/td><td>-81.307<\/td><\/tr><tr><td style=\"color: #888888;\">START_DATE<\/td><td>1981-08-27T13:29:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">END_DATE<\/td><td>2019-06-11T10:17:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">STATION_DE<\/td><td>Open water site located at southwest side of East Lake Tohopekaliga.<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_X<\/td><td>557,373<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_Y<\/td><td>1,437,203<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><b>744<\/b><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">OBJECTID<\/td><td>744<\/td><\/tr><tr><td style=\"color: #888888;\">STATUS<\/td><td>Active<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_T<\/td><td>Chemistry<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_S<\/td><td>Surface Water Grab<\/td><\/tr><tr><td style=\"color: #888888;\">STATION<\/td><td>B06<\/td><\/tr><tr><td style=\"color: #888888;\">SITE<\/td><td>B06<\/td><\/tr><tr><td style=\"color: #888888;\">LAT<\/td><td>28.20<\/td><\/tr><tr><td style=\"color: #888888;\">LON<\/td><td>-81.390<\/td><\/tr><tr><td style=\"color: #888888;\">START_DATE<\/td><td>1981-08-26T12:00:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">END_DATE<\/td><td>2019-06-11T12:01:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">STATION_DE<\/td><td>Open water site located in the central area of Lake Tohopekaliga.<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_X<\/td><td>530,434<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_Y<\/td><td>1,404,124<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><b>854<\/b><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">OBJECTID<\/td><td>854<\/td><\/tr><tr><td style=\"color: #888888;\">STATUS<\/td><td>Active<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_T<\/td><td>Chemistry<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_S<\/td><td>Surface Water Grab<\/td><\/tr><tr><td style=\"color: #888888;\">STATION<\/td><td>D02<\/td><\/tr><tr><td style=\"color: #888888;\">SITE<\/td><td>D02<\/td><\/tr><tr><td style=\"color: #888888;\">LAT<\/td><td>28.04<\/td><\/tr><tr><td style=\"color: #888888;\">LON<\/td><td>-81.433<\/td><\/tr><tr><td style=\"color: #888888;\">START_DATE<\/td><td>1982-04-06T13:05:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">END_DATE<\/td><td>2019-06-11T14:14:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">STATION_DE<\/td><td>Open water site located at west side of Lake Hatchineha<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_X<\/td><td>516,543<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_Y<\/td><td>1,346,808<\/td><\/tr><\/table><\/div>","<div style=\"max-height:10em;overflow:auto;\"><table>\n\t\t\t   <thead><tr><th colspan=\"2\"><b>863<\/b><\/th><\/thead><\/tr><tr><td style=\"color: #888888;\">OBJECTID<\/td><td>863<\/td><\/tr><tr><td style=\"color: #888888;\">STATUS<\/td><td>Active<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_T<\/td><td>Chemistry<\/td><\/tr><tr><td style=\"color: #888888;\">ACTIVITY_S<\/td><td>Surface Water Grab<\/td><\/tr><tr><td style=\"color: #888888;\">STATION<\/td><td>E04<\/td><\/tr><tr><td style=\"color: #888888;\">SITE<\/td><td>E04<\/td><\/tr><tr><td style=\"color: #888888;\">LAT<\/td><td>27.89<\/td><\/tr><tr><td style=\"color: #888888;\">LON<\/td><td>-81.228<\/td><\/tr><tr><td style=\"color: #888888;\">START_DATE<\/td><td>1982-04-06T15:00:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">END_DATE<\/td><td>2019-06-11T15:09:00.000Z<\/td><\/tr><tr><td style=\"color: #888888;\">STATION_DE<\/td><td>Open water site located at east central end of Lake Kissimmee at Marker #7<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_X<\/td><td>582,379<\/td><\/tr><tr><td style=\"color: #888888;\">POINT_Y<\/td><td>1,293,972<\/td><\/tr><\/table><\/div>"],{"maxWidth":500,"minWidth":100,"autoPan":true,"keepInView":false,"closeButton":true,"className":""},["1124","1254","731","744","854","863"],{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addLayersControl","args":[[],"SFWMD WQ Monitoring (Active)",{"collapsed":true,"autoZIndex":true,"position":"topleft"}]}],"limits":{"lat":[26.9018100439508,28.2870827720898],"lng":[-81.4328368922772,-80.7889996146427]},"fitBounds":[26.9018100439508,-81.4328368922772,28.2870827720898,-80.7889996146427,[]]},"evals":[],"jsHooks":[]}</script>
-->
<p>Let retrieve and format the data for PCA analysis.</p>
<div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb5-1" title="1"><span class="co">#Libraries/packages needed</span></a>
<a class="sourceLine" id="cb5-2" title="2"><span class="kw">library</span>(AnalystHelper)</a>
<a class="sourceLine" id="cb5-3" title="3"><span class="kw">library</span>(reshape)</a>
<a class="sourceLine" id="cb5-4" title="4"></a>
<a class="sourceLine" id="cb5-5" title="5"><span class="co">#Date Range of data</span></a>
<a class="sourceLine" id="cb5-6" title="6">sdate=<span class="kw">as.Date</span>(<span class="st">&quot;2005-05-01&quot;</span>)</a>
<a class="sourceLine" id="cb5-7" title="7">edate=<span class="kw">as.Date</span>(<span class="st">&quot;2019-05-01&quot;</span>)</a>
<a class="sourceLine" id="cb5-8" title="8"></a>
<a class="sourceLine" id="cb5-9" title="9"><span class="co">#Site list with lake name (meta-data)</span></a>
<a class="sourceLine" id="cb5-10" title="10">sites=<span class="kw">data.frame</span>(<span class="dt">Station.ID=</span><span class="kw">c</span>(<span class="st">&quot;LZ40&quot;</span>,<span class="st">&quot;ISTK2S&quot;</span>,<span class="st">&quot;E04&quot;</span>,<span class="st">&quot;D02&quot;</span>,<span class="st">&quot;B06&quot;</span>,<span class="st">&quot;A03&quot;</span>),</a>
<a class="sourceLine" id="cb5-11" title="11">                 <span class="dt">LAKE=</span><span class="kw">c</span>(<span class="st">&quot;Okeechobee&quot;</span>,<span class="st">&quot;Istokpoga&quot;</span>,<span class="st">&quot;Kissimmee&quot;</span>,<span class="st">&quot;Hatchineha&quot;</span>,</a>
<a class="sourceLine" id="cb5-12" title="12">                        <span class="st">&quot;Tohopekaliga&quot;</span>,<span class="st">&quot;East Tohopekaliga&quot;</span>))</a>
<a class="sourceLine" id="cb5-13" title="13"></a>
<a class="sourceLine" id="cb5-14" title="14"><span class="co">#Water Quality parameters (meta-data)</span></a>
<a class="sourceLine" id="cb5-15" title="15">parameters=<span class="kw">data.frame</span>(<span class="dt">Test.Number=</span><span class="kw">c</span>(<span class="dv">67</span>,<span class="dv">20</span>,<span class="dv">32</span>,<span class="dv">179</span>,<span class="dv">112</span>,<span class="dv">8</span>,<span class="dv">10</span>,<span class="dv">23</span>,<span class="dv">25</span>,<span class="dv">80</span>,<span class="dv">18</span>,<span class="dv">21</span>),</a>
<a class="sourceLine" id="cb5-16" title="16">                      <span class="dt">param=</span><span class="kw">c</span>(<span class="st">&quot;Alk&quot;</span>,<span class="st">&quot;NH4&quot;</span>,<span class="st">&quot;Cl&quot;</span>,<span class="st">&quot;Chla&quot;</span>,<span class="st">&quot;Chla&quot;</span>,<span class="st">&quot;DO&quot;</span>,<span class="st">&quot;pH&quot;</span>,</a>
<a class="sourceLine" id="cb5-17" title="17">                              <span class="st">&quot;SRP&quot;</span>,<span class="st">&quot;TP&quot;</span>,<span class="st">&quot;TN&quot;</span>,<span class="st">&quot;NOx&quot;</span>,<span class="st">&quot;TKN&quot;</span>))</a>
<a class="sourceLine" id="cb5-18" title="18"></a>
<a class="sourceLine" id="cb5-19" title="19"><span class="co"># Retrieve the data</span></a>
<a class="sourceLine" id="cb5-20" title="20">dat=<span class="kw">DBHYDRO_WQ</span>(sdate,edate,sites<span class="op">$</span>Station.ID,parameters<span class="op">$</span>Test.Number)</a>
<a class="sourceLine" id="cb5-21" title="21"></a>
<a class="sourceLine" id="cb5-22" title="22"><span class="co"># Merge metadata with dataset</span></a>
<a class="sourceLine" id="cb5-23" title="23">dat=<span class="kw">merge</span>(dat,sites,<span class="st">&quot;Station.ID&quot;</span>)</a>
<a class="sourceLine" id="cb5-24" title="24">dat=<span class="kw">merge</span>(dat,parameters,<span class="st">&quot;Test.Number&quot;</span>)</a>
<a class="sourceLine" id="cb5-25" title="25"></a>
<a class="sourceLine" id="cb5-26" title="26"><span class="co"># Cross tabulate the data based on parameter name</span></a>
<a class="sourceLine" id="cb5-27" title="27">dat.xtab=<span class="kw">cast</span>(dat,Station.ID<span class="op">+</span>LAKE<span class="op">+</span>Date.EST<span class="op">~</span>param,<span class="dt">value=</span><span class="st">&quot;HalfMDL&quot;</span>,mean)</a>
<a class="sourceLine" id="cb5-28" title="28"></a>
<a class="sourceLine" id="cb5-29" title="29"><span class="co"># Cleaning up/calculating parameters</span></a>
<a class="sourceLine" id="cb5-30" title="30">dat.xtab<span class="op">$</span>TN=<span class="kw">with</span>(dat.xtab,<span class="kw">TN_Combine</span>(NOx,TKN,TN))</a>
<a class="sourceLine" id="cb5-31" title="31">dat.xtab<span class="op">$</span>DIN=<span class="kw">with</span>(dat.xtab, NOx<span class="op">+</span>NH4)</a>
<a class="sourceLine" id="cb5-32" title="32"></a>
<a class="sourceLine" id="cb5-33" title="33"><span class="co"># More cleaning of the dataset </span></a>
<a class="sourceLine" id="cb5-34" title="34">vars=<span class="kw">c</span>(<span class="st">&quot;Alk&quot;</span>,<span class="st">&quot;Cl&quot;</span>,<span class="st">&quot;Chla&quot;</span>,<span class="st">&quot;DO&quot;</span>,<span class="st">&quot;pH&quot;</span>,<span class="st">&quot;SRP&quot;</span>,<span class="st">&quot;TP&quot;</span>,<span class="st">&quot;TN&quot;</span>,<span class="st">&quot;DIN&quot;</span>)</a>
<a class="sourceLine" id="cb5-35" title="35">dat.xtab=dat.xtab[,<span class="kw">c</span>(<span class="st">&quot;Station.ID&quot;</span>,<span class="st">&quot;LAKE&quot;</span>,<span class="st">&quot;Date.EST&quot;</span>,vars)]</a>
<a class="sourceLine" id="cb5-36" title="36"></a>
<a class="sourceLine" id="cb5-37" title="37"><span class="kw">head</span>(dat.xtab)</a></code></pre></div>
<pre><code>##   Station.ID              LAKE   Date.EST Alk   Cl Chla   DO   pH    SRP
## 1        A03 East Tohopekaliga 2005-05-17  17 19.7 4.00 7.90 6.10 0.0015
## 2        A03 East Tohopekaliga 2005-06-21  22 15.4 4.70 6.90 6.40 0.0015
## 3        A03 East Tohopekaliga 2005-07-19  16 15.1 5.10 7.10  NaN 0.0015
## 4        A03 East Tohopekaliga 2005-08-16  17 14.0 3.00 6.90 6.30 0.0015
## 5        A03 East Tohopekaliga 2005-08-30 NaN  NaN 6.00 7.07 7.44    NaN
## 6        A03 East Tohopekaliga 2005-09-20  17 16.3 0.65 7.30 6.70 0.0010
##      TP    TN   DIN
## 1 0.024 0.710 0.040
## 2 0.024 0.680 0.030
## 3 0.020 0.630 0.020
## 4 0.021 0.550 0.030
## 5   NaN    NA   NaN
## 6 0.018 0.537 0.017</code></pre>
<p>If you are playing the home game with this dataset you’ll notice some <code>NA</code> values, this is because that data was either not collected or removed due to fatal laboratory or field QA/QC. PCA doesn’t work with NA values, unfortunately this means that the whole row needs to be excluded from the analysis.</p>
<p>Lets actually get down to doing a PCA analysis. First off, you have several different flavors (funcations) of PCA to choose from. Each have there own nuisances and come from different packages.</p>
<ul>
<li><p><code>prcomp()</code> and <code>princomp()</code> are from the base <code>stats</code> package. The quickest, easiest and most stable version since its in base.</p></li>
<li><p><code>PCA()</code> in the <code>FactoMineR</code> package.</p></li>
<li><p><code>dubi.pca()</code> in the <code>ade4</code> package.</p></li>
<li><p><code>acp()</code> in the <code>amap</code> package.</p></li>
<li><p><code>rda()</code> in the <code>vegan</code> package. More on this later.</p></li>
</ul>
<p>Personally, I only have experience working with <code>prcomp</code>, <code>princomp</code> and <code>rda</code> functions for PCA. The information shown here in this post can be extracted or calculated from any of these functions. Some are straight forward others are more sinuous. Above I mentioned using the <code>rda</code> function for PCA analysis. <code>rda()</code> is a function in the <code>vegan</code> <code>R</code> package for redundancy analysis (RDA) and the function I am most familiar with to perform PCA analysis. Redundancy analysis is a technique used to explain a dataset Y using a dataset X. Normally RDA is used for “constrained ordination” (ordination with covariates or predictors). Without predictors, RDA is the same as PCA.</p>
<p>As I mentioned above, <code>NA</code>s are a no go in PCA analysis so lets format/clean the data and we can see how much the data is reduced by the <code>na.omit</code> action.</p>
<div class="sourceCode" id="cb7"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb7-1" title="1">dat.xtab2=<span class="kw">na.omit</span>(dat.xtab)</a>
<a class="sourceLine" id="cb7-2" title="2"></a>
<a class="sourceLine" id="cb7-3" title="3"><span class="kw">nrow</span>(dat.xtab)</a></code></pre></div>
<pre><code>## [1] 725</code></pre>
<div class="sourceCode" id="cb9"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb9-1" title="1"><span class="kw">nrow</span>(dat.xtab2)</a></code></pre></div>
<pre><code>## [1] 515</code></pre>
<p>Also its a good idea as with most data, is to look at your data. Granted when the number of variables get really big…imagine trying to looks at a combination of more than eight or nine parameters. Here we have a scatterplot of water quality data within our six lakes. The parameters in this analysis is Alkalinity (ALK), Chloride (Cl), chlorophyll-<em>a</em> (Chl-a), dissolved oxygen (DO), pH, soluble reactive phosphorus (SRP), total phosphorus (TP), total nitrogen (TN) and dissolved inorganic nitrogen (DIN).</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/figure-html/unnamed-chunk-9-1.png" alt="Scatterplot of all data for the example `dat.xtab2` dataset."  />
<p class="caption">
Scatterplot of all data for the example <code>dat.xtab2</code> dataset.
</p>
</div>
<p>Alright, now the data is formatted and we have done some general data exploration. Lets check the adequacy of the data for component analysis…remember the KMO analysis?</p>
<div class="sourceCode" id="cb11"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb11-1" title="1"><span class="kw">KMOS</span>(dat.xtab2[,vars])</a></code></pre></div>
<pre><code>## 
## Kaiser-Meyer-Olkin Statistics
## 
## Call: KMOS(x = dat.xtab2[, vars])
## 
## Measures of Sampling Adequacy (MSA):
##       Alk        Cl      Chla        DO        pH       SRP        TP 
## 0.7274872 0.7238120 0.5096832 0.3118529 0.6392602 0.7777460 0.7524428 
##        TN       DIN 
## 0.6106997 0.7459682 
## 
## KMO-Criterion: 0.6972786</code></pre>
<p>Based on the KMO analysis, the KMO-Criterion of the dataset is 0.7, well above the suggested 0.5 threshold.</p>
<p>Lets also check if the data is significantly different from an identity matrix.</p>
<div class="sourceCode" id="cb13"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb13-1" title="1"><span class="kw">bart_spher</span>(dat.xtab2[,vars])</a></code></pre></div>
<pre><code>##  Bartlett&#39;s Test of Sphericity
## 
## Call: bart_spher(x = dat.xtab2[, vars])
## 
##      X2 = 4616.865
##      df = 36
## p-value &lt; 2.22e-16</code></pre>
<p>Based on Sphericity test (<code>bart_spher()</code>) the results looks good to move forward with a PCA analysis. The actual PCA analysis is pretty straight forward after the data is formatted and <em>“cleaned”</em>.</p>
<div class="sourceCode" id="cb15"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb15-1" title="1"><span class="kw">library</span>(vegan)</a>
<a class="sourceLine" id="cb15-2" title="2"></a>
<a class="sourceLine" id="cb15-3" title="3">dat.xtab2.pca=<span class="kw">rda</span>(dat.xtab2[,vars],<span class="dt">scale=</span>T)</a></code></pre></div>
<p>Before we even begin to plot out the typical PCA plot…try <code>biplot()</code> if your interested. Lets first look at the importance of each component and the variance explained by each component.</p>
<div class="sourceCode" id="cb16"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb16-1" title="1"><span class="co">#Extract eigenvalues (see definition above)</span></a>
<a class="sourceLine" id="cb16-2" title="2">eig &lt;-<span class="st"> </span>dat.xtab2.pca<span class="op">$</span>CA<span class="op">$</span>eig</a>
<a class="sourceLine" id="cb16-3" title="3"></a>
<a class="sourceLine" id="cb16-4" title="4"><span class="co"># Percent of variance explained by each compoinent</span></a>
<a class="sourceLine" id="cb16-5" title="5">variance &lt;-<span class="st"> </span>eig<span class="op">*</span><span class="dv">100</span><span class="op">/</span><span class="kw">sum</span>(eig)</a>
<a class="sourceLine" id="cb16-6" title="6"></a>
<a class="sourceLine" id="cb16-7" title="7"><span class="co"># The cumulative variance of each component (should sum to 1)</span></a>
<a class="sourceLine" id="cb16-8" title="8">cumvar &lt;-<span class="st"> </span><span class="kw">cumsum</span>(variance)</a>
<a class="sourceLine" id="cb16-9" title="9"></a>
<a class="sourceLine" id="cb16-10" title="10"><span class="co"># Combine all the data into one data.frame</span></a>
<a class="sourceLine" id="cb16-11" title="11">eig.pca &lt;-<span class="st"> </span><span class="kw">data.frame</span>(<span class="dt">eig =</span> eig, <span class="dt">variance =</span> variance,<span class="dt">cumvariance =</span> cumvar)</a></code></pre></div>
<p>As with most things in <code>R</code> there are always more than one way to do things. This same information can be extract using the <code>summary(dat.xtab2.pca)$cont</code>.</p>
<p>What does the component eigenvalue and percent variance mean…and what does it tell us. This information helps tell us how much variance is explained by the components. It also helps identify which components should be used moving forward.</p>
<p>Generally there are two general rules:</p>
<ol style="list-style-type: decimal">
<li>Pick components with eignvalues of at least 1.
<ul>
<li>This is called the Kaiser rule. A variation of this method has been created where the confidence intervals of each eigenvalue is calculated and only factors which have the entire confidence interval great than 1.0 is retained <span class="citation">(Beran and Srivastava <a href="#ref-beran_bootstrap_1985" role="doc-biblioref">1985</a>, <a href="#ref-beran_correction:_1987" role="doc-biblioref">1987</a>; Larsen and Warne <a href="#ref-larsen_estimating_2010" role="doc-biblioref">2010</a>)</span>. There is an <code>R</code> package that can calculate eignvalue confidence intervals through bootstrapping, I’m not going to cover this in this post but below is an example if you wanted to explore it for yourself.</li>
</ul></li>
</ol>
<div class="sourceCode" id="cb17"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb17-1" title="1"><span class="kw">library</span>(eigenprcomp)</a>
<a class="sourceLine" id="cb17-2" title="2"></a>
<a class="sourceLine" id="cb17-3" title="3"><span class="kw">boot_pr_comp</span>(<span class="kw">as.matrix</span>(dat.xtab2[,vars]))</a></code></pre></div>
<ol start="2" style="list-style-type: decimal">
<li>The selected components should be able to describe at least 80% of the variance.</li>
</ol>
<p>If you look at <code>eig.pca</code> you’ll see that based on these criteria component 1, 2 and 3 are the components to focus on as they are enough to describe the data. While looking at the raw numbers are good, nice visualizations are a bonus. A scree plot displays these data and shows how much variation each component captures from the data.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/figure-html/unnamed-chunk-15-1.png" alt="Scree plot of eigenvalues for each prinicipal component of `dat.xtab2.pca` with the Kaiser threshold identified."  />
<p class="caption">
Scree plot of eigenvalues for each prinicipal component of <code>dat.xtab2.pca</code> with the Kaiser threshold identified.
</p>
</div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/figure-html/unnamed-chunk-16-1.png" alt="Scree plot of the variance and cumulative variance for each priniciple component from `dat.xtab2.pca`."  />
<p class="caption">
Scree plot of the variance and cumulative variance for each priniciple component from <code>dat.xtab2.pca</code>.
</p>
</div>
<p>Now that we know which components are important, lets put together our biplot and extract components (if needed). To extract out components and specific loadings we can use the <code>scores()</code> function in the <code>vegan</code> package. It is a generic function to extract scores from <code>vegan</code> oridination objects such as RDA, CCA, etc. This function also seems to work with <code>prcomp</code> and <code>princomp</code> PCA functions in <code>stats</code> package.</p>
<div class="sourceCode" id="cb18"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb18-1" title="1">scrs=<span class="kw">scores</span>(dat.xtab2.pca,<span class="dt">display=</span><span class="kw">c</span>(<span class="st">&quot;sites&quot;</span>,<span class="st">&quot;species&quot;</span>),<span class="dt">choices=</span><span class="kw">c</span>(<span class="dv">1</span>,<span class="dv">2</span>,<span class="dv">3</span>));</a></code></pre></div>
<p><code>scrs</code> is a list of two item, species and sites. Species corresponds to the columns of the data and sites correspond to the rows. Use <code>choices</code> to extract the components you want, in this case we want the first three components. Now we can plot the scores.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/figure-html/unnamed-chunk-18-1.png" alt="PCA biplot of two component comparisons from the `data.xtab2.pca` analysis."  />
<p class="caption">
PCA biplot of two component comparisons from the <code>data.xtab2.pca</code> analysis.
</p>
</div>
<p>Typically when you see a PCA biplot, you also see arrows of each variable. This is commonly called loadings and can interpreted as:</p>
<ul>
<li><p>When two vectors are close, forming a small angle, the variables are typically positively correlated.</p></li>
<li><p>If two vectors are at an angle 90<span class="math inline">\(^\circ\)</span> they are typically not correlated.</p></li>
<li><p>If two vectors are at a large angle say in the vicinity of 180<span class="math inline">\(^\circ\)</span> they are typically negatively correlated.</p></li>
</ul>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/figure-html/unnamed-chunk-19-1.png" alt="PCA biplot of two component comparisons from the `data.xtab2.pca` analysis with rescaled loadings."  />
<p class="caption">
PCA biplot of two component comparisons from the <code>data.xtab2.pca</code> analysis with rescaled loadings.
</p>
</div>
<p>You can take this one even further with by showing how each lake falls in the ordination space by joining the <code>sites</code> to the original data frame. This is also how you use the derived components for further analysis.</p>
<div class="sourceCode" id="cb19"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb19-1" title="1">dat.xtab2=<span class="kw">cbind</span>(dat.xtab2,scrs<span class="op">$</span>sites)</a>
<a class="sourceLine" id="cb19-2" title="2"></a>
<a class="sourceLine" id="cb19-3" title="3"><span class="kw">head</span>(dat.xtab2)</a></code></pre></div>
<pre><code>##   Station.ID              LAKE   Date.EST Alk   Cl Chla  DO  pH    SRP
## 1        A03 East Tohopekaliga 2005-05-17  17 19.7 4.00 7.9 6.1 0.0015
## 2        A03 East Tohopekaliga 2005-06-21  22 15.4 4.70 6.9 6.4 0.0015
## 4        A03 East Tohopekaliga 2005-08-16  17 14.0 3.00 6.9 6.3 0.0015
## 6        A03 East Tohopekaliga 2005-09-20  17 16.3 0.65 7.3 6.7 0.0010
## 8        A03 East Tohopekaliga 2005-10-19  15 14.3 2.60 7.8 6.8 0.0010
## 9        A03 East Tohopekaliga 2005-11-15  13 15.8 3.70 8.6 6.7 0.0020
##      TP    TN   DIN        PC1        PC2        PC3
## 1 0.024 0.710 0.040 -0.3901117 -0.2240239 -0.5666993
## 2 0.024 0.680 0.030 -0.3912797 -0.2083258 -0.6284024
## 4 0.021 0.550 0.030 -0.4290627 -0.2486860 -0.6599207
## 6 0.018 0.537 0.017 -0.4045084 -0.2775129 -0.4566961
## 8 0.017 0.454 0.014 -0.4194518 -0.2718903 -0.3418373
## 9 0.010 0.437 0.017 -0.4232014 -0.2807803 -0.2434219</code></pre>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-12-10-PCA_files/figure-html/unnamed-chunk-21-1.png" alt="PCA biplot of two component comparisons from the `data.xtab2.pca` analysis with rescaled loadings and Lakes identified."  />
<p class="caption">
PCA biplot of two component comparisons from the <code>data.xtab2.pca</code> analysis with rescaled loadings and Lakes identified.
</p>
</div>
<p>You can extract a lot of great information from these plots and the underlying component data but immediately we see how the different lakes are group (i.e. Lake Okeechobee is obviously different than the other lakes) and how differently the lakes are loaded with respect to the different variables. Generally this grouping makes sense especially for the lakes to the left of the plot (i.e. East Tohopekaliga, Tohopekaliga, Hatchineha and Kissimmee), these lakes are connected, similar geomorphology, managed in a similar fashion and generally have similar upstream characteristics with shared watersheds.</p>
<p>I hope this blog post has provided a better appreciation of component analysis in <code>R</code>. This is by no means a comprehensive workflow of component analysis and lots of factors need to be considered during this type of analysis but this only scratches the surface.</p>
<!--
some of the different background that motivated this post. 
https://www.statisticssolutions.com/principal-component-analysis-pca/

https://statistics.laerd.com/spss-tutorials/principal-components-analysis-pca-using-spss-statistics.php

https://rpubs.com/jaelison/135029

https://medium.com/@bioturing/how-to-read-pca-biplots-and-scree-plots-186246aae063?

https://medium.com/@bioturing/principal-component-analysis-explained-simply-894e8f6f4bfb

https://ourcodingclub.github.io/2018/05/04/ordination.html

https://www.xlstat.com/en/solutions/features/redundancy-analysis-rda interesting explaination of RDA
-->
</div>
<div id="references" class="section level2 unnumbered">
<h2>References</h2>
<div id="refs" class="references">
<div id="ref-beran_bootstrap_1985">
<p>Beran, Rudolf, and Muni S. Srivastava. 1985. “Bootstrap Tests and Confidence Regions for Functions of a Covariance Matrix.” <em>The Annals of Statistics</em> 13 (1): 95–115. <a href="https://doi.org/10.1214/aos/1176346579">https://doi.org/10.1214/aos/1176346579</a>.</p>
</div>
<div id="ref-beran_correction:_1987">
<p>———. 1987. “Correction: Bootstrap Tests and Confidence Regions for Functions of a Covariance Matrix.” <em>The Annals of Statistics</em> 15 (1): 470–71. <a href="https://doi.org/10.1214/aos/1176350284">https://doi.org/10.1214/aos/1176350284</a>.</p>
</div>
<div id="ref-gotelli_primer_2004">
<p>Gotelli, Nicholas J., and Aaron M. Ellison. 2004. <em>A Primer of Ecological Statistics</em>. Sinauer Associates Publishers.</p>
</div>
<div id="ref-larsen_estimating_2010">
<p>Larsen, Ross, and Russell T. Warne. 2010. “Estimating Confidence Intervals for Eigenvalues in Exploratory Factor Analysis.” <em>Behavior Research Methods</em> 42 (3): 871–76. <a href="https://doi.org/10.3758/BRM.42.3.871">https://doi.org/10.3758/BRM.42.3.871</a>.</p>
</div>
<div id="ref-mosteller_exploratory_1977">
<p>Tukey, John Wilder. 1977. “Exploratory Data Analysis.” In <em>Statistics and Public Policy</em>, edited by Frederick Mosteller, 1st ed. Addison-Wesley Series in Behavioral Science. Quantitative Methods. Addison-Wesley.</p>
</div>
</div>
</div>
</section>
