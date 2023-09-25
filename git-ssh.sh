#!/bin/bash

TODAY=$(date +%F)
SUFIJOGIT=$(date +"%T.%N" | md5sum | base64 | head -c 3)

github-authenticated() {
    # Attempt to ssh to GitHub
    ssh -T "$1" &>/dev/null
    RET=$?
    if [ $RET == 1 ]; then
    return 0
    elif [ $RET == 255 ]; then
    return 1
    else
    echo "unknown exit code in attempt to ssh into git@github.com"
    fi
    return 2
}

echo 'I am going to build the ssh connection with github.'
echo 'Let me ask you some quick questions:'
echo ''
PS3='Do you want to use a key on your computer or are you going to use ybikey, onlykey or similar?: '
options=("I want to use a key on my computer" "I want to use Yubikey, Onlykey or similar")
COLUMNS=12
select fav in "${options[@]}"; do
    case $fav in
        "I want to use a key on my computer")
            KEYS=1
            break
            ;;
        "I want to use Yubikey, Onlykey or similar")
            KEYS=2
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
if [ "$KEYS" = 2 ]; then
  PS3='What type of USB key are you going to use?: '
  options=("Yubikey" "Onlykey")
  COLUMNS=12
  select fav in "${options[@]}"; do
      case $fav in
          "Yubikey")
              USB=1
              break
              ;;
          "Onlykey")
              USB=2
              break
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
fi
if [ "$USB" = 1 ]
PS3='How are you going to use the key? '
  options=("No PIN or touch are required" "PIN but no touch required" "No PIN but touch is required" "A PIN and a touch are required (most secure)")
  COLUMNS=12
  select fav in "${options[@]}"; do
      case $fav in
          "No PIN or touch are required")
              USB=1
              break
              ;;
          "PIN but no touch required")
              USB=2
              break
              ;;
           "No PIN but touch is required")
              USB=3
              break
              ;;
           "A PIN and a touch are required (most secure)")
              USB=4
              break
              ;;           
          *) echo "invalid option $REPLY";;
      esac
  done
fi
if [ "$USB" = 2 ]
PS3='How are you going to use the key? '
  options=("No PIN or touch are required" "No PIN but touch is required")
  COLUMNS=12
  select fav in "${options[@]}"; do
      case $fav in
          "No PIN or touch are required")
              USB=1
              break
              ;;
           "No PIN but touch is required")
              USB=3
              break
              ;;       
          *) echo "invalid option $REPLY";;
      esac
  done
fi

if [ "$KEYS" = 1 ]; then
  sudo ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsagithub -q -N ""
fi
if [ "$USB" = 1 ]; then
  ssh-keygen -t ed25519-sk -O resident -O no-touch-required application=ssh:id_rsagithub -f ~/.ssh/id_rsagithub -P ""
fi
if [ "$USB" = 2 ]; then
  ssh-keygen -t ed25519-sk -O resident -O verify-required -O no-touch-required application=ssh:id_rsagithub -f ~/.ssh/id_rsagithub -P ""
fi
if [ "$USB" = 3 ]; then
  ssh-keygen -t ed25519-sk -O resident application=ssh:id_rsagithub -f ~/.ssh/id_rsagithub -P ""
fi
if [ "$USB" = 4 ]; then
  ssh-keygen -t ed25519-sk -O resident -O verify-required application=ssh:id_rsagithub -f ~/.ssh/id_rsagithub -P ""
fi

chmod 400 ~/.ssh/id_rsagithub
chmod 644 ~/.ssh/id_rsagithub.pub

if ! (grep -wq "source ~/.ssh/id_rsagithub" ~/.ssh/config); then 
    echo 'source ~/.ssh/id_rsagithub' >> ~/.ssh/config
fi

rm -f /root/.ssh/github
echo 'Host githubssh' >> ~/.ssh/github
echo '        User git' >> ~/.ssh/github
echo '        HostName github.com' >> ~/.ssh/github
echo '        IdentityFile  ~/.ssh/id_rsagithub' >> ~/.ssh/github

#Añado las llaves a ssh agent
eval "$(ssh-agent)"
ssh-add ~/.ssh/id_rsagithub
pub=$(cat ~/.ssh/id_rsagithub.pub)
echo ''
echo ''
echo ''
echo ''
echo ''
for (( ; ; ))
do
        githubuser=0
        githubpass=0
        read -r -p "Enter your github username: " githubuser
        echo "Tu usuario de github es $githubuser"
        echo 'Now I need the api-token'
        echo "Here is a manual to create a api-token: https://docs.github.com/es/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens"
        read -r -p "Write $githubuser's github api-token : " githubpass
        curl -u "$githubuser:$githubpass" -X POST -d "{\"title\":\"`hostname$TODAY$SUFIJOGIT`\",\"key\":\"$pub\"}" https://api.github.com/user/keys
        if github-authenticated githubssh; then
            echo "Success! I have already connected to github via ssh."
            break
        else
            echo "Something has gone wrong: the username or the api-token."
            echo "Here is a manual to create a api-token: https://docs.github.com/es/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens"
            read -n 1 -s -r -p "Press Enter to try to connect again"
        fi
done
read -r -p "Enter your github email: " githubemail
git config --global user.email "$githubemail"
git config --global user.name "$githubuser"
echo "You've made it! You can now interact withgithub with your ssh keys."
echo "goodbye"
