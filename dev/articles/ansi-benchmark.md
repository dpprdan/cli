# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x558c2ba2eb98\>
\<environment: 0x558c2c5814b8\>

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
#> 1 ansi         47.1µs     51µs    18937.    99.3KB     19.0
#> 2 plain        47.2µs   50.8µs    19018.        0B     20.0
#> 3 base         11.4µs   12.7µs    76639.    48.4KB     15.3
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
#> 1 ansi         48.6µs   52.5µs    18407.        0B     21.3
#> 2 plain        48.7µs   52.7µs    18312.        0B     19.2
#> 3 base         13.4µs   14.8µs    65202.        0B     26.1
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
#> 1 ansi       113.08µs 120.89µs     8001.   75.07KB     14.7
#> 2 plain       89.63µs  95.94µs    10062.    8.73KB     14.7
#> 3 base         1.85µs   1.98µs   478365.        0B      0
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
#> 1 ansi          349µs    379µs     2612.   33.17KB     17.0
#> 2 plain         344µs    373µs     2646.    1.09KB     19.2
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
#>  1 cli_ansi          5.93µs   6.47µs   149048.     9.2KB     29.8
#>  2 fansi_ansi       31.76µs     35µs    27535.    4.18KB     22.0
#>  3 cli_plain         5.89µs   6.46µs   148702.        0B     29.7
#>  4 fansi_plain      30.71µs  34.34µs    28104.      688B     22.5
#>  5 cli_vec_ansi      7.24µs   7.73µs   125716.      448B     25.1
#>  6 fansi_vec_ansi    40.3µs  42.99µs    22515.    5.02KB     18.0
#>  7 cli_vec_plain     7.86µs   8.33µs   116977.      448B     23.4
#>  8 fansi_vec_plain  38.22µs   40.8µs    23763.    5.02KB     19.0
#>  9 cli_txt_ansi      5.83µs   6.27µs   153324.        0B     30.7
#> 10 fansi_txt_ansi   30.71µs  32.85µs    29488.      688B     23.6
#> 11 cli_txt_plain     6.66µs   7.18µs   134904.        0B     27.0
#> 12 fansi_txt_plain   38.5µs  40.92µs    23442.    5.02KB     18.8
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
#> 1 cli          56.8µs   58.6µs    16670.    22.7KB     8.18
#> 2 fansi       119.3µs    123µs     7896.    55.3KB     8.21
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
#>  1 cli_ansi          6.75µs   7.45µs   128730.        0B    25.8 
#>  2 fansi_ansi       92.61µs  98.12µs     9852.   38.83KB    16.8 
#>  3 base_ansi       852.04ns 901.05ns  1031135.        0B     0   
#>  4 cli_plain         6.78µs   7.44µs   129396.        0B    25.9 
#>  5 fansi_plain      91.41µs  97.25µs     9901.      688B    16.9 
#>  6 base_plain      791.04ns  841.1ns  1104300.        0B     0   
#>  7 cli_vec_ansi     29.18µs  30.23µs    32383.      448B     6.48
#>  8 fansi_vec_ansi  112.08µs 117.99µs     8187.    5.02KB    12.5 
#>  9 base_vec_ansi     14.7µs  14.78µs    66528.      448B     0   
#> 10 cli_vec_plain    27.35µs  28.24µs    34547.      448B     6.91
#> 11 fansi_vec_plain 103.13µs 108.86µs     8820.    5.02KB    14.7 
#> 12 base_vec_plain    8.79µs   8.86µs   110499.      448B     0   
#> 13 cli_txt_ansi     28.77µs  29.55µs    33124.        0B     6.63
#> 14 fansi_txt_ansi  104.17µs 109.77µs     8745.      688B    14.6 
#> 15 base_txt_ansi    14.27µs  14.34µs    68269.        0B     0   
#> 16 cli_txt_plain    26.98µs  27.77µs    35191.        0B     7.04
#> 17 fansi_txt_plain  94.82µs  99.89µs     9592.      688B    16.9 
#> 18 base_txt_plain    8.92µs   8.98µs   109559.        0B     0
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
#>  1 cli_ansi          8.47µs   9.24µs   104558.        0B    31.4 
#>  2 fansi_ansi       93.28µs  98.28µs     9846.      688B    16.8 
#>  3 base_ansi          1.2µs   1.25µs   747017.        0B     0   
#>  4 cli_plain          8.4µs   9.24µs   103883.        0B    20.8 
#>  5 fansi_plain      92.73µs  97.98µs     9873.      688B    17.6 
#>  6 base_plain      971.02ns   1.02µs   923711.        0B     0   
#>  7 cli_vec_ansi     34.59µs  35.49µs    27545.      448B     5.51
#>  8 fansi_vec_ansi  115.25µs 119.53µs     8100.    5.02KB    12.5 
#>  9 base_vec_ansi    42.59µs  42.89µs    22981.      448B     2.30
#> 10 cli_vec_plain    32.78µs  33.72µs    28856.      448B     5.77
#> 11 fansi_vec_plain 105.55µs 110.73µs     8694.    5.02KB    14.7 
#> 12 base_vec_plain   22.29µs   22.6µs    43493.      448B     0   
#> 13 cli_txt_ansi     34.33µs  35.11µs    27826.        0B     5.57
#> 14 fansi_txt_ansi  107.65µs 112.88µs     8572.      688B    14.7 
#> 15 base_txt_ansi    45.28µs   45.7µs    21597.        0B     0   
#> 16 cli_txt_plain     32.5µs  33.37µs    29323.        0B     8.80
#> 17 fansi_txt_plain  97.96µs 103.36µs     9280.      688B    14.6 
#> 18 base_txt_plain   24.27µs   24.6µs    40089.        0B     0
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
#> 1 cli_ansi        6.84µs   7.47µs   129170.        0B    12.9 
#> 2 cli_plain       6.44µs   7.04µs   137311.        0B    27.5 
#> 3 cli_vec_ansi   31.46µs  32.51µs    29986.      848B     6.00
#> 4 cli_vec_plain  10.31µs  11.05µs    88034.      848B     8.80
#> 5 cli_txt_ansi   30.72µs  31.79µs    30797.        0B     6.16
#> 6 cli_txt_plain   7.25µs   7.86µs   122891.        0B    12.3
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
#>  1 cli_ansi            26µs   27.8µs    34838.        0B     27.9
#>  2 fansi_ansi        28.5µs   30.7µs    31382.    7.24KB     25.1
#>  3 cli_plain           26µs   27.5µs    35171.        0B     28.2
#>  4 fansi_plain       28.3µs   30.3µs    31855.      688B     22.3
#>  5 cli_vec_ansi      35.5µs   37.2µs    26025.      848B     20.8
#>  6 fansi_vec_ansi    54.3µs     57µs    17011.    5.41KB     14.9
#>  7 cli_vec_plain     28.8µs   30.7µs    31451.      848B     25.2
#>  8 fansi_vec_plain   37.1µs   39.4µs    24530.    4.59KB     17.2
#>  9 cli_txt_ansi      34.7µs   36.5µs    26575.        0B     21.3
#> 10 fansi_txt_ansi    44.6µs     47µs    20568.    5.12KB     16.9
#> 11 cli_txt_plain     26.6µs   28.1µs    34496.        0B     27.6
#> 12 fansi_txt_plain   29.3µs   31.2µs    30987.      688B     24.8
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
#>  1 cli_ansi        168.07µs 178.33µs     5412.  104.34KB    16.9 
#>  2 fansi_ansi       130.6µs    140µs     6887.  106.35KB    19.2 
#>  3 base_ansi         4.03µs   4.49µs   216466.      224B    21.6 
#>  4 cli_plain       166.72µs 176.51µs     5477.    8.09KB    16.9 
#>  5 fansi_plain     129.88µs 137.76µs     6982.    9.62KB    21.3 
#>  6 base_plain        3.64µs   3.94µs   242452.        0B     0   
#>  7 cli_vec_ansi      7.83ms   8.06ms      123.  823.77KB    26.2 
#>  8 fansi_vec_ansi    1.09ms   1.14ms      848.  846.81KB    17.5 
#>  9 base_vec_ansi   154.01µs 160.56µs     6078.    22.7KB     2.04
#> 10 cli_vec_plain     7.82ms   8.14ms      122.  823.77KB    26.5 
#> 11 fansi_vec_plain   1.04ms    1.1ms      876.  845.98KB    17.8 
#> 12 base_vec_plain  105.43µs 111.43µs     8753.      848B     2.01
#> 13 cli_txt_ansi      3.41ms    3.5ms      284.    63.6KB     2.03
#> 14 fansi_txt_ansi    1.57ms    1.6ms      619.   35.05KB     2.02
#> 15 base_txt_ansi   136.79µs 148.77µs     6634.   18.47KB     2.02
#> 16 cli_txt_plain     2.47ms   2.52ms      394.    63.6KB     0   
#> 17 fansi_txt_plain 524.85µs 565.95µs     1762.    30.6KB     6.17
#> 18 base_txt_plain   88.12µs  90.78µs    10738.   11.05KB     2.02
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
#>  1 cli_ansi        152.88µs 161.65µs     5875.   33.84KB     21.7
#>  2 fansi_ansi       54.91µs  59.42µs    15965.   31.42KB     21.4
#>  3 base_ansi         1.06µs   1.18µs   782907.     4.2KB     78.3
#>  4 cli_plain       146.27µs 157.62µs     6126.        0B     22.4
#>  5 fansi_plain      53.53µs  56.84µs    17020.      872B     23.6
#>  6 base_plain      991.04ns   1.04µs   916028.        0B      0  
#>  7 cli_vec_ansi    276.29µs 288.14µs     3372.   16.73KB     12.6
#>  8 fansi_vec_ansi  116.43µs 121.01µs     8044.    5.59KB     12.5
#>  9 base_vec_ansi    36.31µs  37.24µs    26500.      848B      0  
#> 10 cli_vec_plain   235.11µs  246.6µs     3974.   16.73KB     14.8
#> 11 fansi_vec_plain 110.13µs 114.85µs     8463.    5.59KB     12.6
#> 12 base_vec_plain   30.58µs  31.31µs    31529.      848B      0  
#> 13 cli_txt_ansi    157.51µs 165.62µs     5864.        0B     21.3
#> 14 fansi_txt_ansi   53.99µs  58.02µs    16656.      872B     23.6
#> 15 base_txt_ansi      1.1µs   1.16µs   820680.        0B      0  
#> 16 cli_txt_plain   149.13µs 157.91µs     6131.        0B     23.4
#> 17 fansi_txt_plain  53.62µs  57.57µs    16828.      872B     21.3
#> 18 base_txt_plain    1.01µs   1.06µs   883076.        0B      0
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
#>  1 cli_ansi        410.24µs 438.51µs    2266.         0B    19.1 
#>  2 fansi_ansi       99.88µs 106.18µs    9090.    97.32KB    21.4 
#>  3 base_ansi        38.91µs   41.7µs   22844.         0B    20.6 
#>  4 cli_plain       283.66µs 301.53µs    3234.         0B    19.0 
#>  5 fansi_plain      96.92µs 104.12µs    9311.       872B    14.7 
#>  6 base_plain       32.02µs   33.9µs   28409.         0B     8.53
#>  7 cli_vec_ansi     43.31ms  43.37ms      23.0    2.48KB    23.0 
#>  8 fansi_vec_ansi  235.74µs 247.04µs    3981.     7.25KB     6.14
#>  9 base_vec_ansi     2.27ms   2.36ms     423.    48.18KB    12.9 
#> 10 cli_vec_plain    29.67ms  29.94ms      33.0    2.48KB    13.7 
#> 11 fansi_vec_plain 192.79µs    201µs    4864.     6.42KB     8.23
#> 12 base_vec_plain    1.67ms   1.73ms     577.     47.4KB    12.7 
#> 13 cli_txt_ansi     24.23ms  24.61ms      40.7  507.59KB     4.52
#> 14 fansi_txt_ansi  226.67µs    237µs    4101.     6.77KB     6.13
#> 15 base_txt_ansi     1.26ms    1.3ms     731.   582.06KB    11.0 
#> 16 cli_txt_plain     1.28ms   1.32ms     749.   369.84KB     8.63
#> 17 fansi_txt_plain 179.82µs 187.97µs    5190.     2.51KB     6.15
#> 18 base_txt_plain  853.12µs 896.26µs    1095.   367.31KB    11.2
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
#>  1 cli_ansi          6.85µs   7.49µs   128747.   24.83KB    12.9 
#>  2 fansi_ansi        80.6µs  85.96µs    11265.   28.48KB    10.4 
#>  3 base_ansi         1.01µs   1.08µs   838607.        0B    83.9 
#>  4 cli_plain          6.8µs   7.38µs   130906.        0B    13.1 
#>  5 fansi_plain      79.72µs   85.1µs    11305.    1.98KB    10.4 
#>  6 base_plain      991.04ns   1.05µs   882265.        0B     0   
#>  7 cli_vec_ansi     28.05µs  29.16µs    33582.     1.7KB     6.72
#>  8 fansi_vec_ansi  117.15µs 122.32µs     7930.    8.86KB     6.19
#>  9 base_vec_ansi     6.08µs    6.4µs   152342.      848B    15.2 
#> 10 cli_vec_plain    24.33µs  25.31µs    38738.     1.7KB     3.87
#> 11 fansi_vec_plain 111.18µs 116.75µs     8301.    8.86KB     8.39
#> 12 base_vec_plain    5.89µs   6.03µs   161328.      848B     0   
#> 13 cli_txt_ansi      6.78µs   7.47µs   129841.        0B    13.0 
#> 14 fansi_txt_ansi   80.15µs  85.37µs    11358.    1.98KB    10.4 
#> 15 base_txt_ansi     5.17µs   5.25µs   184498.        0B    18.5 
#> 16 cli_txt_plain     7.68µs   8.34µs   116122.        0B    11.6 
#> 17 fansi_txt_plain  80.63µs  85.37µs    11344.    1.98KB    10.4 
#> 18 base_txt_plain    3.41µs   3.48µs   277064.        0B     0
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
#>  1 cli_ansi       107.81µs 114.84µs    8410.    11.88KB     8.25
#>  2 base_ansi         1.3µs   1.35µs  705425.         0B     0   
#>  3 cli_plain       85.53µs  90.47µs   10569.     8.73KB     8.25
#>  4 base_plain     991.16ns   1.04µs  909483.         0B     0   
#>  5 cli_vec_ansi     4.16ms   4.34ms     229.   838.77KB    15.9 
#>  6 base_vec_ansi   71.92µs  72.19µs   13645.       848B     0   
#>  7 cli_vec_plain    2.34ms   2.42ms     412.    816.9KB    12.9 
#>  8 base_vec_plain  43.08µs  43.72µs   22523.       848B     2.25
#>  9 cli_txt_ansi    13.66ms  13.76ms      72.5  114.42KB     2.07
#> 10 base_txt_ansi   73.67µs  73.96µs   13352.         0B     0   
#> 11 cli_txt_plain  260.72µs 271.48µs    3605.    18.16KB     4.06
#> 12 base_txt_plain  40.97µs  41.59µs   23720.         0B     0
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
#>  1 cli_ansi        110.7µs  116.6µs     8278.        0B    12.4 
#>  2 base_ansi        16.6µs   17.7µs    54599.        0B    10.9 
#>  3 cli_plain       109.7µs    114µs     8502.        0B    12.4 
#>  4 base_plain       16.4µs   17.6µs    54975.        0B    11.0 
#>  5 cli_vec_ansi    201.2µs  211.6µs     4551.     7.2KB     6.12
#>  6 base_vec_ansi      55µs   62.2µs    15282.    1.66KB     4.06
#>  7 cli_vec_plain   188.8µs  198.6µs     4907.     7.2KB     6.17
#>  8 base_vec_plain   49.8µs   56.7µs    17270.    1.66KB     4.06
#>  9 cli_txt_ansi    177.1µs  184.1µs     5300.        0B     8.29
#> 10 base_txt_ansi    38.4µs   39.6µs    24618.        0B     4.92
#> 11 cli_txt_plain   160.4µs  167.5µs     5802.        0B     8.20
#> 12 base_txt_plain   33.9µs   35.3µs    27626.        0B     5.53
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
#> 1 cli          8.23µs   8.94µs   108489.        0B    10.8 
#> 2 base       821.08ns 882.08ns  1013340.        0B     0   
#> 3 cli_vec     23.71µs  24.75µs    38487.      448B     3.85
#> 4 base_vec    11.67µs  11.99µs    82029.      448B     8.20
#> 5 cli_txt     23.98µs  24.79µs    39466.        0B     3.95
#> 6 base_txt    12.32µs   12.4µs    79205.        0B     0
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
#> 1 cli          8.22µs   9.15µs   105923.        0B    10.6 
#> 2 base         1.27µs   1.33µs   704524.        0B    70.5 
#> 3 cli_vec     29.12µs  30.18µs    32452.      448B     3.25
#> 4 base_vec     51.5µs  52.11µs    18966.      448B     0   
#> 5 cli_txt     29.75µs  30.61µs    32042.        0B     3.20
#> 6 base_txt    86.99µs   87.7µs    11273.        0B     0
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
#> 1 cli          8.69µs   9.46µs   102352.        0B    20.5 
#> 2 base       830.97ns 892.09ns  1002643.        0B     0   
#> 3 cli_vec     19.84µs  20.81µs    46971.      448B     4.70
#> 4 base_vec    11.69µs  11.97µs    81935.      448B     0   
#> 5 cli_txt     20.14µs  21.06µs    46397.        0B     9.28
#> 6 base_txt    12.33µs  12.41µs    78793.        0B     0
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
#> 1 cli           6.5µs   7.15µs   135048.    22.1KB    13.5 
#> 2 base         1.03µs    1.1µs   834461.        0B    83.5 
#> 3 cli_vec     30.62µs  31.54µs    31158.     1.7KB     3.12
#> 4 base_vec     8.34µs   8.58µs   111726.      848B     0   
#> 5 cli_txt      6.45µs   7.18µs   134145.        0B    13.4 
#> 6 base_txt     5.42µs   5.54µs   169144.        0B     0
```

## Session info

``` r
sessioninfo::session_info()
```

``` fansi
#> ─ Session info ──────────────────────────────────────────────────────
#>  setting  value
#>  version  R version 4.5.3 (2026-03-11)
#>  os       Ubuntu 24.04.4 LTS
#>  system   x86_64, linux-gnu
#>  ui       X11
#>  language en
#>  collate  C.UTF-8
#>  ctype    C.UTF-8
#>  tz       UTC
#>  date     2026-04-08
#>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.10.0     2026-01-26 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.5.9000 2026-04-08 [1] local
#>  codetools     0.2-20     2024-03-31 [3] CRAN (R 4.5.3)
#>  desc          1.4.3      2023-12-10 [1] RSPM
#>  digest        0.6.39     2025-11-19 [1] RSPM
#>  evaluate      1.0.5      2025-08-27 [1] RSPM
#>  fansi       * 1.0.7      2025-11-19 [1] RSPM
#>  fastmap       1.2.0      2024-05-15 [1] RSPM
#>  fs            2.0.1      2026-03-24 [1] RSPM
#>  glue          1.8.0      2024-09-30 [1] RSPM
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
#>  sessioninfo   1.2.3      2025-02-05 [1] any (@1.2.3)
#>  systemfonts   1.3.2      2026-03-05 [1] RSPM
#>  textshaping   1.0.5      2026-03-06 [1] RSPM
#>  tibble        3.3.1      2026-01-11 [1] RSPM
#>  utf8          1.2.6      2025-06-08 [1] RSPM
#>  vctrs         0.7.2      2026-03-21 [1] RSPM
#>  xfun          0.57       2026-03-20 [1] RSPM
#>  yaml          2.3.12     2025-12-10 [1] RSPM
#> 
#>  [1] /home/runner/work/_temp/Library
#>  [2] /opt/R/4.5.3/lib/R/site-library
#>  [3] /opt/R/4.5.3/lib/R/library
#>  * ── Packages attached to the search path.
#> 
#> ─────────────────────────────────────────────────────────────────────
```
