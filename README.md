# Instant connect via ssh to github with keys on your computer or with Yubikey/Onlykey
This is a simple bash script that when you run it you will have all this in an instant:
- Create your ssh key on your computer or a resident fido 2 key with your Yubikey or Onlykey (You can choose the type of resident key).
- The key will be added as an ssh key on your github
- Finally git is configured

When you're done running the script, you should be able to do things like "git clone githubssh:[your-private-repository]" and touch your yubikey/onlykey



**Instructions**: Copy and paste these commands and Voila!
```console
curl -o git-ssh.sh https://raw.githubusercontent.com/zaqueoae/ssh-github-yubikey/main/git-ssh.sh
bash ~/git-ssh.sh
```


https://github.com/zaqueoae/ssh-github-yubikey/assets/20475209/7fc916fc-ab1f-4292-98b4-566cb8463aa1



## Explanation:
- The difference between choosing yubikey or onlykey is that onlykey has to be unlocked using the physical keyboard, so it does not allow resident keys that require entering the pin.
- You can try ssh connection by running this command
  ```ssh -T githubssh```
