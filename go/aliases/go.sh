# Go related aliases

GO_HOME=/opt/go

if [[ ":$PATH:" != *":$GO_HOME/bin:"* ]]; then
  export PATH="$GO_HOME/bin:$PATH"
fi


