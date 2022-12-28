#######  CLEANING ALL THE ALGOS AND SUBSCRIPTIONS  ########
library(readr)
library(httr)
library(jsonlite)
library(dplyr)

# set up the keyq
Sys.setenv('APCA-API-KEY-ID' = "CKY4IBD93ZMGYI554GJ0")
Sys.setenv('APCA-API-SECRET-KEY' = "qDm0P3JcHUYWtOHgEKL0QHlh79h0QytaXi97gliW")

# read the keys
ALPACA_API_ID <- Sys.getenv("APCA-API-KEY-ID")
ALPACA_API_SECRET <- Sys.getenv("APCA-API-SECRET-KEY")
# ~ % curl -u CKY4IBD93ZMGYI554GJ0:qDm0P3JcHUYWtOHgEKL0QHlh79h0QytaXi97gliW https://broker-api.sandbox.alpaca.markets/v1/accounts

# fetch the broker URL
broker_url = "https://broker-api.sandbox.alpaca.markets/"
accounts_url = "v1/accounts"
assets_url = "v1/assets/"
trading_url = "/v1/trading/accounts/" #You need to add {account_id}"/positions"
positions_url = "/positions" #You need to add {account_id}"/positions"
rebalancing_url = "v1/rebalancing/portfolios"
rebalancing_sub_url = "v1/rebalancing/subscriptions"


