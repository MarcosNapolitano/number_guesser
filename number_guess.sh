#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

N=$(( RANDOM % 1001 ))
CURRENT_TRIES=0

echo "Enter your username:"
read USERNAME

USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

#if exist welcome back + number games + best game, if not welcome first time
if [[ -z $USERNAME_ID ]]
then
  USER_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

else
  GAMES=$($PSQL "SELECT count(*) FROM games WHERE user_id=$USERNAME_ID")
  TRIES=$($PSQL "SELECT min(tries) FROM games WHERE user_id=$USERNAME_ID")

  echo -e "\nWelcome back, $USERNAME! You have played $GAMES games, and your best game took $TRIES guesses."

fi

#guess part
echo "Guess the secret number between 1 and 1000:"
read GUESS

#forces to insert a number not a blank space
while [[ -z $GUESS ]]
do 
  echo -e "Please insert a number:"
  read GUESS

done

#checks for equality and not blank spaces
while [[ -z $GUESS ]] || [ $GUESS != $N ]
do

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    read GUESS

  elif [ $GUESS -lt $N ]
  then
    echo -e "\nIt's higher than that, guess again:"
    ((CURRENT_TRIES+=1))
    read GUESS

  elif [ $GUESS -gt $N ]
  then

    echo -e "\nIt's lower than that, guess again:"
    ((CURRENT_TRIES+=1))
    read GUESS

  fi

done



#record insert
((CURRENT_TRIES+=1))
GAME_INSERT=$($PSQL "INSERT INTO games(user_id, tries) VALUES($USERNAME_ID, $CURRENT_TRIES)")

#congrats
echo "You guessed it in $CURRENT_TRIES tries. The secret number was $N. Nice job!"