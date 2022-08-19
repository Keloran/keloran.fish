function cleanDockerImages --description "Cleans Docker images"
	command docker ps -a | grep 'Exited' | awk '{print $1}' | xargs docker rm
	command docker images -aq | xargs docker rmi
end