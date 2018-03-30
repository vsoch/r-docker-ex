Bootstrap: docker
From: rocker/rstudio

# sudo singularity build r-singularity

%files
    . /home/rstudio/project

%post

    # install packrat

    R -e 'install.packages("packrat", repos="http://cran.rstudio.com", dependencies=TRUE, lib="/usr/local/lib/R/site-library");'

    # copy lock file & install deps
    R -e 'packrat::restore(project="/home/rstudio/project");'
   
    chown -R rstudio /home/rstudio

    # Init the files needed in the container
    /bin/bash /init
