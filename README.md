
<!-- README.md is generated from README.Rmd. Please edit that file -->

# oras

`oras` provides a robust way to read and write data objects to cloud
storage systems container registries. This can be an highly effective
and provider-agnostic (“multi-cloud”) mechanism to distribute reasonably
version stable, content-addressed large data files publicly and at
scale. This approach also supports convenient private distribution
(though the quotas available from the free-tier of most major providers
are much less generous for private files). This package merely provides
an R wrapper to the [oras](https://oras.land) command line interface
tool, see original documentation for details or skip to the
[Quickstart](#Quickstart) to get started from R.

## Background & Motivation

Container registries were initial introduced to support the distribution
of [Docker images](https://docker.com), which use a layered,
content-addressed storage system. The [Open Container
Initiative](https://opencontainers.org/) later defined an [open standard
specification](https://github.com/opencontainers/image-spec/blob/main/spec.md)
for container registries, leading to a proliferation of open source
standard implementations ([zot](https://zotregistry.io/),
[GitLab](https://docs.gitlab.com/ee/user/packages/container_registry/),
and [Harbor](https://goharbor.io/)) that can be self-hosted, while most
major cloud providers including [Google Artifact
Registry](https://cloud.google.com/artifact-registry), [Amazon’s Elastic
Container
Registry](https://aws.amazon.com/blogs/containers/oci-artifact-support-in-amazon-ecr/),
and Microsoft’s [Azure Artifact
Registry](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-oci-artifacts)
offer container registries as a service. (The increasing adoption of the
more general term “Artifact” registry reflects the growing recognition
that these platforms are incredibly useful for arbitrary digital assets
and are by no means limited to Docker containers).

Of particular interest due to it’s generous public data storage quotas
and familiarity to many programmers is the [GitHub Container Registry
(GHCR)](https://ghcr.io), now called “GitHub Packages,” which we’ll use
as the focal point of examples here. But it is worth bearing in mind
that the software involved under the hood is not GitHub-specific, and
could just as easily work against a self-hosted system like
[zot](https://zotregistry.io/) or the major cloud provider registries.

## Quickstart

``` r
install_github("cboettig/oras")
```

``` r
library(oras)
```

After loading the library, the appropriate oras client binary must be
installed by explicit request (as per CRAN policy). Batch scripts should
always call `install_oras()`, which will check if a valid version is
installed and only install if needed (or if an upgrade is requested with
`force=TRUE`). In interactive use, functions will prompt if the oras
binary is not installed.

``` r
install_oras()
```

The default login is set to GitHub’s container registry, GHCR.
Alternative providers can also be indicated. By default, this loads the
`GITHUB_TOKEN` environmental variable – ensure that your token includes
the “packages” scope for it to be able to work with GHCR (best practice
would be to use a dedicated token with *only* packages scope). Instead
of using an environmental variable, the user name and password can be
provided as function arguments (but be sure not to accidentally disclose
your password in shared code that way.) Alternatively, `--username` and
`--password` flags are recognized by most `oras` commands.

``` r
oras_login()
#> Login Succeeded
```

``` r
oras_push("ghcr.io/cboettig/content-store/mtcars:v1", "mtcars.csv")
#> Exists    450a97ba6b43 mtcars.csv
#> Pushed [registry] ghcr.io/cboettig/content-store/mtcars:v1
#> Digest: sha256:7646ba611c1f5e9552d457bdb462a2c9cd0e7eb50abbd7cdac9a63fde78991fd
oras_blob_fetch("ghcr.io/cboettig/content-store/mtcars@sha256:450a97ba6b438c6ea5bdf2aaac7eab0ecbbf812b5ff74b56f62dcf0a0c7eb0e5",
                "cars.csv")
#> 
```

We can now download the asset using either it’s tag (which can be
overwritten) or it’s hash (which is always unique to this particular
content, and retained even after it is overwritten.)

``` r
oras_pull("ghcr.io/cboettig/content-store/mtcars:v1")
#> Downloading 450a97ba6b43 mtcars.csv
#> Downloaded  450a97ba6b43 mtcars.csv
#> Pulled [registry] ghcr.io/cboettig/content-store/mtcars:v1
#> Digest: sha256:7646ba611c1f5e9552d457bdb462a2c9cd0e7eb50abbd7cdac9a63fde78991fd
```

What if we push a different dataset to this same namespace and tag?

``` r
oras_push("ghcr.io/cboettig/content-store/mtcars:v1", "lynx.csv")
#> Exists    c024f4e63aa1 lynx.csv
#> Pushed [registry] ghcr.io/cboettig/content-store/mtcars:v1
#> Digest: sha256:6aa019d03a692f4275c9736c2ac22ed8ffed98055860d17180817549f27bf604
```

Note that because the registry is content-based, if we push an object
that already exits, we get a simple note that the object already exists,
as determined by its SHA256 hash. Also note that using the tag in
`oras_pull`, we now receive the `lynx.csv` file, while using the mtcars
hash, we receive the `mtcars.csv`.  
But the content is preserved and addressable by it’s sha256 hash. Always
use `oras_blob_fetch()` to fetch specific content addressed by hash.

``` r
oras_pull("ghcr.io/cboettig/content-store/mtcars:v1")
#> Downloading c024f4e63aa1 lynx.csv
#> Downloaded  c024f4e63aa1 lynx.csv
#> Pulled [registry] ghcr.io/cboettig/content-store/mtcars:v1
#> Digest: sha256:6aa019d03a692f4275c9736c2ac22ed8ffed98055860d17180817549f27bf604

oras_blob_fetch("ghcr.io/cboettig/content-store/mtcars@sha256:450a97ba6b438c6ea5bdf2aaac7eab0ecbbf812b5ff74b56f62dcf0a0c7eb0e5",
                output = "cars.csv")
#> 
```

Unlike other content-based storage systems like IPFS, content addresses
in container registries are transparent and easily computed by the
SHA256 standard (perhaps the most widely used and supported algorithm
ever written). For instance, we can easily verify the hash quoted by the
registry matches that produced independently:

``` r
openssl::sha256(file("mtcars.csv", "rb")) |> as.character()
#> [1] "450a97ba6b438c6ea5bdf2aaac7eab0ecbbf812b5ff74b56f62dcf0a0c7eb0e5"
openssl::sha256(file("cars.csv", "rb")) |> as.character()
#> [1] "450a97ba6b438c6ea5bdf2aaac7eab0ecbbf812b5ff74b56f62dcf0a0c7eb0e5"
```

## Metadata and manfiests

Richer workflows that add metadata tags to blobs and connect content to
other content in a DAG, allowing a tree of content to be pulled in a
single command (just as a docker image pulls down all its component
“layers”, i.e. blobs), is a natural extension of this and
well-supported. **examples coming**.

## Public addressing

By default, objects pushed to GHCR are marked private, and subject to
quotas or billing (above a free storage tier of 500 MB). Those quotas do
not apply to objects marked public. After creating an object, set it to
public as described in the [GitHub
Documentation](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility)
(this task is not part of the scope of OCI specification nor covered by
the GitHub API.)

A public object can be addressed by hash using the `blobs` endpoint
(common to any OCI standard registry, though GitHub requires this
additional anonymous token `QQ==` be specified in the header):

``` bash
curl -fL --header "Authorization: Bearer QQ==" "https://ghcr.io/v2/cboettig/content-store/mtcars/blobs/sha256:450a97ba6b438c6ea5bdf2aaac7eab0ecbbf812b5ff74b56f62dcf0a0c7eb0e5" -o cars.csv

# verify matching content 
sha256sum cars.csv
#>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
#>                                  Dload  Upload   Total   Spent    Left  Speed
#>   0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
#> 100  1303  100  1303    0     0   2688      0 --:--:-- --:--:-- --:--:--  2688
#> 450a97ba6b438c6ea5bdf2aaac7eab0ecbbf812b5ff74b56f62dcf0a0c7eb0e5  cars.csv
```

Finally, we can log out, to make our connection secure until an
authentication token is again provided. (For non-GHCR use, remember to
specify the registry address)

``` r
oras_logout()
#> 
```
