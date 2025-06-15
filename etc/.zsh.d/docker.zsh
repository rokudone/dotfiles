#
# Defines Docker aliases.
#
# Author:
#   François Vantomme <akarzim@gmail.com>
#

#
# Aliases
#

# Docker
# alias d='docker'
alias da='docker attach'
alias db='docker build'
alias dd='docker diff'
alias ddf='docker system df'
alias de='docker exec'
alias dE='docker exec -it'
alias dh='docker history'
alias di='docker images'
alias din='docker inspect'
alias dim='docker import'
alias dk='docker kill'
alias dl='docker logs'
alias dli='docker login'
alias dlo='docker logout'
alias dls='docker ps'
alias dp='docker pause'
alias dP='docker unpause'
alias dpl='docker pull'
alias dph='docker push'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dr='docker run'
alias dR='docker run -it --rm'
alias dRe='docker run -it --rm --entrypoint /bin/bash'
alias dRM='docker system prune'
alias drm='docker rm'
alias drmi='docker rmi'
alias drn='docker rename'
alias ds='docker start'
alias dS='docker restart'
alias dss='docker stats'
alias dsv='docker save'
alias dt='docker tag'
alias dtop='docker top'
alias dup='docker update'
alias dV='docker volume'
alias dv='docker version'
alias dw='docker wait'
alias dx='docker stop'

## Container (C)
alias dC='docker container'
alias dCa='docker container attach'
alias dCcp='docker container cp'
alias dCd='docker container diff'
alias dCe='docker container exec'
alias dCin='docker container inspect'
alias dCk='docker container kill'
alias dCl='docker container logs'
alias dCls='docker container ls'
alias dCp='docker container pause'
alias dCpr='docker container prune'
alias dCrn='docker container rename'
alias dCS='docker container restart'
alias dCrm='docker container rm'
alias dCr='docker container run'
alias dCR='docker container run -it --rm'
alias dCRe='docker container run -it --rm --entrypoint /bin/bash'
alias dCs='docker container start'
alias dCss='docker container stats'
alias dCx='docker container stop'
alias dCtop='docker container top'
alias dCP='docker container unpause'
alias dCup='docker container update'
alias dCw='docker container wait'

## Image (I)
alias dI='docker image'
alias dIb='docker image build'
alias dIh='docker image history'
alias dIim='docker image import'
alias dIin='docker image inspect'
alias dIls='docker image ls'
alias dIpr='docker image prune'
alias dIpl='docker image pull'
alias dIph='docker image push'
alias dIrm='docker image rm'
alias dIsv='docker image save'
alias dIt='docker image tag'

## Volume (V)
alias dV='docker volume'
alias dVin='docker volume inspect'
alias dVls='docker volume ls'
alias dVpr='docker volume prune'
alias dVrm='docker volume rm'

## Network (N)
alias dN='docker network'
alias dNs='docker network connect'
alias dNx='docker network disconnect'
alias dNin='docker network inspect'
alias dNls='docker network ls'
alias dNpr='docker network prune'
alias dNrm='docker network rm'

## System (Y)
alias dY='docker system'
alias dYdf='docker system df'
alias dYpr='docker system prune'

## Stack (K)
# alias dK='docker stack'
# alias dKls='docker stack ls'
# alias dKps='docker stack ps'
# alias dKrm='docker stack rm'

## Swarm (W)
# alias dW='docker swarm'

## CleanUp (rm)
# Clean up exited containers (docker < 1.13)
alias drmC='docker rm $(docker ps -qaf status=exited)'
# Clean up dangling images (docker < 1.13)
alias drmI='docker rmi $(docker images -qf dangling=true)'
# Clean up dangling volumes (docker < 1.13)
alias drmV='docker volume rm $(docker volume ls -qf dangling=true)'


# Docker Machine (m)
# alias dm='docker-machine'
# alias dma='docker-machine active'
# alias dmcp='docker-machine scp'
# alias dmin='docker-machine inspect'
# alias dmip='docker-machine ip'
# alias dmk='docker-machine kill'
# alias dmls='docker-machine ls'
# alias dmpr='docker-machine provision'
# alias dmps='docker-machine ps'
# alias dmrg='docker-machine regenerate-certs'
# alias dmrm='docker-machine rm'
# alias dms='docker-machine start'
# alias dmsh='docker-machine ssh'
# alias dmst='docker-machine status'
# alias dmS='docker-machine restart'
# alias dmu='docker-machine url'
# alias dmup='docker-machine upgrade'
# alias dmv='docker-machine version'
# alias dmx='docker-machine stop'

# Docker Compose (c)
docker-compose-attach() {
    local service
    if [[ $# -eq 0 ]]; then
        service=$(docker-compose config --services | sort | fzf --height 40% --reverse)
    else
        service="$1"
    fi
    if [[ -n $service ]]; then
        echo "Attaching to $service..."

        # コンテナにアタッチ
        docker-compose attach $service

        echo "Detached from $service. The container is still running."
    else
        echo "No service selected or specified."
    fi
}

alias dc='docker compose'
alias dca='docker-compose-attach'
alias dcb='docker compose build'
alias dcB='docker compose build --no-cache'
alias dcd='docker compose down'
alias dce='docker compose exec'
alias dck='docker compose kill'
alias dcl='docker compose logs'
alias dcla='docker compose logs api -f'
alias dclh='docker compose logs hp -f'
alias dclb='docker compose logs bo -f'
alias dcls='docker compose logs staff -f'
alias dclu='docker compose logs user -f'
alias dcls='docker compose ps'
alias dcp='docker compose pause'
alias dcP='docker compose unpause'
alias dcpl='docker compose pull'
alias dcph='docker compose push'
alias dcps='docker compose ps'
alias dcr='docker compose run'
alias dcR='docker compose run --rm'
alias dcrm='docker compose rm'
alias dcs='docker compose start'
alias dcsc='docker compose scale'
alias dcS='docker compose restart'
alias dcu='docker compose up'
alias dcU='docker compose up -d'
alias dcv='docker compose version'
alias dcx='docker compose stop'

# dcS hoge && dcl -f hoge を行うコマンド
function dcSl() {
    local service_name="$1"
    docker compose restart "$service_name" && docker compose logs -f "$service_name"
}
