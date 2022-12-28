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
Sys.setenv('ETHOS-API-KEY-ID' = "WkfGrq6bDJ")
Sys.setenv('ETHOS-API-SECRET-KEY' = "gNDT8cAC-iXeMe7wu-6agGcR2G")

# read the keys
ETHOS_API_ID <- Sys.getenv("ETHOS-API-KEY-ID")
ETHOS_API_SECRET <- Sys.getenv("ETHOS-API-SECRET-KEY")

#ethos_url
ethos_url <- "https://development.ethosesg.com"


#####  RETRIEVE ALL COMPANIES ######
url_list <- "/companies/list"

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


View(test_500[which(! test_500$Symbol %in% ethos_comp$companies.symbol),])


SP_metrics <- data.frame(matrix(ncol = 11, nrow = 0))
colnames(SP_metrics) <- c('name', 'description', 'link', "uom", "updated_at",  'date',
                         'esg_category', 'peer_value', 'score_base', 'score_normalized', 'ticker' )

duo_metrics <- data.frame(matrix(ncol = 11, nrow = 0))
colnames(SP_metrics) <- c('name', 'description', 'link', "uom", "updated_at",  'date',
                          'esg_category', 'peer_value', 'score_base', 'score_normalized', 'ticker' )


for(j in 0:3){

a = 2*j+1
b = a+1

  duo_metrics <- NULL

  for(i in unique(test_500$Symbol[a:b])){
    
    print(i)
    company_ticker = i
    
    firm_req <- NULL
    firm_json <- NULL
    firm_metrics <- NULL
    ticker <- NULL
    
    body_content <- list(firm_id= ETHOS_API_ID, secret= ETHOS_API_SECRET,
                         options= list(symbols= company_ticker))
    
    firm_req <- POST(url = paste(ethos_url, url_list, sep=""),
                  body = body_content, encode = "json")
    
    firm_json <- fromJSON(rawToChar(content(firm_req, as="raw")))
    firm_metrics <- flatten(as.data.frame(firm_json))
    
    ticker <- firm_metrics$companies.symbol
    firm_metrics <- firm_metrics$companies.metrics
    firm_metrics$ticker <- ticker
    
    duo_metrics <- rbind(duo_metrics, firm_metrics)
    
  }
  
SP_metrics <- rbind(duo_metrics, firm_metrics)
  
  Sys.sleep(3)
  
}

for(j in 0:250){
  
  a = 2*j+1
  b = a+1
  
  for(i in unique(test_500$Symbol[a:b])){
    
    print(unique(test_500$Symbol[a:b]))
    print(i)
    company_ticker = i
  }
  
}

curl -X POST https://development.ethosesg.com/companies/get \
-H 'Content-Type: application/json' \
-d '{
"firm_id": String,
"secret": String,
"options": {
"symbols": [String],
"count": 100,
"offset": 0
}
}'