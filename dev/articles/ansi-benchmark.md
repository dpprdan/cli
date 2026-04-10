# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x55fb30c3b768\>
\<environment: 0x55fb316f6c18\>

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
#> 1 ansi         38.3µs   42.1µs    23228.    99.6KB     23.3
#> 2 plain        37.4µs   41.9µs    23309.        0B     23.3
#> 3 base         10.8µs   12.1µs    80121.    48.4KB     24.0
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
#> 1 ansi           40µs   44.4µs    21910.        0B     26.3
#> 2 plain        39.6µs   43.6µs    22336.        0B     24.6
#> 3 base         12.6µs   14.2µs    68422.        0B     20.5
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
#> 1 ansi         92.7µs  101.3µs     9592.   75.07KB     16.9
#> 2 plain        71.5µs  78.03µs    12384.    8.73KB     17.0
#> 3 base          1.8µs   2.03µs   460296.        0B     46.0
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
#> 1 ansi          278µs    304µs     3263.   33.24KB     21.5
#> 2 plain         277µs    299µs     3323.    1.09KB     23.7
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
#>  1 cli_ansi           5.6µs   6.35µs   151716.    9.27KB     30.3
#>  2 fansi_ansi       26.06µs   29.2µs    33376.    4.18KB     30.1
#>  3 cli_plain         5.54µs   5.99µs   162399.        0B     16.2
#>  4 fansi_plain      26.51µs  28.08µs    34662.      688B     31.2
#>  5 cli_vec_ansi      6.86µs   7.44µs   131138.      448B     13.1
#>  6 fansi_vec_ansi   35.52µs  37.65µs    25842.    5.02KB     23.3
#>  7 cli_vec_plain     7.61µs   8.24µs   118123.      448B     11.8
#>  8 fansi_vec_plain   34.4µs  36.52µs    26744.    5.02KB     21.4
#>  9 cli_txt_ansi      5.54µs   6.06µs   160571.        0B     16.1
#> 10 fansi_txt_ansi   26.57µs  28.47µs    34204.      688B     27.4
#> 11 cli_txt_plain     6.49µs   6.94µs   140612.        0B     28.1
#> 12 fansi_txt_plain  34.38µs   36.6µs    26681.    5.02KB     21.4
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
#> 1 cli          56.2µs     58µs    16981.    22.7KB     8.18
#> 2 fansi       110.9µs    114µs     8621.    55.3KB    10.3
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
#>  1 cli_ansi          6.45µs   7.06µs   136339.        0B    27.3 
#>  2 fansi_ansi       71.53µs  76.56µs    12683.   38.83KB    21.3 
#>  3 base_ansi       861.01ns 951.11ns   987672.        0B     0   
#>  4 cli_plain         6.43µs   7.09µs   136733.        0B    27.4 
#>  5 fansi_plain      71.67µs  76.88µs    12616.      688B    21.3 
#>  6 base_plain      781.03ns  870.9ns  1068183.        0B     0   
#>  7 cli_vec_ansi     27.77µs  29.66µs    33259.      448B     6.65
#>  8 fansi_vec_ansi   91.98µs  97.34µs     9920.    5.02KB    14.8 
#>  9 base_vec_ansi    14.62µs  14.75µs    66434.      448B     6.64
#> 10 cli_vec_plain    25.65µs  27.08µs    36465.      448B     3.65
#> 11 fansi_vec_plain  82.12µs  86.99µs    11144.    5.02KB    19.3 
#> 12 base_vec_plain    8.69µs   8.81µs   110872.      448B     0   
#> 13 cli_txt_ansi     28.52µs  29.31µs    33579.        0B     6.72
#> 14 fansi_txt_ansi   84.59µs  89.69µs    10865.      688B    16.8 
#> 15 base_txt_ansi    14.47µs  14.58µs    67431.        0B     6.74
#> 16 cli_txt_plain    25.04µs  25.81µs    37858.        0B     7.57
#> 17 fansi_txt_plain  74.69µs  79.13µs    12265.      688B    20.3 
#> 18 base_txt_plain     8.5µs    8.6µs   114221.        0B     0
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
#>  1 cli_ansi          7.91µs   8.52µs   114664.        0B    34.4 
#>  2 fansi_ansi       71.46µs  75.38µs    12874.      688B    21.2 
#>  3 base_ansi         1.19µs   1.29µs   740350.        0B     0   
#>  4 cli_plain         7.91µs   8.51µs   114600.        0B    22.9 
#>  5 fansi_plain      71.57µs  75.76µs    12822.      688B    21.3 
#>  6 base_plain      971.95ns   1.08µs   862248.        0B     0   
#>  7 cli_vec_ansi     34.09µs  35.14µs    27999.      448B     8.40
#>  8 fansi_vec_ansi   95.07µs 100.49µs     9682.    5.02KB    14.8 
#>  9 base_vec_ansi    41.57µs  41.92µs    23557.      448B     0   
#> 10 cli_vec_plain    32.57µs   33.5µs    29329.      448B     8.80
#> 11 fansi_vec_plain  85.69µs  90.79µs    10688.    5.02KB    17.1 
#> 12 base_vec_plain   21.98µs  22.21µs    44365.      448B     0   
#> 13 cli_txt_ansi     34.95µs  35.91µs    27389.        0B     8.22
#> 14 fansi_txt_ansi   87.82µs  93.26µs    10448.      688B    16.8 
#> 15 base_txt_ansi    43.52µs  43.86µs    22518.        0B     0   
#> 16 cli_txt_plain    31.94µs  32.77µs    30034.        0B     6.01
#> 17 fansi_txt_plain  76.98µs  82.99µs    11174.      688B    19.2 
#> 18 base_txt_plain   23.11µs  23.27µs    42376.        0B     0
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
#> 1 cli_ansi        6.32µs   6.88µs   141237.        0B    14.1 
#> 2 cli_plain       5.95µs   6.55µs   148003.        0B    29.6 
#> 3 cli_vec_ansi   30.82µs  31.76µs    30998.      848B     6.20
#> 4 cli_vec_plain  10.05µs   10.7µs    91374.      848B     9.14
#> 5 cli_txt_ansi   29.82µs  31.44µs    31369.        0B     6.27
#> 6 cli_txt_plain   6.94µs   7.52µs   129163.        0B    12.9
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
#>  1 cli_ansi            24µs   25.7µs    37837.        0B     30.3
#>  2 fansi_ansi        24.9µs   26.6µs    36387.    7.24KB     29.1
#>  3 cli_plain         23.9µs   25.4µs    38286.        0B     30.7
#>  4 fansi_plain       24.7µs   26.4µs    36744.      688B     25.7
#>  5 cli_vec_ansi      33.3µs   35.9µs    26804.      848B     24.1
#>  6 fansi_vec_ansi    50.6µs   52.7µs    18545.    5.41KB     14.6
#>  7 cli_vec_plain     26.6µs     28µs    34884.      848B     24.4
#>  8 fansi_vec_plain   33.1µs   35.2µs    27793.    4.59KB     22.3
#>  9 cli_txt_ansi        33µs   34.7µs    28179.        0B     22.6
#> 10 fansi_txt_ansi    41.3µs   43.4µs    22601.    5.12KB     18.1
#> 11 cli_txt_plain     24.6µs   26.3µs    37215.        0B     29.8
#> 12 fansi_txt_plain   25.9µs   27.5µs    33459.      688B     23.4
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
#>  1 cli_ansi        130.18µs 138.85µs     7019.  104.86KB    23.4 
#>  2 fansi_ansi      104.29µs 111.05µs     8808.  106.35KB    23.7 
#>  3 base_ansi         3.98µs   4.34µs   223867.      224B    22.4 
#>  4 cli_plain       130.13µs 138.03µs     7030.    8.09KB    23.4 
#>  5 fansi_plain     104.36µs 110.76µs     8807.    9.62KB    23.7 
#>  6 base_plain        3.46µs    3.7µs   261125.        0B     0   
#>  7 cli_vec_ansi      6.48ms   6.64ms      150.  823.77KB    31.7 
#>  8 fansi_vec_ansi    1.04ms   1.08ms      889.  846.81KB    19.8 
#>  9 base_vec_ansi   150.99µs 159.73µs     6108.    22.7KB     2.05
#> 10 cli_vec_plain     6.49ms   6.66ms      149.  823.77KB    31.7 
#> 11 fansi_vec_plain 962.53µs      1ms      992.  845.98KB    17.6 
#> 12 base_vec_plain   102.6µs 106.55µs     9099.      848B     2.02
#> 13 cli_txt_ansi      3.21ms   3.25ms      306.    63.6KB     0   
#> 14 fansi_txt_ansi    1.58ms   1.61ms      620.   35.05KB     2.02
#> 15 base_txt_ansi   140.21µs 151.81µs     6541.   18.47KB     2.03
#> 16 cli_txt_plain     2.35ms   2.38ms      417.    63.6KB     0   
#> 17 fansi_txt_plain 521.88µs 561.39µs     1755.    30.6KB     2.02
#> 18 base_txt_plain   90.59µs  93.15µs    10589.   11.05KB     2.02
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
#>  1 cli_ansi        124.64µs 132.71µs     7423.   33.84KB    14.6 
#>  2 fansi_ansi       47.66µs   52.2µs    18793.   31.42KB    15.0 
#>  3 base_ansi         1.06µs   1.14µs   833087.     4.2KB     0   
#>  4 cli_plain       125.03µs 132.94µs     7406.        0B    14.6 
#>  5 fansi_plain      47.67µs  51.53µs    19071.      872B    14.6 
#>  6 base_plain      971.14ns   1.06µs   879829.        0B     0   
#>  7 cli_vec_ansi    249.31µs 258.38µs     3822.   16.73KB     8.28
#>  8 fansi_vec_ansi  112.67µs 117.36µs     8394.    5.59KB     6.16
#>  9 base_vec_ansi    36.27µs  36.59µs    26975.      848B     0   
#> 10 cli_vec_plain   211.24µs 220.18µs     4459.   16.73KB    10.5 
#> 11 fansi_vec_plain  102.7µs  107.8µs     9085.    5.59KB     6.17
#> 12 base_vec_plain   29.86µs  30.49µs    32310.      848B     3.23
#> 13 cli_txt_ansi    134.37µs 142.78µs     6890.        0B    12.5 
#> 14 fansi_txt_ansi   48.45µs  52.37µs    18715.      872B    14.7 
#> 15 base_txt_ansi     1.08µs   1.17µs   797639.        0B     0   
#> 16 cli_txt_plain   126.16µs 134.45µs     7318.        0B    14.6 
#> 17 fansi_txt_plain  48.08µs  51.86µs    18893.      872B    14.7 
#> 18 base_txt_plain  991.98ns   1.08µs   857018.        0B     0
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
#>  1 cli_ansi         333.7µs 355.59µs    2793.         0B    12.5 
#>  2 fansi_ansi       85.81µs  93.54µs   10395.    97.32KB    14.7 
#>  3 base_ansi        32.47µs  34.95µs   27989.         0B    11.2 
#>  4 cli_plain       219.71µs 234.03µs    4194.         0B    14.9 
#>  5 fansi_plain      85.31µs  92.54µs   10587.       872B    12.5 
#>  6 base_plain       25.97µs  27.81µs   34889.         0B    14.0 
#>  7 cli_vec_ansi      34.6ms  35.85ms      28.0    2.48KB    28.0 
#>  8 fansi_vec_ansi  228.22µs 235.48µs    4172.     7.25KB     6.14
#>  9 base_vec_ansi     2.15ms    2.2ms     452.    48.18KB    12.7 
#> 10 cli_vec_plain    22.42ms  22.66ms      43.6    2.48KB    21.8 
#> 11 fansi_vec_plain 182.93µs 188.64µs    5215.     6.42KB     8.34
#> 12 base_vec_plain    1.57ms   1.64ms     607.     47.4KB    12.7 
#> 13 cli_txt_ansi     23.56ms  23.71ms      42.1  507.59KB     7.02
#> 14 fansi_txt_ansi  224.16µs 234.61µs    4218.     6.77KB     4.06
#> 15 base_txt_ansi     1.27ms   1.31ms     755.   582.06KB    11.2 
#> 16 cli_txt_plain     1.25ms   1.29ms     765.   369.84KB     8.72
#> 17 fansi_txt_plain 173.09µs 181.69µs    5423.     2.51KB     8.30
#> 18 base_txt_plain   857.5µs 894.38µs    1109.   367.31KB    11.1
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
#>  1 cli_ansi          6.63µs   7.37µs   131266.   25.09KB    13.1 
#>  2 fansi_ansi       69.28µs  74.88µs    13020.   28.48KB    12.5 
#>  3 base_ansi        970.9ns   1.08µs   845486.        0B     0   
#>  4 cli_plain         6.59µs   7.33µs   130717.        0B    26.1 
#>  5 fansi_plain      68.77µs  74.56µs    13145.    1.98KB    12.7 
#>  6 base_plain       941.1ns   1.06µs   868323.        0B     0   
#>  7 cli_vec_ansi     26.62µs  27.78µs    35434.     1.7KB     3.54
#>  8 fansi_vec_ansi  104.51µs 110.76µs     8835.    8.86KB     8.37
#>  9 base_vec_ansi     6.05µs   6.34µs   153541.      848B    15.4 
#> 10 cli_vec_plain    23.27µs  24.35µs    40375.     1.7KB     4.04
#> 11 fansi_vec_plain  99.58µs 104.97µs     9350.    8.86KB     8.35
#> 12 base_vec_plain     5.7µs   5.92µs   164695.      848B     0   
#> 13 cli_txt_ansi      6.63µs   7.37µs   129843.        0B    26.0 
#> 14 fansi_txt_ansi   69.89µs  74.86µs    13085.    1.98KB    12.5 
#> 15 base_txt_ansi     5.56µs   5.69µs   171826.        0B     0   
#> 16 cli_txt_plain     7.52µs   8.28µs   117239.        0B    11.7 
#> 17 fansi_txt_plain  69.69µs  74.72µs    13113.    1.98KB    12.5 
#> 18 base_txt_plain    3.56µs   3.67µs   263168.        0B    26.3
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
#>  1 cli_ansi        86.38µs  92.55µs   10510.    11.88KB    10.4 
#>  2 base_ansi        1.24µs   1.33µs  703009.         0B    70.3 
#>  3 cli_plain       68.01µs  72.45µs   13364.     8.73KB     8.21
#>  4 base_plain     961.12ns   1.04µs  882947.         0B    88.3 
#>  5 cli_vec_ansi     3.99ms   4.21ms     237.   838.77KB    13.4 
#>  6 base_vec_ansi   71.27µs  71.73µs   13762.       848B     0   
#>  7 cli_vec_plain    2.22ms   2.32ms     431.    816.9KB    15.2 
#>  8 base_vec_plain  42.42µs  42.84µs   23037.       848B     2.30
#>  9 cli_txt_ansi    13.73ms  13.85ms      72.0  114.42KB     2.06
#> 10 base_txt_ansi   70.08µs  71.34µs   13845.         0B     0   
#> 11 cli_txt_plain  244.16µs  254.1µs    3868.    18.16KB     4.06
#> 12 base_txt_plain  40.37µs  40.95µs   24080.         0B     0
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
#>  1 cli_ansi         87.4µs   93.1µs    10501.        0B    15.0 
#>  2 base_ansi        15.5µs   16.3µs    60030.        0B    12.0 
#>  3 cli_plain        86.7µs   90.7µs    10783.        0B    16.7 
#>  4 base_plain       15.2µs   16.1µs    60861.        0B    12.2 
#>  5 cli_vec_ansi    177.5µs    186µs     5292.     7.2KB     8.25
#>  6 base_vec_ansi    53.7µs   59.6µs    16510.    1.66KB     2.01
#>  7 cli_vec_plain   162.2µs  171.7µs     5721.     7.2KB     8.34
#>  8 base_vec_plain   48.3µs   54.6µs    18258.    1.66KB     4.06
#>  9 cli_txt_ansi    155.5µs  160.9µs     6123.        0B     8.19
#> 10 base_txt_ansi    38.4µs   39.8µs    24745.        0B     4.95
#> 11 cli_txt_plain   137.8µs    144µs     6838.        0B    10.3 
#> 12 base_txt_plain   32.7µs   34.7µs    28352.        0B     5.67
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
#> 1 cli          7.68µs   8.36µs   116522.        0B    11.7 
#> 2 base       830.86ns 932.02ns   981522.        0B     0   
#> 3 cli_vec     23.55µs  24.58µs    40004.      448B     4.00
#> 4 base_vec    12.07µs  12.32µs    79600.      448B     0   
#> 5 cli_txt     23.44µs   24.3µs    40383.        0B     8.08
#> 6 base_txt    12.92µs   13.3µs    74550.        0B     0
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
#> 1 cli          7.65µs   8.38µs   116333.        0B    11.6 
#> 2 base         1.29µs   1.43µs   653935.        0B     0   
#> 3 cli_vec     31.07µs  32.19µs    30616.      448B     3.06
#> 4 base_vec    53.91µs  54.77µs    18050.      448B     2.01
#> 5 cli_txt     30.02µs  30.93µs    31863.        0B     3.19
#> 6 base_txt    88.93µs  89.73µs    11021.        0B     0
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
#> 1 cli          8.29µs    9.1µs   106842.        0B    10.7 
#> 2 base       830.97ns    932ns   989625.        0B    99.0 
#> 3 cli_vec     19.82µs   20.8µs    47223.      448B     4.72
#> 4 base_vec    12.02µs   12.3µs    80010.      448B     0   
#> 5 cli_txt     20.45µs   21.3µs    46239.        0B     9.25
#> 6 base_txt     12.9µs   13.3µs    74663.        0B     0
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
#> 1 cli          6.21µs    6.9µs   140334.    22.2KB    14.0 
#> 2 base       971.95ns   1.13µs   816922.        0B     0   
#> 3 cli_vec     31.18µs  32.24µs    30522.     1.7KB     6.11
#> 4 base_vec     8.67µs   9.05µs   108982.      848B     0   
#> 5 cli_txt      6.21µs    6.9µs   140406.        0B    14.0 
#> 6 base_txt     5.04µs   5.25µs   185535.        0B     0
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
#>  date     2026-04-10
#>  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.10.0     2026-01-26 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-04-09 [1] local
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
