<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en"><head>

<meta charset="utf-8">
<meta name="generator" content="quarto-1.6.39">

<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">

<meta name="author" content="Huan Shuo Hsu">

<link href="PAC Competition_files/libs/bootstrap/bootstrap-icons.css" rel="stylesheet">
<link href="PAC Competition_files/libs/bootstrap/bootstrap-973236bd072d72a04ee9cd82dcc9cb29.min.css" rel="stylesheet" append-hash="true" id="quarto-bootstrap" data-mode="light">


</head>

<body>

<div id="quarto-content" class="page-columns page-rows-contents page-layout-article toc-left">
<div id="quarto-sidebar-toc-left" class="sidebar toc-left">
  <nav id="TOC" role="doc-toc" class="toc-active">
    <h2 id="toc-title">Table of contents</h2>
   
  <ul>
  <li><a href="#load-data" id="toc-load-data" class="nav-link active" data-scroll-target="#load-data">Load Data</a></li>
  <li><a href="#data-exploration" id="toc-data-exploration" class="nav-link" data-scroll-target="#data-exploration">Data Exploration</a>
  <ul>
  <li><a href="#key-summary" id="toc-key-summary" class="nav-link" data-scroll-target="#key-summary">Key Summary</a></li>
  <li><a href="#ctr-click-through-rate" id="toc-ctr-click-through-rate" class="nav-link" data-scroll-target="#ctr-click-through-rate">CTR (Click Through Rate)</a></li>
  <li><a href="#targeting-score" id="toc-targeting-score" class="nav-link" data-scroll-target="#targeting-score">Targeting Score</a></li>
  <li><a href="#visual-appeal" id="toc-visual-appeal" class="nav-link" data-scroll-target="#visual-appeal">Visual Appeal</a></li>
  <li><a href="#contextual-relevance" id="toc-contextual-relevance" class="nav-link" data-scroll-target="#contextual-relevance">Contextual Relevance</a></li>
  <li><a href="#headline-sentiment" id="toc-headline-sentiment" class="nav-link" data-scroll-target="#headline-sentiment">Headline Sentiment</a></li>
  <li><a href="#body-keyword-density" id="toc-body-keyword-density" class="nav-link" data-scroll-target="#body-keyword-density">Body Keyword Density</a></li>
  <li><a href="#body-readability-score" id="toc-body-readability-score" class="nav-link" data-scroll-target="#body-readability-score">Body Readability Score</a></li>
  </ul></li>
  <li><a href="#data-cleaining" id="toc-data-cleaining" class="nav-link" data-scroll-target="#data-cleaining">Data Cleaining</a>
  <ul>
  <li><a href="#handling-skewness-of-ctr" id="toc-handling-skewness-of-ctr" class="nav-link" data-scroll-target="#handling-skewness-of-ctr">Handling Skewness of CTR</a></li>
  <li><a href="#separating-columns-by-data-type" id="toc-separating-columns-by-data-type" class="nav-link" data-scroll-target="#separating-columns-by-data-type">Separating Columns by Data Type</a></li>
  <li><a href="#imputing-missing-values" id="toc-imputing-missing-values" class="nav-link" data-scroll-target="#imputing-missing-values">Imputing Missing Values</a></li>
  <li><a href="#feature-selection" id="toc-feature-selection" class="nav-link" data-scroll-target="#feature-selection">Feature Selection</a></li>
  </ul></li>
  <li><a href="#xgboost" id="toc-xgboost" class="nav-link" data-scroll-target="#xgboost">XGBoost</a>
  <ul>
  <li><a href="#cross-validation" id="toc-cross-validation" class="nav-link" data-scroll-target="#cross-validation">Cross Validation</a></li>
  <li><a href="#hyperparameter-tuning" id="toc-hyperparameter-tuning" class="nav-link" data-scroll-target="#hyperparameter-tuning">Hyperparameter Tuning</a></li>
  </ul></li>
  <li><a href="#prediction" id="toc-prediction" class="nav-link" data-scroll-target="#prediction">Prediction</a></li>
  <li><a href="#final-comment" id="toc-final-comment" class="nav-link" data-scroll-target="#final-comment">Final Comment</a></li>
  </ul>
</nav>
</div>
<div id="quarto-margin-sidebar" class="sidebar margin-sidebar zindex-bottom">
</div>
<main class="content" id="quarto-document-content">

<header id="title-block-header" class="quarto-title-block default">
<div class="quarto-title">
<h1 class="title">PAC Competition</h1>
</div>



<div class="quarto-title-meta">

    <div>
    <div class="quarto-title-meta-heading">Author</div>
    <div class="quarto-title-meta-contents">
             <p>Huan Shuo Hsu </p>
          </div>
  </div>
    
  
    
  </div>
  


</header>


