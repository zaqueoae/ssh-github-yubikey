#!/bin/bash
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
if [ "$KEYS" = 1 ]; then
  sudo ssh-keygen -b 4096 -t rsa -f /root/.ssh/id_rsagithub -q -N ""
  chmod 400 /root/.ssh/id_rsagithub
  chmod 644 /root/.ssh/id_rsagithub.pub
fi
if [ "$KEYS" = 2 ] && [ "$USB" = 1 ]; then
  
fi


echo 'Host githubssh' >> /root/.ssh/github
echo '        User git' >> /root/.ssh/github
echo '        HostName github.com' >> /root/.ssh/github
echo '        IdentityFile /root/.ssh/id_rsagithub' >> /root/.ssh/github

#Añado las llaves a ssh agent
eval "$(ssh-agent)"
ssh-add /root/.ssh/id_rsagithub
pub=$(cat /root/.ssh/id_rsagithub.pub)
echo ''
echo ''
echo ''
echo ''
echo ''
for (( ; ; ))
do
        githubuser=0
        githubpass=0
        read -r -p "Escribe tu usuario de github: " githubuser
        echo "Tu usuario de github es $githubuser"
        echo ''
        read -r -p "Escribe la contraseña de github de $githubuser: " githubpass
        curl -u "$githubuser:$githubpass" -X POST -d "{\"title\":\"`hostname$TODAY$SUFIJOGIT`\",\"key\":\"$pub\"}" https://api.github.com/user/keys
        if github-authenticated githubssh; then
            echo "Hemos conectado"
            break
        else
            echo "Algo ha fallado: el nombre de usuario o el api token."
            echo "Aquí tienes un manual para crear un api token: https://docs.github.com/es/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens"
            read -n 1 -s -r -p "Pulsa Enter para volver a intentar conectar"
        fi
done
