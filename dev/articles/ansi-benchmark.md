# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x55ac37e4eb98\>
\<environment: 0x55ac388efb10\>

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
#> 1 ansi           45µs   48.3µs    19988.    99.6KB     20.9
#> 2 plain        44.9µs   48.8µs    19874.        0B     21.8
#> 3 base         11.3µs   12.5µs    76990.    48.6KB     23.1
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
#> 1 ansi         48.4µs   52.5µs    18191.        0B     21.6
#> 2 plain        48.3µs   52.2µs    18501.        0B     21.3
#> 3 base         13.3µs   14.6µs    65995.        0B     26.4
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
#> 1 ansi       112.19µs  119.3µs     8111.   76.15KB     16.8
#> 2 plain       89.12µs  94.06µs    10259.    8.73KB     14.6
#> 3 base         1.87µs   1.99µs   483544.        0B      0
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
#> 1 ansi          347µs    376µs     2573.   33.23KB     19.2
#> 2 plain         340µs    368µs     2679.    1.09KB     19.1
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
#>  1 cli_ansi          5.75µs   6.34µs   151806.    9.27KB    30.4 
#>  2 fansi_ansi        31.2µs  34.49µs    28056.    4.18KB    25.3 
#>  3 cli_plain         5.74µs   6.26µs   154113.        0B    30.8 
#>  4 fansi_plain       30.6µs  33.31µs    28392.      688B    14.2 
#>  5 cli_vec_ansi      7.15µs   7.61µs   126359.      448B    12.6 
#>  6 fansi_vec_ansi   40.87µs  43.64µs    22015.    5.02KB     8.81
#>  7 cli_vec_plain     7.78µs   8.25µs   117319.      448B    11.7 
#>  8 fansi_vec_plain  38.64µs  41.11µs    23462.    5.02KB    11.7 
#>  9 cli_txt_ansi      5.71µs   6.11µs   158377.        0B    15.8 
#> 10 fansi_txt_ansi   31.05µs  33.31µs    29049.      688B    11.6 
#> 11 cli_txt_plain     6.56µs   6.98µs   139205.        0B    13.9 
#> 12 fansi_txt_plain  38.64µs   41.5µs    23334.    5.02KB     9.34
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
#> 1 cli          57.5µs   59.4µs    16414.    22.7KB     4.05
#> 2 fansi       118.9µs  127.1µs     7780.    55.3KB     4.05
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
#>  1 cli_ansi          7.02µs   7.62µs   126126.        0B    12.6 
#>  2 fansi_ansi       91.81µs  97.22µs     9900.   38.84KB    10.3 
#>  3 base_ansi        902.1ns 952.16ns   974608.        0B     0   
#>  4 cli_plain         6.92µs   7.59µs   127259.        0B    12.7 
#>  5 fansi_plain      91.76µs  97.09µs     9974.      688B     8.19
#>  6 base_plain      821.08ns 872.07ns  1054852.        0B     0   
#>  7 cli_vec_ansi     29.55µs  30.33µs    32238.      448B     3.22
#>  8 fansi_vec_ansi  112.84µs 118.61µs     8097.    5.02KB     8.25
#>  9 base_vec_ansi    17.21µs  17.32µs    56847.      448B     0   
#> 10 cli_vec_plain    27.68µs  28.49µs    34320.      448B     3.43
#> 11 fansi_vec_plain 102.74µs  108.9µs     8893.    5.02KB     8.25
#> 12 base_vec_plain   10.12µs  10.23µs    95984.      448B     0   
#> 13 cli_txt_ansi     28.96µs   29.7µs    32953.        0B     3.30
#> 14 fansi_txt_ansi  104.74µs 110.47µs     8757.      688B     8.21
#> 15 base_txt_ansi    16.88µs  16.95µs    58160.        0B     0   
#> 16 cli_txt_plain    27.31µs     28µs    34906.        0B     3.49
#> 17 fansi_txt_plain  94.05µs  99.61µs     9723.      688B     8.20
#> 18 base_txt_plain    9.86µs  10.38µs    96267.        0B     0
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
#>  1 cli_ansi          8.52µs   9.33µs   103278.        0B    10.3 
#>  2 fansi_ansi       92.75µs  98.38µs     9829.      688B    10.4 
#>  3 base_ansi         1.23µs   1.29µs   736284.        0B     0   
#>  4 cli_plain         8.51µs   9.24µs   104948.        0B    10.5 
#>  5 fansi_plain       91.8µs  97.66µs     9834.      688B     8.18
#>  6 base_plain        1.01µs   1.07µs   853283.        0B     0   
#>  7 cli_vec_ansi     34.62µs  35.54µs    27529.      448B     5.51
#>  8 fansi_vec_ansi  116.05µs 122.33µs     7863.    5.02KB     6.15
#>  9 base_vec_ansi    41.01µs  41.35µs    23850.      448B     0   
#> 10 cli_vec_plain    32.96µs  33.95µs    28797.      448B     2.88
#> 11 fansi_vec_plain 106.01µs 110.83µs     8726.    5.02KB     8.24
#> 12 base_vec_plain   21.67µs  22.03µs    44741.      448B     0   
#> 13 cli_txt_ansi     34.36µs   35.2µs    27743.        0B     5.55
#> 14 fansi_txt_ansi  107.42µs 112.82µs     8578.      688B     6.11
#> 15 base_txt_ansi    43.19µs  44.16µs    22369.        0B     0   
#> 16 cli_txt_plain     32.5µs  33.39µs    29286.        0B     5.86
#> 17 fansi_txt_plain  97.62µs 102.83µs     9396.      688B     8.20
#> 18 base_txt_plain   23.57µs  23.86µs    41337.        0B     0
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
#> 1 cli_ansi        7.01µs   7.61µs   126805.        0B    12.7 
#> 2 cli_plain       6.55µs   7.08µs   136068.        0B    13.6 
#> 3 cli_vec_ansi   32.13µs  33.23µs    29352.      848B     2.94
#> 4 cli_vec_plain  10.46µs  11.18µs    87008.      848B     8.70
#> 5 cli_txt_ansi   31.09µs  32.16µs    30165.        0B     3.02
#> 6 cli_txt_plain   7.41µs   8.08µs   119877.        0B    12.0
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
#>  1 cli_ansi          25.9µs   27.8µs    34607.        0B    13.8 
#>  2 fansi_ansi          29µs   31.4µs    30705.    7.24KB    12.3 
#>  3 cli_plain         25.1µs   27.2µs    35586.        0B    17.8 
#>  4 fansi_plain       28.7µs   30.8µs    31300.      688B    12.5 
#>  5 cli_vec_ansi      35.1µs   37.1µs    26155.      848B    10.5 
#>  6 fansi_vec_ansi    55.2µs   58.4µs    16649.    5.41KB     6.17
#>  7 cli_vec_plain     28.3µs   30.2µs    32047.      848B    16.0 
#>  8 fansi_vec_plain   37.5µs   39.8µs    24388.    4.59KB     9.76
#>  9 cli_txt_ansi      34.6µs   35.9µs    27049.        0B    10.8 
#> 10 fansi_txt_ansi    44.8µs   46.6µs    20830.    5.12KB     8.34
#> 11 cli_txt_plain     26.7µs   28.2µs    33135.        0B    16.6 
#> 12 fansi_txt_plain   29.7µs   31.7µs    30458.      688B    12.2
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
#>  1 cli_ansi        165.61µs 173.58µs     5570.  104.86KB    10.3 
#>  2 fansi_ansi      131.43µs 139.69µs     6950.  106.35KB    10.4 
#>  3 base_ansi         4.15µs    4.5µs   215182.      224B     0   
#>  4 cli_plain       164.09µs 172.73µs     5615.    8.09KB    10.3 
#>  5 fansi_plain     129.27µs 137.77µs     7068.    9.62KB    10.3 
#>  6 base_plain        3.66µs   3.93µs   247246.        0B     0   
#>  7 cli_vec_ansi      7.74ms   7.83ms      127.  823.77KB    13.6 
#>  8 fansi_vec_ansi    1.06ms   1.08ms      904.  846.81KB    17.2 
#>  9 base_vec_ansi   156.55µs  161.2µs     6061.    22.7KB     2.03
#> 10 cli_vec_plain     7.66ms   7.87ms      126.  823.77KB    11.5 
#> 11 fansi_vec_plain 990.06µs   1.02ms      972.  845.98KB    19.5 
#> 12 base_vec_plain  107.04µs 113.52µs     8725.      848B     2.02
#> 13 cli_txt_ansi       3.4ms   3.44ms      290.    63.6KB     2.01
#> 14 fansi_txt_ansi    1.57ms   1.59ms      626.   35.05KB     0   
#> 15 base_txt_ansi   138.56µs 147.13µs     6729.   18.47KB     2.02
#> 16 cli_txt_plain     2.44ms   2.49ms      401.    63.6KB     2.02
#> 17 fansi_txt_plain 515.71µs 535.66µs     1861.    30.6KB     2.02
#> 18 base_txt_plain   89.21µs  91.55µs    10751.   11.05KB     2.02
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
#>  1 cli_ansi        150.36µs 156.68µs     6203.   33.84KB    12.4 
#>  2 fansi_ansi        54.7µs   59.2µs    16284.   31.42KB    12.4 
#>  3 base_ansi         1.06µs   1.11µs   864771.     4.2KB     0   
#>  4 cli_plain        148.8µs 156.01µs     6190.        0B    12.4 
#>  5 fansi_plain      55.33µs   59.3µs    16318.      872B    10.3 
#>  6 base_plain      991.98ns   1.05µs   876379.        0B    87.6 
#>  7 cli_vec_ansi    275.88µs 286.92µs     3417.   16.73KB     6.29
#>  8 fansi_vec_ansi  116.55µs 121.43µs     8024.    5.59KB     6.16
#>  9 base_vec_ansi    35.52µs  35.87µs    27492.      848B     0   
#> 10 cli_vec_plain   233.66µs 242.71µs     4019.   16.73KB     8.28
#> 11 fansi_vec_plain 109.89µs 114.02µs     8535.    5.59KB     6.16
#> 12 base_vec_plain   30.05µs  30.77µs    32063.      848B     0   
#> 13 cli_txt_ansi    158.72µs 166.46µs     5809.        0B    12.5 
#> 14 fansi_txt_ansi   54.72µs  59.16µs    16199.      872B    12.1 
#> 15 base_txt_ansi     1.09µs   1.14µs   838121.        0B     0   
#> 16 cli_txt_plain    148.2µs 154.21µs     6296.        0B    12.4 
#> 17 fansi_txt_plain  54.15µs   56.7µs    17060.      872B    12.4 
#> 18 base_txt_plain    1.01µs   1.05µs   907201.        0B     0
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
#>  1 cli_ansi        403.76µs 429.12µs    2318.         0B    10.3 
#>  2 fansi_ansi       99.76µs  106.9µs    9093.    97.33KB    12.6 
#>  3 base_ansi        39.65µs  42.08µs   22902.         0B     9.16
#>  4 cli_plain       277.15µs 290.78µs    3357.         0B    10.3 
#>  5 fansi_plain      98.81µs 106.05µs    9154.       872B    12.4 
#>  6 base_plain       31.85µs  33.79µs   28493.         0B     8.55
#>  7 cli_vec_ansi     42.77ms  43.36ms      23.1    2.48KB    23.1 
#>  8 fansi_vec_ansi  239.26µs 249.46µs    3920.     7.25KB     6.13
#>  9 base_vec_ansi     2.29ms   2.36ms     422.    48.18KB    12.8 
#> 10 cli_vec_plain    29.24ms  29.58ms      33.7    2.48KB    14.0 
#> 11 fansi_vec_plain 193.32µs  201.8µs    4837.     6.42KB     8.23
#> 12 base_vec_plain    1.66ms   1.72ms     581.     47.4KB    10.5 
#> 13 cli_txt_ansi     25.17ms  25.51ms      39.1  507.59KB     6.91
#> 14 fansi_txt_ansi  228.49µs 237.97µs    4127.     6.77KB     6.12
#> 15 base_txt_ansi     1.27ms   1.29ms     765.   582.06KB     8.70
#> 16 cli_txt_plain     1.28ms   1.32ms     740.   369.84KB     8.70
#> 17 fansi_txt_plain 181.74µs  189.7µs    5137.     2.51KB     8.29
#> 18 base_txt_plain  857.11µs  892.7µs    1107.   367.31KB     8.65
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
#>  1 cli_ansi          6.75µs    7.5µs   122019.   25.09KB    12.2 
#>  2 fansi_ansi       81.29µs  86.46µs    10906.   28.48KB    10.3 
#>  3 base_ansi         1.05µs   1.12µs   826146.        0B     0   
#>  4 cli_plain          6.6µs   7.38µs   127376.        0B    12.7 
#>  5 fansi_plain      79.44µs  85.11µs    11121.    1.98KB    12.2 
#>  6 base_plain        1.02µs   1.08µs   794320.        0B     0   
#>  7 cli_vec_ansi      27.4µs  28.34µs    33713.     1.7KB     3.37
#>  8 fansi_vec_ansi  117.38µs 121.72µs     7792.    8.86KB     8.32
#>  9 base_vec_ansi     6.06µs   6.35µs   149036.      848B     0   
#> 10 cli_vec_plain    23.27µs  24.45µs    39478.     1.7KB     3.95
#> 11 fansi_vec_plain 111.49µs 116.05µs     8112.    8.86KB     8.33
#> 12 base_vec_plain    5.81µs      6µs   163769.      848B     0   
#> 13 cli_txt_ansi      6.68µs   7.24µs   130888.        0B    13.1 
#> 14 fansi_txt_ansi   79.46µs  83.32µs    11305.    1.98KB    10.3 
#> 15 base_txt_ansi     6.47µs   6.54µs   149599.        0B    15.0 
#> 16 cli_txt_plain      7.5µs   8.12µs   116519.        0B    11.7 
#> 17 fansi_txt_plain  79.19µs  85.38µs    11205.    1.98KB    10.4 
#> 18 base_txt_plain    4.12µs   4.18µs   231753.        0B     0
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
#>  1 cli_ansi       106.58µs 111.23µs    8657.    11.88KB     8.19
#>  2 base_ansi        1.32µs   1.37µs  700031.         0B     0   
#>  3 cli_plain       84.74µs  88.53µs   10896.     8.73KB     8.20
#>  4 base_plain       1.03µs   1.07µs  891208.         0B     0   
#>  5 cli_vec_ansi     4.19ms    4.3ms     233.   838.77KB    15.4 
#>  6 base_vec_ansi    71.9µs  72.25µs   13685.       848B     0   
#>  7 cli_vec_plain    2.32ms    2.4ms     416.    816.9KB    12.9 
#>  8 base_vec_plain  42.98µs  43.31µs   22819.       848B     0   
#>  9 cli_txt_ansi    14.39ms  14.46ms      69.1  114.42KB     4.19
#> 10 base_txt_ansi    73.7µs  73.95µs   13347.         0B     0   
#> 11 cli_txt_plain  271.81µs 280.42µs    3482.    18.16KB     2.01
#> 12 base_txt_plain  41.07µs  41.99µs   23254.         0B     0
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
#>  1 cli_ansi        109.1µs  115.1µs     8393.        0B    10.3 
#>  2 base_ansi        16.9µs   17.9µs    53992.        0B    16.2 
#>  3 cli_plain       109.4µs    115µs     8411.        0B    10.4 
#>  4 base_plain       16.7µs   17.8µs    54445.        0B    10.9 
#>  5 cli_vec_ansi    204.5µs  216.5µs     4513.     7.2KB     6.12
#>  6 base_vec_ansi    59.1µs   65.3µs    15076.    1.66KB     4.06
#>  7 cli_vec_plain   189.7µs  204.2µs     4651.     7.2KB     6.13
#>  8 base_vec_plain     52µs     58µs    17086.    1.66KB     4.06
#>  9 cli_txt_ansi    182.1µs  188.7µs     5164.        0B     6.10
#> 10 base_txt_ansi    40.9µs   42.1µs    23124.        0B     6.94
#> 11 cli_txt_plain   164.8µs  171.7µs     5664.        0B     6.10
#> 12 base_txt_plain   35.3µs   36.6µs    26478.        0B     7.95
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
#> 1 cli           8.3µs   8.97µs   107701.        0B    10.8 
#> 2 base          871ns 922.01ns  1001407.        0B     0   
#> 3 cli_vec      23.9µs  24.69µs    39601.      448B     3.96
#> 4 base_vec     11.6µs  11.87µs    82836.      448B     0   
#> 5 cli_txt        24µs  24.76µs    39441.        0B     7.89
#> 6 base_txt     12.6µs   12.7µs    76063.        0B     0
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
#> 1 cli          8.24µs   8.92µs   108187.        0B    10.8 
#> 2 base         1.29µs   1.35µs   690990.        0B     0   
#> 3 cli_vec     29.74µs  30.59µs    31985.      448B     3.20
#> 4 base_vec    50.67µs  51.15µs    19309.      448B     2.01
#> 5 cli_txt     29.67µs  30.45µs    32115.        0B     3.21
#> 6 base_txt    86.67µs  87.57µs    11286.        0B     0
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
#> 1 cli          8.96µs   9.71µs    99508.        0B     9.95
#> 2 base       872.07ns 922.13ns   983635.        0B    98.4 
#> 3 cli_vec     19.78µs  20.71µs    46998.      448B     4.70
#> 4 base_vec    11.64µs  11.91µs    80735.      448B     0   
#> 5 cli_txt     20.66µs  21.42µs    45395.        0B     4.54
#> 6 base_txt    12.61µs  12.73µs    76968.        0B     7.70
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
#> 1 cli          6.44µs    7.1µs   134132.    22.2KB    13.4 
#> 2 base         1.05µs   1.14µs   688564.        0B     0   
#> 3 cli_vec     30.76µs  31.59µs    30266.     1.7KB     3.03
#> 4 base_vec     8.37µs    8.7µs   112688.      848B    11.3 
#> 5 cli_txt      6.37µs   6.99µs   138423.        0B    13.8 
#> 6 base_txt     5.71µs   5.78µs   167764.        0B     0
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
#>  date     2026-05-21
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.11.0     2026-05-16 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-05-21 [1] local
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
