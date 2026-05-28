# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x5654f0955048\>
\<environment: 0x5654f13f5f80\>

## Introduction

Often we can use the corresponding base R function as a baseline. We
also compare to the fansi package, where it is possible.

## Data

In cli the typical use case is short string scalars, but we run some
benchmarks longer strings and string vectors as well.

``` r

library(cli)
library(fansi)
options(cli.unicode = TRUE)
options(cli.num_colors = 256)
```

``` r

ansi <- format_inline(
  "{col_green(symbol$tick)} {.code print(x)} {.emph emphasised}"
)
```

``` r

plain <- ansi_strip(ansi)
```

``` r

vec_plain <- rep(plain, 100)
vec_ansi <- rep(ansi, 100)
vec_plain6 <- rep(plain, 6)
vec_ansi6 <- rep(plain, 6)
```

``` r

txt_plain <- paste(vec_plain, collapse = " ")
txt_ansi <- paste(vec_ansi, collapse = " ")
```

``` r

uni <- paste(
  "\U0001f477\u200d\u2640\ufe0f",
  "\U0001f477\U0001f3fb",
  "\U0001f477\u200d\u2640\ufe0f",
  "\U0001f477\U0001f3fb",
  "\U0001f477\U0001f3ff\u200d\u2640\ufe0f"
)
vec_uni <- rep(uni, 100)
txt_uni <- paste(vec_uni, collapse = " ")
```

## ANSI functions

### `ansi_align()`

``` r

bench::mark(
  ansi  = ansi_align(ansi, width = 20),
  plain = ansi_align(plain, width = 20), 
  base  = format(plain, width = 20),
  check = FALSE
)
```

``` fansi
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi         47.6µs     51µs    18819.    99.6KB     18.9
#> 2 plain        46.7µs   50.4µs    19193.        0B     19.8
#> 3 base         11.6µs   12.8µs    75330.    48.6KB     22.6
```

``` r

bench::mark(
  ansi  = ansi_align(ansi, width = 20, align = "right"),
  plain = ansi_align(plain, width = 20, align = "right"), 
  base  = format(plain, width = 20, justify = "right"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi         48.7µs   52.5µs    18401.        0B     21.2
#> 2 plain        48.2µs   52.4µs    18426.        0B     23.6
#> 3 base         13.6µs     15µs    64471.        0B     19.3
```

### `ansi_chartr()`

``` r

bench::mark(
  ansi  = ansi_chartr("abc", "XYZ", ansi),
  plain = ansi_chartr("abc", "XYZ", plain),
  base  = chartr("abc", "XYZ", plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi       119.62µs    128µs     7563.   77.03KB     14.7
#> 2 plain       95.98µs    102µs     9478.    8.91KB     12.5
#> 3 base         1.86µs      2µs   477006.        0B     47.7
```

### `ansi_columns()`

``` r

bench::mark(
  ansi  = ansi_columns(vec_ansi6, width = 120),
  plain = ansi_columns(vec_plain6, width = 120),
  check = FALSE
)
```

``` fansi
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 ansi          348µs    372µs     2657.   33.23KB     19.1
#> 2 plain         342µs    372µs     2654.    1.09KB     19.2
```

### `ansi_has_any()`

``` r

bench::mark(
  cli_ansi        = ansi_has_any(ansi),
  fansi_ansi      = has_sgr(ansi),
  cli_plain       = ansi_has_any(plain),
  fansi_plain     = has_sgr(plain),
  cli_vec_ansi    = ansi_has_any(vec_ansi),
  fansi_vec_ansi  = has_sgr(vec_ansi),
  cli_vec_plain   = ansi_has_any(vec_plain),
  fansi_vec_plain = has_sgr(vec_plain),
  cli_txt_ansi    = ansi_has_any(txt_ansi),
  fansi_txt_ansi  = has_sgr(txt_ansi),
  cli_txt_plain   = ansi_has_any(txt_plain),
  fansi_txt_plain = has_sgr(vec_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          5.87µs   6.41µs   150744.    9.27KB     15.1
#>  2 fansi_ansi       31.82µs  34.66µs    27899.    4.18KB     25.1
#>  3 cli_plain         5.81µs   6.33µs   152491.        0B     30.5
#>  4 fansi_plain      30.61µs  33.88µs    27978.      688B     16.8
#>  5 cli_vec_ansi      7.19µs   7.69µs   125912.      448B     12.6
#>  6 fansi_vec_ansi   41.21µs  43.83µs    21905.    5.02KB     11.0
#>  7 cli_vec_plain     7.78µs   8.28µs   116818.      448B      0  
#>  8 fansi_vec_plain  38.83µs  41.42µs    23336.    5.02KB     11.7
#>  9 cli_txt_ansi      5.75µs   6.18µs   157443.        0B     15.7
#> 10 fansi_txt_ansi   31.02µs  33.22µs    29119.      688B     11.7
#> 11 cli_txt_plain      6.6µs   7.03µs   138515.        0B     13.9
#> 12 fansi_txt_plain  39.37µs  41.86µs    23080.    5.02KB     11.5
```

