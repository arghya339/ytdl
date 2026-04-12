#!/usr/bin/env bash

# Copyright (C) 2025, Arghyadeep Mondal <github.com/arghya339>

shopt -s extglob

managePlaylistItems() {
  #mapfile -t titles < <(yt-dlp --js-runtimes deno --remote-components ejs:github --flat-playlist --get-title "$url" -q --no-warnings)
  #urls=($(yt-dlp --js-runtimes deno --remote-components ejs:github --flat-playlist --get-url "$url" -q --no-warnings))
  itemsJson=$(yt-dlp --js-runtimes deno --remote-components ejs:github --flat-playlist -j "$url" -q --no-warnings | jq -s '.[] | {playlist_index: .playlist_index, title: .title, url: .url}')
  mapfile -t titles < <(jq -r '.title' <<< "$itemsJson")
  urls=($(jq -r '.url' <<< "$itemsJson"))
  
  declare -gA itemsStates
  for ((i=0; i<${#titles[@]}; i++)); do
    ([ "${titles[i]}" == "[Private video]" ] || [ "${titles[i]}" == "[Deleted video]" ]) && itemsStates["${titles[i]}"]=0 || itemsStates["${titles[i]}"]=1
  done
  
  declare -A defaultItemsStates
  for key in "${!itemsStates[@]}"; do
    defaultItemsStates["$key"]=${itemsStates["$key"]}
  done
  
  declare -A itemsDescriptions
  for ((i=0; i<${#urls[@]}; i++)); do
    itemsDescriptions["${titles[i]}"]=${urls[i]}
  done
  
  selectedItems=()
  for title in "${titles[@]}"; do
    [ ${itemsStates["$title"]} -eq 1 ] && selectedItems+=("$title")
  done
  
  [ $highlightedItem -ge ${#titles[@]} ] && highlightedItem=0
  
  highlightedItem=0
  highlightedButton=0
  includeAllState=0  # 0 for Include All, 1 for Exclude All
  
  items_per_page=$((rows - 13))
  
  currentPage=0
  totalPages=$(( (${#titles[@]} + items_per_page - 1) / items_per_page ))
  
  show_menu() {
    printf '\033[2J\033[3J\033[H'
    echo -n "Navigate with [↑] [↓] [→] [←]"
    [ $isMacOS == false ] && echo -n " [PGUP] [PGDN]"
    echo -e "\nToggle with [␣]"
    echo -e "Confirm with [↵]\n"
    
    start_index=$((currentPage * items_per_page))
    end_index=$((start_index + items_per_page - 1))
    [ $end_index -ge ${#titles[@]} ] && end_index=$((${#titles[@]} - 1))
    
    for ((i=start_index; i<=end_index; i++)); do
      title="${titles[i]}"
      state=${itemsStates["$title"]}
      [ $state -eq 1 ] && mark="$symbol1" || mark="$symbol0"
      
      if [ $i -eq $highlightedItem ]; then
        echo -e "${whiteBG}$mark $title${Reset}"
      else
        echo -e "$mark $title"
      fi
    done
    
    for ((i=end_index+1; i<(start_index + items_per_page); i++)); do
      echo
    done
    
    [ $includeAllState -eq 0 ] && ieLabel="<Include All>" || ieLabel="<Exclude All>"
    if [ $highlightedButton -eq 0 ]; then
      echo -e "\n${whiteBG}$buttonsSymbol <Select> ${Reset}    <Recommend>     $ieLabel     <Back>"
    elif [ $highlightedButton -eq 1 ]; then
      echo -e "\n  <Select>   ${whiteBG}$buttonsSymbol <Recommend> ${Reset}    $ieLabel     <Back>"
    elif [ $highlightedButton -eq 2 ]; then
      echo -e "\n  <Select>     <Recommend>   ${whiteBG}$buttonsSymbol $ieLabel ${Reset}    <Back>"
    else
      echo -e "\n  <Select>     <Recommend>     $ieLabel   ${whiteBG}$buttonsSymbol <Back> ${Reset}"
    fi
    
    [ ${#selectedItems[@]} -le 1 ] && echo -e "\nSelected: ${#selectedItems[@]} item" || echo -e "\nSelected: ${#selectedItems[@]} items"
    
    currentPageItems=$((end_index - start_index + 1))
    previousPageItems=$((currentPage * items_per_page))
    echo "Items: $((previousPageItems + currentPageItems))/${#titles[@]}"
    
    [ ${#titles[@]} -gt $items_per_page ] && echo "Page $((currentPage + 1))/$totalPages"
    
    highlightedItemName="${titles[$highlightedItem]}"
    [ -n "${itemsDescriptions[$highlightedItemName]}" ] && echo -ne "ⓘ ${itemsDescriptions[$highlightedItemName]}"
  }
  
  printf '\033[?25l'
  while true; do
    currentPage=$((highlightedItem / items_per_page))
    show_menu
    IFS= read -rsn1 key
      case $key in
        $'\E')  # ESC
          # /bin/bash -c 'read -r -p "Type any ESC key: " input && printf "You Entered: %q\n" "$input"'  # q=safelyQuoted
          read -rsn2 -t 0.1 key2
          case "$key2" in
            '[A')  # Up arrow
              if [ $highlightedItem -gt 0 ]; then
                ((highlightedItem--))
              else
                highlightedItem=$((${#titles[@]} - 1))
              fi
              ;;
            '[B')  # Dn arrow
              if [ $highlightedItem -lt $(( ${#titles[@]} - 1 )) ]; then
                ((highlightedItem++))
              else
                highlightedItem=0
              fi
              ;;
            '[5')  # PgUp
              targetPage=$((currentPage - 1))
              if [ $targetPage -lt 0 ]; then
                 targetPage=$((totalPages - 1))
              fi
              highlightedItem=$((targetPage * items_per_page))
              ;;
            '[6')  # PgDn
              targetPage=$((currentPage + 1))
              if [ $targetPage -ge $totalPages ]; then
               targetPage=0
              fi
              highlightedItem=$((targetPage * items_per_page))
              ;;
            '[C')  # right arrow
              ((highlightedButton++))
              [ $highlightedButton -gt 3 ] && highlightedButton=0 ;;
            '[D')  # left arrow
              ((highlightedButton--))
              [ $highlightedButton -lt 0 ] && highlightedButton=3 ;;
          esac
          ;;
        " ")  # Space
          if [ ${itemsStates["$highlightedItemName"]} -eq 1 ]; then
            itemsStates["$highlightedItemName"]=0
            for i in "${!selectedItems[@]}"; do
              if [ "${selectedItems[i]}" == "$highlightedItemName" ]; then
                unset 'selectedItems[i]'
              fi
            done
            selectedItems=("${selectedItems[@]}")
          else
            itemsStates["$highlightedItemName"]=1
            if [[ ! " ${selectedItems[@]} " =~ " ${highlightedItemName} " ]]; then
              selectedItems+=("$highlightedItemName")
            fi
          fi
          ;;
        "")  # Enter
          if [ $highlightedButton -eq 0 ]; then
            if [ ${#selectedItems[@]} -gt 0 ]; then
              printf '\033[2J\033[3J\033[H'
              echo -e "$info selectedItems:"
              selectedItemsIndexArgs=""
              for ((i=0; i<${#titles[@]}; i++)); do
                title="${titles[i]}"
                if [ ${itemsStates["$title"]} -eq 1 ]; then
                  currentNum=$((i+1))
                  [ $i -lt 9 ] && echo " $currentNum. $title" || echo "$currentNum. $title"
                  if [ -z "$rangeStart" ]; then
                    rangeStart=$currentNum
                    previousNum=$currentNum
                  elif [ $currentNum -eq $((previousNum+1)) ]; then
                    previousNum=$currentNum
                  else
                    if [ "$rangeStart" -eq "$previousNum" ]; then
                      selectedItemsIndexArgs+="${selectedItemsIndexArgs:+,}$rangeStart"
                    else
                      selectedItemsIndexArgs+="${selectedItemsIndexArgs:+,}$rangeStart-$previousNum"
                    fi
                    rangeStart=$currentNum
                    previousNum=$currentNum
                  fi
                fi
              done
              if [ -n "$rangeStart" ]; then
                if [ "$rangeStart" -eq "$previousNum" ]; then
                  selectedItemsIndexArgs+="${selectedItemsIndexArgs:+,}$rangeStart"
                else
                  selectedItemsIndexArgs+="${selectedItemsIndexArgs:+,}$rangeStart-$previousNum"
                fi
              fi
              echo -e "$info selectedItemsIndexArgs: $selectedItemsIndexArgs"  # pattern: 1,3,5 or 2-5 or 1,4-6
              break
            else
              printf '\033[2J\033[3J\033[H'
              echo "NO ITEMS SELECTED !!"
              echo; read -p "Press Enter to continue..."
            fi
          elif [ $highlightedButton -eq 1 ]; then
            for key in "${!itemsStates[@]}"; do
              itemsStates["$key"]=${defaultItemsStates["$key"]}
            done
            selectedItems=()
            for title in "${titles[@]}"; do
              if [ ${itemsStates["$title"]} -eq 1 ]; then
                selectedItems+=("$title")
                echo "$title"
              fi
            done
          elif [ $highlightedButton -eq 2 ]; then
            if [ $includeAllState -eq 0 ]; then
              for title in "${titles[@]}"; do
                itemsStates["$title"]=1
              done
              selectedItems=("${titles[@]}")
              includeAllState=1
            else
              for title in "${titles[@]}"; do
                itemsStates["$title"]=0
              done
              selectedItems=()
              includeAllState=0
            fi
          else
            printf '\033[2J\033[3J\033[H'
            return 1
            break
          fi
          ;;
      esac
  done
  printf '\033[?25h'
  if [ $highlightedButton -eq 0 ]; then
    playlist_items="$selectedItemsIndexArgs"
    return 0
  fi
}