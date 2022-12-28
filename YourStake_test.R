library(httr)
library(jsonlite)
library(dplyr)
library(tidyquant) # To download the data
library(plotly) # To create interactive charts
library(timetk) # To manipulate the data series
library(tidyr)
library(tidyverse)
library(readxl)


#####  SET UP   ######

# set up the keyq
Sys.setenv('YOURSTAKE-API-TOKEN' = "e837b153dc19c6f6eb93ddb141d5e55de837b153dc19")

# read the keys
YOURSTAKE_API_TOKEN <- Sys.getenv("YOURSTAKE-API-TOKEN")

#ethos_url
yourstake_url <- "https://www.yourstake.org/api/v1/"


#####  RETRIEVE ALL COMPANIES ######
esg_issues <- "esgissues"
url <- "https://www.yourstake.org/api/v1/esgissues/"

test <- GET(url = paste(yourstake_url, esg_issues, sep=""),
            add_headers(Authorization = YOURSTAKE_API_TOKEN))

test <- GET(url = url,
            add_headers(Authorization = YOURSTAKE_API_TOKEN))

report <- "portfolios/$AAPL/report/impact/"

test <- GET(url = paste(yourstake_url, report, sep=""),
            add_headers(Authorization = YOURSTAKE_API_TOKEN)))


test_ex <- fromJSON(content(test, as="text"))
test_ex <- fromJSON(readLines(test), warn = F)


body_content <- list(firm_id= ETHOS_API_ID, secret= ETHOS_API_SECRET)

all_ethos_comp <- POST(url = paste(ethos_url, url_list, sep=""),
                       body = body_content)

ethos_comp <- fromJSON(content(all_ethos_comp, as="text"))
ethos_comp <- as.data.frame(ethos_comp[1])

######  RETRIEVE THE S&P 500  #########
SP500 <- as.data.frame(sp500tickers)
#write.csv(SP500, file= "Desktop/S&P500.csv")

###########   ESG Selection from YourStake  #############
screens <- read.csv("Desktop/screenings_Yourstake.csv", header = TRUE)

fossil_free <- screens[screens$Fossil_Fuel_Industry_Exposure_Percentile > 0,]
ceo_free <- screens[screens$CEO_Pay_Percentile > 10,]

ESG_portfolio <- screens[screens$Fossil_Fuel_Industry_Exposure_Percentile > 0 &
                           screens$CEO_Pay_Percentile > 10 &
                           screens$Deforestation_Producers_Exposure_Percentile > 0 &
                           screens$Prison_Industry_Exposure_Percentile > 0 &
                           screens$Women_on_Boards_Percentile > 20,
]

###### GET ALL THE METRICS FOR APPLE ######
url_list <- "/companies/metrics/get"

body_content <- list(firm_id= ETHOS_API_ID, secret= ETHOS_API_SECRET,
                     options= list(symbols= "AAPL"))

apple <- POST(url = paste(ethos_url, url_list, sep=""),
              body = body_content, encode = "json")

apple_json <- fromJSON(rawToChar(content(apple, as="raw")))
apple_metrics <- flatten(as.data.frame(apple_json))
ticker <- apple_metrics$companies.symbol
apple_metrics <- apple_metrics$companies.metrics
apple_metrics$ticker <- ticker



###### GET ALL THE METRICS FOR THE S&P500 ######
url_list <- "/companies/metrics/get"

test_500 <- as.data.frame(sp500tickers)
test_500$Symbol[test_500$Symbol == "GOOG"] <- "GOOGL"
test_500$Symbol[test_500$Symbol == "FOXA"] <- "FOX"
test_500$Symbol[test_500$Symbol == "NWSA"] <- "NWS"