<section id="load-data" class="level1">
<h1>Load Data</h1>
<p>The provided dataset <code>analsysis_data</code> will be the train set, and <code>scoring_data</code> will be the test set.</p>
<div class="cell">
<div class="sourceCode cell-code" id="cb1"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Load Required Libraries ---</span></span>
<span id="cb1-2"><a href="#cb1-2" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(dplyr)</span>
<span id="cb1-3"><a href="#cb1-3" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(caret)</span>
<span id="cb1-4"><a href="#cb1-4" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb1-5"><a href="#cb1-5" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Load Data ---</span></span>
<span id="cb1-6"><a href="#cb1-6" aria-hidden="true" tabindex="-1"></a>train <span class="ot">&lt;-</span> <span class="fu">read.csv</span>(<span class="st">"analysis_data.csv"</span>)</span>
<span id="cb1-7"><a href="#cb1-7" aria-hidden="true" tabindex="-1"></a>test <span class="ot">&lt;-</span> <span class="fu">read.csv</span>(<span class="st">"scoring_data.csv"</span>)</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
</section>
<section id="data-exploration" class="level1">
<h1>Data Exploration</h1>
<p>To begin the analysis, the <code>skim</code> function is used from the <strong>skimr</strong> package to gain an overview of the dataset. This function provides a summary of each variable, including its distribution, data type, and completeness. We will then pick out a few important variables base on domain knowledge and take a deeper dive into their structure.</p>
<div class="cell">
<div class="sourceCode cell-code" id="cb2"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb2-1"><a href="#cb2-1" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(skimr)</span>
<span id="cb2-2"><a href="#cb2-2" aria-hidden="true" tabindex="-1"></a><span class="fu">skim</span>(train)</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<table class="caption-top table table-sm table-striped small">
<caption>Data summary</caption>
<tbody>
<tr class="odd">
<td style="text-align: left;">Name</td>
<td style="text-align: left;">train</td>
</tr>
<tr class="even">
<td style="text-align: left;">Number of rows</td>
<td style="text-align: left;">4000</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Number of columns</td>
<td style="text-align: left;">29</td>
</tr>
<tr class="even">
<td style="text-align: left;">_______________________</td>
<td style="text-align: left;"></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Column type frequency:</td>
<td style="text-align: left;"></td>
</tr>
<tr class="even">
<td style="text-align: left;">character</td>
<td style="text-align: left;">8</td>
</tr>
<tr class="odd">
<td style="text-align: left;">numeric</td>
<td style="text-align: left;">21</td>
</tr>
<tr class="even">
<td style="text-align: left;">________________________</td>
<td style="text-align: left;"></td>
</tr>
<tr class="odd">
<td style="text-align: left;">Group variables</td>
<td style="text-align: left;">None</td>
</tr>
</tbody>
</table>
<p><strong>Variable type: character</strong></p>
<table class="caption-top table table-sm table-striped small">
<colgroup>
<col style="width: 22%">
<col style="width: 13%">
<col style="width: 18%">
<col style="width: 5%">
<col style="width: 5%">
<col style="width: 8%">
<col style="width: 12%">
<col style="width: 14%">
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">skim_variable</th>
<th style="text-align: right;">n_missing</th>
<th style="text-align: right;">complete_rate</th>
<th style="text-align: right;">min</th>
<th style="text-align: right;">max</th>
<th style="text-align: right;">empty</th>
<th style="text-align: right;">n_unique</th>
<th style="text-align: right;">whitespace</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">position_on_page</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">10</td>
<td style="text-align: right;">11</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">3</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="even">
<td style="text-align: left;">ad_format</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">3</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="odd">
<td style="text-align: left;">age_group</td>
<td style="text-align: right;">125</td>
<td style="text-align: right;">0.97</td>
<td style="text-align: right;">3</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">8</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="even">
<td style="text-align: left;">gender</td>
<td style="text-align: right;">77</td>
<td style="text-align: right;">0.98</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">6</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">3</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="odd">
<td style="text-align: left;">location</td>
<td style="text-align: right;">318</td>
<td style="text-align: right;">0.92</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="even">
<td style="text-align: left;">time_of_day</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">5</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">4</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="odd">
<td style="text-align: left;">day_of_week</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">6</td>
<td style="text-align: right;">9</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">0</td>
</tr>
<tr class="even">
<td style="text-align: left;">device_type</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">6</td>
<td style="text-align: right;">7</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">3</td>
<td style="text-align: right;">0</td>
</tr>
</tbody>
</table>
<p><strong>Variable type: numeric</strong></p>
<table class="caption-top table table-sm table-striped small">
<colgroup>
<col style="width: 21%">
<col style="width: 9%">
<col style="width: 12%">
<col style="width: 7%">
<col style="width: 7%">
<col style="width: 7%">
<col style="width: 7%">
<col style="width: 7%">
<col style="width: 7%">
<col style="width: 7%">
<col style="width: 5%">
</colgroup>
<thead>
<tr class="header">
<th style="text-align: left;">skim_variable</th>
<th style="text-align: right;">n_missing</th>
<th style="text-align: right;">complete_rate</th>
<th style="text-align: right;">mean</th>
<th style="text-align: right;">sd</th>
<th style="text-align: right;">p0</th>
<th style="text-align: right;">p25</th>
<th style="text-align: right;">p50</th>
<th style="text-align: right;">p75</th>
<th style="text-align: right;">p100</th>
<th style="text-align: left;">hist</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">id</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">5508.43</td>
<td style="text-align: right;">2562.14</td>
<td style="text-align: right;">1002.00</td>
<td style="text-align: right;">3337.50</td>
<td style="text-align: right;">5513.50</td>
<td style="text-align: right;">7697.25</td>
<td style="text-align: right;">9999.00</td>
<td style="text-align: left;">▇▇▇▇▇</td>
</tr>
<tr class="even">
<td style="text-align: left;">targeting_score</td>
<td style="text-align: right;">244</td>
<td style="text-align: right;">0.94</td>
<td style="text-align: right;">4.02</td>
<td style="text-align: right;">2.78</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">2.00</td>
<td style="text-align: right;">3.00</td>
<td style="text-align: right;">5.00</td>
<td style="text-align: right;">23.00</td>
<td style="text-align: left;">▇▃▁▁▁</td>
</tr>
<tr class="odd">
<td style="text-align: left;">visual_appeal</td>
<td style="text-align: right;">244</td>
<td style="text-align: right;">0.94</td>
<td style="text-align: right;">4.04</td>
<td style="text-align: right;">4.18</td>
<td style="text-align: right;">-9.54</td>
<td style="text-align: right;">1.13</td>
<td style="text-align: right;">3.81</td>
<td style="text-align: right;">6.62</td>
<td style="text-align: right;">26.45</td>
<td style="text-align: left;">▁▇▅▁▁</td>
</tr>
<tr class="even">
<td style="text-align: left;">contextual_relevance</td>
<td style="text-align: right;">244</td>
<td style="text-align: right;">0.94</td>
<td style="text-align: right;">0.51</td>
<td style="text-align: right;">0.50</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: left;">▇▁▁▁▇</td>
</tr>
<tr class="odd">
<td style="text-align: left;">headline_length</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">36.87</td>
<td style="text-align: right;">23.97</td>
<td style="text-align: right;">5.00</td>
<td style="text-align: right;">19.00</td>
<td style="text-align: right;">29.00</td>
<td style="text-align: right;">51.00</td>
<td style="text-align: right;">100.00</td>
<td style="text-align: left;">▇▆▃▂▂</td>
</tr>
<tr class="even">
<td style="text-align: left;">cta_strength</td>
<td style="text-align: right;">244</td>
<td style="text-align: right;">0.94</td>
<td style="text-align: right;">3.95</td>
<td style="text-align: right;">2.76</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">2.00</td>
<td style="text-align: right;">3.00</td>
<td style="text-align: right;">5.00</td>
<td style="text-align: right;">18.00</td>
<td style="text-align: left;">▇▆▁▁▁</td>
</tr>
<tr class="odd">
<td style="text-align: left;">brand_familiarity</td>
<td style="text-align: right;">244</td>
<td style="text-align: right;">0.94</td>
<td style="text-align: right;">4.01</td>
<td style="text-align: right;">2.97</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">2.00</td>
<td style="text-align: right;">3.00</td>
<td style="text-align: right;">5.00</td>
<td style="text-align: right;">27.00</td>
<td style="text-align: left;">▇▂▁▁▁</td>
</tr>
<tr class="even">
<td style="text-align: left;">ad_frequency</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">5.53</td>
<td style="text-align: right;">2.85</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">3.00</td>
<td style="text-align: right;">6.00</td>
<td style="text-align: right;">8.00</td>
<td style="text-align: right;">10.00</td>
<td style="text-align: left;">▇▇▇▇▇</td>
</tr>
<tr class="odd">
<td style="text-align: left;">market_saturation</td>
<td style="text-align: right;">244</td>
<td style="text-align: right;">0.94</td>
<td style="text-align: right;">3.91</td>
<td style="text-align: right;">2.79</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">2.00</td>
<td style="text-align: right;">3.00</td>
<td style="text-align: right;">5.00</td>
<td style="text-align: right;">20.00</td>
<td style="text-align: left;">▇▃▁▁▁</td>
</tr>
<tr class="even">
<td style="text-align: left;">seasonality</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">0.50</td>
<td style="text-align: right;">0.50</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: left;">▇▁▁▁▇</td>
</tr>
<tr class="odd">
<td style="text-align: left;">headline_sentiment</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">-0.03</td>
<td style="text-align: right;">2.02</td>
<td style="text-align: right;">-7.04</td>
<td style="text-align: right;">-1.39</td>
<td style="text-align: right;">-0.07</td>
<td style="text-align: right;">1.33</td>
<td style="text-align: right;">7.11</td>
<td style="text-align: left;">▁▃▇▃▁</td>
</tr>
<tr class="even">
<td style="text-align: left;">headline_word_count</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">6.60</td>
<td style="text-align: right;">3.51</td>
<td style="text-align: right;">2.00</td>
<td style="text-align: right;">4.00</td>
<td style="text-align: right;">6.00</td>
<td style="text-align: right;">9.00</td>
<td style="text-align: right;">15.00</td>
<td style="text-align: left;">▇▇▃▃▂</td>
</tr>
<tr class="odd">
<td style="text-align: left;">headline_power_words</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">0.51</td>
<td style="text-align: right;">0.50</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: left;">▇▁▁▁▇</td>
</tr>
<tr class="even">
<td style="text-align: left;">body_text_length</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">58.04</td>
<td style="text-align: right;">49.37</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">21.00</td>
<td style="text-align: right;">43.00</td>
<td style="text-align: right;">82.00</td>
<td style="text-align: right;">200.00</td>
<td style="text-align: left;">▇▅▂▁▁</td>
</tr>
<tr class="odd">
<td style="text-align: left;">body_word_count</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">11.38</td>
<td style="text-align: right;">9.91</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">4.00</td>
<td style="text-align: right;">8.00</td>
<td style="text-align: right;">17.00</td>
<td style="text-align: right;">40.00</td>
<td style="text-align: left;">▇▃▂▁▁</td>
</tr>
<tr class="even">
<td style="text-align: left;">body_sentiment</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">0.03</td>
<td style="text-align: right;">2.00</td>
<td style="text-align: right;">-6.35</td>
<td style="text-align: right;">-1.36</td>
<td style="text-align: right;">0.05</td>
<td style="text-align: right;">1.40</td>
<td style="text-align: right;">6.68</td>
<td style="text-align: left;">▁▅▇▃▁</td>
</tr>
<tr class="odd">
<td style="text-align: left;">headline_question</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">0.51</td>
<td style="text-align: right;">0.50</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: left;">▇▁▁▁▇</td>
</tr>
<tr class="even">
<td style="text-align: left;">headline_numbers</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">0.50</td>
<td style="text-align: right;">0.50</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: left;">▇▁▁▁▇</td>
</tr>
<tr class="odd">
<td style="text-align: left;">body_keyword_density</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">0.06</td>
<td style="text-align: right;">0.03</td>
<td style="text-align: right;">0.01</td>
<td style="text-align: right;">0.03</td>
<td style="text-align: right;">0.05</td>
<td style="text-align: right;">0.08</td>
<td style="text-align: right;">0.10</td>
<td style="text-align: left;">▇▇▇▇▇</td>
</tr>
<tr class="even">
<td style="text-align: left;">body_readability_score</td>
<td style="text-align: right;">205</td>
<td style="text-align: right;">0.95</td>
<td style="text-align: right;">74.87</td>
<td style="text-align: right;">14.39</td>
<td style="text-align: right;">50.04</td>
<td style="text-align: right;">62.42</td>
<td style="text-align: right;">74.76</td>
<td style="text-align: right;">87.12</td>
<td style="text-align: right;">100.00</td>
<td style="text-align: left;">▇▇▇▇▇</td>
</tr>
<tr class="odd">
<td style="text-align: left;">CTR</td>
<td style="text-align: right;">0</td>
<td style="text-align: right;">1.00</td>
<td style="text-align: right;">0.22</td>
<td style="text-align: right;">0.21</td>
<td style="text-align: right;">0.00</td>
<td style="text-align: right;">0.11</td>
<td style="text-align: right;">0.18</td>
<td style="text-align: right;">0.27</td>
<td style="text-align: right;">3.75</td>
<td style="text-align: left;">▇▁▁▁▁</td>
</tr>
</tbody>
</table>
</div>
</div>
<section id="key-summary" class="level4">
<h4 class="anchored" data-anchor-id="key-summary">Key Summary</h4>
<ul>
<li><code>4000</code> observations</li>
<li><code>29</code> variables</li>
<li><code>8</code> <code>character</code> type variables</li>
<li><code>12</code> <code>numeric</code> type variables</li>
<li>The <code>complete_rate</code> of the data are all above <code>94%</code>.</li>
<li><strong>Skewness and Distribution</strong>
<ul>
<li>Several variables appear heavily skewed, as seen in the distribution charts <code>(▇▃▁▁▁, ▇▁▁▁▇)</code>.</li>
<li>For instance, variables like <code>CTR</code>, <code>visual_appeal</code>, and <code>market_saturation</code> are <strong>right-skewed</strong> (long tails toward higher values).</li>
</ul></li>
<li><strong>Range of Values</strong>
<ul>
<li>Wide Ranges: Some variables have a large range of values, indicating potential outliers or diverse scales:
<ul>
<li><code>visual_appeal</code>: Min = <code>-9.54</code>, Max = <code>26.45</code>.</li>
<li><code>CTR</code>: Min = <code>0.00</code>, Max = <code>3.75</code>.</li>
</ul></li>
<li>Binary/Categorical Variables: Variables like <code>headline_question</code>, <code>headline_numbers</code>, and <code>contextual_relevance</code> appear binary, with values predominantly <code>0</code> or <code>1</code>.</li>
</ul></li>
</ul>
</section>
<section id="ctr-click-through-rate" class="level3">
<h3 class="anchored" data-anchor-id="ctr-click-through-rate">CTR (Click Through Rate)</h3>
<ul>
<li>Mean = <code>0.22</code>, Median = <code>0.18</code>: Right-skewed distribution confirmed by the histogram <code>(▇▁▁▁▁).</code></li>
<li>The range (<code>0.00</code> to <code>3.75</code>) indicates most observations are clustered at lower values, with few extreme values.</li>
<li>Suggests potential outliers in CTR that need handling. This <strong>high skewness</strong> confirms that the CTR variable is not normally distributed and may require transformations or a model capable of handling skewed data, such as decision-tree-based methods like XGBoost.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb3"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb3-1"><a href="#cb3-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Load necessary libraries</span></span>
<span id="cb3-2"><a href="#cb3-2" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(ggplot2)</span>
<span id="cb3-3"><a href="#cb3-3" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(e1071)</span>
<span id="cb3-4"><a href="#cb3-4" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb3-5"><a href="#cb3-5" aria-hidden="true" tabindex="-1"></a><span class="co"># Extract the CTR variable</span></span>
<span id="cb3-6"><a href="#cb3-6" aria-hidden="true" tabindex="-1"></a>ctr_data <span class="ot">&lt;-</span> train<span class="sc">$</span>CTR</span>
<span id="cb3-7"><a href="#cb3-7" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb3-8"><a href="#cb3-8" aria-hidden="true" tabindex="-1"></a><span class="co"># Calculate skewness</span></span>
<span id="cb3-9"><a href="#cb3-9" aria-hidden="true" tabindex="-1"></a>ctr_skewness <span class="ot">&lt;-</span> <span class="fu">skewness</span>(ctr_data)</span>
<span id="cb3-10"><a href="#cb3-10" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb3-11"><a href="#cb3-11" aria-hidden="true" tabindex="-1"></a><span class="co"># Plot the distribution of CTR</span></span>
<span id="cb3-12"><a href="#cb3-12" aria-hidden="true" tabindex="-1"></a><span class="fu">ggplot</span>(<span class="fu">data.frame</span>(<span class="at">CTR =</span> ctr_data), <span class="fu">aes</span>(<span class="at">x =</span> CTR)) <span class="sc">+</span></span>
<span id="cb3-13"><a href="#cb3-13" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_histogram</span>(<span class="at">bins =</span> <span class="dv">30</span>, <span class="at">fill =</span> <span class="st">"blue"</span>, <span class="at">alpha =</span> <span class="fl">0.7</span>, <span class="at">color =</span> <span class="st">"black"</span>) <span class="sc">+</span></span>
<span id="cb3-14"><a href="#cb3-14" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_density</span>(<span class="fu">aes</span>(<span class="at">y =</span> ..count..), <span class="at">color =</span> <span class="st">"red"</span>, <span class="at">size =</span> <span class="dv">1</span>) <span class="sc">+</span></span>
<span id="cb3-15"><a href="#cb3-15" aria-hidden="true" tabindex="-1"></a>  <span class="fu">labs</span>(</span>
<span id="cb3-16"><a href="#cb3-16" aria-hidden="true" tabindex="-1"></a>    <span class="at">title =</span> <span class="fu">paste</span>(<span class="st">"Distribution of CTR (Skewness ="</span>, <span class="fu">round</span>(ctr_skewness, <span class="dv">2</span>), <span class="st">")"</span>),</span>
<span id="cb3-17"><a href="#cb3-17" aria-hidden="true" tabindex="-1"></a>    <span class="at">x =</span> <span class="st">"CTR"</span>,</span>
<span id="cb3-18"><a href="#cb3-18" aria-hidden="true" tabindex="-1"></a>    <span class="at">y =</span> <span class="st">"Frequency"</span></span>
<span id="cb3-19"><a href="#cb3-19" aria-hidden="true" tabindex="-1"></a>  ) <span class="sc">+</span></span>
<span id="cb3-20"><a href="#cb3-20" aria-hidden="true" tabindex="-1"></a>  <span class="fu">theme_minimal</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-3-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
<div class="sourceCode cell-code" id="cb4"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb4-1"><a href="#cb4-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Display summary statistics</span></span>
<span id="cb4-2"><a href="#cb4-2" aria-hidden="true" tabindex="-1"></a>ctr_summary <span class="ot">&lt;-</span> <span class="fu">summary</span>(ctr_data)</span>
<span id="cb4-3"><a href="#cb4-3" aria-hidden="true" tabindex="-1"></a>ctr_skewness</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output cell-output-stdout">
<pre><code>[1] 5.395977</code></pre>
</div>
<div class="sourceCode cell-code" id="cb6"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb6-1"><a href="#cb6-1" aria-hidden="true" tabindex="-1"></a>ctr_summary</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output cell-output-stdout">
<pre><code>   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
 0.0000  0.1082  0.1811  0.2154  0.2672  3.7450 </code></pre>
