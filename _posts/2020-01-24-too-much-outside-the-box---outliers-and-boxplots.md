---
title: "Too much outside the box - Outliers and Boxplots"


date: "January 24, 2020"
layout: post
---


<section class="main-content">
<p><strong>Keywords:</strong> boxplots, outlier, data analysis</p>
<hr />
<p>In a recent commentary due out in <a href="https://www.springer.com/journal/227" target="_blank">Marine Biology</a> soon (hopefully) I argue against the use of boxplots as a method of outlier detection. Also seems that boxplots are very popular with people having strong opinons …</p>
<p><img src="{{ site.url }}{{ site.baseurl }}\images\20200124_Boxplot\tweet.png" width="50%" style="display: block; margin: auto;" /></p>
<p>Before we get too into the weeds lets present the classical definition of what an outlier is, here I use <span class="citation">Gotelli and Ellison (<a href="#ref-gotelli_primer_2013" role="doc-biblioref">2013</a>)</span> but across statistical literature outliers are generally defined/described similarly.</p>
<blockquote>
<p>“…extreme data points that are not characteristic of the distribution they were sampled…” <span class="citation">(Gotelli and Ellison <a href="#ref-gotelli_primer_2013" role="doc-biblioref">2013</a>)</span>.</p>
</blockquote>
<p>What would a classic example of this definition look like in “real data” (below is generated data…technically not real data)?</p>
<p>Here is how the data was generated for demonstration purposes</p>
<div class="sourceCode" id="cb1"><pre class="sourceCode r"><code class="sourceCode r"><a class="sourceLine" id="cb1-1" title="1"><span class="kw">set.seed</span>(<span class="dv">123</span>)</a>
<a class="sourceLine" id="cb1-2" title="2"><span class="co"># &quot;Data</span></a>
<a class="sourceLine" id="cb1-3" title="3">N.val&lt;-<span class="dv">100</span></a>
<a class="sourceLine" id="cb1-4" title="4">x.val&lt;-<span class="kw">seq</span>(<span class="dv">0</span>,<span class="dv">1</span>,<span class="dt">length.out=</span>N.val)</a>
<a class="sourceLine" id="cb1-5" title="5">m&lt;-<span class="dv">5</span></a>
<a class="sourceLine" id="cb1-6" title="6">b&lt;-<span class="dv">1</span></a>
<a class="sourceLine" id="cb1-7" title="7">error.val&lt;-<span class="dv">1</span></a>
<a class="sourceLine" id="cb1-8" title="8">y.val&lt;-((m<span class="op">*</span>x.val)<span class="op">+</span>b)<span class="op">+</span><span class="kw">rnorm</span>(N.val,<span class="dv">0</span>,error.val)</a>
<a class="sourceLine" id="cb1-9" title="9"></a>
<a class="sourceLine" id="cb1-10" title="10"><span class="co"># Outlier</span></a>
<a class="sourceLine" id="cb1-11" title="11">y.val.out&lt;-y.val[<span class="dv">95</span>]<span class="op">+</span><span class="fl">2.5</span></a></code></pre></div>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-01-24-Boxplot_files/figure-html/unnamed-chunk-4-1.png" alt="Visual example of an outlier based on the definition above."  />
<p class="caption">
Visual example of an outlier based on the definition above.
</p>
</div>
<p>Clearly, based on the example above it seems like the <span style="red">red</span> point in the plot to the left looks like it doesn’t really belong. A quick density plot of the data with and without the point (use <code>plot(density(...))</code>) gives you a sense of if the extreme data point is outside of the data distribution. The plot to the right demonstrates the data distribution and mean (dashed) without the extreme value relative to the extreme value (<span style="red">red</span> line).</p>
<p>The next step to really determine if its an outlier would be to conduct an outlier test on your data. Outliers in data can distort the data distribution, affect predictions (if used in a model) and affect the overall accuracy of estimates if they are not detected and handled, especially in bi-variate analysis (such as linear modeling). Most of the information you will see on the internet and in some textbooks is that boxplots are good way to identify outliers. I fully endorse using boxplots as a first looks at the data, just to get a sense of things as they were intended by <span class="citation">Tukey (<a href="#ref-tukey_exploratory_1977" role="doc-biblioref">1977</a>)</span>. Thats right <a href="https://en.wikipedia.org/wiki/John_Tukey" target="_blank">Dr. John W Tukey</a> was the mastermind behind the boxplot…you may remember him from such statistical analyses as <a href="https://en.wikipedia.org/wiki/Tukey%27s_range_test" target="_blank">Tukey’s range test/HSD</a> or <a href="https://en.wikipedia.org/wiki/Tukey_lambda_distribution" target="blank">Tukey lambda distribution</a>.</p>
<p>Overall, boxplots are extremely helpful in quickly visualization of the central tendency and spread of the data. Don’t confuse the central tendency and spread for mean and standard deviation, as these values are not usually displayed in boxplots.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-01-24-Boxplot_files/figure-html/unnamed-chunk-5-1.png" alt="Components of a classic Tukey boxplot."  />
<p class="caption">
Components of a classic Tukey boxplot.
</p>
</div>
<p>At its root, boxplots providing no information on the underlying data distribution and provide a somewhat arbitrary detection of extreme values especially for non-normal data distributions <span class="citation">(Kampstra <a href="#ref-kampstra_beanplot:_2008" role="doc-biblioref">2008</a>; Krzywinski and Altman <a href="#ref-krzywinski_visualizing_2014" role="doc-biblioref">2014</a>)</span>. Extreme values are identified using a univariate boxplot simply identifies values that fall outside of 1.5 time the inter-quartile range (IQR) of the first or third quartile <span class="citation">(Tukey <a href="#ref-tukey_exploratory_1977" role="doc-biblioref">1977</a>)</span>. As discussed above, outliers are extreme values outside the distribution of the data. Since IQR (i.e. median, 25th quantile, 75th quantile, etc.) calculations are distributionless calculations, values outside the IQR therefore are not based on any distribution. Below are four examples of data pulled from different distributions with a mean of zero (<span class="math inline">\(\mu = 0\)</span>) and standard deviation of one (<span class="math inline">\(\sigma = 1\)</span>). In these cases, especially for normally and skewed normal distributions, median, 25<sup>th</sup> quantile and 75<sup>th</sup> quantile values do not differ greatly, but the number of outliers do differ.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-01-24-Boxplot_files/figure-html/unnamed-chunk-7-1.png" alt="Boxplot and distribution plots of uniform, normal and skewed normal distributions with μ = 0 and σ = 1 (mean and standard deviation) and an N = 10,000."  />
<p class="caption">
Boxplot and distribution plots of uniform, normal and skewed normal distributions with μ = 0 and σ = 1 (mean and standard deviation) and an N = 10,000.
</p>
</div>
<p>The boxplot examples above show the span of over 10,000 values pulled from uniform, normal and skewed normal distribtuions. A directly obvious observations is that the uniform distribition does not generate any extreme values while the others generate some depending on the skewness of the distributions. <span class="citation">Kampstra (<a href="#ref-kampstra_beanplot:_2008" role="doc-biblioref">2008</a>)</span> suggests that even for normal distributions the number of extreme values identified will increase concurrently with sample size. This is demonstrated below where as sample size increases, the number of extreme values identified also increases. Furthermore, as sample size increases the IQR estimates narrows which you would expect given the central limit theorem. This sample size dependance ultimately makes individual “outlier” detection problematic.</p>
<div class="figure" style="text-align: center">
<img src="{{ site.url }}{{ site.baseurl }}/knitr_files/2020-01-24-Boxplot_files/figure-html/unnamed-chunk-9-1.png" alt="Number of potential outliers detected using a univariate boxplot (top) and inter-quartile range as a function of sample size (bottom) from a normally distributed simulated dataset with a mean of zero and a standard deviation of one (μ  = 0; σ = 1)."  />
<p class="caption">
Number of potential outliers detected using a univariate boxplot (top) and inter-quartile range as a function of sample size (bottom) from a normally distributed simulated dataset with a mean of zero and a standard deviation of one (μ = 0; σ = 1).
</p>
</div>
<p>Bottom line, a boxplot is not a suitable outlier detection test but rather an exploratory data analysis to understand the data. While boxplots do identify extreme values, these extreme values are not truely outliers, they are just values that outside a <em>distribution-less</em> metric on the near extremes of the IQR. Outlier tests such as the Grubbs test, Cochran test or even the Dixon test all can be used to idenify outliers. These tests and more can be found in the <code>outlier</code> <code>R</code> package. Outlier identification and culling is a tricky situtation and requires a strong and rigirous justification and validation that data points identified as an outlier is truely an outlier otherwise you can run afoul of type I and/or type II errors.</p>
<div id="references" class="section level2 unnumbered">
<h2>References</h2>
<div id="refs" class="references">
<div id="ref-gotelli_primer_2013">
<p>Gotelli, Nicholas J., and Aaron M. Ellison. 2013. <em>A Primer of Ecological Statistics</em>. Sunderland, MA: Sinauer Associates, Inc.</p>
</div>
<div id="ref-kampstra_beanplot:_2008">
<p>Kampstra, Peter. 2008. “Beanplot: A Boxplot Alternative for Visual Comparison of Distributions.” <em>Journal of Statistical Software</em> 28 (Code Snippet 1). <a href="https://doi.org/10.18637/jss.v028.c01">https://doi.org/10.18637/jss.v028.c01</a>.</p>
</div>
<div id="ref-krzywinski_visualizing_2014">
<p>Krzywinski, Martin, and Naomi Altman. 2014. “Visualizing Samples with Box Plots.” <em>Nature Methods</em> 11 (2): 119–20. <a href="https://doi.org/10.1038/nmeth.2813">https://doi.org/10.1038/nmeth.2813</a>.</p>
</div>
<div id="ref-tukey_exploratory_1977">
<p>Tukey, John Wilder. 1977. “Exploratory Data Analysis.” In <em>Statistics and Public Policy</em>, edited by Frederick Mosteller, 1st ed. Addison-Wesley Series in Behavioral Science. Quantitative Methods. Addison-Wesley.</p>
</div>
</div>
</div>
</section>
