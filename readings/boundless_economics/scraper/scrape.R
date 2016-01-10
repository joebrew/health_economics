# Directories
root_dir <- getwd() # start in the health_economics folder

# Libraries
library(rvest)
library(htmlwidgets)
library(readr)

# Go to first page of chapter 1
start_url <- paste0('https://www.boundless.com/economics/textbooks/boundless-economics-textbook/principles-of-economics-1/',
                     'the-study-of-economics-39/the-magic-of-the-economy-139-12237/')
start_html <- read_html(start_url)

# Define the end (ie, last section of last chapter)
end_url <- paste0('https://www.boundless.com/economics/textbooks/boundless-economics-textbook/immigration-economics-38/introduction-to-immigration-economics-138/',
                   'impact-of-immigration-on-the-host-and-home-country-economies-546-12643/')

# Run a while loop to get all the pages of the book, 
# saving the results into an html ............................................

# Define a counter
i <- 0

# Set a starting point
new_url <- start_url

# Define a destination to save files
destination <- paste0(root_dir, '/readings/boundless_economics/files')

# Character vectors of results
file_names <- urls <- as.character()

while(new_url != end_url){
  message(paste0('Starting page ', i, '\n', '___________', '\n'))
  try({
    
    # Raise the counter
    i <- i + 1
    
    # Define a filename
    file_name <- as.character(i)
    while(nchar(file_name) < 3){
      file_name <- paste0('0', file_name)
    }
    
    message('Reading new file')
    # Read the new_url
    new_html <- new_url %>%
      read_html()
    
    # Get the text name of the section we're downloading
    new_name <- new_html %>%
      html_nodes(xpath = '//*[contains(concat( " ", @class, " " ), 
                 concat( " ", "content__title", " " ))]') %>%
      html_text()
    
    # Combine the name of the section into the file name
    file_name <- paste0(file_name, ' - ', new_name)
    
    # Prepend the file name with directory information
    # and suffix with file extension
    file_name <- paste0(destination, '/', file_name, '.html')
    
    message('Downloading file')
    # Download the html
    download.file(url = new_url,
                  destfile = file_name)
    
    # Store results of the file downloaded
    file_names <- c(file_names, file_name)
    urls <- c(urls, new_url)
    
    # Done with that page - move to the next one...
    # Replace the new_url with the next one (from the next button)
    message('Moving on')
    new_url <- new_html %>%
      html_nodes(xpath = '//*[contains(concat( " ", @class, " " ), 
             concat( " ", "adjacent-concept-link__button", " " ))]') %>%
      html_attr(name = 'href') 
    # Add an appropriate preface
    new_url <- paste0('https://www.boundless.com',
                      new_url)
    # If there are 2 (ie, both a prev and next menu), select the last (ie, next) one
    new_url <- new_url[[length(new_url)]]
  })
}

# Define which chapters are which
chapters <- unlist(
  lapply(
    strsplit(
      as.character(
        lapply(
          strsplit(
            gsub(
              paste0('https://www.boundless.com/economics/textbooks/boundless-economics-textbook/',
                 '|https://www.boundless.com/economics/textbooks/1515/',
                 '|https://www.boundless.com/56/textbooks/boundless-economics-textbook/'),
                                                                     '',
                                                                     urls),
                                                                split = '/'),
                                                       function(x){
                                                         x[1]
                                                       })), '-'),
                          function(x){
                            x[length(x)]
                          }
    ) 
  )
# Create a table of filenames, chapters, etc.
toc <- data.frame(
  chapter = chapters,
  abbreviated = gsub('/home/joebrew/Documents/health_economics/readings/boundless_economics/files/', '', file_names),
  url = urls,
  file_name = file_names
)
# Write table of contents 
write_csv(toc, 'readings/boundless_economics/toc.csv')
