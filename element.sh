#!/bin/bash
ARGUMENT=$1
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN_FUNCTION() {
  # read argument

  # check if argument is a valid number
  if [[ $1 =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    SEARCH_BY_NUMBER $1
  fi

  # check if argument is a valid symbol
  if [[ $1 =~ ^[A-Za-z]{1,2}$ ]]; then
    SEARCH_BY_SYMBOL $1
  fi

  # check if argument is a valid name
  if [[ $1 =~ ^[A-Za-z]{3,}$ ]]; then
    SEARCH_BY_NAME $1
  fi

}

SEARCH_BY_NUMBER() {
  QUERY_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number = $1")

  if [[ -z $QUERY_RESULT ]]; then
    echo -e "I could not find that element in the database."
    return
  fi

  CREATE_RESULT_STRING "$QUERY_RESULT"
}

SEARCH_BY_SYMBOL() {
  QUERY_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE symbol = '$1'")

  if [[ -z $QUERY_RESULT ]]; then
    echo -e "I could not find that element in the database."
    return
  fi

  CREATE_RESULT_STRING "$QUERY_RESULT"
}

SEARCH_BY_NAME() {
  FORMATTED_NAME=$(sed 's/^\(.\)\(.*\)/\U\1\L\2/' <<< $1)

  QUERY_RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE name = '$FORMATTED_NAME'")

  if [[ -z $QUERY_RESULT ]]; then
    echo -e "I could not find that element in the database."
    return
  fi

  CREATE_RESULT_STRING "$QUERY_RESULT"
}

CREATE_RESULT_STRING() {
  FORMATTED_RESULT=$(sed 's/|/ /g' <<< "$1")

  read NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$FORMATTED_RESULT"

  echo -e "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
}

if [[ -z $1 ]]; then
  echo -e "Please provide an element as an argument."
else
  MAIN_FUNCTION $1
fi