### `ansi_html()`

This is typically used with longer text.

``` r

bench::mark(
  cli   = ansi_html(txt_ansi),
  fansi = sgr_to_html(txt_ansi, classes = TRUE),
  check = FALSE
)
```

``` fansi
#> # A tibble: 2 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          56.3µs   58.3µs    16653.    22.7KB     4.05
#> 2 fansi       119.8µs  125.7µs     7754.    55.3KB     4.06
```

### `ansi_nchar()`

``` r

bench::mark(
  cli_ansi        = ansi_nchar(ansi),
  fansi_ansi      = nchar_sgr(ansi),
  base_ansi       = nchar(ansi),
  cli_plain       = ansi_nchar(plain),
  fansi_plain     = nchar_sgr(plain),
  base_plain      = nchar(plain),
  cli_vec_ansi    = ansi_nchar(vec_ansi),
  fansi_vec_ansi  = nchar_sgr(vec_ansi),
  base_vec_ansi   = nchar(vec_ansi),
  cli_vec_plain   = ansi_nchar(vec_plain),
  fansi_vec_plain = nchar_sgr(vec_plain),
  base_vec_plain  = nchar(vec_plain),
  cli_txt_ansi    = ansi_nchar(txt_ansi),
  fansi_txt_ansi  = nchar_sgr(txt_ansi),
  base_txt_ansi   = nchar(txt_ansi),
  cli_txt_plain   = ansi_nchar(txt_plain),
  fansi_txt_plain = nchar_sgr(txt_plain),
  base_txt_plain  = nchar(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          7.03µs   7.72µs   125230.        0B    12.5 
#>  2 fansi_ansi       93.33µs  99.08µs     9742.   38.84KB     8.21
#>  3 base_ansi       901.05ns 952.04ns   977706.        0B     0   
#>  4 cli_plain         6.97µs   7.64µs   124829.        0B    12.5 
#>  5 fansi_plain      92.96µs  97.99µs     9883.      688B     8.21
#>  6 base_plain      831.09ns 872.07ns  1050170.        0B     0   
#>  7 cli_vec_ansi     28.85µs  29.84µs    32676.      448B     3.27
#>  8 fansi_vec_ansi  114.39µs 120.04µs     8068.    5.02KB     8.28
#>  9 base_vec_ansi     17.2µs  17.32µs    56606.      448B     0   
#> 10 cli_vec_plain    27.64µs  28.49µs    34296.      448B     3.43
#> 11 fansi_vec_plain 103.66µs 110.23µs     8690.    5.02KB     8.28
#> 12 base_vec_plain   10.11µs  10.24µs    95143.      448B     0   
#> 13 cli_txt_ansi     28.81µs  29.57µs    33042.        0B     3.30
#> 14 fansi_txt_ansi  105.08µs 110.63µs     8748.      688B     8.19
#> 15 base_txt_ansi     16.9µs  16.97µs    58026.        0B     0   
#> 16 cli_txt_plain    27.15µs  27.92µs    35029.        0B     3.50
#> 17 fansi_txt_plain  94.41µs  100.2µs     9666.      688B     8.21
#> 18 base_txt_plain    9.85µs  10.04µs    97027.        0B     0
```