######## DELETE ALL SUBSCRIPTIONS #######
# Check all subscriptions
get_subscriptions <- GET(url = paste(broker_url,subscriptions_url, sep=""), 
                      authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
subscriptions = as.data.frame(fromJSON(rawToChar(get_subscriptions$content))[1])
print(subscriptions)

#Delete the list of portfolios
for (i in unique(subscriptions$subscriptions.id)){
  del_subscriptions <- DELETE(url = paste(broker_url,subscriptions_url,"/",i, sep=""), 
                              authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
  
  print(paste("done for ",i))
}

# Check all subscriptions
get_subscriptions <- GET(url = paste(broker_url,subscriptions_url, sep=""), 
                         authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
subscriptions = as.data.frame(fromJSON(rawToChar(get_subscriptions$content))[1])
print(subscriptions)


######   DELETE ALL PORTFOLIOS  ##########
# You need to unsubscribe subscriptions that are linked to a portfolio prior to deleting it

# Look at all the existing portfolios
get_portfolios <- GET(url = paste(broker_url,portfolio_url, sep=""), 
                      authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
portfolios = fromJSON(rawToChar(get_portfolios$content))
print(portfolios)

# Deletes all the portfolios
for (i in unique(portfolios$id)){
  del_portfolios <- DELETE(url = paste(broker_url,portfolio_url,"/",i, sep=""), 
                           authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))

  print(paste("done for ",i))  
}

#Verifies that all portfolios are deleted
get_portfolios <- GET(url = paste(broker_url,portfolio_url, sep=""), 
                      authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
portfolios = fromJSON(rawToChar(get_portfolios$content))
print(portfolios)


#######   CREATE A PORTFOLIO  ########
#gets the weighting
# Get the CSV with stock list and their weight
Risk_Weighting <- read_csv("OneDrive/EarthQuake/R Alpaca/Risk_Weighting.csv")
View(Risk_Weighting)

##### RISK Portfolios #####
#rebalancing conditions
reb_cond <- list (type = "calendar", sub_type = "weekly", day = "Tuesday")

# With EAGG
#create 10 portfolios
for(i in 1:3) { 
  print(i)
  port_name <- paste("port", i, sep = "")
  port_descripton <- paste ("Risk", i, "portfolio")
  vteb <- list(type = "asset", symbol = "VTEB", percent = Risk_Weighting$VTEB[Risk_Weighting$Risk_Level==i])
  eagg <- list(type = "asset", symbol = "EAGG", percent = Risk_Weighting$EAGG[Risk_Weighting$Risk_Level==i])
  chgx <- list(type = "asset", symbol = "CHGX", percent = Risk_Weighting$PARWX[Risk_Weighting$Risk_Level==i])
  schp <- list(type = "asset", symbol = "SCHP", percent = Risk_Weighting$SCHP[Risk_Weighting$Risk_Level==i])
  
  request_portfolio <- list(
    name = port_name,
    description = port_descripton,
    weights = list(vteb, eagg, chgx,schp),
    cooldown_days = 7,
    rebalance_conditions = list(reb_cond)
  )
  
  portfolio <- POST(url = paste(broker_url,rebalancing_url,sep=""),
                      body = request_portfolio, encode = "json",
                      authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
  
  content(portfolio)
}

# Without EAGG
#create 10 portfolios
for(i in 4:6) { 
  print(i)
  port_name <- paste("port", i, sep = "")
  port_descripton <- paste ("Risk", i, "portfolio")
  vteb <- list(type = "asset", symbol = "VTEB", percent = Risk_Weighting$VTEB[Risk_Weighting$Risk_Level==i])
  chgx <- list(type = "asset", symbol = "CHGX", percent = Risk_Weighting$PARWX[Risk_Weighting$Risk_Level==i])
  schp <- list(type = "asset", symbol = "SCHP", percent = Risk_Weighting$SCHP[Risk_Weighting$Risk_Level==i])
  
  request_portfolio <- list(
    name = port_name,
    description = port_descripton,
    weights = list(vteb, chgx,schp),
    cooldown_days = 7,
    rebalance_conditions = list(reb_cond)
  )
  
  portfolio <- POST(url = paste(broker_url,rebalancing_url,sep=""),
                    body = request_portfolio, encode = "json",
                    authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
  
  content(portfolio)
}

# Without SCHP
for(i in 7:10) { 
  print(i)
  port_name <- paste("port", i, sep = "")
  port_descripton <- paste ("Risk", i, "portfolio")
  vteb <- list(type = "asset", symbol = "VTEB", percent = Risk_Weighting$VTEB[Risk_Weighting$Risk_Level==i])
  chgx <- list(type = "asset", symbol = "CHGX", percent = Risk_Weighting$PARWX[Risk_Weighting$Risk_Level==i])

  request_portfolio <- list(
    name = port_name,
    description = port_descripton,
    weights = list(vteb, chgx),
    cooldown_days = 7,
    rebalance_conditions = list(reb_cond)
  )
  
  portfolio <- POST(url = paste(broker_url,rebalancing_url,sep=""),
                    body = request_portfolio, encode = "json",
                    authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
  
  content(portfolio)
}

# # Assets in the portfolio and their weight
# vteb <- list(type = "asset", symbol = "VTEB", percent = "35")
# eagg <- list(type = "asset", symbol = "EAGG", percent = "19")
# chgx <- list(type = "asset", symbol = "CHGX", percent = "34")
# schp <- list(type = "asset", symbol = "SCHP", percent = "12")
# 
# request_portfolio <- list(
#   name = "test",
#   description = "test Portfolio",
#   weights = list(vteb, eagg, chgx,schp),
#   cooldown_days = 7,
#   rebalance_conditions = list(reb_cond)
# )
# 
# portfolio_1 <- POST(url = paste(broker_url,rebalancing_url,sep=""),
#                     body = request_portfolio, encode = "json",
#                     authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
# 
# content(portfolio_1)


######  ASSIGN A PORTFOLIO  ######
subscription_body <- list(account_id = 'f5397e23-2a51-47f2-80e9-b6236d73bf11',
                          portfolio_id = 'ae621a19-123c-4ebc-9b33-e8642274a3d1')

subscription <- POST(url = paste(broker_url,rebalancing_sub_url,sep=""),
                     body = subscription_body, encode = "json",
                     authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))

content(subscription)


######## LIQUIDATE ALL POSITIONS #######
# Check all subscriptions
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
active_clients

to_refund = "9070ab62-9abf-42bd-a50c-12716138450e"

#Unsubscribe account
get_subscriptions <- GET(url = paste(broker_url,subscriptions_url, sep=""), 
                         authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
subscriptions = as.data.frame(fromJSON(rawToChar(get_subscriptions$content))[1])
print(subscriptions)

acc=subscriptions$subscriptions.id[subscriptions$subscriptions.account_id== to_refund]

unsubscribe_account <- DELETE (url = paste(broker_url,subscriptions_url,"/",acc, sep=""), 
                        authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
unsubscribe_acc = as.data.frame(fromJSON(rawToChar(unsubscribe_account$content))[1])
print(unsubscribe_acc)

del_positions<- DELETE (url = paste(broker_url,trading_url,to_refund,positions_url, sep=""), 
                        body = list(cancel_orders=TRUE), encode = "json",
                        authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
positions_del = as.data.frame(fromJSON(rawToChar(del_positions$content))[1])
print(positions_del)


get_positions<- GET(url = paste(broker_url,trading_url,to_refund,positions_url, sep=""), 
                         authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
positions = as.data.frame(fromJSON(rawToChar(get_positions$content))[1])
print(positions)

# #Delete the list of portfolios
# for (i in unique(subscriptions$subscriptions.id)){
#   del_subscriptions <- DELETE(url = paste(broker_url,subscriptions_url,"/",i, sep=""), 
#                               authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
#   
#   print(paste("done for ",i))
# }
# 
# # Check all subscriptions
# get_subscriptions <- GET(url = paste(broker_url,subscriptions_url, sep=""), 
#                          authenticate(ALPACA_API_ID, ALPACA_API_SECRET, type="basic"))
# subscriptions = as.data.frame(fromJSON(rawToChar(get_subscriptions$content))[1])
# print(subscriptions)