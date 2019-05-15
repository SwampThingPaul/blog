---
title: "NetCDF data and R"


date: "May 15, 2019 "
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> data format, NetCDF, R,</p>
<hr />
<p>Apologies for the extreme hiatus in blog posts. I am going to ease back into things by discussing NetCDF files and how to work with them in R. In recent years, NetCDF files have gained popularity especially for climatology, meteorology, remote sensing, oceanographic and GIS data applications. As you would have guessed it, NetCDF is an acronym that stands for <strong>Net</strong>work <strong>C</strong>ommon <strong>D</strong>ata <strong>F</strong>orm. <a href="https://www.unidata.ucar.edu/publications/factsheets/current/factsheet_netcdf.pdf" target="_blank">NetCDF</a> and can be described as an open-source array-oriented data storage format.</p>
<p>Here are a few examples of data stored in NetCDF format:</p>
<ul>
<li><p>Climate data from <a href="https://cds.climate.copernicus.eu/cdsapp#!/search?type=dataset" target="_blank">https://climate.copernicus.eu/</a>.</p></li>
<li><p>Climate and atmospheric data from <a href="https://www.ecmwf.int/en/forecasts/datasets" target="_blank">https://www.ecmwf.int/</a>.</p></li>
<li><p>Climate data from <a href="https://climatedataguide.ucar.edu/climate-data" target="_blank">https://climatedataguide.ucar.edu/</a>.</p></li>
<li><p>Oceanographic data from <a href="https://data.nodc.noaa.gov/cgi-bin/iso?id=gov.noaa.nodc:NCEI-WOD" target="_blank">NOAA</a>.</p></li>
<li><p>Antarctic bathymetry data. Here is a blog post on <a href="https://ropensci.org/blog/2018/11/13/antarctic/" target="_blank">rOpenSci.org</a> discussing retrieval of Antarctic bathymetry data.</p></li>
<li><p>Everglades Water level data from <a href="https://sofia.usgs.gov/eden/models/watersurfacemod_download.php#netcdf" target="blank">US Geological Survey</a>.</p></li>
</ul>
<p>For this blog post I will walk through my exploration of working with NetCDF files in R using the Everglades water level data (above) as an example. The data is actually a double whammy, its geospatial and hydrologic data. This blog post is ultimately bits and pieces of other blog posts scatter around the web. I hope you find it useful.</p>
<hr />
<p>First lets load the necessary R-packages/libraries.</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" title="1"><span class="co"># Libraries</span></a>
<a class="sourceLine" id="cb1-2" title="2"><span class="kw">library</span>(chron) <span class="co"># package for creating chronological objects</span></a>
<a class="sourceLine" id="cb1-3" title="3"><span class="kw">library</span>(ncdf4)  <span class="co"># package to handle NetCDF</span></a>
<a class="sourceLine" id="cb1-4" title="4"></a>
<a class="sourceLine" id="cb1-5" title="5"><span class="kw">library</span>(raster) <span class="co"># package for raster manipulation</span></a>
<a class="sourceLine" id="cb1-6" title="6"><span class="kw">library</span>(rgdal) <span class="co"># package for geospatial analysis</span></a>
<a class="sourceLine" id="cb1-7" title="7"><span class="kw">library</span>(tmap) <span class="co"># package for plotting map data</span></a>
<a class="sourceLine" id="cb1-8" title="8"><span class="kw">library</span>(RColorBrewer) <span class="co"># package for color ramps</span></a></code></pre></div>
<p>Navigate to the data <a href="https://sofia.usgs.gov/eden/models/watersurfacemod_download.php#netcdf" target="_blank">website</a> and pick a data file. I decided on <a href="https://sofia.usgs.gov/eden/data/netcdf/v2/2017_q4_v2prov.zip" target="_blank">2017_Q4</a> (link will download a file). Once the file is downloaded, unzip the file using either R with the <code>unzip()</code> function or some other decompression software/operating system tools.</p>
<pre><code>## OGR data source with driver: OpenFileGDB 
## Source: &quot;D:\_GISData\SFER_GIS_Geodatabase.gdb&quot;, layer: &quot;EPA_Boundary&quot;
## with 1 features
## It has 4 fields</code></pre>
<pre><code>## OGR data source with driver: OpenFileGDB 
## Source: &quot;D:\_GISData\SFER_GIS_Geodatabase.gdb&quot;, layer: &quot;SFWMD_Canals&quot;
## with 702 features
## It has 18 fields</code></pre>
<pre><code>## OGR data source with driver: OpenFileGDB 
## Source: &quot;D:\_GISData\SFER_GIS_Geodatabase.gdb&quot;, layer: &quot;SFWMD_Shoreline&quot;
## with 1684 features
## It has 3 fields</code></pre>
<p>Alright now that the file is downloaded and unzipped lets open the file. I created an variable called <code>working.dir</code> which is a string indicating my “working directory” location (<code>working.dir&lt;-"D:/UF/_Working_Blog/NetCDFBlog"</code>) and points me to where I downloaded and unzipped the data file.</p>
<div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb5-1" title="1">dat.nc&lt;-<span class="kw">nc_open</span>(<span class="kw">paste0</span>(working.dir,<span class="st">&quot;/USGS_EDEN/2017_q4.nc&quot;</span>))</a></code></pre></div>
<p>Excellent! The data is now in the R-environment, let take a look at the data.</p>
<div class="sourceCode" id="cb6"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb6-1" title="1"><span class="kw">print</span>(dat.nc)</a></code></pre></div>
<pre><code>## File D:/UF/_Working_Blog/NetCDFBlog/USGS_EDEN/2017_q4.nc (NC_FORMAT_CLASSIC):
## 
##      2 variables (excluding dimension variables):
##         float stage[x,y,time]   
##             long_name: stage
##             esri_pe_string: PROJCS[&quot;NAD_1983_UTM_Zone_17N&quot;,GEOGCS[&quot;GCS_North_American_1983&quot;,DATUM[&quot;D_North_American_1983&quot;,SPHEROID[&quot;GRS_1980&quot;,6378137.0,298.257222101]],PRIMEM[&quot;Greenwich&quot;,0.0],UNIT[&quot;Degree&quot;,0.0174532925199433]],PROJECTION[&quot;Transverse_Mercator&quot;],PARAMETER[&quot;False_Easting&quot;,500000.0],PARAMETER[&quot;False_Northing&quot;,0.0],PARAMETER[&quot;Central_Meridian&quot;,-81.0],PARAMETER[&quot;Scale_Factor&quot;,0.9996],PARAMETER[&quot;Latitude_Of_Origin&quot;,0.0],UNIT[&quot;Meter&quot;,1.0]]
##             coordinates: x y
##             grid_mapping: transverse_mercator
##             units: cm
##             min: -8.33670043945312
##             max: 499.500701904297
##         int transverse_mercator[]   
##             grid_mapping_name: transverse_mercator
##             longitude_of_central_meridian: -81
##             latitude_of_projection_origin: 0
##             scale_factor_at_central_meridian: 0.9996
##             false_easting: 5e+05
##             false_northing: 0
##             semi_major_axis: 6378137
##             inverse_flattening: 298.257222101
## 
##      3 dimensions:
##         time  Size:92
##             long_name: model timestep
##             units: days since 2017-10-01T12:00:00Z
##         y  Size:405
##             long_name: y coordinate of projection
##             standard_name: projection_y_coordinate
##             units: m
##         x  Size:287
##             long_name: x coordinate of projection
##             standard_name: projection_x_coordinate
##             units: m
## 
##     2 global attributes:
##         Conventions: CF-1.0
##         Source_Software: JEM NetCDF writer</code></pre>
<p>As you can see all the metadata needed to understand what the <code>dat.nc</code> file is lives in the file. Definately a pro for using NetCDF files. Now lets extract our three dimensions (latitude, longitude and time).</p>
<div class="sourceCode" id="cb8"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb8-1" title="1">lon &lt;-<span class="st"> </span><span class="kw">ncvar_get</span>(dat.nc,<span class="st">&quot;x&quot;</span>);<span class="co"># extracts longitude</span></a>
<a class="sourceLine" id="cb8-2" title="2">nlon &lt;-<span class="st"> </span><span class="kw">dim</span>(lon);<span class="co"># returns the number of records</span></a>
<a class="sourceLine" id="cb8-3" title="3"></a>
<a class="sourceLine" id="cb8-4" title="4">lat &lt;-<span class="st"> </span><span class="kw">ncvar_get</span>(dat.nc,<span class="st">&quot;y&quot;</span>);<span class="co"># extracts latitude</span></a>
<a class="sourceLine" id="cb8-5" title="5">nlat &lt;-<span class="st"> </span><span class="kw">dim</span>(lat);<span class="co"># returns the number of records</span></a>
<a class="sourceLine" id="cb8-6" title="6"></a>
<a class="sourceLine" id="cb8-7" title="7">time &lt;-<span class="st"> </span><span class="kw">ncvar_get</span>(dat.nc,<span class="st">&quot;time&quot;</span>);<span class="co"># extracts time</span></a>
<a class="sourceLine" id="cb8-8" title="8">tunits &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,<span class="st">&quot;time&quot;</span>,<span class="st">&quot;units&quot;</span>);<span class="co"># assigns units to time</span></a>
<a class="sourceLine" id="cb8-9" title="9">nt &lt;-<span class="st"> </span><span class="kw">dim</span>(time)</a></code></pre></div>
<p>Now that we have our coordinates in space and time extracted let get to the actual data. If you remember when we viewed the dataset using <code>print()</code> sifting through the output you’ll notice <code>long_name: stage</code>, that is our data.</p>
<div class="sourceCode" id="cb9"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb9-1" title="1">dname=<span class="st">&quot;stage&quot;</span></a>
<a class="sourceLine" id="cb9-2" title="2">tmp_array &lt;-<span class="st"> </span><span class="kw">ncvar_get</span>(dat.nc,dname)</a>
<a class="sourceLine" id="cb9-3" title="3">dlname &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,dname,<span class="st">&quot;long_name&quot;</span>)</a>
<a class="sourceLine" id="cb9-4" title="4">dunits &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,dname,<span class="st">&quot;units&quot;</span>)</a>
<a class="sourceLine" id="cb9-5" title="5">fillvalue &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,dname,<span class="st">&quot;_FillValue&quot;</span>)</a></code></pre></div>
<p>We can also extract other information including global attributes such as title, source, references, etc. from the datasets metadata.</p>
<div class="sourceCode" id="cb10"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb10-1" title="1"><span class="co"># get global attributes</span></a>
<a class="sourceLine" id="cb10-2" title="2">title &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,<span class="dv">0</span>,<span class="st">&quot;title&quot;</span>)</a>
<a class="sourceLine" id="cb10-3" title="3">institution &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,<span class="dv">0</span>,<span class="st">&quot;institution&quot;</span>)</a>
<a class="sourceLine" id="cb10-4" title="4">datasource &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,<span class="dv">0</span>,<span class="st">&quot;source&quot;</span>)</a>
<a class="sourceLine" id="cb10-5" title="5">references &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,<span class="dv">0</span>,<span class="st">&quot;references&quot;</span>)</a>
<a class="sourceLine" id="cb10-6" title="6">history &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,<span class="dv">0</span>,<span class="st">&quot;history&quot;</span>)</a>
<a class="sourceLine" id="cb10-7" title="7">Conventions &lt;-<span class="st"> </span><span class="kw">ncatt_get</span>(dat.nc,<span class="dv">0</span>,<span class="st">&quot;Conventions&quot;</span>)</a></code></pre></div>
<p>Now that we got everything we wanted from the NetCDF file we can “close” the connection by using <code>nc_close(dat.nc)</code>.</p>
<p>The data we just extracted from this NetCDF file is a time-series of daily spatially interpolated water level data across a large ecosystem (several thousand km<sup>2</sup>). Using the <code>chron</code> library lets format this data to something more workable by extracting the date information from <code>tunits$value</code> and <code>time</code> variables.</p>
<div class="sourceCode" id="cb11"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb11-1" title="1">tustr &lt;-<span class="st"> </span><span class="kw">strsplit</span>(tunits<span class="op">$</span>value, <span class="st">&quot; &quot;</span>)</a>
<a class="sourceLine" id="cb11-2" title="2">tdstr &lt;-<span class="st"> </span><span class="kw">strsplit</span>(<span class="kw">unlist</span>(tustr)[<span class="dv">3</span>], <span class="st">&quot;-&quot;</span>)</a>
<a class="sourceLine" id="cb11-3" title="3">tmonth &lt;-<span class="st"> </span><span class="kw">as.integer</span>(<span class="kw">unlist</span>(tdstr)[<span class="dv">2</span>])</a>
<a class="sourceLine" id="cb11-4" title="4">tday &lt;-<span class="st"> </span><span class="kw">as.integer</span>(<span class="kw">substring</span>(<span class="kw">unlist</span>(tdstr)[<span class="dv">3</span>],<span class="dv">1</span>,<span class="dv">2</span>))</a>
<a class="sourceLine" id="cb11-5" title="5">tyear &lt;-<span class="st"> </span><span class="kw">as.integer</span>(<span class="kw">unlist</span>(tdstr)[<span class="dv">1</span>])</a>
<a class="sourceLine" id="cb11-6" title="6">time.val=<span class="kw">as.Date</span>(<span class="kw">chron</span>(time,<span class="dt">origin=</span><span class="kw">c</span>(tmonth, tday, tyear)))</a></code></pre></div>
<p>We know from both the metadata information within the file and information from where we retrieved the data that this NetCDF is an array representing the fourth quarter of 2017. This information combined with the extracted day, month and year information above we can determine the date corresponding to each file within the NetCDF array</p>
<div class="sourceCode" id="cb12"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb12-1" title="1"><span class="kw">head</span>(time.val)</a></code></pre></div>
<pre><code>## [1] &quot;2017-10-01&quot; &quot;2017-10-02&quot; &quot;2017-10-03&quot; &quot;2017-10-04&quot; &quot;2017-10-05&quot;
## [6] &quot;2017-10-06&quot;</code></pre>
<p>Like most data, sometime values of a variable are missing or not available (outside of modeling domain) and are identified using a specific “fill value” (<code>_FillValue</code>) or “missing value” (<code>missing_value</code>). To replace theses values its pretty simple and similar to that of a normal data frame.</p>
<div class="sourceCode" id="cb14"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb14-1" title="1"><span class="co"># replace netCDF fill values with NA&#39;s</span></a>
<a class="sourceLine" id="cb14-2" title="2">tmp_array[tmp_array<span class="op">==</span>fillvalue<span class="op">$</span>value] &lt;-<span class="st"> </span><span class="ot">NA</span></a></code></pre></div>
<p>To count the number of data points (i.e. non-NA values) you can use <code>length(na.omit(as.vector(tmp_array[,,1])))</code></p>
<p>Now that the data is extracted, sorted and cleaned lets take a couple of slices from this beautiful NetDF pie.</p>
<div class="sourceCode" id="cb15"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb15-1" title="1"><span class="co"># get a single slice or layer (day)</span></a>
<a class="sourceLine" id="cb15-2" title="2">m &lt;-<span class="st"> </span><span class="dv">1</span></a>
<a class="sourceLine" id="cb15-3" title="3">slice1 &lt;-<span class="st"> </span>tmp_array[,,m]</a>
<a class="sourceLine" id="cb15-4" title="4">time.val[m];<span class="co">#corresponding day</span></a></code></pre></div>
<pre><code>## [1] &quot;2017-10-01&quot;</code></pre>
<div class="sourceCode" id="cb17"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb17-1" title="1"><span class="co"># get a single slice or layer (day)</span></a>
<a class="sourceLine" id="cb17-2" title="2">m &lt;-<span class="st"> </span><span class="dv">20</span></a>
<a class="sourceLine" id="cb17-3" title="3">slice2 &lt;-<span class="st"> </span>tmp_array[,,m]</a>
<a class="sourceLine" id="cb17-4" title="4">time.val[m]</a></code></pre></div>
<pre><code>## [1] &quot;2017-10-20&quot;</code></pre>
<p><strong><em>Before we get to the mapping nitty gritty</em></strong> visit my prior blog post on <a href="https://swampthingecology.org/blog/mapping-in-rstats/" target="_blank">Mapping in #rstats</a>. To generate the maps I will be using the <code>tmap</code> library.</p>
<p>If you notice the <code>slice1</code> and <code>slice2</code> are “Large matrix” files and not spatial files yet. Remember back when we looked at the metadata in the file header using <code>print(dat.nc)</code>? It identified the spatial projection of the data in the <code>esri_pe_string:</code> field. During the process of extracting the NetCDF slice and the associated transformation to a raster the data is i the wrong orientation therefore we have to use the <code>flip()</code> function to get it pointed in the correct direction.</p>
<div class="sourceCode" id="cb19"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb19-1" title="1"><span class="co">#Defining the projection</span></a>
<a class="sourceLine" id="cb19-2" title="2">utm17.pro=<span class="kw">CRS</span>(<span class="st">&quot;+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs&quot;</span>)</a>
<a class="sourceLine" id="cb19-3" title="3"></a>
<a class="sourceLine" id="cb19-4" title="4">slice1.r &lt;-<span class="st"> </span><span class="kw">raster</span>(<span class="kw">t</span>(slice1), <span class="dt">xmn=</span><span class="kw">min</span>(lon), <span class="dt">xmx=</span><span class="kw">max</span>(lon), <span class="dt">ymn=</span><span class="kw">min</span>(lat), <span class="dt">ymx=</span><span class="kw">max</span>(lat), </a>
<a class="sourceLine" id="cb19-5" title="5">                   <span class="dt">crs=</span>utm17.pro)</a>
<a class="sourceLine" id="cb19-6" title="6">slice1.r &lt;-<span class="st"> </span><span class="kw">flip</span>(slice1.r, <span class="dt">direction=</span><span class="st">&#39;y&#39;</span>)</a>
<a class="sourceLine" id="cb19-7" title="7"></a>
<a class="sourceLine" id="cb19-8" title="8">slice2.r &lt;-<span class="st"> </span><span class="kw">raster</span>(<span class="kw">t</span>(slice2), <span class="dt">xmn=</span><span class="kw">min</span>(lon), <span class="dt">xmx=</span><span class="kw">max</span>(lon), <span class="dt">ymn=</span><span class="kw">min</span>(lat), <span class="dt">ymx=</span><span class="kw">max</span>(lat), </a>
<a class="sourceLine" id="cb19-9" title="9">                   <span class="dt">crs=</span>utm17.pro)</a>
<a class="sourceLine" id="cb19-10" title="10">slice2.r &lt;-<span class="st"> </span><span class="kw">flip</span>(slice2.r, <span class="dt">direction=</span><span class="st">&#39;y&#39;</span>)</a></code></pre></div>
<p>Now lets take a look at our work!</p>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-05-15-NetCDF_files/figure-html/unnamed-chunk-14-1.png" style="display: block; margin: auto;" /><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-05-15-NetCDF_files/figure-html/unnamed-chunk-14-2.png" style="display: block; margin: auto;" /></p>
<p>Now that these slices are raster files, you can take it one step further and do raster based maths…for instance seeing the change in water level between the two dates.</p>
<div class="sourceCode" id="cb20"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb20-1" title="1">slice.diff=slice2.r<span class="op">-</span>slice1.r</a></code></pre></div>
<p><img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-05-15-NetCDF_files/figure-html/unnamed-chunk-16-1.png" style="display: block; margin: auto;" /></p>
<hr />
</section>