``` r

bench::mark(
  cli_ansi        = ansi_nchar(ansi, type = "width"),
  fansi_ansi      = nchar_sgr(ansi, type = "width"),
  base_ansi       = nchar(ansi, "width"),
  cli_plain       = ansi_nchar(plain, type = "width"),
  fansi_plain     = nchar_sgr(plain, type = "width"),
  base_plain      = nchar(plain, "width"),
  cli_vec_ansi    = ansi_nchar(vec_ansi, type = "width"),
  fansi_vec_ansi  = nchar_sgr(vec_ansi, type = "width"),
  base_vec_ansi   = nchar(vec_ansi, "width"),
  cli_vec_plain   = ansi_nchar(vec_plain, type = "width"),
  fansi_vec_plain = nchar_sgr(vec_plain, type = "width"),
  base_vec_plain  = nchar(vec_plain, "width"),
  cli_txt_ansi    = ansi_nchar(txt_ansi, type = "width"),
  fansi_txt_ansi  = nchar_sgr(txt_ansi, type = "width"),
  base_txt_ansi   = nchar(txt_ansi, "width"),
  cli_txt_plain   = ansi_nchar(txt_plain, type = "width"),
  fansi_txt_plain = nchar_sgr(txt_plain, type = "width"),
  base_txt_plain  = nchar(txt_plain, type = "width"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          8.56µs   9.38µs   103188.        0B    10.3 
#>  2 fansi_ansi       92.96µs  98.56µs     9817.      688B    10.4 
#>  3 base_ansi         1.22µs   1.28µs   739330.        0B     0   
#>  4 cli_plain          8.6µs   9.39µs   103142.        0B    10.3 
#>  5 fansi_plain      92.79µs  98.07µs     9838.      688B     8.21
#>  6 base_plain           1µs   1.06µs   876599.        0B     0   
#>  7 cli_vec_ansi     34.69µs  35.66µs    27446.      448B     5.49
#>  8 fansi_vec_ansi  115.61µs 122.08µs     7926.    5.02KB     6.16
#>  9 base_vec_ansi    41.01µs  41.32µs    23886.      448B     0   
#> 10 cli_vec_plain    33.45µs  34.51µs    28331.      448B     2.83
#> 11 fansi_vec_plain 106.23µs 111.68µs     8664.    5.02KB     8.27
#> 12 base_vec_plain   21.74µs  22.04µs    44679.      448B     0   
#> 13 cli_txt_ansi     35.08µs  35.96µs    27122.        0B     5.43
#> 14 fansi_txt_ansi  107.16µs 113.17µs     8558.      688B     6.12
#> 15 base_txt_ansi    42.97µs  44.01µs    22384.        0B     0   
#> 16 cli_txt_plain    33.13µs  33.99µs    28553.        0B     5.71
#> 17 fansi_txt_plain  97.28µs 102.59µs     9413.      688B     8.21
#> 18 base_txt_plain   23.12µs  23.85µs    41364.        0B     0
```

### `ansi_simplify()`

Nothing to compare here.

``` r

bench::mark(
  cli_ansi      = ansi_simplify(ansi),
  cli_plain     = ansi_simplify(plain),
  cli_vec_ansi  = ansi_simplify(vec_ansi),
  cli_vec_plain = ansi_simplify(vec_plain),
  cli_txt_ansi  = ansi_simplify(txt_ansi),
  cli_txt_plain = ansi_simplify(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression         min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>    <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli_ansi        7.03µs   7.65µs   126443.        0B    12.6 
#> 2 cli_plain       6.55µs   7.12µs   135494.        0B    13.6 
#> 3 cli_vec_ansi   31.57µs  32.82µs    29789.      848B     2.98
#> 4 cli_vec_plain  10.59µs  11.35µs    85598.      848B     8.56
#> 5 cli_txt_ansi   30.69µs  31.72µs    30846.        0B     3.08
#> 6 cli_txt_plain   7.43µs   8.11µs   119828.        0B     0
```

### `ansi_strip()`

``` r

bench::mark(
  cli_ansi        = ansi_strip(ansi),
  fansi_ansi      = strip_sgr(ansi),
  cli_plain       = ansi_strip(plain),
  fansi_plain     = strip_sgr(plain),
  cli_vec_ansi    = ansi_strip(vec_ansi),
  fansi_vec_ansi  = strip_sgr(vec_ansi),
  cli_vec_plain   = ansi_strip(vec_plain),
  fansi_vec_plain = strip_sgr(vec_plain),
  cli_txt_ansi    = ansi_strip(txt_ansi),
  fansi_txt_ansi  = strip_sgr(txt_ansi),
  cli_txt_plain   = ansi_strip(txt_plain),
  fansi_txt_plain = strip_sgr(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          26.2µs   27.8µs    34741.        0B    13.9 
#>  2 fansi_ansi        29.2µs   31.5µs    30604.    7.24KB    12.2 
#>  3 cli_plain         25.9µs   27.6µs    35056.        0B    14.0 
#>  4 fansi_plain       28.7µs   30.9µs    31171.      688B    15.6 
#>  5 cli_vec_ansi      35.3µs     37µs    26225.      848B    10.5 
#>  6 fansi_vec_ansi    56.3µs   59.1µs    16431.    5.41KB     6.19
#>  7 cli_vec_plain     28.8µs   30.6µs    31615.      848B    15.8 
#>  8 fansi_vec_plain     38µs     40µs    24201.    4.59KB     9.68
#>  9 cli_txt_ansi      33.8µs   35.7µs    27027.        0B    10.8 
#> 10 fansi_txt_ansi    44.9µs   46.6µs    20830.    5.12KB     8.34
#> 11 cli_txt_plain     26.6µs     28µs    34664.        0B    13.9 
#> 12 fansi_txt_plain   29.4µs     31µs    31201.      688B    15.6
```

