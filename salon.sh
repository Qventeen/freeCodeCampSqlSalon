#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql -X -U freecodecamp -d salon --tuples-only -c"

SERVICE_MENU() {
  #if incomming message
  if [[ "$1" ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  #get list of services from db
  AVAILABLE_SERVICES=$($PSQL "select * from services")
  #if no any services
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo -e "\nNo any services for order. Try latter."
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo -e "$SERVICE_ID) $SERVICE_NAME"
    done
    #get number of service
    read SERVICE_ID_SELECTED
    #if not number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      SERVICE_MENU "It is not a number"
    else
      #get service name
      SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
      
      #if incorrect number
      if [[ -z $SERVICE_NAME ]]
      then
        SERVICE_MENU "I could not find that service. What would ou like today?"
      else
        #make order
        ORDER
      fi
    fi
  fi
}

ORDER() {
  echo -e "\nWhat's your phone number?"
  #read phone number
  read CUSTOMER_PHONE
  #get name by number
  CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
  
  #if name not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    #create new customer
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  #get customer id by phone number
  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")  
  
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  
  read SERVICE_TIME
  INSERT_ORDER_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
}

SERVICE_MENU


