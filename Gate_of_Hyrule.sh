#!/bin/bash

function init() {
    echo "
#################################################################
#                                                               #
#                    THE LEGEND OF ZELDA                        #
#                                                               #
#################################################################
"

  }


#Player function ; fetch aand parse all players data on players.csv file
function player () {


    random_num=$((1 + $RANDOM % 5))


    while IFS="," read -r id name hp mp str
    do

	if [[ $random_num == "$id" ]];
	then

	    player_name=$name
	    player_hp=$hp
	    player_str=$str
	fi

    done < <(cut -d "," -f1-5 `echo players.csv` | tail -n +2)

}


#Enemies function; fetch and parse all enemies data on enemies.csv file
function enemies () {

    random_num2=$((1 + $RANDOM % 12))

    while IFS="," read -r id name hp mp str
    do

	if [[ $random_num2 == "$id" ]];
	then
	    enemies_name=$name
	    enemies_hp=$hp
	    enemies_str=$str
	    enemies_p_str=$((enemies_str/2))
	fi

    done < <(cut -d "," -f1-5 `echo enemies.csv` | tail -n +2)
}

#Boss function ; fetch and parse all boss data on bosses.csv file
function boss () {

    random_num3=$((1 + $RANDOM % 7))

    while IFS="," read -r id name hp mp str
    do

	if [[ $random_num3 == "$id" ]];
	then
	    boss_name=$name
	    boss_hp=$hp
	    boss_str=$str
	fi

    done < <(cut -d "," -f1-5 `echo bosses.csv` | tail -n +2)


}

#game function ; main game ; contains all game (user interface)
function game () {

    # define and assign a fight_num var ; count fight number
    fight_num=1

    # Player function call
    player

    player_max_hp=$player_hp

    # Heal mechanics
    player_heal=$(($player_hp / 2))


    # first loop to count and re-assign fight number and ...
    while [[ $fight_num -lt 11 ]]
    do

	# Function Call
	enemies
	boss


	enemies_max_hp=$enemies_hp

	# define and assign a round variable ; verify if is the 1 round to  echo player_name encounter enemies_name"
	round=1

	# Verify and re-assign var to boss data, if the fight number is 10
	if [[ $fight_num == 10 ]]
	then
	    enemies_name=$boss_name
	    enemies_hp=$boss_hp
	    enemies_damage=$boss_str
	    enemies_max_hp=$boss_hp
	fi

	#Loop for  Fight (user interface and all)
	while [[ $player_hp -gt 0 ]] || [[ $enemies_hp -gt 0 ]]
	do

	    # Compare and show header ; if is the fight 10 or else
	    if [[ $fight_num == 10 ]]
	    then
		init;
		echo "<<========= BOSS FIGHT ! ===========>>"
	    else
		init;
		echo "<<========= FIGHT $fight_num ==========>>"
	    fi

	    # Enemies and player name and hp
	    echo -e "\e[31m$enemies_name\e[0m"
	    echo "HP: " $enemies_hp "/ $enemies_max_hp"
	    echo ""
	    echo -e "\e[32m$player_name\e[0m"
	    echo "HP: "$player_hp "/ $player_max_hp"
	    echo ""


	    # use of round var
	    if [[ $round  == "1" ]]
	    then
		echo -n -e "\e[32m$player_name\e[0m" && echo -n " encounter a " &&  echo -e "\e[31m$enemies_name\e[0m"
		round=$(($round+1))
	    fi

	    # User move section
	    echo ""
	    echo  "---------  Make a move ! -----------"
	    echo "1. Attack   2. Heal   3.Protect   4.Escape"
	    echo ""

	    echo -n "Move -> "

	    # User move choice
	    read choix

	    # Move define ; 1 = Attack , 2 = Heal
	    if [[ $choix == "1" ]]
	    then
		echo -e "\e[32m$player_name\e[0m" " Attacked and dealt $player_str damages !"
		echo ""
		enemies_hp=$(($enemies_hp-$player_str))

		if [[ $enemies_hp -gt 0 ]]
		then
		    echo -e "\e[31m$enemies_name\e[0m" " Attacked and dealt $enemies_str damages"
		    echo ""
		    player_hp=$(($player_hp-$enemies_str))
		read
		fi
		
		
	    elif [[ $choix == "2" ]]
	    then
		echo ""
		echo -e "\e[32m$player_name\e[0m" " You use Heal"
		echo ""
		# Testing and assign Heal to Player
		player_heal_test=$(($player_hp + $player_heal))
		if [[ $player_heal_test -gt $player_max_hp ]]
		then
		    player_hp=$player_max_hp
		else
		    player_hp=$(($player_hp+$player_heal))
		fi

	       if [[ $enemies_hp -gt 0 ]]
	       then
		   echo -e "\e[31m$enemies_name\e[0m" " Attacked and dealt $enemies_str damages"
		   echo ""
		   player_hp=$(($player_hp-$enemies_str))
	       read
		fi

            elif [[ $choix == "3" ]]
	    then
		echo -e "\e[32m$player_name\e[0m" " Attacked and dealt $player_str damages !"
		echo ""
		enemies_hp=$(($enemies_hp-$player_str))

		if [[ $enemies_hp -gt 0 ]]
		then
		    echo -e "\e[31m$enemies_name\e[0m" " attacked and dealt $enemies_p_str damages"
		    echo ""
		    player_hp=$(($player_hp-($enemies_str/2)))
		read
		fi

	    elif [[ $choix == "4" ]]
	    then
		echo ""
		echo "   You escaped the fight"
		echo "------- TRY AGAIN -------"
		echo  ""
		read
		game;
	        
		
	    else
		echo "Error : NULL Choice"
		continue
	    fi

	    # Enemies Move if enemies_hp is gt 0 ; else is end of the fight
	    if [[ $enemies_hp -le 0 ]];then
		fight_num_test=1
		echo ""
		echo "<<======================>>"
		echo -e "\e[31m$enemies_name\e[0m" " DIED ---> You win ! "
		echo "Press ENTRER to continue"
		
		read
		break
	    fi

	    # Player dead and end of the fight
	    if [[ $player_hp -eq 0 || $player_hp -lt 0 ]]
	    then
		fight_num_test=0
		echo ""
		echo "<<======================>>"
		echo -e "\e[32m$player_name\e[0m" " DIED ---> You loose ! "
		echo -n "try again  " && echo -e "\e[32m$player_name\e[0m"
		echo "------- GAME OVER --------"
		player_hp=$player_max_hp
		read
		break
	    fi
	done

	# Add 1 to fight_num  ; if fight_num_test=0 ; fight_num re-assign to 1 to restart the game
	fight_num=$(($fight_num + 1))
	if [[ $fight_num_test -eq 0  ]]
	then
	    fight_num=1
	fi

    done
}



function main {
    game
}


main
