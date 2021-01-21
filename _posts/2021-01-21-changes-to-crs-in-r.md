---
title: "Changes to CRS in R"


date: "January 21, 2021"
layout: post
---

<script src="{{ site.url }}{{ site.baseurl }}/knitr_files/2021-01-21-CRS_files/header-attrs-2.6/header-attrs.js"></script>

<section class="main-content">
<p><strong>Keywords:</strong> R, spatial data, coordinates</p>
<pre><code>There is nothing more deceptive than an obvious fact.
- Arthur Conan Doyle, The Boscombe Valley Mystery</code></pre>
<p>If you haven’t heard already, big changes are afoot in the <a href="https://rspatial.org/" target="_blank">R-spatial</a> community. <img src="{{ site.url }}{{ site.baseurl }}\images\20210121_CRS\sherlock_afoot.gif" width="50%" style="display: block; margin: auto;" /></p>
<p>…if you were/are like me you experienced a mix of emotions. But not to worry there are loads of resources and a people working the issues right now.</p>
<p><img src="{{ site.url }}{{ site.baseurl }}\images\20210121_CRS\sherlock_shcoked.gif" width="40%" style="display: block; margin: auto;" /></p>
<p>…so expect lots of blog posts and resources from people.</p>
<hr />
<p>The cliff notes version (short, short version) is that changes in the representation of coordinate reference systems (CRS) have finally caught up with how spatial data is handled in R packages. In a vignette, <a href="https://twitter.com/RogerBivand" target="_blank">Roger Bivand</a> explains the nitty gritty title <a href="https://rgdal.r-forge.r-project.org/articles/CRS_projections_transformations.html" target="_blank"><em>“Why have CRS, projections and transformations”</em></a>.</p>
<ul>
<li>YouTube lecture by Roger Bivand (<a href="https://youtu.be/2H1Tn4oN32M" target="_blank">link</a>)</li>
<li>Associated material (<a href="https://rsbivand.github.io/ECS530_h20/ECS530_III.html" target="_blank">link</a>)</li>
<li>Bivand, R.S. Progress in the R ecosystem for representing and handling spatial data. J Geogr Syst (2020). <a href="https://doi.org/10.1007/s10109-020-00336-0" target="_blank">https://doi.org/10.1007/s10109-020-00336-0</a></li>
</ul>
<p>Roger also penned this post explaining the migration specific for the <code>rgdal</code>, <code>sp</code> and <code>raster</code> packages specific to read, write, project, and transform objects using PROJ strings (<a href="https://cran.r-project.org/web/packages/rgdal/vignettes/PROJ6_GDAL3.html#Migration_to_PROJ6GDAL3" target="_blank"><em>“Migration to PROJ6/GDAL3”</em></a>). It gets rather complex but a good resource.</p>
<p>In another resource I came across in my sleuthing and troubleshooting Edzer Pebesma and Roger Bivand discusses how <a href="https://gdal.org/" target="_blank">GDAL</a> and <a href="https://proj.org" target="_blank">PROJ</a> (formerly proj.4) relates to geospatial tools including several <code>R</code> packages in a post <a href="https://www.r-spatial.org/r/2020/03/17/wkt.html" target="_blank"><em>“R spatial follows GDAL and PROJ developement”</em></a>. As an example they outline the dependency for package sf is for instance pictured here:</p>
<p><img src="https://keen-swartz-3146c4.netlify.com/images/sf_deps.png" width="75%" style="display: block; margin: auto;" /></p>
<p>Also something worth reiterating here, briefly:</p>
<ul>
<li><p>PROJ provides methods for coordinate representation, conversion (projection) and transformation, and</p></li>
<li><p>GDAL allows reading and writing of spatial raster and vector data in a standardized form, and provides a high-level interface to PROJ for these data structures, including the representation of coordinate reference systems (CRS)</p></li>
</ul>
<hr />
<p>We are ultimately dealing with coordinate reference systems (or CRS) but it also goes by another name…spatial reference system (SRS). This might make more sense soon. As summarized by <a href="https://github.com/inbo" target="_blank">INBO</a>, CRS are defined by several elements:</p>
<ul>
<li>a coordinate system,</li>
<li>a ‘datum’; it localizes the geodetic coordinate system relative to the Earth and needs a geometric definition of the ellipsoid,</li>
<li>only for projected CRSes: coordinate conversion parameters that determine the conversion from the geodetic to the projected coordinates.</li>
</ul>
<p><a href="https://github.com/inbo" target="_blank">INBO</a> did a fantastic tutorial (<a href="https://inbo.github.io/tutorials/tutorials/spatial_crs_coding/" target="_blank">https://inbo.github.io/tutorials/tutorials/spatial_crs_coding/</a>) on the changes walking through the how-to for <code>sp</code>, <code>sf</code> and <code>raster</code> packages. The <code>rgdal</code> package leans heavily on the <code>sp</code> package…incase you were worried.</p>
<hr />
<p>Here are some examples and things that I have learned dealing with this issue. Nothing special and I suggest visiting the resources identified above (especially <a href="https://inbo.github.io/tutorials/tutorials/spatial_crs_coding/" target="_blank">https://inbo.github.io/tutorials/tutorials/spatial_crs_coding/</a>). I am partial to the <code>sp</code> and <code>rgdal</code> packages, this is what I initially learned and got comfortable using. So lets load <code>rgdal</code>.</p>
<div class="sourceCode" id="cb2"><pre class="sourceCode r"><code class="sourceCode r"><span id="cb2-1"><a href="#cb2-1" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(rgdal)</span></code></pre></div>
<p>In the good’ol days you could define a CRS with this</p>
<pre><code>utm17 &lt;- CRS(&quot;+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs&quot;)</code></pre>
<p>Do this now and you get…</p>
<pre><code>## Warning in showSRID(uprojargs, format = &quot;PROJ&quot;, multiline = &quot;NO&quot;, prefer_proj =
## prefer_proj): Discarded datum Unknown based on GRS80 ellipsoid in CRS definition</code></pre>
<p>There might be several ways to do this but the easiest I found is</p>
<div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><span id="cb5-1"><a href="#cb5-1" aria-hidden="true" tabindex="-1"></a>utm17 <span class="ot">&lt;-</span> <span class="fu">CRS</span>(<span class="at">SRS_string=</span><span class="st">&quot;EPSG:4326&quot;</span>)</span></code></pre></div>
<p>Notice the the argument <code>SRS_string</code> … as in spatial reference system! (I just picked that up writing this post).</p>
<p>Another thing in the update is the use of WKT (well-known text) over that of PROJ strings. WKT strings are interesting and provides lots of good information on the CRS (or SRS) if your into that kind of thing. To make a WKT you use the <code>wkt()</code> function.</p>
<div class="sourceCode" id="cb6"><pre class="sourceCode r"><code class="sourceCode r"><span id="cb6-1"><a href="#cb6-1" aria-hidden="true" tabindex="-1"></a>utm17 <span class="ot">&lt;-</span> <span class="fu">CRS</span>(<span class="at">SRS_string=</span><span class="st">&quot;EPSG:4326&quot;</span>)</span>
<span id="cb6-2"><a href="#cb6-2" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb6-3"><a href="#cb6-3" aria-hidden="true" tabindex="-1"></a>utm17.wkt<span class="ot">=</span><span class="fu">wkt</span>(utm17)</span>
<span id="cb6-4"><a href="#cb6-4" aria-hidden="true" tabindex="-1"></a>utm17.wkt</span></code></pre></div>
<pre><code>## [1] &quot;GEOGCRS[\&quot;WGS 84 (with axis order normalized for visualization)\&quot;,\n    DATUM[\&quot;World Geodetic System 1984\&quot;,\n        ELLIPSOID[\&quot;WGS 84\&quot;,6378137,298.257223563,\n            LENGTHUNIT[\&quot;metre\&quot;,1]],\n        ID[\&quot;EPSG\&quot;,6326]],\n    PRIMEM[\&quot;Greenwich\&quot;,0,\n        ANGLEUNIT[\&quot;degree\&quot;,0.0174532925199433],\n        ID[\&quot;EPSG\&quot;,8901]],\n    CS[ellipsoidal,2],\n        AXIS[\&quot;geodetic longitude (Lon)\&quot;,east,\n            ORDER[1],\n            ANGLEUNIT[\&quot;degree\&quot;,0.0174532925199433,\n                ID[\&quot;EPSG\&quot;,9122]]],\n        AXIS[\&quot;geodetic latitude (Lat)\&quot;,north,\n            ORDER[2],\n            ANGLEUNIT[\&quot;degree\&quot;,0.0174532925199433,\n                ID[\&quot;EPSG\&quot;,9122]]]]&quot;</code></pre>
<p>or you can print the WKT to be more readable/organized with:</p>
<div class="sourceCode" id="cb8"><pre class="sourceCode r"><code class="sourceCode r"><span id="cb8-1"><a href="#cb8-1" aria-hidden="true" tabindex="-1"></a><span class="fu">cat</span>(utm17.wkt)</span></code></pre></div>
<pre><code>## GEOGCRS[&quot;WGS 84 (with axis order normalized for visualization)&quot;,
##     DATUM[&quot;World Geodetic System 1984&quot;,
##         ELLIPSOID[&quot;WGS 84&quot;,6378137,298.257223563,
##             LENGTHUNIT[&quot;metre&quot;,1]],
##         ID[&quot;EPSG&quot;,6326]],
##     PRIMEM[&quot;Greenwich&quot;,0,
##         ANGLEUNIT[&quot;degree&quot;,0.0174532925199433],
##         ID[&quot;EPSG&quot;,8901]],
##     CS[ellipsoidal,2],
##         AXIS[&quot;geodetic longitude (Lon)&quot;,east,
##             ORDER[1],
##             ANGLEUNIT[&quot;degree&quot;,0.0174532925199433,
##                 ID[&quot;EPSG&quot;,9122]]],
##         AXIS[&quot;geodetic latitude (Lat)&quot;,north,
##             ORDER[2],
##             ANGLEUNIT[&quot;degree&quot;,0.0174532925199433,
##                 ID[&quot;EPSG&quot;,9122]]]]</code></pre>
<p>Further down the road when you are doing analyses or even plotting in some packages (i.e. <code>tmap</code>) you might get a bunch of warnings like:</p>
<pre><code>Warning message:
In sp::proj4string(obj) : CRS object has comment, which is lost in output</code></pre>
<p>This shouldn’t stop any of the operations but you can “mute” the warnings by running <code>options("rgdal_show_exportToProj4_warnings"="none")</code> in your console. I keep my “un-muted” to make sure I don’t inadvertently miss something.</p>
<p>If your wanting to transform a dataset from one datum to another you will need to use the WKT string. For instance I use several different state agency spatial datasets, one of which uses <code>NAD83 HARN</code> (which is a discarded datum…still learning about what this means) and I usually work in <code>UTM</code>. I find UTM CRSes easier to work with in general. Going back to the example dataset…if I read the file into <code>R</code> I get:</p>
<pre><code>dat&lt;-readOGR(shapefile) #just as an example

Warning message:
In OGRSpatialRef(dsn, layer, morphFromESRI = morphFromESRI, dumpSRS = dumpSRS,  :
  Discarded datum NAD83_High_Accuracy_Reference_Network in CRS definition: +proj=tmerc +lat_0=24.3333333333333 +lon_0=-81 +k=0.999941177 +x_0=200000.0001016 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=us-ft +no_defs</code></pre>
<p>That was enough to make my head spin…but if you notice its just a warning message and it will still read the file into the <code>R</code> environment. Now to transform the CRS:</p>
<pre><code>dat.tran&lt;-spTransform(dat,utm17.wkt)</code></pre>
<p>But lets say you are making a <code>SpatialPointsDataFrame</code>, one of the arguments is <code>proj4string</code> (which we are moving away from and the motivation for this whole post!).</p>
<p>Here is some data…</p>
<div class="sourceCode" id="cb13"><pre class="sourceCode r"><code class="sourceCode r"><span id="cb13-1"><a href="#cb13-1" aria-hidden="true" tabindex="-1"></a>dat2<span class="ot">&lt;-</span><span class="fu">data.frame</span>(<span class="at">SITE=</span><span class="fu">c</span>(<span class="dv">1</span>,<span class="dv">2</span>,<span class="dv">3</span>),</span>
<span id="cb13-2"><a href="#cb13-2" aria-hidden="true" tabindex="-1"></a>                 <span class="at">UTMX=</span><span class="fu">c</span>(<span class="dv">590382</span>,<span class="dv">583910</span>,<span class="dv">585419</span>),</span>
<span id="cb13-3"><a href="#cb13-3" aria-hidden="true" tabindex="-1"></a>                 <span class="at">UTMY=</span><span class="fu">c</span>(<span class="dv">2830587</span>,<span class="dv">2821685</span>,<span class="dv">2819900</span>))</span>
<span id="cb13-4"><a href="#cb13-4" aria-hidden="true" tabindex="-1"></a>dat2</span></code></pre></div>
<pre><code>##   SITE   UTMX    UTMY
## 1    1 590382 2830587
## 2    2 583910 2821685
## 3    3 585419 2819900</code></pre>
<div class="sourceCode" id="cb15"><pre class="sourceCode r"><code class="sourceCode r"><span id="cb15-1"><a href="#cb15-1" aria-hidden="true" tabindex="-1"></a>dat2.shp<span class="ot">&lt;-</span><span class="fu">SpatialPointsDataFrame</span>(dat2[,<span class="fu">c</span>(<span class="st">&quot;UTMX&quot;</span>,<span class="st">&quot;UTMY&quot;</span>)],</span>
<span id="cb15-2"><a href="#cb15-2" aria-hidden="true" tabindex="-1"></a>                                <span class="at">data=</span>dat2,</span>
<span id="cb15-3"><a href="#cb15-3" aria-hidden="true" tabindex="-1"></a>                                <span class="at">proj4string=</span>utm17)</span></code></pre></div>
<p>This is as much as I have been able to work through these changes. It’s not huge scale changes to existing work-flows but enough to cause some heartburn.</p>
<p><img src="{{ site.url }}{{ site.baseurl }}\images\20210121_CRS\sherlock_drugged.gif" width="50%" style="display: block; margin: auto;" /></p>
<p>Hope this was helpful (sorry for all the Sherlock gifs)…keep coding friends.</p>
<p><img src="{{ site.url }}{{ site.baseurl }}\images\20210121_CRS\sherlock_smile.gif" width="40%" style="display: block; margin: auto;" /></p>
<hr />
</section>
