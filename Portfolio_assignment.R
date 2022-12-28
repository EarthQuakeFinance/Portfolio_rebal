library(googlesheets4)
library(googleCloudRunner)
library(googleAuthR)
library(httr)
library(jsonlite)
library(dplyr)

# read the keys
Sys.setenv('APCA-API-KEY-ID' = "CKY4IBD93ZMGYI554GJ0")
Sys.setenv('APCA-API-SECRET-KEY' = "qDm0P3JcHUYWtOHgEKL0QHlh79h0QytaXi97gliW")

GCE_AUTH_FILE="alpacaportfoliobalancing-44800fde91c8.json"
GCE_DEFAULT_PROJECT_ID="104832190364286526802"
GCS_DEFAULT_BUCKET="alpaca_code_repositotory_v1"
CR_REGION="northamerica-northeast1"
CR_BUILD_EMAIL=portfolio-rebalancing-v1@alpacaportfoliobalancing.iam.gserviceaccount.com



ALPACA_API_ID <- Sys.getenv("APCA-API-KEY-ID")
ALPACA_API_SECRET <- Sys.getenv("APCA-API-SECRET-KEY")

# fetch the broker URL
broker_url = "https://broker-api.sandbox.alpaca.markets/"
accounts_url = "v1/accounts"
assets_url = "v1/assets/"
trading_url = "/v1/trading/accounts/" #You need to add {account_id}"/positions"
positions_url = "/positions" #You need to add {account_id}"/positions"
rebalancing_url = "v1/rebalancing/portfolios"
portfolio_url ="v1/rebalancing/portfolios"
subscriptions_url = "v1/rebalancing/subscriptions"

### GET THE RISK PROFILES ####
#Read clients google sheets data into R
clients <- read_sheet('https://docs.google.com/spreadsheets/d/1U2EqhZDBF_hLTnsW4FBVyC3_ZTbzMoXhMzlZWfzOv0I/edit#gid=0')
clients <- as.data.frame(clients)
clients <- clients[!is.na(clients$account_ID),]
clients$risk_profile_previous_day[is.na(clients$risk_profile_previous_day)] <- 0


#Get all accounts from Alpaqa broker API & merge it with risk profiles
get_accounts <- GET(url = paste(broker_url,accounts_url, sep=""), 
           authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))

alpaqa_accounts = fromJSON(rawToChar(get_accounts$content))
active_clients <- merge(clients, alpaqa_accounts, by.x=("account_ID"), by.y="account_number", all.x=TRUE)
#Uses accounts with new risk profile
to_allocate <- active_clients[!(active_clients$risk_profile == active_clients$risk_profile_previous_day),]

######  ASSIGN A PORTFOLIO  ######
#retrieves all the portfolios
get_portfolios <- GET(url = paste(broker_url,portfolio_url, sep=""), 
                    authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
portfolios = fromJSON(rawToChar(get_portfolios$content))
print(portfolios)

for (i in unique(to_allocate$account_ID)){
  print(i)
  
  account <- active_clients$id[active_clients$account_ID==i]
  portfolio_profile <- paste("port",  active_clients$risk_profile[active_clients$account_ID==i], sep="")
  port_id <- portfolios$id[portfolios$name ==portfolio_profile]
  
  subscription_body <- list(account_id = account,
                            portfolio_id = port_id)
  
  subscription <- POST(url = paste(broker_url,rebalancing_sub_url,sep=""),
                       body = subscription_body, encode = "json",
                       authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
  
  content(subscription)
}