</div>
</div>
</section>
<section id="targeting-score" class="level3">
<h3 class="anchored" data-anchor-id="targeting-score">Targeting Score</h3>
<ul>
<li>Mean = <code>4.02</code>, Median = <code>3.00</code>: The variable is <strong>moderately skewed right</strong>, as most values are clustered toward the lower end.</li>
<li>Maximum = <code>23</code>, which might be an outlier considering the interquartile range (IQR = <code>3.00</code> to <code>5.00</code>).</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb8"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb8-1"><a href="#cb8-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Histogram for Targeting Score</span></span>
<span id="cb8-2"><a href="#cb8-2" aria-hidden="true" tabindex="-1"></a><span class="fu">ggplot</span>(<span class="fu">data.frame</span>(<span class="at">TargetingScore =</span> train<span class="sc">$</span>targeting_score), <span class="fu">aes</span>(<span class="at">x =</span> TargetingScore)) <span class="sc">+</span></span>
<span id="cb8-3"><a href="#cb8-3" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_histogram</span>(<span class="at">binwidth =</span> <span class="dv">1</span>, <span class="at">fill =</span> <span class="st">"purple"</span>, <span class="at">alpha =</span> <span class="fl">0.7</span>, <span class="at">color =</span> <span class="st">"black"</span>) <span class="sc">+</span></span>
<span id="cb8-4"><a href="#cb8-4" aria-hidden="true" tabindex="-1"></a>  <span class="fu">labs</span>(<span class="at">title =</span> <span class="st">"Distribution of Targeting Score"</span>, <span class="at">x =</span> <span class="st">"Targeting Score"</span>, <span class="at">y =</span> <span class="st">"Frequency"</span>) <span class="sc">+</span></span>
<span id="cb8-5"><a href="#cb8-5" aria-hidden="true" tabindex="-1"></a>  <span class="fu">theme_minimal</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-4-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
</div>
</section>
<section id="visual-appeal" class="level3">
<h3 class="anchored" data-anchor-id="visual-appeal">Visual Appeal</h3>
<ul>
<li><strong>Large range</strong>: Min = <code>-9.54</code>, Max = <code>26.45</code>. Negative values suggest data issues or a specific encoding for certain conditions.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb9"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb9-1"><a href="#cb9-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Histogram for Visual Appeal</span></span>
<span id="cb9-2"><a href="#cb9-2" aria-hidden="true" tabindex="-1"></a><span class="fu">ggplot</span>(<span class="fu">data.frame</span>(<span class="at">VisualAppeal =</span> train<span class="sc">$</span>visual_appeal), <span class="fu">aes</span>(<span class="at">x =</span> VisualAppeal)) <span class="sc">+</span></span>
<span id="cb9-3"><a href="#cb9-3" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_histogram</span>(<span class="at">binwidth =</span> <span class="dv">1</span>, <span class="at">fill =</span> <span class="st">"red"</span>, <span class="at">alpha =</span> <span class="fl">0.7</span>, <span class="at">color =</span> <span class="st">"black"</span>) <span class="sc">+</span></span>
<span id="cb9-4"><a href="#cb9-4" aria-hidden="true" tabindex="-1"></a>  <span class="fu">labs</span>(<span class="at">title =</span> <span class="st">"Distribution of Visual Appeal"</span>, <span class="at">x =</span> <span class="st">"Visual Appeal"</span>, <span class="at">y =</span> <span class="st">"Frequency"</span>) <span class="sc">+</span></span>
<span id="cb9-5"><a href="#cb9-5" aria-hidden="true" tabindex="-1"></a>  <span class="fu">theme_minimal</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-5-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
</div>
</section>
<section id="contextual-relevance" class="level3">
<h3 class="anchored" data-anchor-id="contextual-relevance">Contextual Relevance</h3>
<ul>
<li>Binary variable: Almost entirely <code>0s</code> and <code>1s</code>. The histogram shows two spikes at these values <code>(▇▁▁▁▇).</code></li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb10"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb10-1"><a href="#cb10-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Barplot for Contextual Relevance (binary variable)</span></span>
<span id="cb10-2"><a href="#cb10-2" aria-hidden="true" tabindex="-1"></a><span class="fu">ggplot</span>(<span class="fu">data.frame</span>(<span class="at">ContextualRelevance =</span> <span class="fu">factor</span>(train<span class="sc">$</span>contextual_relevance)), <span class="fu">aes</span>(<span class="at">x =</span> ContextualRelevance)) <span class="sc">+</span></span>
<span id="cb10-3"><a href="#cb10-3" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_bar</span>(<span class="at">fill =</span> <span class="st">"darkblue"</span>, <span class="at">alpha =</span> <span class="fl">0.7</span>) <span class="sc">+</span></span>
<span id="cb10-4"><a href="#cb10-4" aria-hidden="true" tabindex="-1"></a>  <span class="fu">labs</span>(<span class="at">title =</span> <span class="st">"Barplot of Contextual Relevance"</span>, <span class="at">x =</span> <span class="st">"Contextual Relevance (0 or 1)"</span>, <span class="at">y =</span> <span class="st">"Count"</span>) <span class="sc">+</span></span>
<span id="cb10-5"><a href="#cb10-5" aria-hidden="true" tabindex="-1"></a>  <span class="fu">theme_minimal</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-6-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
</div>
</section>
<section id="headline-sentiment" class="level3">
<h3 class="anchored" data-anchor-id="headline-sentiment">Headline Sentiment</h3>
<ul>
<li>Mean = <code>-0.03</code>, Median = <code>-0.07</code>: Near-zero mean suggests a <strong>balanced sentiment</strong> overall.</li>
<li>Distribution is fairly normal <code>(▁▃▇▃▁)</code>, but the range (<code>-7.04 to</code>7.11`) shows some <strong>extreme sentiment values</strong>.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb11"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb11-1"><a href="#cb11-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Histogram for Headline Sentiment</span></span>
<span id="cb11-2"><a href="#cb11-2" aria-hidden="true" tabindex="-1"></a><span class="fu">ggplot</span>(<span class="fu">data.frame</span>(<span class="at">HeadlineSentiment =</span> train<span class="sc">$</span>headline_sentiment), <span class="fu">aes</span>(<span class="at">x =</span> HeadlineSentiment)) <span class="sc">+</span></span>
<span id="cb11-3"><a href="#cb11-3" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_histogram</span>(<span class="at">binwidth =</span> <span class="fl">0.5</span>, <span class="at">fill =</span> <span class="st">"magenta"</span>, <span class="at">alpha =</span> <span class="fl">0.7</span>, <span class="at">color =</span> <span class="st">"black"</span>) <span class="sc">+</span></span>
<span id="cb11-4"><a href="#cb11-4" aria-hidden="true" tabindex="-1"></a>  <span class="fu">labs</span>(<span class="at">title =</span> <span class="st">"Distribution of Headline Sentiment"</span>, <span class="at">x =</span> <span class="st">"Headline Sentiment"</span>, <span class="at">y =</span> <span class="st">"Frequency"</span>) <span class="sc">+</span></span>
<span id="cb11-5"><a href="#cb11-5" aria-hidden="true" tabindex="-1"></a>  <span class="fu">theme_minimal</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-7-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
</div>
</section>
<section id="body-keyword-density" class="level3">
<h3 class="anchored" data-anchor-id="body-keyword-density">Body Keyword Density</h3>
<ul>
<li>Mean = <code>0.06</code>, Median = <code>0.05</code>: Relatively low density, with a narrow range (<code>0.01</code> to <code>0.10</code>).</li>
<li>Appears <strong>evenly distributed</strong> (<code>▇▇▇▇▇</code>).</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb12"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb12-1"><a href="#cb12-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Histogram for Body Keyword Density</span></span>
<span id="cb12-2"><a href="#cb12-2" aria-hidden="true" tabindex="-1"></a><span class="fu">ggplot</span>(<span class="fu">data.frame</span>(<span class="at">BodyKeywordDensity =</span> train<span class="sc">$</span>body_keyword_density), <span class="fu">aes</span>(<span class="at">x =</span> BodyKeywordDensity)) <span class="sc">+</span></span>
<span id="cb12-3"><a href="#cb12-3" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_histogram</span>(<span class="at">binwidth =</span> <span class="fl">0.01</span>, <span class="at">fill =</span> <span class="st">"orange"</span>, <span class="at">alpha =</span> <span class="fl">0.7</span>, <span class="at">color =</span> <span class="st">"black"</span>) <span class="sc">+</span></span>
<span id="cb12-4"><a href="#cb12-4" aria-hidden="true" tabindex="-1"></a>  <span class="fu">labs</span>(<span class="at">title =</span> <span class="st">"Distribution of Body Keyword Density"</span>, <span class="at">x =</span> <span class="st">"Body Keyword Density"</span>, <span class="at">y =</span> <span class="st">"Frequency"</span>) <span class="sc">+</span></span>
<span id="cb12-5"><a href="#cb12-5" aria-hidden="true" tabindex="-1"></a>  <span class="fu">theme_minimal</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-8-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
</div>
</section>
<section id="body-readability-score" class="level3">
<h3 class="anchored" data-anchor-id="body-readability-score">Body Readability Score</h3>
<ul>
<li>Mean = <code>74.87</code>, Median = <code>74.76</code>: Centered around the same value, suggesting a narrow range of readability scores.</li>
<li>Minimum = <code>50.04</code>, Maximum = <code>100</code>: High values indicate content is generally readable.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb13"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb13-1"><a href="#cb13-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Histogram for Body Readability Score</span></span>
<span id="cb13-2"><a href="#cb13-2" aria-hidden="true" tabindex="-1"></a><span class="fu">ggplot</span>(<span class="fu">data.frame</span>(<span class="at">BodyReadability =</span> train<span class="sc">$</span>body_readability_score), <span class="fu">aes</span>(<span class="at">x =</span> BodyReadability)) <span class="sc">+</span></span>
<span id="cb13-3"><a href="#cb13-3" aria-hidden="true" tabindex="-1"></a>  <span class="fu">geom_histogram</span>(<span class="at">binwidth =</span> <span class="dv">5</span>, <span class="at">fill =</span> <span class="st">"green"</span>, <span class="at">alpha =</span> <span class="fl">0.7</span>, <span class="at">color =</span> <span class="st">"black"</span>) <span class="sc">+</span></span>
<span id="cb13-4"><a href="#cb13-4" aria-hidden="true" tabindex="-1"></a>  <span class="fu">labs</span>(<span class="at">title =</span> <span class="st">"Distribution of Body Readability Score"</span>, <span class="at">x =</span> <span class="st">"Body Readability Score"</span>, <span class="at">y =</span> <span class="st">"Frequency"</span>) <span class="sc">+</span></span>
<span id="cb13-5"><a href="#cb13-5" aria-hidden="true" tabindex="-1"></a>  <span class="fu">theme_minimal</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-9-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
</div>
</section>
</section>
<section id="data-cleaining" class="level1">
<h1>Data Cleaining</h1>
<p>The data cleaning process began with examining the structure and content of the training and testing datasets. To <strong>address skewness</strong> in the target variable CTR, a <strong>Box-Cox transformation</strong> was applied after adding a small constant to ensure all values were positive, and the optimal lambda was determined to improve normality. Missing values were handled separately for numeric and categorical variables: numeric columns were imputed using the <strong>bagging method</strong> from the caret package, while categorical columns were imputed with the most frequent value (<code>mode</code>). After imputation, numeric and categorical columns were recombined into complete datasets with no missing values. Non-contributory columns, identified through 88feature importance analysis88 (<code>seasonality</code>, <code>market_saturation</code>, <code>headline_question</code>), were removed to reduce noise. These steps ensured the data was clean, consistent, and ready for modeling.</p>
<section id="handling-skewness-of-ctr" class="level3">
<h3 class="anchored" data-anchor-id="handling-skewness-of-ctr">Handling Skewness of CTR</h3>
<ul>
<li>The target variable <code>CTR</code> (Click-Through Rate) is adjusted for skewness to improve model performance.</li>
<li><strong>Box-Cox Transformation</strong>: Applied to <code>CTR</code> since it requires positive values. A small constant (+1) is added to all values. The optimal Box-Cox lambda is determined using the boxcox function from the MASS package.</li>
<li>Transformation ensures the target variable is more normally distributed, which benefits models sensitive to non-normality.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb14"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb14-1"><a href="#cb14-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Load necessary libraries</span></span>
<span id="cb14-2"><a href="#cb14-2" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(MASS)</span>
<span id="cb14-3"><a href="#cb14-3" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb14-4"><a href="#cb14-4" aria-hidden="true" tabindex="-1"></a><span class="co"># Box-Cox requires positive values, so we add a small constant (1)</span></span>
<span id="cb14-5"><a href="#cb14-5" aria-hidden="true" tabindex="-1"></a>train<span class="sc">$</span>CTR <span class="ot">&lt;-</span> train<span class="sc">$</span>CTR <span class="sc">+</span> <span class="dv">1</span></span>
<span id="cb14-6"><a href="#cb14-6" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb14-7"><a href="#cb14-7" aria-hidden="true" tabindex="-1"></a><span class="co"># Find the optimal lambda for the Box-Cox transformation</span></span>
<span id="cb14-8"><a href="#cb14-8" aria-hidden="true" tabindex="-1"></a>lambda <span class="ot">&lt;-</span> <span class="fu">boxcox</span>(<span class="fu">lm</span>(CTR <span class="sc">~</span> <span class="dv">1</span>, <span class="at">data =</span> train), <span class="at">lambda =</span> <span class="fu">seq</span>(<span class="sc">-</span><span class="dv">2</span>, <span class="dv">2</span>, <span class="fl">0.1</span>))<span class="sc">$</span>x[<span class="fu">which.max</span>(<span class="fu">boxcox</span>(<span class="fu">lm</span>(CTR <span class="sc">~</span> <span class="dv">1</span>, <span class="at">data =</span> train), <span class="at">lambda =</span> <span class="fu">seq</span>(<span class="sc">-</span><span class="dv">2</span>, <span class="dv">2</span>, <span class="fl">0.1</span>))<span class="sc">$</span>y)]</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output-display">
<div>
<figure class="figure">
<p><img src="PAC-Competition_files/figure-html/unnamed-chunk-10-1.png" class="img-fluid figure-img" width="672"></p>
</figure>
</div>
</div>
<div class="sourceCode cell-code" id="cb15"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb15-1"><a href="#cb15-1" aria-hidden="true" tabindex="-1"></a><span class="fu">print</span>(<span class="fu">paste</span>(<span class="st">"Optimal lambda:"</span>, lambda))</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output cell-output-stdout">
<pre><code>[1] "Optimal lambda: -2"</code></pre>
</div>
<div class="sourceCode cell-code" id="cb17"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb17-1"><a href="#cb17-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Apply Box-Cox transformation using the optimal lambda</span></span>
<span id="cb17-2"><a href="#cb17-2" aria-hidden="true" tabindex="-1"></a><span class="cf">if</span> (lambda <span class="sc">==</span> <span class="dv">0</span>) {</span>
<span id="cb17-3"><a href="#cb17-3" aria-hidden="true" tabindex="-1"></a>  train<span class="sc">$</span>CTR <span class="ot">&lt;-</span> <span class="fu">log</span>(train<span class="sc">$</span>CTR)</span>
<span id="cb17-4"><a href="#cb17-4" aria-hidden="true" tabindex="-1"></a>} <span class="cf">else</span> {</span>
<span id="cb17-5"><a href="#cb17-5" aria-hidden="true" tabindex="-1"></a>  train<span class="sc">$</span>CTR <span class="ot">&lt;-</span> (train<span class="sc">$</span>CTR <span class="sc">^</span> lambda <span class="sc">-</span> <span class="dv">1</span>) <span class="sc">/</span> lambda</span>
<span id="cb17-6"><a href="#cb17-6" aria-hidden="true" tabindex="-1"></a>}</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
</section>
<section id="separating-columns-by-data-type" class="level3">
<h3 class="anchored" data-anchor-id="separating-columns-by-data-type">Separating Columns by Data Type</h3>
<ul>
<li>Columns are categorized into <strong>numeric</strong> and <strong>categorical</strong> variables for targeted processing.</li>
<li>Numeric Columns: Includes continuous and integer variables.</li>
<li>Categorical Columns: Includes string or factor variables.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb18"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb18-1"><a href="#cb18-1" aria-hidden="true" tabindex="-1"></a>train_numeric_cols <span class="ot">&lt;-</span> train <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(<span class="sc">~</span> <span class="fu">is.numeric</span>(.) <span class="sc">||</span> <span class="fu">is.integer</span>(.)) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb18-2"><a href="#cb18-2" aria-hidden="true" tabindex="-1"></a>train_categorical_cols <span class="ot">&lt;-</span> train <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(is.character) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb18-3"><a href="#cb18-3" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb18-4"><a href="#cb18-4" aria-hidden="true" tabindex="-1"></a>test_numeric_cols <span class="ot">&lt;-</span> test <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(<span class="sc">~</span> <span class="fu">is.numeric</span>(.) <span class="sc">||</span> <span class="fu">is.integer</span>(.)) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb18-5"><a href="#cb18-5" aria-hidden="true" tabindex="-1"></a>test_categorical_cols <span class="ot">&lt;-</span> test <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(is.character) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
</section>
<section id="imputing-missing-values" class="level3">
<h3 class="anchored" data-anchor-id="imputing-missing-values">Imputing Missing Values</h3>
<ul>
<li>To handle missing data, different strategies are used for numeric and categorical variables</li>
<li>Numeric Columns:
<ul>
<li><strong>Bagging Imputation</strong>:
<ul>
<li>Missing numeric values are imputed using the caret package’s bagImpute method.</li>
<li>This method uses bootstrap aggregating (bagging) to make predictions based on other numeric columns, ensuring robust imputation.</li>
</ul></li>
</ul></li>
<li>Categorical Columns:
<ul>
<li><p><strong>Mode Imputation</strong>:</p>
<ul>
<li>The most frequent value (<code>mode</code>) is used to fill missing values in each categorical column.</li>
<li>A custom <code>impute_mode</code> function ensures consistent handling of missing values.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb19"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb19-1"><a href="#cb19-1" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Separate Columns by Data Type ---</span></span>
<span id="cb19-2"><a href="#cb19-2" aria-hidden="true" tabindex="-1"></a>train_numeric_cols <span class="ot">&lt;-</span> train <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(<span class="sc">~</span> <span class="fu">is.numeric</span>(.) <span class="sc">||</span> <span class="fu">is.integer</span>(.)) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb19-3"><a href="#cb19-3" aria-hidden="true" tabindex="-1"></a>train_categorical_cols <span class="ot">&lt;-</span> train <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(is.character) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb19-4"><a href="#cb19-4" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb19-5"><a href="#cb19-5" aria-hidden="true" tabindex="-1"></a>test_numeric_cols <span class="ot">&lt;-</span> test <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(<span class="sc">~</span> <span class="fu">is.numeric</span>(.) <span class="sc">||</span> <span class="fu">is.integer</span>(.)) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb19-6"><a href="#cb19-6" aria-hidden="true" tabindex="-1"></a>test_categorical_cols <span class="ot">&lt;-</span> test <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(is.character) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb19-7"><a href="#cb19-7" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb19-8"><a href="#cb19-8" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Impute Numeric Columns ---</span></span>
<span id="cb19-9"><a href="#cb19-9" aria-hidden="true" tabindex="-1"></a><span class="fu">set.seed</span>(<span class="dv">1031</span>)</span>
<span id="cb19-10"><a href="#cb19-10" aria-hidden="true" tabindex="-1"></a><span class="co"># Fit the numeric imputer on the training data</span></span>
<span id="cb19-11"><a href="#cb19-11" aria-hidden="true" tabindex="-1"></a>train_numeric_imputer <span class="ot">&lt;-</span> <span class="fu">preProcess</span>(train[, train_numeric_cols], <span class="at">method =</span> <span class="st">'bagImpute'</span>)</span>
<span id="cb19-12"><a href="#cb19-12" aria-hidden="true" tabindex="-1"></a>test_numeric_imputer <span class="ot">&lt;-</span> <span class="fu">preProcess</span>(test[, test_numeric_cols], <span class="at">method =</span> <span class="st">'bagImpute'</span>)</span>
<span id="cb19-13"><a href="#cb19-13" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb19-14"><a href="#cb19-14" aria-hidden="true" tabindex="-1"></a><span class="co"># Impute numeric columns in both train and test datasets</span></span>
<span id="cb19-15"><a href="#cb19-15" aria-hidden="true" tabindex="-1"></a>train_numeric_imputed <span class="ot">&lt;-</span> <span class="fu">predict</span>(train_numeric_imputer, <span class="at">newdata =</span> train[, train_numeric_cols])</span>
<span id="cb19-16"><a href="#cb19-16" aria-hidden="true" tabindex="-1"></a>test_numeric_imputed <span class="ot">&lt;-</span> <span class="fu">predict</span>(test_numeric_imputer, <span class="at">newdata =</span> test[, test_numeric_cols])</span>
<span id="cb19-17"><a href="#cb19-17" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb19-18"><a href="#cb19-18" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Impute Categorical Columns ---</span></span>
<span id="cb19-19"><a href="#cb19-19" aria-hidden="true" tabindex="-1"></a>impute_mode <span class="ot">&lt;-</span> <span class="cf">function</span>(x) {</span>
<span id="cb19-20"><a href="#cb19-20" aria-hidden="true" tabindex="-1"></a>  <span class="co"># Get the mode (most common value) for each column</span></span>
<span id="cb19-21"><a href="#cb19-21" aria-hidden="true" tabindex="-1"></a>  mode_value <span class="ot">&lt;-</span> <span class="fu">names</span>(<span class="fu">sort</span>(<span class="fu">table</span>(x), <span class="at">decreasing =</span> <span class="cn">TRUE</span>))[<span class="dv">1</span>]</span>
<span id="cb19-22"><a href="#cb19-22" aria-hidden="true" tabindex="-1"></a>  x[<span class="fu">is.na</span>(x)] <span class="ot">&lt;-</span> mode_value</span>
<span id="cb19-23"><a href="#cb19-23" aria-hidden="true" tabindex="-1"></a>  <span class="fu">return</span>(x)</span>
<span id="cb19-24"><a href="#cb19-24" aria-hidden="true" tabindex="-1"></a>}</span>
<span id="cb19-25"><a href="#cb19-25" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb19-26"><a href="#cb19-26" aria-hidden="true" tabindex="-1"></a><span class="co"># Apply mode imputation for categorical columns in both datasets</span></span>
<span id="cb19-27"><a href="#cb19-27" aria-hidden="true" tabindex="-1"></a>train_categorical_imputed <span class="ot">&lt;-</span> train[, train_categorical_cols] <span class="sc">%&gt;%</span> <span class="fu">mutate_all</span>(impute_mode)</span>
<span id="cb19-28"><a href="#cb19-28" aria-hidden="true" tabindex="-1"></a>test_categorical_imputed <span class="ot">&lt;-</span> test[, test_categorical_cols] <span class="sc">%&gt;%</span> <span class="fu">mutate_all</span>(impute_mode)</span>
<span id="cb19-29"><a href="#cb19-29" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb19-30"><a href="#cb19-30" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Combine Imputed Numeric and Categorical Data ---</span></span>
<span id="cb19-31"><a href="#cb19-31" aria-hidden="true" tabindex="-1"></a>train_final <span class="ot">&lt;-</span> <span class="fu">cbind</span>(train_numeric_imputed, train_categorical_imputed)</span>
<span id="cb19-32"><a href="#cb19-32" aria-hidden="true" tabindex="-1"></a>test_final <span class="ot">&lt;-</span> <span class="fu">cbind</span>(test_numeric_imputed, test_categorical_imputed)</span>
<span id="cb19-33"><a href="#cb19-33" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb19-34"><a href="#cb19-34" aria-hidden="true" tabindex="-1"></a><span class="co"># Make sure all missing values are filled</span></span>
<span id="cb19-35"><a href="#cb19-35" aria-hidden="true" tabindex="-1"></a><span class="fu">colSums</span>(<span class="fu">is.na</span>(train_final))</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
<div class="cell-output cell-output-stdout">
<pre><code>                    id        targeting_score          visual_appeal 
                     0                      0                      0 
  contextual_relevance        headline_length           cta_strength 
                     0                      0                      0 
     brand_familiarity           ad_frequency      market_saturation 
                     0                      0                      0 
           seasonality     headline_sentiment    headline_word_count 
                     0                      0                      0 
  headline_power_words       body_text_length        body_word_count 
                     0                      0                      0 
        body_sentiment      headline_question       headline_numbers 
                     0                      0                      0 
  body_keyword_density body_readability_score                    CTR 
                     0                      0                      0 
      position_on_page              ad_format              age_group 
                     0                      0                      0 
                gender               location            time_of_day 
                     0                      0                      0 
           day_of_week            device_type 
                     0                      0 </code></pre>
</div>
</div>
<p>All missing values from <code>train</code> and <code>test</code> are now filled. The dataset is ready for training.</p></li>
</ul></li>
</ul>
</section>
<section id="feature-selection" class="level3">
<h3 class="anchored" data-anchor-id="feature-selection">Feature Selection</h3>
<p>The features (<code>headline_power_words</code>, <code>headline_numbers</code>, <code>headline_question</code>, <code>age_group</code>, <code>location</code>, <code>market_saturation</code>, <code>gender</code>, <code>brand_familiarity</code>, <code>position_on_page</code>) were removed based on a combination of feature importance analysis from xgboosting and domain knowledge. The <strong>xgboosting</strong> method used will be displayed after this section. These columns were found to have low predictive value or redundant information, contributing minimally to the model’s performance. Including such features can introduce noise, lead to overfitting, and unnecessarily increase model complexity. Removing them improves the model’s interpretability, reduces computational cost, and enhances generalizability to new data.</p>
<div class="cell">
<div class="sourceCode cell-code" id="cb21"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb21-1"><a href="#cb21-1" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Feature Importance ---</span></span>
<span id="cb21-2"><a href="#cb21-2" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb21-3"><a href="#cb21-3" aria-hidden="true" tabindex="-1"></a><span class="co"># List of columns to remove based on previous analysis</span></span>
<span id="cb21-4"><a href="#cb21-4" aria-hidden="true" tabindex="-1"></a>columns_to_remove <span class="ot">&lt;-</span> <span class="fu">c</span>(<span class="st">"headline_power_words"</span>, <span class="st">"headline_numbers"</span>, <span class="st">"headline_question"</span>, <span class="st">"age_group"</span>, <span class="st">"location"</span>, <span class="st">"market_saturation"</span>, <span class="st">"gender"</span>, <span class="st">"brand_familiarity"</span>, <span class="st">"position_on_page"</span>)</span>
<span id="cb21-5"><a href="#cb21-5" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb21-6"><a href="#cb21-6" aria-hidden="true" tabindex="-1"></a><span class="co"># Remove specified columns from the dataset</span></span>
<span id="cb21-7"><a href="#cb21-7" aria-hidden="true" tabindex="-1"></a>train_final <span class="ot">&lt;-</span> dplyr<span class="sc">::</span><span class="fu">select</span>(train_final, <span class="sc">-</span><span class="fu">all_of</span>(<span class="fu">intersect</span>(columns_to_remove, <span class="fu">colnames</span>(train_final))))</span>
<span id="cb21-8"><a href="#cb21-8" aria-hidden="true" tabindex="-1"></a>test_final <span class="ot">&lt;-</span> dplyr<span class="sc">::</span><span class="fu">select</span>(test_final, <span class="sc">-</span><span class="fu">all_of</span>(<span class="fu">intersect</span>(columns_to_remove, <span class="fu">colnames</span>(test_final))))</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
</section>
</section>
<section id="xgboost" class="level1">
<h1>XGBoost</h1>
<ul>
<li>Separated Predictors and Target: Extracted the predictor features (<code>train_x</code>) and the target variable (<code>train_y</code>) from the training dataset. Assigned the test dataset predictors to <code>test_x</code>.</li>
<li>Converted Data to <strong>Matrix Format</strong>: Prepared the data in matrix format as required by XGBoost.</li>
</ul>
<div class="cell">
<div class="sourceCode cell-code" id="cb22"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb22-1"><a href="#cb22-1" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Label Encode Categorical Columns ---</span></span>
<span id="cb22-2"><a href="#cb22-2" aria-hidden="true" tabindex="-1"></a><span class="co"># Identify Numeric and Categorical Columns</span></span>
<span id="cb22-3"><a href="#cb22-3" aria-hidden="true" tabindex="-1"></a>train_numeric_cols <span class="ot">&lt;-</span> train_final <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(is.numeric) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb22-4"><a href="#cb22-4" aria-hidden="true" tabindex="-1"></a>train_categorical_cols <span class="ot">&lt;-</span> train_final <span class="sc">%&gt;%</span> <span class="fu">select_if</span>(is.character) <span class="sc">%&gt;%</span> <span class="fu">colnames</span>()</span>
<span id="cb22-5"><a href="#cb22-5" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb22-6"><a href="#cb22-6" aria-hidden="true" tabindex="-1"></a><span class="co"># Function to label encode categorical columns</span></span>
<span id="cb22-7"><a href="#cb22-7" aria-hidden="true" tabindex="-1"></a>label_encode <span class="ot">&lt;-</span> <span class="cf">function</span>(df, cols) {</span>
<span id="cb22-8"><a href="#cb22-8" aria-hidden="true" tabindex="-1"></a>  <span class="cf">for</span> (col <span class="cf">in</span> cols) {</span>
<span id="cb22-9"><a href="#cb22-9" aria-hidden="true" tabindex="-1"></a>    df[[col]] <span class="ot">&lt;-</span> <span class="fu">as.integer</span>(<span class="fu">as.factor</span>(df[[col]]))</span>
<span id="cb22-10"><a href="#cb22-10" aria-hidden="true" tabindex="-1"></a>  }</span>
<span id="cb22-11"><a href="#cb22-11" aria-hidden="true" tabindex="-1"></a>  <span class="fu">return</span>(df)</span>
<span id="cb22-12"><a href="#cb22-12" aria-hidden="true" tabindex="-1"></a>}</span>
<span id="cb22-13"><a href="#cb22-13" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb22-14"><a href="#cb22-14" aria-hidden="true" tabindex="-1"></a><span class="co"># Apply label encoding to train and test datasets</span></span>
<span id="cb22-15"><a href="#cb22-15" aria-hidden="true" tabindex="-1"></a>train_final <span class="ot">&lt;-</span> <span class="fu">label_encode</span>(train_final, train_categorical_cols)</span>
<span id="cb22-16"><a href="#cb22-16" aria-hidden="true" tabindex="-1"></a>test_final <span class="ot">&lt;-</span> <span class="fu">label_encode</span>(test_final, test_categorical_cols)</span>
<span id="cb22-17"><a href="#cb22-17" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb22-18"><a href="#cb22-18" aria-hidden="true" tabindex="-1"></a><span class="co"># --- MODEL TRAINING ---</span></span>
<span id="cb22-19"><a href="#cb22-19" aria-hidden="true" tabindex="-1"></a><span class="co"># Separate predictors and target variable</span></span>
<span id="cb22-20"><a href="#cb22-20" aria-hidden="true" tabindex="-1"></a>train_x <span class="ot">&lt;-</span> train_final <span class="sc">%&gt;%</span> dplyr<span class="sc">::</span><span class="fu">select</span>(<span class="sc">-</span>CTR)</span>
<span id="cb22-21"><a href="#cb22-21" aria-hidden="true" tabindex="-1"></a>train_y <span class="ot">&lt;-</span> train_final<span class="sc">$</span>CTR</span>
<span id="cb22-22"><a href="#cb22-22" aria-hidden="true" tabindex="-1"></a>test_x <span class="ot">&lt;-</span> test_final</span>
<span id="cb22-23"><a href="#cb22-23" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb22-24"><a href="#cb22-24" aria-hidden="true" tabindex="-1"></a><span class="co"># Convert data to matrix format for XGBoost</span></span>
<span id="cb22-25"><a href="#cb22-25" aria-hidden="true" tabindex="-1"></a>train_matrix <span class="ot">&lt;-</span> <span class="fu">as.matrix</span>(train_x)</span>
<span id="cb22-26"><a href="#cb22-26" aria-hidden="true" tabindex="-1"></a>test_matrix <span class="ot">&lt;-</span> <span class="fu">as.matrix</span>(test_x)</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
<section id="cross-validation" class="level3">
<h3 class="anchored" data-anchor-id="cross-validation">Cross Validation</h3>
<p>Configured a <em>5-fold cross-validation</em> process with verbose output to monitor progress during training. This is to evaluate model performance across multiple folds of the training data, ensuring that the model generalizes well and avoids overfitting.</p>
<div class="cell">
<div class="sourceCode cell-code" id="cb23"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb23-1"><a href="#cb23-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Set up cross-validation controls</span></span>
<span id="cb23-2"><a href="#cb23-2" aria-hidden="true" tabindex="-1"></a>train_control <span class="ot">&lt;-</span> <span class="fu">trainControl</span>(<span class="at">method =</span> <span class="st">"cv"</span>, <span class="at">number =</span> <span class="dv">5</span>, <span class="at">verboseIter =</span> <span class="cn">TRUE</span>)</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
</section>
<section id="hyperparameter-tuning" class="level3">
<h3 class="anchored" data-anchor-id="hyperparameter-tuning">Hyperparameter Tuning</h3>
<p>Created a tuning grid to explore a range of hyperparameter values for the XGBoost model to systematically explore combinations of hyperparameters to optimize model performance.</p>
<div class="cell">
<div class="sourceCode cell-code" id="cb24"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb24-1"><a href="#cb24-1" aria-hidden="true" tabindex="-1"></a><span class="co"># Define an extended tuning grid for XGBoost to explore more hyperparameters</span></span>
<span id="cb24-2"><a href="#cb24-2" aria-hidden="true" tabindex="-1"></a>tune_grid <span class="ot">&lt;-</span> <span class="fu">expand.grid</span>(</span>
<span id="cb24-3"><a href="#cb24-3" aria-hidden="true" tabindex="-1"></a>  <span class="at">nrounds =</span> <span class="fu">c</span>(<span class="dv">100</span>, <span class="dv">200</span>, <span class="dv">300</span>),</span>
<span id="cb24-4"><a href="#cb24-4" aria-hidden="true" tabindex="-1"></a>  <span class="at">max_depth =</span> <span class="fu">c</span>(<span class="dv">3</span>, <span class="dv">4</span>, <span class="dv">5</span>, <span class="dv">6</span>),</span>
<span id="cb24-5"><a href="#cb24-5" aria-hidden="true" tabindex="-1"></a>  <span class="at">eta =</span> <span class="fu">c</span>(<span class="fl">0.01</span>, <span class="fl">0.05</span>, <span class="fl">0.1</span>, <span class="fl">0.2</span>),</span>
<span id="cb24-6"><a href="#cb24-6" aria-hidden="true" tabindex="-1"></a>  <span class="at">gamma =</span> <span class="fu">c</span>(<span class="dv">0</span>, <span class="fl">0.01</span>, <span class="fl">0.1</span>),</span>
<span id="cb24-7"><a href="#cb24-7" aria-hidden="true" tabindex="-1"></a>  <span class="at">colsample_bytree =</span> <span class="fu">c</span>(<span class="fl">0.5</span>, <span class="fl">0.7</span>, <span class="fl">0.9</span>),</span>
<span id="cb24-8"><a href="#cb24-8" aria-hidden="true" tabindex="-1"></a>  <span class="at">subsample =</span> <span class="fu">c</span>(<span class="fl">0.6</span>, <span class="fl">0.8</span>, <span class="fl">1.0</span>),</span>
<span id="cb24-9"><a href="#cb24-9" aria-hidden="true" tabindex="-1"></a>  <span class="at">min_child_weight =</span> <span class="fu">c</span>(<span class="dv">1</span>, <span class="dv">3</span>, <span class="dv">5</span>)</span>
<span id="cb24-10"><a href="#cb24-10" aria-hidden="true" tabindex="-1"></a>)</span>
<span id="cb24-11"><a href="#cb24-11" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb24-12"><a href="#cb24-12" aria-hidden="true" tabindex="-1"></a><span class="co"># Tune the XGBoost model to find the best parameters</span></span>
<span id="cb24-13"><a href="#cb24-13" aria-hidden="true" tabindex="-1"></a><span class="fu">set.seed</span>(<span class="dv">123</span>)</span>
<span id="cb24-14"><a href="#cb24-14" aria-hidden="true" tabindex="-1"></a>xgb_tuned <span class="ot">&lt;-</span> <span class="fu">train</span>(</span>
<span id="cb24-15"><a href="#cb24-15" aria-hidden="true" tabindex="-1"></a>  <span class="at">x =</span> train_matrix,</span>
<span id="cb24-16"><a href="#cb24-16" aria-hidden="true" tabindex="-1"></a>  <span class="at">y =</span> train_y,</span>
<span id="cb24-17"><a href="#cb24-17" aria-hidden="true" tabindex="-1"></a>  <span class="at">method =</span> <span class="st">"xgbTree"</span>,</span>
<span id="cb24-18"><a href="#cb24-18" aria-hidden="true" tabindex="-1"></a>  <span class="at">trControl =</span> train_control,</span>
<span id="cb24-19"><a href="#cb24-19" aria-hidden="true" tabindex="-1"></a>  <span class="at">tuneGrid =</span> tune_grid,</span>
<span id="cb24-20"><a href="#cb24-20" aria-hidden="true" tabindex="-1"></a>  <span class="at">metric =</span> <span class="st">"RMSE"</span></span>
<span id="cb24-21"><a href="#cb24-21" aria-hidden="true" tabindex="-1"></a>)</span>
<span id="cb24-22"><a href="#cb24-22" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb24-23"><a href="#cb24-23" aria-hidden="true" tabindex="-1"></a><span class="co"># Print the best tuning parameters</span></span>
<span id="cb24-24"><a href="#cb24-24" aria-hidden="true" tabindex="-1"></a><span class="fu">print</span>(xgb_tuned<span class="sc">$</span>bestTune)</span>
<span id="cb24-25"><a href="#cb24-25" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb24-26"><a href="#cb24-26" aria-hidden="true" tabindex="-1"></a><span class="co"># Define final model parameters based on best tuning results</span></span>
<span id="cb24-27"><a href="#cb24-27" aria-hidden="true" tabindex="-1"></a>params <span class="ot">&lt;-</span> <span class="fu">list</span>(</span>
<span id="cb24-28"><a href="#cb24-28" aria-hidden="true" tabindex="-1"></a>  <span class="at">objective =</span> <span class="st">"reg:squarederror"</span>,</span>
<span id="cb24-29"><a href="#cb24-29" aria-hidden="true" tabindex="-1"></a>  <span class="at">eval_metric =</span> <span class="st">"rmse"</span>,</span>
<span id="cb24-30"><a href="#cb24-30" aria-hidden="true" tabindex="-1"></a>  <span class="at">nthread =</span> <span class="dv">2</span>,</span>
<span id="cb24-31"><a href="#cb24-31" aria-hidden="true" tabindex="-1"></a>  <span class="at">max_depth =</span> xgb_tuned<span class="sc">$</span>bestTune<span class="sc">$</span>max_depth,</span>
<span id="cb24-32"><a href="#cb24-32" aria-hidden="true" tabindex="-1"></a>  <span class="at">eta =</span> xgb_tuned<span class="sc">$</span>bestTune<span class="sc">$</span>eta,</span>
<span id="cb24-33"><a href="#cb24-33" aria-hidden="true" tabindex="-1"></a>  <span class="at">subsample =</span> xgb_tuned<span class="sc">$</span>bestTune<span class="sc">$</span>subsample,</span>
<span id="cb24-34"><a href="#cb24-34" aria-hidden="true" tabindex="-1"></a>  <span class="at">colsample_bytree =</span> xgb_tuned<span class="sc">$</span>bestTune<span class="sc">$</span>colsample_bytree,</span>
<span id="cb24-35"><a href="#cb24-35" aria-hidden="true" tabindex="-1"></a>  <span class="at">gamma =</span> xgb_tuned<span class="sc">$</span>bestTune<span class="sc">$</span>gamma,</span>
<span id="cb24-36"><a href="#cb24-36" aria-hidden="true" tabindex="-1"></a>  <span class="at">min_child_weight =</span> xgb_tuned<span class="sc">$</span>bestTune<span class="sc">$</span>min_child_weight</span>
<span id="cb24-37"><a href="#cb24-37" aria-hidden="true" tabindex="-1"></a>)</span>
<span id="cb24-38"><a href="#cb24-38" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb24-39"><a href="#cb24-39" aria-hidden="true" tabindex="-1"></a><span class="co"># Convert training data to DMatrix format</span></span>
<span id="cb24-40"><a href="#cb24-40" aria-hidden="true" tabindex="-1"></a>train_dmatrix <span class="ot">&lt;-</span> <span class="fu">xgb.DMatrix</span>(<span class="at">data =</span> train_matrix, <span class="at">label =</span> train_y)</span>
<span id="cb24-41"><a href="#cb24-41" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb24-42"><a href="#cb24-42" aria-hidden="true" tabindex="-1"></a><span class="co"># Train the final XGBoost model with the best parameters</span></span>
<span id="cb24-43"><a href="#cb24-43" aria-hidden="true" tabindex="-1"></a>xgb_model <span class="ot">&lt;-</span> <span class="fu">xgboost</span>(</span>
<span id="cb24-44"><a href="#cb24-44" aria-hidden="true" tabindex="-1"></a>  <span class="at">params =</span> params,</span>
<span id="cb24-45"><a href="#cb24-45" aria-hidden="true" tabindex="-1"></a>  <span class="at">data =</span> train_dmatrix,</span>
<span id="cb24-46"><a href="#cb24-46" aria-hidden="true" tabindex="-1"></a>  <span class="at">nrounds =</span> xgb_tuned<span class="sc">$</span>bestTune<span class="sc">$</span>nrounds,</span>
<span id="cb24-47"><a href="#cb24-47" aria-hidden="true" tabindex="-1"></a>  <span class="at">verbose =</span> <span class="dv">1</span></span>
<span id="cb24-48"><a href="#cb24-48" aria-hidden="true" tabindex="-1"></a>)</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
</section>
</section>
<section id="prediction" class="level1">
<h1>Prediction</h1>
<p>The final prediction resulted in <strong>RMSE</strong> of <code>0.081</code> on the <strong>50% test set</strong>. And later a <em>RMSE</em> of <code>0.063</code> on the <strong>final test set</strong> on Kaggle.</p>
<div class="cell">
<div class="sourceCode cell-code" id="cb25"><pre class="sourceCode r code-with-copy"><code class="sourceCode r"><span id="cb25-1"><a href="#cb25-1" aria-hidden="true" tabindex="-1"></a><span class="fu">library</span>(xgboost)</span>
<span id="cb25-2"><a href="#cb25-2" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb25-3"><a href="#cb25-3" aria-hidden="true" tabindex="-1"></a><span class="co"># Load the trained model</span></span>
<span id="cb25-4"><a href="#cb25-4" aria-hidden="true" tabindex="-1"></a>xgb_model <span class="ot">&lt;-</span> <span class="fu">readRDS</span>(<span class="st">"xgb_model.rds"</span>)</span>
<span id="cb25-5"><a href="#cb25-5" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb25-6"><a href="#cb25-6" aria-hidden="true" tabindex="-1"></a><span class="co"># Load the tuning results</span></span>
<span id="cb25-7"><a href="#cb25-7" aria-hidden="true" tabindex="-1"></a>xgb_tuned <span class="ot">&lt;-</span> <span class="fu">readRDS</span>(<span class="st">"xgb_tuned_results.rds"</span>)</span>
<span id="cb25-8"><a href="#cb25-8" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb25-9"><a href="#cb25-9" aria-hidden="true" tabindex="-1"></a><span class="co"># Make predictions on the test set</span></span>
<span id="cb25-10"><a href="#cb25-10" aria-hidden="true" tabindex="-1"></a>test_dmatrix <span class="ot">&lt;-</span> <span class="fu">xgb.DMatrix</span>(<span class="at">data =</span> test_matrix)</span>
<span id="cb25-11"><a href="#cb25-11" aria-hidden="true" tabindex="-1"></a>test_pred <span class="ot">&lt;-</span> <span class="fu">predict</span>(xgb_model, test_dmatrix)</span>
<span id="cb25-12"><a href="#cb25-12" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb25-13"><a href="#cb25-13" aria-hidden="true" tabindex="-1"></a><span class="co"># For the scoring data, convert to DMatrix and make predictions</span></span>
<span id="cb25-14"><a href="#cb25-14" aria-hidden="true" tabindex="-1"></a>scoring_matrix <span class="ot">&lt;-</span> <span class="fu">as.matrix</span>(test_final)</span>
<span id="cb25-15"><a href="#cb25-15" aria-hidden="true" tabindex="-1"></a>scoring_dmatrix <span class="ot">&lt;-</span> <span class="fu">xgb.DMatrix</span>(<span class="at">data =</span> scoring_matrix)</span>
<span id="cb25-16"><a href="#cb25-16" aria-hidden="true" tabindex="-1"></a>scoring_pred <span class="ot">&lt;-</span> <span class="fu">predict</span>(xgb_model, scoring_dmatrix)</span>
<span id="cb25-17"><a href="#cb25-17" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb25-18"><a href="#cb25-18" aria-hidden="true" tabindex="-1"></a><span class="co"># --- Inverse Box-Cox Transformation ---</span></span>
<span id="cb25-19"><a href="#cb25-19" aria-hidden="true" tabindex="-1"></a><span class="cf">if</span> (lambda <span class="sc">==</span> <span class="dv">0</span>) {</span>
<span id="cb25-20"><a href="#cb25-20" aria-hidden="true" tabindex="-1"></a>  scoring_pred <span class="ot">&lt;-</span> <span class="fu">exp</span>(scoring_pred)</span>
<span id="cb25-21"><a href="#cb25-21" aria-hidden="true" tabindex="-1"></a>} <span class="cf">else</span> {</span>
<span id="cb25-22"><a href="#cb25-22" aria-hidden="true" tabindex="-1"></a>  scoring_pred <span class="ot">&lt;-</span> (scoring_pred <span class="sc">*</span> lambda <span class="sc">+</span> <span class="dv">1</span>)<span class="sc">^</span>(<span class="dv">1</span> <span class="sc">/</span> lambda) <span class="sc">-</span> <span class="dv">1</span></span>
<span id="cb25-23"><a href="#cb25-23" aria-hidden="true" tabindex="-1"></a>}</span>
<span id="cb25-24"><a href="#cb25-24" aria-hidden="true" tabindex="-1"></a></span>
<span id="cb25-25"><a href="#cb25-25" aria-hidden="true" tabindex="-1"></a><span class="co"># Create submission file</span></span>
<span id="cb25-26"><a href="#cb25-26" aria-hidden="true" tabindex="-1"></a>submission <span class="ot">&lt;-</span> <span class="fu">data.frame</span>(<span class="at">id =</span> test<span class="sc">$</span>id, <span class="at">CTR =</span> scoring_pred)</span>
<span id="cb25-27"><a href="#cb25-27" aria-hidden="true" tabindex="-1"></a><span class="fu">write.csv</span>(submission, <span class="st">"xgboost_submission.csv"</span>, <span class="at">row.names =</span> <span class="cn">FALSE</span>)</span></code><button title="Copy to Clipboard" class="code-copy-button"><i class="bi"></i></button></pre></div>
</div>
</section>
<section id="final-comment" class="level1">
<h1>Final Comment</h1>
<p>A lot of experience and insights were gained during this project. There are several things that I did correctly and incorrectly that will be mentioned below.</p>
<section id="model-selection" class="level5">
<h5 class="anchored" data-anchor-id="model-selection">Model Selection</h5>
<p>If I had the opportunity to revisit this project, I would dedicate more effort to understanding the underlying patterns in the data rather than focusing solely on creating the most optimized model. During the process, I allocated significant time to understanding and applying basic feature engineering, experimenting with different models from <strong>linear regression</strong> to <strong>decision tree</strong>, and extensively tuning them to reduce the RMSE. Although the dataset was not the most complex, exploring the data first instead of jumping directly into modeling would not only be a time saver, but also give me deeper insight of the data to make more informed decisions throughout the process.</p>
</section>
<section id="data-exploration-1" class="level5">
<h5 class="anchored" data-anchor-id="data-exploration-1">Data Exploration</h5>
<p>In hindsight, I would prioritize more creative exploration of the data. For instance, I would experiment with binning continuous variables into categorical ones, exploring transformations such as <strong>interactions between variables</strong> (e.g., feature_a * feature_b), and deriving insights from unique patterns in the data. Additionally, I would investigate the relationship between the variables through <strong>correlation grids</strong> and analyze properties like the distribution of categories or the length of specific fields to uncover hidden relationships. This exploratory approach could have revealed insights that were missed.</p>
</section>
<section id="model-fitting" class="level5">
<h5 class="anchored" data-anchor-id="model-fitting">Model Fitting</h5>
<p>I would also spend more time analyzing overfitting in the models. Throughout the project, my models consistently showed RMSE values that were approximately <code>10%</code> better on test data compared to the final data and <code>20%</code> better on training data compared to the test data. This highlights <strong>significant overfitting</strong> issues that I did not fully address. A deeper exploration of feature selection, regularization techniques, or more effective validation strategies could have helped mitigate this problem.</p>
</section>
</section>

</main>
<!-- /main column -->
<script id="quarto-html-after-body" type="application/javascript">
window.document.addEventListener("DOMContentLoaded", function (event) {
  const toggleBodyColorMode = (bsSheetEl) => {
    const mode = bsSheetEl.getAttribute("data-mode");
    const bodyEl = window.document.querySelector("body");
    if (mode === "dark") {
      bodyEl.classList.add("quarto-dark");
      bodyEl.classList.remove("quarto-light");
    } else {
      bodyEl.classList.add("quarto-light");
      bodyEl.classList.remove("quarto-dark");
    }
  }
  const toggleBodyColorPrimary = () => {
    const bsSheetEl = window.document.querySelector("link#quarto-bootstrap");
    if (bsSheetEl) {
      toggleBodyColorMode(bsSheetEl);
    }
  }
  toggleBodyColorPrimary();  
  const icon = "";
  const anchorJS = new window.AnchorJS();
  anchorJS.options = {
    placement: 'right',
    icon: icon
  };
  anchorJS.add('.anchored');
  const isCodeAnnotation = (el) => {
    for (const clz of el.classList) {
      if (clz.startsWith('code-annotation-')) {                     
        return true;
      }
    }
    return false;
  }
  const onCopySuccess = function(e) {
    // button target
    const button = e.trigger;
    // don't keep focus
    button.blur();
    // flash "checked"
    button.classList.add('code-copy-button-checked');
    var currentTitle = button.getAttribute("title");
    button.setAttribute("title", "Copied!");
    let tooltip;
    if (window.bootstrap) {
      button.setAttribute("data-bs-toggle", "tooltip");
      button.setAttribute("data-bs-placement", "left");
      button.setAttribute("data-bs-title", "Copied!");
      tooltip = new bootstrap.Tooltip(button, 
        { trigger: "manual", 
          customClass: "code-copy-button-tooltip",
          offset: [0, -8]});
      tooltip.show();    
    }
    setTimeout(function() {
      if (tooltip) {
        tooltip.hide();
        button.removeAttribute("data-bs-title");
        button.removeAttribute("data-bs-toggle");
        button.removeAttribute("data-bs-placement");
      }
      button.setAttribute("title", currentTitle);
      button.classList.remove('code-copy-button-checked');
    }, 1000);
    // clear code selection
    e.clearSelection();
  }
  const getTextToCopy = function(trigger) {
      const codeEl = trigger.previousElementSibling.cloneNode(true);
      for (const childEl of codeEl.children) {
        if (isCodeAnnotation(childEl)) {
          childEl.remove();
        }
      }
      return codeEl.innerText;
  }
  const clipboard = new window.ClipboardJS('.code-copy-button:not([data-in-quarto-modal])', {
    text: getTextToCopy
  });
  clipboard.on('success', onCopySuccess);
  if (window.document.getElementById('quarto-embedded-source-code-modal')) {
    const clipboardModal = new window.ClipboardJS('.code-copy-button[data-in-quarto-modal]', {
      text: getTextToCopy,
      container: window.document.getElementById('quarto-embedded-source-code-modal')
    });
    clipboardModal.on('success', onCopySuccess);
  }
    var localhostRegex = new RegExp(/^(?:http|https):\/\/localhost\:?[0-9]*\//);
    var mailtoRegex = new RegExp(/^mailto:/);
      var filterRegex = new RegExp('/' + window.location.host + '/');
    var isInternal = (href) => {
        return filterRegex.test(href) || localhostRegex.test(href) || mailtoRegex.test(href);
    }
    // Inspect non-navigation links and adorn them if external
 	var links = window.document.querySelectorAll('a[href]:not(.nav-link):not(.navbar-brand):not(.toc-action):not(.sidebar-link):not(.sidebar-item-toggle):not(.pagination-link):not(.no-external):not([aria-hidden]):not(.dropdown-item):not(.quarto-navigation-tool):not(.about-link)');
    for (var i=0; i<links.length; i++) {
      const link = links[i];
      if (!isInternal(link.href)) {
        // undo the damage that might have been done by quarto-nav.js in the case of
        // links that we want to consider external
        if (link.dataset.originalHref !== undefined) {
          link.href = link.dataset.originalHref;
        }
      }
    }
  function tippyHover(el, contentFn, onTriggerFn, onUntriggerFn) {
    const config = {
      allowHTML: true,
      maxWidth: 500,
      delay: 100,
      arrow: false,
      appendTo: function(el) {
          return el.parentElement;
      },
      interactive: true,
      interactiveBorder: 10,
      theme: 'quarto',
      placement: 'bottom-start',
    };
    if (contentFn) {
      config.content = contentFn;
    }
    if (onTriggerFn) {
      config.onTrigger = onTriggerFn;
    }
    if (onUntriggerFn) {
      config.onUntrigger = onUntriggerFn;
    }
    window.tippy(el, config); 
  }
  const noterefs = window.document.querySelectorAll('a[role="doc-noteref"]');
  for (var i=0; i<noterefs.length; i++) {
    const ref = noterefs[i];
    tippyHover(ref, function() {
      // use id or data attribute instead here
      let href = ref.getAttribute('data-footnote-href') || ref.getAttribute('href');
      try { href = new URL(href).hash; } catch {}
      const id = href.replace(/^#\/?/, "");
      const note = window.document.getElementById(id);
      if (note) {
        return note.innerHTML;
      } else {
        return "";
      }
    });
  }
  const xrefs = window.document.querySelectorAll('a.quarto-xref');
  const processXRef = (id, note) => {
    // Strip column container classes
    const stripColumnClz = (el) => {
      el.classList.remove("page-full", "page-columns");
      if (el.children) {
        for (const child of el.children) {
          stripColumnClz(child);
        }
      }
    }
    stripColumnClz(note)
    if (id === null || id.startsWith('sec-')) {
      // Special case sections, only their first couple elements
      const container = document.createElement("div");
      if (note.children && note.children.length > 2) {
        container.appendChild(note.children[0].cloneNode(true));
        for (let i = 1; i < note.children.length; i++) {
          const child = note.children[i];
          if (child.tagName === "P" && child.innerText === "") {
            continue;
          } else {
            container.appendChild(child.cloneNode(true));
            break;
          }
        }
        if (window.Quarto?.typesetMath) {
          window.Quarto.typesetMath(container);
        }
        return container.innerHTML
      } else {
        if (window.Quarto?.typesetMath) {
          window.Quarto.typesetMath(note);
        }
        return note.innerHTML;
      }
    } else {
      // Remove any anchor links if they are present
      const anchorLink = note.querySelector('a.anchorjs-link');
      if (anchorLink) {
        anchorLink.remove();
      }
      if (window.Quarto?.typesetMath) {
        window.Quarto.typesetMath(note);
      }
      if (note.classList.contains("callout")) {
        return note.outerHTML;
      } else {
        return note.innerHTML;
      }
    }
  }
  for (var i=0; i<xrefs.length; i++) {
    const xref = xrefs[i];
    tippyHover(xref, undefined, function(instance) {
      instance.disable();
      let url = xref.getAttribute('href');
      let hash = undefined; 
      if (url.startsWith('#')) {
        hash = url;
      } else {
        try { hash = new URL(url).hash; } catch {}
      }
      if (hash) {
        const id = hash.replace(/^#\/?/, "");
        const note = window.document.getElementById(id);
        if (note !== null) {
          try {
            const html = processXRef(id, note.cloneNode(true));
            instance.setContent(html);
          } finally {
            instance.enable();
            instance.show();
          }
        } else {
          // See if we can fetch this
          fetch(url.split('#')[0])
          .then(res => res.text())
          .then(html => {
            const parser = new DOMParser();
            const htmlDoc = parser.parseFromString(html, "text/html");
            const note = htmlDoc.getElementById(id);
            if (note !== null) {
              const html = processXRef(id, note);
              instance.setContent(html);
            } 
          }).finally(() => {
            instance.enable();
            instance.show();
          });
        }
      } else {
        // See if we can fetch a full url (with no hash to target)
        // This is a special case and we should probably do some content thinning / targeting
        fetch(url)
        .then(res => res.text())
        .then(html => {
          const parser = new DOMParser();
          const htmlDoc = parser.parseFromString(html, "text/html");
          const note = htmlDoc.querySelector('main.content');
          if (note !== null) {
            // This should only happen for chapter cross references
            // (since there is no id in the URL)
            // remove the first header
            if (note.children.length > 0 && note.children[0].tagName === "HEADER") {
              note.children[0].remove();
            }
            const html = processXRef(null, note);
            instance.setContent(html);
          } 
        }).finally(() => {
          instance.enable();
          instance.show();
        });
      }
    }, function(instance) {
    });
  }
      let selectedAnnoteEl;
      const selectorForAnnotation = ( cell, annotation) => {
        let cellAttr = 'data-code-cell="' + cell + '"';
        let lineAttr = 'data-code-annotation="' +  annotation + '"';
        const selector = 'span[' + cellAttr + '][' + lineAttr + ']';
        return selector;
      }
      const selectCodeLines = (annoteEl) => {
        const doc = window.document;
        const targetCell = annoteEl.getAttribute("data-target-cell");
        const targetAnnotation = annoteEl.getAttribute("data-target-annotation");
        const annoteSpan = window.document.querySelector(selectorForAnnotation(targetCell, targetAnnotation));
        const lines = annoteSpan.getAttribute("data-code-lines").split(",");
        const lineIds = lines.map((line) => {
          return targetCell + "-" + line;
        })
        let top = null;
        let height = null;
        let parent = null;
        if (lineIds.length > 0) {
            //compute the position of the single el (top and bottom and make a div)
            const el = window.document.getElementById(lineIds[0]);
            top = el.offsetTop;
            height = el.offsetHeight;
            parent = el.parentElement.parentElement;
          if (lineIds.length > 1) {
            const lastEl = window.document.getElementById(lineIds[lineIds.length - 1]);
            const bottom = lastEl.offsetTop + lastEl.offsetHeight;
            height = bottom - top;
          }
          if (top !== null && height !== null && parent !== null) {
            // cook up a div (if necessary) and position it 
            let div = window.document.getElementById("code-annotation-line-highlight");
            if (div === null) {
              div = window.document.createElement("div");
              div.setAttribute("id", "code-annotation-line-highlight");
              div.style.position = 'absolute';
              parent.appendChild(div);
            }
            div.style.top = top - 2 + "px";
            div.style.height = height + 4 + "px";
            div.style.left = 0;
            let gutterDiv = window.document.getElementById("code-annotation-line-highlight-gutter");
            if (gutterDiv === null) {
              gutterDiv = window.document.createElement("div");
              gutterDiv.setAttribute("id", "code-annotation-line-highlight-gutter");
              gutterDiv.style.position = 'absolute';
              const codeCell = window.document.getElementById(targetCell);
              const gutter = codeCell.querySelector('.code-annotation-gutter');
              gutter.appendChild(gutterDiv);
            }
            gutterDiv.style.top = top - 2 + "px";
            gutterDiv.style.height = height + 4 + "px";
          }
          selectedAnnoteEl = annoteEl;
        }
      };
      const unselectCodeLines = () => {
        const elementsIds = ["code-annotation-line-highlight", "code-annotation-line-highlight-gutter"];
        elementsIds.forEach((elId) => {
          const div = window.document.getElementById(elId);
          if (div) {
            div.remove();
          }
        });
        selectedAnnoteEl = undefined;
      };
        // Handle positioning of the toggle
    window.addEventListener(
      "resize",
      throttle(() => {
        elRect = undefined;
        if (selectedAnnoteEl) {
          selectCodeLines(selectedAnnoteEl);
        }
      }, 10)
    );
    function throttle(fn, ms) {
    let throttle = false;
    let timer;
      return (...args) => {
        if(!throttle) { // first call gets through
            fn.apply(this, args);
            throttle = true;
        } else { // all the others get throttled
            if(timer) clearTimeout(timer); // cancel #2
            timer = setTimeout(() => {
              fn.apply(this, args);
              timer = throttle = false;
            }, ms);
        }
      };
    }
      // Attach click handler to the DT
      const annoteDls = window.document.querySelectorAll('dt[data-target-cell]');
      for (const annoteDlNode of annoteDls) {
        annoteDlNode.addEventListener('click', (event) => {
          const clickedEl = event.target;
          if (clickedEl !== selectedAnnoteEl) {
            unselectCodeLines();
            const activeEl = window.document.querySelector('dt[data-target-cell].code-annotation-active');
            if (activeEl) {
              activeEl.classList.remove('code-annotation-active');
            }
            selectCodeLines(clickedEl);
            clickedEl.classList.add('code-annotation-active');
          } else {
            // Unselect the line
            unselectCodeLines();
            clickedEl.classList.remove('code-annotation-active');
          }
        });
      }
  const findCites = (el) => {
    const parentEl = el.parentElement;
    if (parentEl) {
      const cites = parentEl.dataset.cites;
      if (cites) {
        return {
          el,
          cites: cites.split(' ')
        };
      } else {
        return findCites(el.parentElement)
      }
    } else {
      return undefined;
    }
  };
  var bibliorefs = window.document.querySelectorAll('a[role="doc-biblioref"]');
  for (var i=0; i<bibliorefs.length; i++) {
    const ref = bibliorefs[i];
    const citeInfo = findCites(ref);
    if (citeInfo) {
      tippyHover(citeInfo.el, function() {
        var popup = window.document.createElement('div');
        citeInfo.cites.forEach(function(cite) {
          var citeDiv = window.document.createElement('div');
          citeDiv.classList.add('hanging-indent');
          citeDiv.classList.add('csl-entry');
          var biblioDiv = window.document.getElementById('ref-' + cite);
          if (biblioDiv) {
            citeDiv.innerHTML = biblioDiv.innerHTML;
          }
          popup.appendChild(citeDiv);
        });
        return popup.innerHTML;
      });
    }
  }
});
</script>
</div> <!-- /content -->




</body></html>