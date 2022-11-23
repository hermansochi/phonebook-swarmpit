deploy:
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'docker network create --driver=overlay --attachable traefik-public || true'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'export NODE_ID=$$(docker info -f "{{.Swarm.NodeID}}") ; echo NODE_ID=$$NODE_ID'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'docker node update --label-add swarmpit.db-data=true $$(docker info -f "{{.Swarm.NodeID}}")'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'docker node update --label-add swarmpit.influx-data=true $$(docker info -f "{{.Swarm.NodeID}}")'
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'rm -rf swarmpit && mkdir swarmpit'
	scp -o StrictHostKeyChecking=no -P ${PORT} docker-compose-production.yml deploy@${HOST}:swarmpit/docker-compose.yml
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd swarmpit && docker stack deploy -c docker-compose.yml swarmpit'

rollback:
	ssh -o StrictHostKeyChecking=no deploy@${HOST} -p ${PORT} 'cd swarmpit_${BUILD_NUMBER} && docker stack deploy -c docker-compose.yml swarmpit'