### `ansi_strsplit()`

``` r

bench::mark(
  cli_ansi        = ansi_strsplit(ansi, "i"),
  fansi_ansi      = strsplit_sgr(ansi, "i"),
  base_ansi       = strsplit(ansi, "i"),
  cli_plain       = ansi_strsplit(plain, "i"),
  fansi_plain     = strsplit_sgr(plain, "i"),
  base_plain      = strsplit(plain, "i"),
  cli_vec_ansi    = ansi_strsplit(vec_ansi, "i"),
  fansi_vec_ansi  = strsplit_sgr(vec_ansi, "i"),
  base_vec_ansi   = strsplit(vec_ansi, "i"),
  cli_vec_plain   = ansi_strsplit(vec_plain, "i"),
  fansi_vec_plain = strsplit_sgr(vec_plain, "i"),
  base_vec_plain  = strsplit(vec_plain, "i"),
  cli_txt_ansi    = ansi_strsplit(txt_ansi, "i"),
  fansi_txt_ansi  = strsplit_sgr(txt_ansi, "i"),
  base_txt_ansi   = strsplit(txt_ansi, "i"),
  cli_txt_plain   = ansi_strsplit(txt_plain, "i"),
  fansi_txt_plain = strsplit_sgr(txt_plain, "i"),
  base_txt_plain  = strsplit(txt_plain, "i"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi        165.25µs 173.64µs     5581.  104.86KB    10.3 
#>  2 fansi_ansi      130.72µs  139.6µs     6961.  106.35KB    10.4 
#>  3 base_ansi         4.13µs    4.5µs   215698.      224B     0   
#>  4 cli_plain       163.23µs 172.29µs     5607.    8.09KB    10.3 
#>  5 fansi_plain     129.19µs 137.33µs     7044.    9.62KB    10.4 
#>  6 base_plain        3.61µs   3.92µs   247554.        0B     0   
#>  7 cli_vec_ansi      7.86ms   8.04ms      124.  823.77KB    13.7 
#>  8 fansi_vec_ansi    1.07ms    1.1ms      887.  846.81KB    17.4 
#>  9 base_vec_ansi   158.18µs 162.91µs     5997.    22.7KB     2.04
#> 10 cli_vec_plain     7.72ms   7.93ms      126.  823.77KB    11.2 
#> 11 fansi_vec_plain   1.01ms   1.04ms      954.  845.98KB    17.8 
#> 12 base_vec_plain  107.72µs 112.16µs     8677.      848B     4.06
#> 13 cli_txt_ansi      3.26ms   3.39ms      288.    63.6KB     0   
#> 14 fansi_txt_ansi    1.58ms   1.62ms      614.   35.05KB     0   
#> 15 base_txt_ansi    137.8µs 145.01µs     6814.   18.47KB     4.08
#> 16 cli_txt_plain     2.44ms   2.48ms      401.    63.6KB     0   
#> 17 fansi_txt_plain 518.82µs 545.76µs     1801.    30.6KB     2.02
#> 18 base_txt_plain   89.08µs  91.88µs    10684.   11.05KB     2.02
```

### `ansi_strtrim()`

