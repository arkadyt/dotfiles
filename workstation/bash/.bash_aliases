alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -alF -G'
alias la='ls -A'
alias l='ls -CF'

alias dkrm-e="docker ps -aq --filter=status=exited | xargs -I {} docker rm -f {}"
alias dkrm-s="docker ps -aq --filter=status=stopped | xargs -I {} docker rm -f {}"
alias dkrm-es="docker ps -aq --filter=status=stopped --filter=status=exited | xargs -I {} docker rm -f {}"
alias dkrm-a="docker ps -aq | xargs -I % docker rm -f %"
alias dkirm-a="docker image ls -aq | xargs -I {} docker image rm -f {}"

alias gbr="git branch $@"
alias gst="git status $@"
alias gog="git log --oneline -10 $@"
alias glg="git log --oneline --graph -35 $@"
alias gdd="git add $@"
alias gcm="git commit $@"
alias gpl="git pull $@"
alias gps="git push $@"
alias gdi="git diff $@"
alias gch="git checkout $@"

alias py3="python3 $@"
alias py2="python2 $@"

alias vi="nvim $@"
