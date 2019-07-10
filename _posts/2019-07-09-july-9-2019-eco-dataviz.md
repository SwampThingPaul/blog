---
title: "July 9, 2019 Eco DataViz"


date: "July 9, 2019"
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> dataviz, R, Sea Ice</p>
<p>Following the progression of my data viz journey, I decided to tackle some Arctic sea-ice data after checking out <a href="https://twitter.com/ZLabe" target="_blank">Zack Labe’s</a> Arctic Ice <a href="https://sites.uci.edu/zlabe/arctic-sea-ice-figures/" target="_blank">figures</a>. The data this week is modeled sea-ice volume and thickness from the <a href="http://psc.apl.uw.edu" target="_blank">Polar Science Center</a> Pan-Arctic Ice Ocean Modeling and Assimilation System (<a href="http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/" target="_blank">PIOMAS</a>). Sea ice volume is an important climate indicator. It depends on both ice thickness and extent and therefore more directly tied to climate forcing than extent alone.</p>
<p>Each data viz endeavor I try to learn something new or explore existing technique. Dates in <code>R</code> can be stressful to say the least. For anyone who has worked with time-series data would agree. Dates can be formatted as a date format using <code>as.Date()</code>, <code>format()</code>, <code>as.POSIXct()</code> or <code>as.POSIXlt()</code>…most of my time in <code>R</code> is spent formatting dates. Here is a useful <a href="https://www.stat.berkeley.edu/~s133/dates.html" target="_blank">page</a> on working with dates in <code>R</code>. The PIOMAS data has three variables…Year, Day of Year (1 - 365) and Thickness (or Volume). I downloaded the data from <a href="http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/data/" target="_blank">webpage</a> and unzipped the gzipped tar file using a third party to extract the data, but this can also be done in <code>R</code>. The two data sets volume and thickness data s ASCII files.</p>
<p>Lets load our libraries/packages.</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" title="1"><span class="co">#Libraries</span></a>
<a class="sourceLine" id="cb1-2" title="2"><span class="co">#devtools::install_github(&quot;SwampThingPaul/AnalystHelper&quot;)</span></a>
<a class="sourceLine" id="cb1-3" title="3"><span class="kw">library</span>(AnalystHelper);</a>
<a class="sourceLine" id="cb1-4" title="4"><span class="kw">library</span>(plyr)</a>
<a class="sourceLine" id="cb1-5" title="5"><span class="kw">library</span>(reshape)</a></code></pre></div>
<div class="sourceCode" id="cb2"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb2-1" title="1">thick.dat=<span class="kw">read.table</span>(<span class="st">&quot;PIOMAS.thick.daily.1979.2019.Current.v2.1.dat&quot;</span>,</a>
<a class="sourceLine" id="cb2-2" title="2"><span class="dt">header=</span>F,<span class="dt">skip=</span><span class="dv">1</span>,<span class="dt">col.names=</span><span class="kw">c</span>(<span class="st">&quot;Year&quot;</span>,<span class="st">&quot;Day&quot;</span>,<span class="st">&quot;Thickness_m&quot;</span>))</a></code></pre></div>
<div class="sourceCode" id="cb3"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb3-1" title="1"><span class="kw">head</span>(thick.dat,5L)</a></code></pre></div>
<pre><code>##   Year Day Thickness_m
## 1 1979   1       1.951
## 2 1979   2       1.955
## 3 1979   3       1.962
## 4 1979   4       1.965
## 5 1979   5       1.973</code></pre>
<p>The sea-ice volume data is in the same format.</p>
<div class="sourceCode" id="cb5"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb5-1" title="1">vol.dat=<span class="kw">read.table</span>(<span class="st">&quot;PIOMAS.vol.daily.1979.2019.Current.v2.1.dat&quot;</span>,</a>
<a class="sourceLine" id="cb5-2" title="2">                   <span class="dt">header=</span>F,<span class="dt">skip=</span><span class="dv">1</span>,<span class="dt">col.names=</span><span class="kw">c</span>(<span class="st">&quot;Year&quot;</span>,<span class="st">&quot;Day&quot;</span>,<span class="st">&quot;Vol_km3&quot;</span>))</a>
<a class="sourceLine" id="cb5-3" title="3">vol.dat<span class="op">$</span>Vol_km3=vol.dat<span class="op">$</span>Vol_km3<span class="op">*</span><span class="fl">1E+3</span>;<span class="co">#To convert data </span></a></code></pre></div>
<div class="sourceCode" id="cb6"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb6-1" title="1"><span class="kw">head</span>(vol.dat,5L)</a></code></pre></div>
<pre><code>##   Year Day Vol_km3
## 1 1979   1   26405
## 2 1979   2   26496
## 3 1979   3   26582
## 4 1979   4   26672
## 5 1979   5   26770</code></pre>
<p>The sea-ice thickness data are expressed in meters, and volume in x10<sup>3</sup> km<sup>3</sup>. Understanding what the data represent and how they are derived is most of the job of a scientist especially in data visualization. Inherently all data has its limits.</p>
<p>Currently we have two different data files <code>vol.dat</code> and <code>thick.dat</code>, lets get them into one single <code>data.frame</code> and sort the data accordingly (just in case).</p>
<div class="sourceCode" id="cb8"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb8-1" title="1">dat=<span class="kw">merge</span>(thick.dat,vol.dat,<span class="kw">c</span>(<span class="st">&quot;Year&quot;</span>,<span class="st">&quot;Day&quot;</span>))</a>
<a class="sourceLine" id="cb8-2" title="2">dat=dat[<span class="kw">order</span>(dat<span class="op">$</span>Year,dat<span class="op">$</span>Day),]</a></code></pre></div>
<p>Alright here come the fun part…dates in <code>R</code>. Remember the data is Year and Day of Year, which mean no month or day (i.e. Date). Essentially you have to back calculate day of the year to an actual date. Thankfully this is pretty easy. Check out <code>?strptime</code> and <code>?format</code>!!</p>
<div class="sourceCode" id="cb9"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb9-1" title="1">dat<span class="op">$</span>month.day=<span class="kw">format</span>(<span class="kw">strptime</span>(dat<span class="op">$</span>Day,<span class="st">&quot;%j&quot;</span>),<span class="st">&quot;%m-%d&quot;</span>)</a></code></pre></div>
<p>This gets us Month-Day from day of the year. Now for some tricky. Lets actually make this a date by using paste and leveraging <code>date.fun()</code> from <code>AnalystHelper</code>.</p>
<div class="sourceCode" id="cb10"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb10-1" title="1">dat<span class="op">$</span>Date=<span class="kw">with</span>(dat,<span class="kw">date.fun</span>(<span class="kw">paste</span>(Year,month.day,<span class="dt">sep=</span><span class="st">&quot;-&quot;</span>),<span class="dt">tz=</span><span class="st">&quot;GMT&quot;</span>))</a></code></pre></div>
<p>Viola!! We have a <code>POSIXct</code> formatted field that has Year-Month-Day…in-case you wanted to check the sea-ice volume on your birthday, wedding anniversary, etc. …no one? Just me? …OK moving on!!</p>
<p>Some more tricky which comes in handy when aggregating data is to determine the month and year (for monthly summary statistics). Also we can determine what decade the data is from, it wasn’t used in this analysis but something interesting I discovered in my data musings.</p>
<div class="sourceCode" id="cb11"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb11-1" title="1">dat<span class="op">$</span>month.yr=<span class="kw">with</span>(dat,<span class="kw">date.fun</span>(<span class="kw">paste</span>(Year,<span class="kw">format</span>(Date,<span class="st">&quot;%m&quot;</span>),<span class="dv">01</span>,<span class="dt">sep=</span><span class="st">&quot;-&quot;</span>),<span class="dt">tz=</span><span class="st">&quot;GMT&quot;</span>))</a>
<a class="sourceLine" id="cb11-2" title="2">dat<span class="op">$</span>decade=((dat<span class="op">$</span>Year)<span class="op">%/%</span><span class="dv">10</span>)<span class="op">*</span><span class="dv">10</span></a></code></pre></div>
<p>Now that we have the data put together lets start plotting.</p>
<p>Here we have just daily (modeled) sea-ice thickness data from PIOMAS.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-07-09-DataViz_files/figure-html/unnamed-chunk-11-1.png" alt="Pan Arctic Sea-Ice thickness from 1979 to present. Data source: Polar Science Center - ([PIOMAS](http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/))."  />
<p class="caption">
Pan Arctic Sea-Ice thickness from 1979 to present. Data source: Polar Science Center - (<a href="http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/">PIOMAS</a>).
</p>
</div>
<p>Now we can estimate annual mean and some confidence interval around the mean…lets say 95%.</p>
<div class="sourceCode" id="cb12"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb12-1" title="1"><span class="co">#Calculate annual mean, sd and N. Excluding 2019 (partial year)</span></a>
<a class="sourceLine" id="cb12-2" title="2">period.mean=<span class="kw">ddply</span>(<span class="kw">subset</span>(dat,Year<span class="op">!=</span><span class="dv">2019</span>),<span class="st">&quot;Year&quot;</span>,summarise,</a>
<a class="sourceLine" id="cb12-3" title="3">                  <span class="dt">mean.val=</span><span class="kw">mean</span>(Thickness_m,<span class="dt">na.rm=</span>T),</a>
<a class="sourceLine" id="cb12-4" title="4">                  <span class="dt">sd.val=</span><span class="kw">sd</span>(Thickness_m,<span class="dt">na.rm=</span>T),</a>
<a class="sourceLine" id="cb12-5" title="5">                  <span class="dt">N.val=</span><span class="kw">N</span>(Thickness_m))</a>
<a class="sourceLine" id="cb12-6" title="6"><span class="co">#Degrees of freedom</span></a>
<a class="sourceLine" id="cb12-7" title="7">period.mean<span class="op">$</span>Df=period.mean<span class="op">$</span>N.val<span class="dv">-1</span></a>
<a class="sourceLine" id="cb12-8" title="8"><span class="co">#Student-T statistic</span></a>
<a class="sourceLine" id="cb12-9" title="9">period.mean<span class="op">$</span>Tp=<span class="kw">abs</span>(<span class="kw">qt</span>(<span class="dv">1</span><span class="fl">-0.95</span>,period.mean<span class="op">$</span>Df))</a>
<a class="sourceLine" id="cb12-10" title="10"><span class="co">#Lower and Upper CI calculation</span></a>
<a class="sourceLine" id="cb12-11" title="11">period.mean<span class="op">$</span>LCI=<span class="kw">with</span>(period.mean,mean.val<span class="op">-</span>sd.val<span class="op">*</span>(Tp<span class="op">/</span><span class="kw">sqrt</span>(N.val)))</a>
<a class="sourceLine" id="cb12-12" title="12">period.mean<span class="op">$</span>UCI=<span class="kw">with</span>(period.mean,mean.val<span class="op">+</span>sd.val<span class="op">*</span>(Tp<span class="op">/</span><span class="kw">sqrt</span>(N.val)))</a></code></pre></div>
<p>Now lets add that to the plot with some additional trickery to plot annual mean <span class="math inline">\(\pm\)</span> 95% CI stating on Jan 1st of every year.</p>
<div class="sourceCode" id="cb13"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb13-1" title="1"><span class="kw">with</span>(period.mean,<span class="kw">lines</span>(<span class="kw">date.fun</span>(<span class="kw">paste</span>(Year,<span class="st">&quot;01-01&quot;</span>,<span class="dt">sep=</span><span class="st">&quot;-&quot;</span>),<span class="dt">tz=</span><span class="st">&quot;GMT&quot;</span>),mean.val,<span class="dt">lty=</span><span class="dv">1</span>,<span class="dt">col=</span><span class="st">&quot;red&quot;</span>))</a>
<a class="sourceLine" id="cb13-2" title="2"><span class="kw">with</span>(period.mean,<span class="kw">lines</span>(<span class="kw">date.fun</span>(<span class="kw">paste</span>(Year,<span class="st">&quot;01-01&quot;</span>,<span class="dt">sep=</span><span class="st">&quot;-&quot;</span>),<span class="dt">tz=</span><span class="st">&quot;GMT&quot;</span>),LCI,<span class="dt">lty=</span><span class="dv">2</span>,<span class="dt">col=</span><span class="st">&quot;red&quot;</span>))</a>
<a class="sourceLine" id="cb13-3" title="3"><span class="kw">with</span>(period.mean,<span class="kw">lines</span>(<span class="kw">date.fun</span>(<span class="kw">paste</span>(Year,<span class="st">&quot;01-01&quot;</span>,<span class="dt">sep=</span><span class="st">&quot;-&quot;</span>),<span class="dt">tz=</span><span class="st">&quot;GMT&quot;</span>),UCI,<span class="dt">lty=</span><span class="dv">2</span>,<span class="dt">col=</span><span class="st">&quot;red&quot;</span>))</a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-07-09-DataViz_files/figure-html/unnamed-chunk-14-1.png" alt="Pan Arctic Sea-Ice thickness from 1979 to present with annual mean and 95% confidence interval. Data source: Polar Science Center - ([PIOMAS](http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/))."  />
<p class="caption">
Pan Arctic Sea-Ice thickness from 1979 to present with annual mean and 95% confidence interval. Data source: Polar Science Center - (<a href="http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/">PIOMAS</a>).
</p>
</div>
<p>What does sea-ice volume look like?</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-07-09-DataViz_files/figure-html/unnamed-chunk-15-1.png" alt="Pan Arctic Sea-Ice volume from 1979 to present with annual mean and 95% confidence interval. Data source: Polar Science Center - ([PIOMAS](http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/))."  />
<p class="caption">
Pan Arctic Sea-Ice volume from 1979 to present with annual mean and 95% confidence interval. Data source: Polar Science Center - (<a href="http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/">PIOMAS</a>).
</p>
</div>
<p>Some interesting and alarming trends in both thickness and volume for sure! There is an obvious seasonal trend in the data…one way to look at this is to look at the period of record daily change.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-07-09-DataViz_files/figure-html/unnamed-chunk-16-1.png" alt="Period of record mean (1979 - 2018) daily mean and 95% confidence interval sea-ice volume and thickness. Data source: Polar Science Center - ([PIOMAS](http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/))."  />
<p class="caption">
Period of record mean (1979 - 2018) daily mean and 95% confidence interval sea-ice volume and thickness. Data source: Polar Science Center - (<a href="http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/">PIOMAS</a>).
</p>
</div>
<p><br></p>
<p>Now how does the thickness versus volume relationship look? Since the volume of data is so much we can do some interesting color coding for the different years. Here I use a color ramp <code>colorRampPalette(c("dodgerblue1","indianred1"))</code> with each year getting a color along the color ramp.</p>
<p>Here is how I set up the color ramp.</p>
<div class="sourceCode" id="cb14"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb14-1" title="1">N.yrs=<span class="kw">length</span>(<span class="kw">unique</span>(dat<span class="op">$</span>Year))</a>
<a class="sourceLine" id="cb14-2" title="2">cols=<span class="kw">colorRampPalette</span>(<span class="kw">c</span>(<span class="st">&quot;dodgerblue1&quot;</span>,<span class="st">&quot;indianred1&quot;</span>))(N.yrs)</a></code></pre></div>
<p>In the plot I use a loop to plot each year with a different color.</p>
<div class="sourceCode" id="cb15"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb15-1" title="1"><span class="kw">plot</span>(...)</a>
<a class="sourceLine" id="cb15-2" title="2"></a>
<a class="sourceLine" id="cb15-3" title="3"><span class="cf">for</span>(i <span class="cf">in</span> <span class="dv">1</span><span class="op">:</span>N.yrs){</a>
<a class="sourceLine" id="cb15-4" title="4">  <span class="kw">with</span>(<span class="kw">subset</span>(dat,Year<span class="op">==</span>yrs.val[i]),</a>
<a class="sourceLine" id="cb15-5" title="5">       <span class="kw">points</span>(Vol_km3,Thickness_m,<span class="dt">pch=</span><span class="dv">21</span>,</a>
<a class="sourceLine" id="cb15-6" title="6">              <span class="dt">bg=</span><span class="kw">adjustcolor</span>(cols[i],<span class="fl">0.2</span>),</a>
<a class="sourceLine" id="cb15-7" title="7">              <span class="dt">col=</span><span class="kw">adjustcolor</span>(cols[i],<span class="fl">0.4</span>),</a>
<a class="sourceLine" id="cb15-8" title="8">              <span class="dt">lwd=</span><span class="fl">0.1</span>,<span class="dt">cex=</span><span class="fl">1.25</span>))</a>
<a class="sourceLine" id="cb15-9" title="9">}</a></code></pre></div>
<p>As is with most data viz, especially in base <code>R</code> is some degree of tricking and layering. To build the color ramp legend I used the following (I adapted a version of <a href="https://stackoverflow.com/questions/13355176/gradient-legend-in-base/13355440#13355440" target="_blank">this</a>.).</p>
<div class="sourceCode" id="cb16"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb16-1" title="1"><span class="co"># A raster of the color ramp</span></a>
<a class="sourceLine" id="cb16-2" title="2">legend_image=<span class="kw">as.raster</span>(<span class="kw">matrix</span>(cols,<span class="dt">ncol=</span><span class="dv">1</span>))</a>
<a class="sourceLine" id="cb16-3" title="3"><span class="co"># Empty plot</span></a>
<a class="sourceLine" id="cb16-4" title="4"><span class="kw">plot</span>(<span class="kw">c</span>(<span class="dv">0</span>,<span class="dv">1</span>),<span class="kw">c</span>(<span class="dv">0</span>,<span class="dv">1</span>),<span class="dt">type =</span> <span class="st">&#39;n&#39;</span>, <span class="dt">axes =</span> F,<span class="dt">xlab =</span> <span class="st">&#39;&#39;</span>, <span class="dt">ylab =</span> <span class="st">&#39;&#39;</span>)</a>
<a class="sourceLine" id="cb16-5" title="5"><span class="co"># Gradient labels</span></a>
<a class="sourceLine" id="cb16-6" title="6"><span class="kw">text</span>(<span class="dt">x=</span><span class="fl">0.6</span>, <span class="dt">y =</span> <span class="kw">c</span>(<span class="fl">0.5</span>,<span class="fl">0.8</span>), <span class="dt">labels =</span> <span class="kw">c</span>(<span class="dv">2019</span>,<span class="dv">1979</span>),<span class="dt">cex=</span><span class="fl">0.8</span>,<span class="dt">xpd=</span><span class="ot">NA</span>,<span class="dt">adj=</span><span class="dv">0</span>)</a>
<a class="sourceLine" id="cb16-7" title="7"><span class="co"># Put the color ramp on the legend</span></a>
<a class="sourceLine" id="cb16-8" title="8"><span class="kw">rasterImage</span>(legend_image, <span class="fl">0.25</span>, <span class="fl">0.5</span>, <span class="fl">0.5</span>,<span class="fl">0.8</span>)</a>
<a class="sourceLine" id="cb16-9" title="9"><span class="co"># Label to legend</span></a>
<a class="sourceLine" id="cb16-10" title="10"><span class="kw">text</span>(<span class="fl">0.25</span><span class="op">+</span>(<span class="fl">0.5-0.25</span>)<span class="op">/</span><span class="dv">2</span>,<span class="fl">0.85</span>,<span class="st">&quot;Year&quot;</span>,<span class="dt">xpd=</span><span class="ot">NA</span>)</a></code></pre></div>
<p><br></p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2019-07-09-DataViz_files/figure-html/unnamed-chunk-20-1.png" alt="Sea-ice thickness versus volume for the 41 year period. Minimum ice thickness and volume identified for 1980, 1990, 2000 and 2010. Data source: Polar Science Center - ([PIOMAS](http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/))."  />
<p class="caption">
Sea-ice thickness versus volume for the 41 year period. Minimum ice thickness and volume identified for 1980, 1990, 2000 and 2010. Data source: Polar Science Center - (<a href="http://psc.apl.uw.edu/research/projects/arctic-sea-ice-volume-anomaly/">PIOMAS</a>).
</p>
</div>
<p>Hope you found this data visualization exercise interesting and thought provoking. Happy data trails!</p>
<hr />
</section>