``` r

bench::mark(
  cli_ansi        = ansi_strtrim(ansi, 10),
  fansi_ansi      = strtrim_sgr(ansi, 10),
  base_ansi       = strtrim(ansi, 10),
  cli_plain       = ansi_strtrim(plain, 10),
  fansi_plain     = strtrim_sgr(plain, 10),
  base_plain      = strtrim(plain, 10),
  cli_vec_ansi    = ansi_strtrim(vec_ansi, 10),
  fansi_vec_ansi  = strtrim_sgr(vec_ansi, 10),
  base_vec_ansi   = strtrim(vec_ansi, 10),
  cli_vec_plain   = ansi_strtrim(vec_plain, 10),
  fansi_vec_plain = strtrim_sgr(vec_plain, 10),
  base_vec_plain  = strtrim(vec_plain, 10),
  cli_txt_ansi    = ansi_strtrim(txt_ansi, 10),
  fansi_txt_ansi  = strtrim_sgr(txt_ansi, 10),
  base_txt_ansi   = strtrim(txt_ansi, 10),
  cli_txt_plain   = ansi_strtrim(txt_plain, 10),
  fansi_txt_plain = strtrim_sgr(txt_plain, 10),
  base_txt_plain  = strtrim(txt_plain, 10),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi        151.77µs 158.87µs     6093.   33.84KB    12.5 
#>  2 fansi_ansi       56.17µs  60.32µs    15964.   31.42KB    10.4 
#>  3 base_ansi         1.07µs   1.13µs   829904.     4.2KB     0   
#>  4 cli_plain        148.8µs 155.57µs     6223.        0B    12.4 
#>  5 fansi_plain      55.98µs  59.69µs    16118.      872B    12.5 
#>  6 base_plain      982.08ns   1.03µs   904418.        0B     0   
#>  7 cli_vec_ansi    275.49µs 287.39µs     3411.   16.73KB     6.16
#>  8 fansi_vec_ansi  116.39µs 121.56µs     7981.    5.59KB     8.48
#>  9 base_vec_ansi    35.48µs  35.96µs    27442.      848B     0   
#> 10 cli_vec_plain   233.55µs 243.68µs     3989.   16.73KB     8.28
#> 11 fansi_vec_plain 109.28µs    114µs     8494.    5.59KB     6.18
#> 12 base_vec_plain   30.12µs  31.34µs    31520.      848B     0   
#> 13 cli_txt_ansi    158.58µs 165.87µs     5850.        0B    12.5 
#> 14 fansi_txt_ansi   56.02µs  59.91µs    16122.      872B    10.4 
#> 15 base_txt_ansi      1.1µs   1.16µs   808250.        0B     0   
#> 16 cli_txt_plain      148µs 154.18µs     6297.        0B    14.6 
#> 17 fansi_txt_plain  54.67µs  57.53µs    16790.      872B    10.3 
#> 18 base_txt_plain    1.02µs   1.07µs   877322.        0B     0
```

### `ansi_strwrap()`

This function is most useful for longer text, but it is often called for
short text in cli, so it makes sense to benchmark that as well.

``` r

bench::mark(
  cli_ansi        = ansi_strwrap(ansi, 30),
  fansi_ansi      = strwrap_sgr(ansi, 30),
  base_ansi       = strwrap(ansi, 30),
  cli_plain       = ansi_strwrap(plain, 30),
  fansi_plain     = strwrap_sgr(plain, 30),
  base_plain      = strwrap(plain, 30),
  cli_vec_ansi    = ansi_strwrap(vec_ansi, 30),
  fansi_vec_ansi  = strwrap_sgr(vec_ansi, 30),
  base_vec_ansi   = strwrap(vec_ansi, 30),
  cli_vec_plain   = ansi_strwrap(vec_plain, 30),
  fansi_vec_plain = strwrap_sgr(vec_plain, 30),
  base_vec_plain  = strwrap(vec_plain, 30),
  cli_txt_ansi    = ansi_strwrap(txt_ansi, 30),
  fansi_txt_ansi  = strwrap_sgr(txt_ansi, 30),
  base_txt_ansi   = strwrap(txt_ansi, 30),
  cli_txt_plain   = ansi_strwrap(txt_plain, 30),
  fansi_txt_plain = strwrap_sgr(txt_plain, 30),
  base_txt_plain  = strwrap(txt_plain, 30),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi        422.36µs 451.06µs    2212.     6.18KB    10.3 
#>  2 fansi_ansi      100.04µs 107.19µs    9053.    97.33KB    10.5 
#>  3 base_ansi        39.51µs  42.13µs   22822.         0B    11.4 
#>  4 cli_plain        278.6µs 291.54µs    3344.         0B    10.3 
#>  5 fansi_plain      99.72µs 106.23µs    9118.       872B    10.3 
#>  6 base_plain       32.54µs  34.48µs   27919.         0B    11.2 
#>  7 cli_vec_ansi     45.41ms  45.79ms      21.8   94.67KB    18.2 
#>  8 fansi_vec_ansi  242.31µs 251.55µs    3895.     7.25KB     6.15
#>  9 base_vec_ansi      2.3ms   2.37ms     420.    48.18KB    12.8 
#> 10 cli_vec_plain     29.3ms  29.71ms      33.6    2.48KB    14.0 
#> 11 fansi_vec_plain 194.66µs 203.82µs    4775.     6.42KB     8.36
#> 12 base_vec_plain    1.66ms   1.73ms     575.     47.4KB    10.5 
#> 13 cli_txt_ansi     27.03ms  27.45ms      36.2    4.27MB     7.24
#> 14 fansi_txt_ansi  227.53µs 237.62µs    4124.     6.77KB     6.11
#> 15 base_txt_ansi     1.25ms   1.29ms     766.   582.06KB     8.78
#> 16 cli_txt_plain     1.29ms   1.32ms     745.   369.84KB     8.64
#> 17 fansi_txt_plain 180.07µs 188.21µs    5175.     2.51KB     8.30
#> 18 base_txt_plain  847.18µs 887.88µs    1112.   367.31KB     8.69
```

