#!/bin/bash

echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services;")

echo "$SERVICES" | while IFS="|" read -r ID NAME; do
  echo -e "$ID) $NAME"
done

while true; do
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]
    then
      echo -e "\nI could not find that service. What would you like today?"
      echo "$SERVICES" | while IFS="|" read -r ID NAME; do
        echo -e "$ID) $NAME"
      done

      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    break
  fi
done

echo -e "What's your phone number?"

read CUSTOMER_PHONE

PHONE_CUSTOMER=$($PSQL "SELECT phone, name FROM customers WHERE phone='$CUSTOMER_PHONE';")

if [[ -z $PHONE_CUSTOMER ]]
  then
    echo -e "I don't have a record for that phone number, what's your name?"

    read CUSTOMER_NAME

    NEW_CUSTOMER_NAME=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

    NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME';")

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"

    read SERVICE_TIME

    NEW_CUSTOMER_TIME=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($NEW_CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

else
  OLD_CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

  OLD_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

  echo -e "\nWhat time would you like your $SERVICE_NAME, $OLD_CUSTOMER_NAME?"
  read SERVICE_TIME

  OLD_CUSTOMER_TIME=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($OLD_CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $OLD_CUSTOMER_NAME."
fi

