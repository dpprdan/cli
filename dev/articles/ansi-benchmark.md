# ANSI function benchmarks

\$output function (x, options) { if (class == “output” && output_asis(x,
options)) return(x) hook.t(x, options\[\[paste0(“attr.”, class)\]\],
options\[\[paste0(“class.”, class)\]\]) } \<bytecode: 0x56218176d518\>
\<environment: 0x56218220e490\>

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
#> 1 ansi        29.98µs  34.34µs    28430.    99.6KB     28.5
#> 2 plain       29.96µs  34.25µs    28566.        0B     28.6
#> 3 base         8.53µs   9.94µs    97663.    48.6KB     29.3
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
#> 1 ansi        30.82µs   35.8µs    27301.        0B     32.8
#> 2 plain       32.11µs   36.2µs    26978.        0B     32.4
#> 3 base         9.95µs   11.6µs    83630.        0B     33.5
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
#> 1 ansi        74.31µs  81.92µs    11840.   76.15KB     23.7
#> 2 plain       56.51µs  63.09µs    15468.    8.73KB     23.5
#> 3 base         1.46µs   1.64µs   580994.        0B      0
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
#> 1 ansi          222µs    247µs     3987.   33.23KB     28.5
#> 2 plain         206µs    244µs     4056.    1.09KB     25.9
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
#>  1 cli_ansi          4.31µs   4.85µs   198066.    9.27KB     19.8
#>  2 fansi_ansi       21.39µs  23.85µs    40845.    4.18KB     20.4
#>  3 cli_plain         4.34µs   4.92µs   196647.        0B     19.7
#>  4 fansi_plain       21.4µs  23.94µs    40874.      688B     16.4
#>  5 cli_vec_ansi      5.36µs      6µs   161798.      448B     16.2
#>  6 fansi_vec_ansi   28.54µs  31.47µs    31030.    5.02KB     15.5
#>  7 cli_vec_plain     5.92µs   6.53µs   148674.      448B     14.9
#>  8 fansi_vec_plain  27.95µs  31.03µs    31487.    5.02KB     12.6
#>  9 cli_txt_ansi      4.29µs   4.92µs   196118.        0B     19.6
#> 10 fansi_txt_ansi   21.76µs  24.22µs    40374.      688B     16.2
#> 11 cli_txt_plain     5.05µs   5.62µs   172545.        0B     17.3
#> 12 fansi_txt_plain  27.82µs  31.07µs    31476.    5.02KB     15.7
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
#> 1 cli          44.1µs   45.9µs    21426.    22.7KB     6.43
#> 2 fansi        94.8µs   99.3µs     9906.    55.3KB     6.12
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
#>  1 cli_ansi          5.09µs   5.87µs   164830.        0B    16.5 
#>  2 fansi_ansi        56.8µs  62.51µs    15665.   38.84KB    12.4 
#>  3 base_ansi       711.07ns 781.15ns  1142672.        0B   114.  
#>  4 cli_plain         5.15µs   5.88µs   164380.        0B    16.4 
#>  5 fansi_plain      56.38µs  62.43µs    15680.      688B    12.4 
#>  6 base_plain       641.1ns 711.07ns  1242041.        0B     0   
#>  7 cli_vec_ansi     21.58µs  23.25µs    42407.      448B     4.24
#>  8 fansi_vec_ansi   73.08µs  79.83µs    12238.    5.02KB    12.6 
#>  9 base_vec_ansi    14.73µs  14.89µs    66275.      448B     0   
#> 10 cli_vec_plain     19.8µs  20.81µs    46984.      448B     4.70
#> 11 fansi_vec_plain  65.17µs  70.78µs    13835.    5.02KB    12.5 
#> 12 base_vec_plain    8.49µs    8.6µs   114132.      448B     0   
#> 13 cli_txt_ansi     21.84µs  22.73µs    43370.        0B     4.34
#> 14 fansi_txt_ansi   66.61µs  72.87µs    13462.      688B    10.3 
#> 15 base_txt_ansi    14.66µs  14.77µs    66712.        0B     6.67
#> 16 cli_txt_plain    19.58µs  20.56µs    47833.        0B     4.78
#> 17 fansi_txt_plain  59.06µs  64.28µs    15225.      688B    12.4 
#> 18 base_txt_plain    8.49µs   8.57µs   114593.        0B     0
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
#>  1 cli_ansi           6.2µs   7.04µs   137369.        0B    27.5 
#>  2 fansi_ansi        57.3µs  62.81µs    15605.      688B    12.4 
#>  3 base_ansi        932.1ns   1.02µs   894207.        0B     0   
#>  4 cli_plain          6.2µs   7.02µs   138098.        0B    27.6 
#>  5 fansi_plain       56.5µs  62.48µs    15688.      688B    12.4 
#>  6 base_plain         781ns 862.05ns  1035179.        0B   104.  
#>  7 cli_vec_ansi      26.4µs   27.6µs    35738.      448B     3.57
#>  8 fansi_vec_ansi    75.9µs  81.71µs    11995.    5.02KB    10.5 
#>  9 base_vec_ansi     32.3µs  32.51µs    30383.      448B     0   
#> 10 cli_vec_plain     24.9µs  26.03µs    37848.      448B     3.79
#> 11 fansi_vec_plain   67.9µs  73.73µs    13255.    5.02KB    12.6 
#> 12 base_vec_plain    16.9µs  17.22µs    57267.      448B     0   
#> 13 cli_txt_ansi      26.8µs  27.82µs    35441.        0B     3.54
#> 14 fansi_txt_ansi    68.6µs  74.94µs    13081.      688B    12.4 
#> 15 base_txt_ansi       34µs  34.23µs    28872.        0B     0   
#> 16 cli_txt_plain     24.9µs  25.97µs    37927.        0B     3.79
#> 17 fansi_txt_plain   60.5µs  66.43µs    14757.      688B    12.4 
#> 18 base_txt_plain      18µs  18.26µs    54172.        0B     5.42
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
#> 1 cli_ansi        5.01µs   5.49µs   177810.        0B    17.8 
#> 2 cli_plain       4.75µs   5.26µs   181876.        0B    18.2 
#> 3 cli_vec_ansi   24.03µs  24.87µs    39715.      848B     3.97
#> 4 cli_vec_plain   7.89µs   8.47µs   116094.      848B     0   
#> 5 cli_txt_ansi   23.25µs  24.31µs    40634.        0B     4.06
#> 6 cli_txt_plain   5.49µs      6µs   162760.        0B    16.3
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
#>  1 cli_ansi            19µs   20.4µs    47807.        0B    23.9 
#>  2 fansi_ansi        20.2µs   21.8µs    44842.    7.24KB    17.9 
#>  3 cli_plain         18.8µs   20.2µs    48314.        0B    19.3 
#>  4 fansi_plain       19.7µs   21.8µs    44776.      688B    17.9 
#>  5 cli_vec_ansi      26.4µs     29µs    33879.      848B    16.9 
#>  6 fansi_vec_ansi    40.2µs   42.8µs    22969.    5.41KB     9.19
#>  7 cli_vec_plain       21µs     23µs    42481.      848B    17.0 
#>  8 fansi_vec_plain   27.3µs   29.8µs    32884.    4.59KB    13.2 
#>  9 cli_txt_ansi      26.2µs   28.2µs    34738.        0B    17.4 
#> 10 fansi_txt_ansi    33.1µs   35.3µs    27727.    5.12KB    11.1 
#> 11 cli_txt_plain     19.5µs   21.4µs    45591.        0B    18.2 
#> 12 fansi_txt_plain     21µs     23µs    42407.      688B    17.0
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
#>  1 cli_ansi        104.66µs 112.91µs     8658.  104.86KB    17.0 
#>  2 fansi_ansi       85.26µs  93.84µs    10506.  106.35KB    14.7 
#>  3 base_ansi         3.17µs   3.55µs   275095.      224B     0   
#>  4 cli_plain       103.37µs  111.9µs     8760.    8.09KB    16.8 
#>  5 fansi_plain      84.47µs  93.25µs    10580.    9.62KB    14.7 
#>  6 base_plain        2.78µs   3.17µs   305963.        0B    30.6 
#>  7 cli_vec_ansi      5.18ms   5.37ms      186.  823.77KB    18.4 
#>  8 fansi_vec_ansi  788.05µs 850.15µs     1149.  846.81KB    22.5 
#>  9 base_vec_ansi   121.61µs 127.54µs     7631.    22.7KB     4.14
#> 10 cli_vec_plain     5.11ms   5.38ms      185.  823.77KB    18.7 
#> 11 fansi_vec_plain 772.84µs 811.43µs     1204.  845.98KB    24.7 
#> 12 base_vec_plain   81.84µs  86.39µs    11357.      848B     4.06
#> 13 cli_txt_ansi      2.52ms   2.56ms      387.    63.6KB     0   
#> 14 fansi_txt_ansi    1.24ms   1.27ms      781.   35.05KB     2.02
#> 15 base_txt_ansi   110.54µs  118.3µs     8433.   18.47KB     2.02
#> 16 cli_txt_plain     1.83ms   1.86ms      536.    63.6KB     2.02
#> 17 fansi_txt_plain  408.2µs 422.02µs     2360.    30.6KB     2.02
#> 18 base_txt_plain   71.72µs  74.25µs    13187.   11.05KB     2.02
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
#>  1 cli_ansi          98.5µs  103.7µs     9442.   33.84KB    18.9 
#>  2 fansi_ansi        37.1µs   41.1µs    23898.   31.42KB    16.7 
#>  3 base_ansi        811.1ns  882.1ns  1022483.     4.2KB     0   
#>  4 cli_plain         99.5µs    107µs     9219.        0B    18.9 
#>  5 fansi_plain       37.1µs   41.9µs    23534.      872B    16.5 
#>  6 base_plain         741ns    822ns  1096079.        0B     0   
#>  7 cli_vec_ansi     195.3µs  204.5µs     4832.   16.73KB    10.4 
#>  8 fansi_vec_ansi    87.7µs   92.4µs    10681.    5.59KB     8.29
#>  9 base_vec_ansi     28.3µs   28.6µs    34605.      848B     0   
#> 10 cli_vec_plain    165.6µs    174µs     5668.   16.73KB    12.6 
#> 11 fansi_vec_plain   81.8µs   86.4µs    11422.    5.59KB     8.29
#> 12 base_vec_plain    23.6µs   23.8µs    41481.      848B     0   
#> 13 cli_txt_ansi       106µs    115µs     8581.        0B    16.9 
#> 14 fansi_txt_ansi    37.9µs   42.2µs    23335.      872B    18.7 
#> 15 base_txt_ansi      842ns  912.1ns  1029916.        0B     0   
#> 16 cli_txt_plain    100.7µs  109.1µs     9047.        0B    16.7 
#> 17 fansi_txt_plain   37.8µs   41.9µs    23430.      872B    18.8 
#> 18 base_txt_plain   762.1ns  841.1ns  1109745.        0B     0
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
#>  1 cli_ansi        263.62µs 284.52µs    3466.         0B    16.8 
#>  2 fansi_ansi       65.99µs  74.57µs   13152.    97.33KB    14.9 
#>  3 base_ansi        25.47µs  27.89µs   35025.         0B    17.5 
#>  4 cli_plain        173.4µs 185.67µs    5305.         0B    16.7 
#>  5 fansi_plain      66.23µs  73.47µs   13434.       872B    15.2 
#>  6 base_plain       20.36µs  21.76µs   44953.         0B    18.0 
#>  7 cli_vec_ansi     27.39ms   27.6ms      36.1    2.48KB    28.9 
#>  8 fansi_vec_ansi  181.01µs 186.76µs    5286.     7.25KB     8.25
#>  9 base_vec_ansi     1.71ms    1.8ms     556.    48.18KB    17.6 
#> 10 cli_vec_plain    18.35ms  18.59ms      53.8    2.48KB    23.9 
#> 11 fansi_vec_plain 145.51µs 153.66µs    6427.     6.42KB     8.26
#> 12 base_vec_plain    1.27ms   1.33ms     750.     47.4KB    17.3 
#> 13 cli_txt_ansi     20.12ms  20.24ms      49.3  507.59KB     6.72
#> 14 fansi_txt_ansi  175.86µs 184.72µs    5351.     6.77KB     6.12
#> 15 base_txt_ansi     1.02ms   1.05ms     930.   582.06KB    13.9 
#> 16 cli_txt_plain        1ms   1.04ms     943.   369.84KB    11.1 
#> 17 fansi_txt_plain  135.4µs 143.59µs    6862.     2.51KB     8.36
#> 18 base_txt_plain  684.19µs 722.43µs    1363.   367.31KB    13.6
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
#>  1 cli_ansi          5.15µs   5.97µs   161032.   25.09KB    16.1 
#>  2 fansi_ansi       55.81µs  61.87µs    15863.   28.48KB    14.7 
#>  3 base_ansi       791.16ns 891.04ns  1004604.        0B     0   
#>  4 cli_plain         5.03µs   5.88µs   161364.        0B    32.3 
#>  5 fansi_plain      55.37µs  61.13µs    16040.    1.98KB    14.7 
#>  6 base_plain      761.12ns 862.05ns  1029812.        0B     0   
#>  7 cli_vec_ansi     20.55µs  21.81µs    45074.     1.7KB     4.51
#>  8 fansi_vec_ansi   84.19µs  90.35µs    10845.    8.86KB    10.6 
#>  9 base_vec_ansi      4.8µs   5.29µs   183018.      848B    18.3 
#> 10 cli_vec_plain    17.87µs  19.04µs    51632.     1.7KB     5.16
#> 11 fansi_vec_plain  79.09µs  85.67µs    11453.    8.86KB    10.5 
#> 12 base_vec_plain    4.51µs   4.95µs   199702.      848B     0   
#> 13 cli_txt_ansi      5.11µs   5.97µs   161271.        0B    16.1 
#> 14 fansi_txt_ansi   55.77µs  61.85µs    15825.    1.98KB    17.0 
#> 15 base_txt_ansi     5.49µs    5.6µs   173955.        0B     0   
#> 16 cli_txt_plain      5.8µs   6.59µs   146488.        0B    14.7 
#> 17 fansi_txt_plain  55.74µs  61.73µs    15869.    1.98KB    14.7 
#> 18 base_txt_plain    3.42µs   3.52µs   274856.        0B     0
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
#>  1 cli_ansi        68.77µs  74.43µs   13082.    11.88KB    14.1 
#>  2 base_ansi      982.08ns   1.06µs  903573.         0B     0   
#>  3 cli_plain       53.66µs  57.31µs   17032.     8.73KB    12.4 
#>  4 base_plain     781.03ns  841.1ns 1149093.         0B     0   
#>  5 cli_vec_ansi     3.21ms   3.28ms     304.   838.77KB    17.7 
#>  6 base_vec_ansi   54.64µs  55.73µs   17770.       848B     0   
#>  7 cli_vec_plain    1.79ms   1.87ms     533.    816.9KB    20.0 
#>  8 base_vec_plain  32.47µs   33.5µs   29677.       848B     0   
#>  9 cli_txt_ansi    11.94ms  12.04ms      83.0  114.42KB     4.25
#> 10 base_txt_ansi   54.26µs  55.34µs   17854.         0B     0   
#> 11 cli_txt_plain  203.69µs 212.07µs    4654.    18.16KB     2.01
#> 12 base_txt_plain  31.28µs  31.81µs   31112.         0B     0
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
#>  1 cli_ansi           71µs     77µs    12694.        0B    16.7 
#>  2 base_ansi        12.3µs   13.7µs    71119.        0B    14.2 
#>  3 cli_plain        70.9µs   76.6µs    12741.        0B    18.9 
#>  4 base_plain       12.3µs   13.6µs    71291.        0B    14.3 
#>  5 cli_vec_ansi    151.5µs  160.2µs     6141.     7.2KB     8.24
#>  6 base_vec_ansi    43.9µs   49.9µs    19761.    1.66KB     4.06
#>  7 cli_vec_plain   140.2µs  148.7µs     6595.     7.2KB    10.4 
#>  8 base_vec_plain   38.6µs   44.3µs    22279.    1.66KB     4.46
#>  9 cli_txt_ansi    131.6µs  138.9µs     7077.        0B     8.28
#> 10 base_txt_ansi      32µs     41µs    26090.        0B     5.22
#> 11 cli_txt_plain   119.4µs  125.4µs     7828.        0B    12.4 
#> 12 base_txt_plain   26.9µs   28.5µs    34488.        0B     6.90
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
#> 1 cli          6.01µs   6.87µs   140144.        0B    14.0 
#> 2 base       661.01ns  741.1ns  1191880.        0B     0   
#> 3 cli_vec     18.17µs  19.28µs    50822.      448B    10.2 
#> 4 base_vec     9.46µs   9.76µs   100976.      448B     0   
#> 5 cli_txt     18.22µs  19.15µs    51255.        0B     5.13
#> 6 base_txt    10.65µs  11.12µs    89240.        0B     0
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
#> 1 cli          5.96µs   6.86µs   140639.        0B    14.1 
#> 2 base         1.02µs   1.11µs   812551.        0B    81.3 
#> 3 cli_vec     22.98µs  24.25µs    40573.      448B     4.06
#> 4 base_vec    41.84µs   42.4µs    23216.      448B     0   
#> 5 cli_txt     23.16µs  24.32µs    40513.        0B     4.05
#> 6 base_txt    78.97µs   79.9µs    12398.        0B     0
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
#> 1 cli           6.4µs   7.36µs   130175.        0B    26.0 
#> 2 base       671.02ns  741.1ns  1208398.        0B     0   
#> 3 cli_vec     15.54µs  16.68µs    58753.      448B     5.88
#> 4 base_vec     9.47µs   9.74µs   101119.      448B     0   
#> 5 cli_txt     16.61µs   17.8µs    54898.        0B    11.0 
#> 6 base_txt    10.64µs  11.11µs    89348.        0B     0
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
#> 1 cli          4.85µs   5.68µs   168612.    22.2KB    16.9 
#> 2 base       811.07ns 901.05ns   950176.        0B    95.0 
#> 3 cli_vec     23.84µs  25.06µs    39270.     1.7KB     3.93
#> 4 base_vec     6.66µs   6.81µs   144056.      848B     0   
#> 5 cli_txt      4.77µs   5.61µs   171202.        0B    17.1 
#> 6 base_txt     4.35µs   4.85µs   203875.        0B     0
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
#>  date     2026-05-20
#>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
#>  quarto   NA
#> 
#> ─ Packages ──────────────────────────────────────────────────────────
#>  package     * version    date (UTC) lib source
#>  bench         1.1.4      2025-01-16 [1] RSPM
#>  bslib         0.11.0     2026-05-16 [1] RSPM
#>  cachem        1.1.0      2024-05-16 [1] RSPM
#>  cli         * 3.6.6.9000 2026-05-20 [1] local
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