### `ansi_substr()`

``` r

bench::mark(
  cli_ansi        = ansi_substr(ansi, 2, 10),
  fansi_ansi      = substr_sgr(ansi, 2, 10),
  base_ansi       = substr(ansi, 2, 10),
  cli_plain       = ansi_substr(plain, 2, 10),
  fansi_plain     = substr_sgr(plain, 2, 10),
  base_plain      = substr(plain, 2, 10),
  cli_vec_ansi    = ansi_substr(vec_ansi, 2, 10),
  fansi_vec_ansi  = substr_sgr(vec_ansi, 2, 10),
  base_vec_ansi   = substr(vec_ansi, 2, 10),
  cli_vec_plain   = ansi_substr(vec_plain, 2, 10),
  fansi_vec_plain = substr_sgr(vec_plain, 2, 10),
  base_vec_plain  = substr(vec_plain, 2, 10),
  cli_txt_ansi    = ansi_substr(txt_ansi, 2, 10),
  fansi_txt_ansi  = substr_sgr(txt_ansi, 2, 10),
  base_txt_ansi   = substr(txt_ansi, 2, 10),
  cli_txt_plain   = ansi_substr(txt_plain, 2, 10),
  fansi_txt_plain = substr_sgr(txt_plain, 2, 10),
  base_txt_plain  = substr(txt_plain, 2, 10),
  check = FALSE
)
```

``` fansi
#> # A tibble: 18 × 6
#>    expression           min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>      <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          6.73µs   7.38µs   128557.   25.09KB    25.7 
#>  2 fansi_ansi       81.43µs  86.19µs    11183.   28.48KB    10.4 
#>  3 base_ansi         1.03µs   1.09µs   860155.        0B     0   
#>  4 cli_plain         6.69µs    7.4µs   129981.        0B    13.0 
#>  5 fansi_plain      80.84µs  86.22µs    11158.    1.98KB    10.5 
#>  6 base_plain        1.01µs   1.06µs   808614.        0B    80.9 
#>  7 cli_vec_ansi     26.31µs  27.34µs    35836.     1.7KB     3.58
#>  8 fansi_vec_ansi  117.94µs    124µs     7815.    8.86KB     6.21
#>  9 base_vec_ansi     6.09µs   6.37µs   150898.      848B    15.1 
#> 10 cli_vec_plain    23.03µs  23.95µs    40879.     1.7KB     4.09
#> 11 fansi_vec_plain 112.59µs 118.08µs     8174.    8.86KB     8.36
#> 12 base_vec_plain    5.67µs   6.06µs   161517.      848B     0   
#> 13 cli_txt_ansi       6.8µs   7.54µs   127570.        0B    12.8 
#> 14 fansi_txt_ansi   81.13µs  86.62µs    11127.    1.98KB    10.4 
#> 15 base_txt_ansi     6.48µs   6.55µs   149053.        0B     0   
#> 16 cli_txt_plain     7.55µs   8.28µs   115010.        0B    23.0 
#> 17 fansi_txt_plain  79.78µs  84.51µs    11446.    1.98KB     9.76
#> 18 base_txt_plain    4.11µs   4.17µs   234500.        0B     0
```

### `ansi_tolower()` , `ansi_toupper()`

``` r

bench::mark(
  cli_ansi        = ansi_tolower(ansi),
  base_ansi       = tolower(ansi),
  cli_plain       = ansi_tolower(plain),
  base_plain      = tolower(plain),
  cli_vec_ansi    = ansi_tolower(vec_ansi),
  base_vec_ansi   = tolower(vec_ansi),
  cli_vec_plain   = ansi_tolower(vec_plain),
  base_vec_plain  = tolower(vec_plain),
  cli_txt_ansi    = ansi_tolower(txt_ansi),
  base_txt_ansi   = tolower(txt_ansi),
  cli_txt_plain   = ansi_tolower(txt_plain),
  base_txt_plain  = tolower(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression          min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi       112.51µs 117.43µs    8179.     12.1KB     8.23
#>  2 base_ansi        1.31µs   1.36µs  716496.         0B     0   
#>  3 cli_plain        90.8µs  94.52µs   10197.     8.91KB     8.22
#>  4 base_plain       1.03µs   1.07µs  906557.         0B     0   
#>  5 cli_vec_ansi     4.21ms   4.34ms     229.   838.95KB    13.1 
#>  6 base_vec_ansi    71.9µs  72.14µs   13696.       848B     0   
#>  7 cli_vec_plain    2.36ms   2.46ms     403.   817.08KB    15.4 
#>  8 base_vec_plain  42.63µs  43.14µs   22876.       848B     0   
#>  9 cli_txt_ansi    14.44ms   14.6ms      68.3   114.6KB     2.07
#> 10 base_txt_ansi   73.86µs  74.07µs   13338.         0B     0   
#> 11 cli_txt_plain  307.13µs 317.28µs    3087.    18.34KB     2.01
#> 12 base_txt_plain  40.75µs   41.9µs   23527.         0B     0
```

