FROM rocker/verse:4.5
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
 && apt-get install -y pandoc 
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
  mercurial gdal-bin libgdal-dev gsl-bin libgsl-dev \
  libc6-i386
RUN apt-get install -y --no-install-recommends unzip python3-pip dvipng  wget git make python3-venv 
RUN pip3 install --break-system-packages jupyter jupyter-cache flatlatex matplotlib
RUN apt-get --purge -y remove texlive.\*-doc$
RUN apt-get clean
RUN R -e "install.packages(c('reticulate', 'remotes', 'purrr'))"
ENV R_CRAN_WEB="https://cran.rstudio.com/"
RUN R -e "install.packages(c('FactoMineR', 'Factoshiny', 'parallel', 'ggpubr', 'imager', 'RefManageR', 'wesanderson', 'plotly'))" # GET function
RUN R -e "install.packages(c('palmerpenguins','GGally', 'ggforce', 'factoextra', 'flextable'))"



