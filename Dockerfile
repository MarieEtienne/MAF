FROM rocker/verse:4.5

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      pandoc mercurial gdal-bin libgdal-dev gsl-bin libgsl-dev libc6-i386 \
      unzip python3-pip python3-venv dvipng wget git make \
      ghostscript fontconfig \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Python dans un venv (évite le conflit avec le numpy de Debian) ---
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir jupyter jupyter-cache flatlatex matplotlib
ENV PATH="/opt/venv/bin:$PATH"
ENV QUARTO_PYTHON=/opt/venv/bin/python
ENV RETICULATE_PYTHON=/opt/venv/bin/python

# --- LaTeX : on complète la TeX Live déjà fournie par rocker/verse ---
RUN tlmgr install \
      xetex beamer pgf translator tcolorbox environ fontspec unicode-math \
      lm lm-math tex-gyre xcolor etoolbox iftex amsmath tools caption \
      bookmark xurl booktabs fancyvrb framed upquote microtype parskip \
      footnotehyper \
 && fmtutil-sys --all

# --- R ---
ENV R_CRAN_WEB="https://cran.rstudio.com/"
RUN R -e "install.packages(c('reticulate', 'remotes', 'purrr'))"
RUN R -e "install.packages(c('FactoMineR', 'Factoshiny', 'factoextra', 'explor', 'ggpubr', 'imager', 'RefManageR', 'wesanderson', 'plotly'))"
RUN R -e "install.packages(c('palmerpenguins', 'GGally', 'ggforce', 'flextable', 'kableExtra', 'janitor'))"
RUN R -e "install.packages(c('imager'))"
