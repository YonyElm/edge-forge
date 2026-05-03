FROM node:18-bullseye

# System dependencies
RUN apt-get update -qq && \
    apt-get install -y git ca-certificates curl vim bash-completion && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install opencode-ai globally
RUN npm install -g opencode-ai

# Set working directory
WORKDIR /workspace

# Environment variables
ENV HOME=/root
ENV NODE_ENV=production
ENV npm_config_prefix=/usr/local
ENV npm_config_cache=/tmp/npm-cache
ENV PATH=/usr/local/bin:$PATH

# Enable bash completion
RUN if [ -f /etc/bash_completion ]; then \
    echo ". /etc/bash_completion" >> /root/.bashrc; \
    fi

# Better prompt and aliases
RUN echo '\
export PS1="\u@sandbox:\w\$ "\n\
export LS_OPTIONS="--color=auto"\n\
eval "$(dircolors)"\n\
alias ls="ls $LS_OPTIONS"\n\
alias ll="ls -alF"\n\
alias la="ls -A"\n\
alias l="ls -CF"\n\
alias ..="cd .."\n\
alias ...="cd ../.."\n\
' >> /root/.bashrc

CMD ["bash"]
