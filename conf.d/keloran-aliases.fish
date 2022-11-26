if type -q nerdctl
	alias docker="nerdctl"
end

if type -q yay
	if type -q paru
		alias yay=paru
	end
end

if type -q yay
	alias yeet="yay -Rcs"
else if type -q paru
	alias yeet="paru -Rcs"
end

function updatedb --wraps updatedb
	sudo updatedb
end

function yarn --wraps yarn
	/usr/bin/yarn --use-yarnrc $XDG_CONFIG_HOME/yarn/config
end

set CDPATH $CDPATH $HOME/Documents/Projects
