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

set CDPATH $CDPATH $HOME/Documents/Projects
