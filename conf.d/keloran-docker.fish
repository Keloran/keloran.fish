function cleanDockerImages --description "Cleans Docker images"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	command $dockerCmd ps -a | grep 'Exited' | awk '{print $1}' | xargs $dockerCmd rm
	command $dockerCmd images -aq | xargs $dockerCmd rmi
end

function dockerRemoveDangling --description "Removes dangling images"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	command $dockerCmd images -f 'dangling=true' -q | awk '{print $1}' | xargs -L1 $dockerCmd rmi
end

function dockerUpdateAll --description "Updates all known docker images to the latest version"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	command $dockerCmd images --format '{{.Repository}} {{.Tag}}' | awk '{print $1 ":" $2}' | grep -iv 'repository' | xargs -L1 $dockerCmd pull
end

function dockerPsClean --description "Clean all the non valid images from docker ps"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	set --local exitedImagesExist (command $dockerCmd ps -a --format '{{.Names}} {{.Status}}' | grep 'Exited' | wc -l)
  set --local createdImagesExist (command $dockerCmd ps -a --format '{{.Names}} {{.Status}}' | grep 'Created' | wc -l)
	if test $exitedImagesExist -gt 0
		command $dockerCmd ps -a --format '{{.Names}} {{.Status}}' | grep 'Exited' | awk '{print $1}' | xargs $dockerCmd rm
	end
  if test $createdImagesExist -gt 0
    command $dockerCmd ps -a --format '{{.Names}} {{.Status}}' | grep 'Created' | awk '{print $1}' | xargs $dockerCmd rm
  end
end

function dockerClean --description "Docker Clean"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	set -l cmd ""
	if  type -q docker-clean
		set cmd "$cmd && docker-clean"
	end

	echo $cmd
end

function dockerStop --description "Stop container"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	if test -e $PWD/Makefile
		if grep "docker-down" $PWD/Makefile
			command make docker-down
			dockerPsClean
			commandline -r (dockerClean)
			commandline -f execute
			return
		end
	end

	if test -e $PWD/docker-compose.yml || test -e $PWD/docker-compose.yaml
		command $dockerCmd compose stop
		command yes | docker-compose rm
		dockerPsClean
		commandline -r (dockerClean)
		commandline -f execute
		return
	end

	if test -e $PWD/Dockerfile || test -e $PWD/Containerfile
		set -l dockerPath (path basename $PWD | tr '[:upper:]' '[:lower:]')
		command $dockerCmd stop "$dockerPath"_build
		command $dockerCmd rmi "$dockerPath"_build
		dockerPsClean
		commandline -r (dockerClean)
		commandline -f execute
		return
	end
end

function dockerStart --description "Start Container"
	dockerStop

	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	if test -e $PWD/Makefile
		if grep "docker-up" $PWD/Makefile
			command make docker-up
			return
		end
	end

	if test -e $PWD/docker-compose.yml || test -e $PWD/docker-compose.yaml
		command $dockerCmd compose build
		command $dockerCmd compose up -d
		command $dockerCmd compose ps
		return
	end

	if test -e $PWD/Dockerfile || test -e $PWD/Containerfile
		set -l dockerPath (path basename $PWD | tr '[:upper:]' '[:lower:]')
		command $dockerCmd build -t "$dockerPath"_build
		command $dockerCmd run -P -rm -d -it --name "$dockerPath"_build $dockerPath
		return
	end
end

function dockerExec --description "Execute in container"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	if test -e $PWD/docker-compose.yml || test -e $PWD/docker-compose.yaml
		if test (count $argv) -eq 0
			echo "Missing container name to execute into"
			command $dockerCmd compose ps -a
			return
		else
			if test (count $argv) -eq 2
				command $dockerCmd compose exec $argv[1] $argv[2]
			else
				command $dockerCmd compose exec $argv[1] sh
			end
			return
		end
	end

	if test -e $PWD/Dockerfile || test -e $PWD/Containerfile
		set -l dockerPath (path basename $PWD | tr '[:upper:]' '[:lower:]')
		if test (count $argv) -eq 0
			command $dockerCmd exec "$dockerPath"_build sh
		else
			command $dockerCmd exec "$dockerPath"_build $argv[1]
		end
		return
	end
end

function dockerLogs --description "Get the logs for containers"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	if test -e $PWD/docker-compose.yml || test -e $PWD/docker-compose.yaml
		if test (count $argv) -eq 0
			command $dockerCmd logs -f
		else
			command $dockerCmd logs -f $argv
		end
		return
	end

	if test -e $PWD/Dockerfile || test -e $PWD/Containerfile
		set -l dockerPath (path basename $PWD | tr '[:upper:]' '[:lower:]')
		command $dockerCmd logs -f "$dockerPath"_build
		return
	end
end

function dockerRestart --description "Restart containers"
	set --local dockerCmd docker
	if type -q nerdctl
		set dockerCmd nerdctl
	end

	if test -e $PWD/docker-compose.yml || test -e $PWD/docker-compose.yaml
		if test (count $argv) -gt 0
			command $dockerCmd stop $argv
			command $dockerCmd start $argv
			return
		end
	end

	dockerStop
	dockerStart
end
