# Instant connect via ssh to github with keys on your computer or with Yubikey/Onlykey
This is a simple bash script that when you run it you will have all this in an instant:
- Create your ssh key on your computer or a resident fido 2 key with your Yubikey or Onlykey
- The key will be added as an ssh key on your github
- Finally git is configured


**Instructions**: Copy and paste these commands and Voila!
```console
curl -o https://github.com/zaqueoae/yubikey-ssh/blob/main/git-ssh.sh
bash ~/git-ssh.sh
```