### `ansi_trimws()`

``` r

bench::mark(
  cli_ansi        = ansi_trimws(ansi),
  base_ansi       = trimws(ansi),
  cli_plain       = ansi_trimws(plain),
  base_plain      = trimws(plain),
  cli_vec_ansi    = ansi_trimws(vec_ansi),
  base_vec_ansi   = trimws(vec_ansi),
  cli_vec_plain   = ansi_trimws(vec_plain),
  base_vec_plain  = trimws(vec_plain),
  cli_txt_ansi    = ansi_trimws(txt_ansi),
  base_txt_ansi   = trimws(txt_ansi),
  cli_txt_plain   = ansi_trimws(txt_plain),
  base_txt_plain  = trimws(txt_plain),
  check = FALSE
)
```

``` fansi
#> # A tibble: 12 × 6
#>    expression          min   median `itr/sec` mem_alloc `gc/sec`
#>    <bch:expr>     <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#>  1 cli_ansi          111µs    116µs     8321.        0B    10.3 
#>  2 base_ansi        16.8µs   17.9µs    53973.        0B    16.2 
#>  3 cli_plain         109µs  114.4µs     8447.        0B    10.3 
#>  4 base_plain       16.8µs   17.9µs    53690.        0B    10.7 
#>  5 cli_vec_ansi    207.2µs  216.9µs     4498.     7.2KB     6.13
#>  6 base_vec_ansi    59.6µs   65.4µs    14958.    1.66KB     4.06
#>  7 cli_vec_plain   195.6µs  203.6µs     4783.     7.2KB     6.15
#>  8 base_vec_plain   51.8µs   58.3µs    16799.    1.66KB     4.06
#>  9 cli_txt_ansi    184.6µs  191.4µs     5084.        0B     6.11
#> 10 base_txt_ansi    41.2µs   42.6µs    22832.        0B     6.85
#> 11 cli_txt_plain   166.8µs  172.5µs     5633.        0B     6.11
#> 12 base_txt_plain   35.4µs   37.1µs    26162.        0B     5.23
```

## UTF-8 functions

### `utf8_nchar()`

``` r

bench::mark(
  cli        = utf8_nchar(uni, type = "chars"),
  base       = nchar(uni, "chars"),
  cli_vec    = utf8_nchar(vec_uni, type = "chars"),
  base_vec   = nchar(vec_uni, "chars"),
  cli_txt    = utf8_nchar(txt_uni, type = "chars"),
  base_txt   = nchar(txt_uni, "chars"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          8.31µs   9.05µs   106683.        0B    10.7 
#> 2 base       871.02ns 922.13ns  1000046.        0B     0   
#> 3 cli_vec     25.36µs  27.45µs    35607.      448B     3.56
#> 4 base_vec    11.63µs   11.9µs    82479.      448B     0   
#> 5 cli_txt     24.97µs   27.5µs    35450.        0B     7.09
#> 6 base_txt    12.62µs  12.71µs    77357.        0B     0
```

``` r

bench::mark(
  cli        = utf8_nchar(uni, type = "width"),
  base       = nchar(uni, "width"),
  cli_vec    = utf8_nchar(vec_uni, type = "width"),
  base_vec   = nchar(vec_uni, "width"),
  cli_txt    = utf8_nchar(txt_uni, type = "width"),
  base_txt   = nchar(txt_uni, "width"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          8.26µs   8.98µs   107683.        0B    10.8 
#> 2 base          1.3µs   1.36µs   686926.        0B     0   
#> 3 cli_vec     29.18µs  30.13µs    32385.      448B     3.24
#> 4 base_vec    50.55µs  51.29µs    19132.      448B     2.01
#> 5 cli_txt     29.66µs  30.53µs    32053.        0B     3.21
#> 6 base_txt    86.78µs  87.78µs    11244.        0B     0
```

