
FROM rocker/verse:4.4
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
 && apt-get install -y pandoc \
    pandoc-citeproc
RUN R -e "install.packages('remotes')"
RUN R -e "install.packages('purrr')" # map function
ENV R_CRAN_WEB="https://cran.rstudio.com/"
RUN R -e "install.packages(c('FactoMineR', 'parallel', 'ggpubr', 'imager', 'RefManageR', 'wesanderson', 'plotly'))" # GET function
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
  mercurial gdal-bin libgdal-dev gsl-bin libgsl-dev \
  libc6-i386
RUN apt-get install -y --no-install-recommends unzip python3-pip dvipng pandoc wget git make python3-venv && \
    pip3 install jupyter jupyter-cache flatlatex matplotlib && \
    apt-get --purge -y remove texlive.\*-doc$ && \
    apt-get clean
RUN R -e "install.packages(c('reticulate'))"
