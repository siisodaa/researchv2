# Use the Rocker R image
FROM rocker/r-ver:4.2.3

# Install required R packages
RUN R -e "install.packages(c('shiny', 'DT', 'plotly', 'dplyr'), repos='http://cran.rstudio.com/')"

# Copy your project files into the Docker image
COPY . /home/rstudio/myproject
WORKDIR /home/rstudio/myproject

# Expose the port Shiny will run on
EXPOSE 8888

# Start the Shiny app
CMD ["R", "-e", "shiny::runApp('/home/rstudio/myproject/server.R', port=8888, host='0.0.0.0')"]