``` r

bench::mark(
  cli        = utf8_nchar(uni, type = "codepoints"),
  base       = nchar(uni, "chars"),
  cli_vec    = utf8_nchar(vec_uni, type = "codepoints"),
  base_vec   = nchar(vec_uni, "chars"),
  cli_txt    = utf8_nchar(txt_uni, type = "codepoints"),
  base_txt   = nchar(txt_uni, "chars"),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          8.83µs    9.6µs   100854.        0B    10.1 
#> 2 base       881.03ns    942ns   961738.        0B    96.2 
#> 3 cli_vec     19.95µs   20.8µs    46921.      448B     4.69
#> 4 base_vec    11.62µs   11.9µs    82687.      448B     0   
#> 5 cli_txt     20.53µs   21.3µs    45712.        0B     4.57
#> 6 base_txt    12.62µs   12.8µs    77041.        0B     7.70
```

### `utf8_substr()`

``` r

bench::mark(
  cli        = utf8_substr(uni, 2, 10),
  base       = substr(uni, 2, 10),
  cli_vec    = utf8_substr(vec_uni, 2, 10),
  base_vec   = substr(vec_uni, 2, 10),
  cli_txt    = utf8_substr(txt_uni, 2, 10),
  base_txt   = substr(txt_uni, 2, 10),
  check = FALSE
)
```

``` fansi
#> # A tibble: 6 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 cli          6.53µs   7.15µs   135331.    22.2KB    13.5 
#> 2 base         1.04µs   1.11µs   846015.        0B     0   
#> 3 cli_vec      33.2µs  34.23µs    28619.     1.7KB     2.86
#> 4 base_vec     8.36µs   8.65µs   112978.      848B    11.3 
#> 5 cli_txt      6.38µs   6.97µs   138641.        0B    13.9 
#> 6 base_txt     5.71µs   5.78µs   168507.        0B     0
```

## Session info

``` r

sessioninfo::session_info()
```

``` fansi
#> ─ Session info ──────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.6.0 (2026-04-24)
#>  os       Ubuntu 24.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-05-28
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.11.0     2026-05-16 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-05-28 [1] local
#>  codetools     0.2-20     2024-03-31 [3] CRAN (R 4.6.0)
#>  desc          1.4.3      2023-12-10 [1] RSPM
#>  digest        0.6.39     2025-11-19 [1] RSPM
#>  evaluate      1.0.5      2025-08-27 [1] RSPM
#>  fansi       * 1.0.7      2025-11-19 [1] RSPM
#>  fastmap       1.2.0      2024-05-15 [1] RSPM
#>  fs            2.1.0      2026-04-18 [1] RSPM
#>  glue          1.8.1      2026-04-17 [1] RSPM
#>  htmltools     0.5.9      2025-12-04 [1] RSPM
#>  htmlwidgets   1.6.4      2023-12-06 [1] RSPM
#>  jquerylib     0.1.4      2021-04-26 [1] RSPM
#>  jsonlite      2.0.0      2025-03-27 [1] RSPM
#>  knitr         1.51       2025-12-20 [1] RSPM
#>  lifecycle     1.0.5      2026-01-08 [1] RSPM
#>  magrittr      2.0.5      2026-04-04 [1] RSPM
#>  pillar        1.11.1     2025-09-17 [1] RSPM
#>  pkgconfig     2.0.3      2019-09-22 [1] RSPM
#>  pkgdown       2.2.0      2025-11-06 [1] any (@2.2.0)
#>  profmem       0.7.0      2025-05-02 [1] RSPM
#>  R6            2.6.1      2025-02-15 [1] RSPM
#>  ragg          1.5.2      2026-03-23 [1] RSPM
#>  rlang         1.2.0      2026-04-06 [1] RSPM
#>  rmarkdown     2.31       2026-03-26 [1] RSPM
#>  sass          0.4.10     2025-04-11 [1] RSPM
#>  sessioninfo   1.2.3      2025-02-05 [1] RSPM
#>  systemfonts   1.3.2      2026-03-05 [1] RSPM
#>  textshaping   1.0.5      2026-03-06 [1] RSPM
#>  tibble        3.3.1      2026-01-11 [1] RSPM
#>  utf8          1.2.6      2025-06-08 [1] RSPM
#>  vctrs         0.7.3      2026-04-11 [1] RSPM
#>  xfun          0.57       2026-03-20 [1] RSPM
#>  yaml          2.3.12     2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.6.0/lib/R/site-library
#>  [3] /opt/R/4.6.0/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ─────────────────────────────────────────────────────────────────────
```
