
<!-- README.md is generated from README.Rmd. Please edit that file -->

# oras

An R wrapper to the [oras](https://oras.land) cli.

## Quickstart

``` r
install_github("cboettig/oras")
```

``` r
library(oras)
```

``` r
oras_login()
#> Login Succeeded
```

``` r
oras_push("ghcr.io/cboettig/content-store/mtcars:v1", "mtcars.csv")
#> Exists    450a97ba6b43 mtcars.csv
#> Pushed [registry] ghcr.io/cboettig/content-store/mtcars:v1
#> Digest: sha256:4eb5d65df41d383b21a185bdffb0c49a767159f4b9a6ad9454f7b4339917e76d
```
