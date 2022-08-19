# Update System
function updateMacOS --description "brew update"
	set -l cmd ""

	if type -q brew
		set cmd "brew update"
		set cmd "$cmd && brew upgrade"
		set cmd "$cmd && brew upgrade --cask"
	end

	if type -q mas
		set cmd "$cmd && mas outdate"
	end

	echo $cmd
end

function updateArch --description "Update Arch System"
	set -l cmd ""

	if type -q pacman
		set cmd "sudo pacman -Syu"
	end

	if type -q yay 
		set cmd "yay -Syu"
	end

	if type -q paru
		set cmd "paru -Syu"
	end

	if type -q topgrade
		set cmd "topgrade"
	end

	echo $cmd
end

function updateSys --description "Update system"
	switch (uname)
	case Linux	
		if type -q pacman
			commandline -r (updateArch)
		end
	case Darwin
		commandline -r (updateMacOS)
	end 

	commandline -f execute
end

# Clean System
function cleanMacOS --description "Clean MacOS"
	set cmd -l ""
	if type -q brew
		set cmd "brew cleanup"
	end

	echo $cmd
end

function cleanArch --description "Clean Arch"
	set cmd -l ""
	if type -q pacman
		set cmd "pacman -Sc"
	end

	if type -q yay
		set cmd "yay -Sc"
	end

	if type -q paru
		set cmd "paru -Sc"
	end

	echo $cmd
end

function cleanSystem --description "Clean system"
	switch (uname)
	case Linux
		if type -q pacman
			commandline -r (cleanArch)
		end
	case Darwin
		commandline -r (cleanMacOS)
	end

	commandline -f execute
end

