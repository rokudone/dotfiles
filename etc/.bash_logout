if [ $SHLVL = '1' ]; then
  if [ "$SSH_AGENT_PID" != "" ]; then
    ssh-agent -k
    ssh-add -D
  fi
fi
