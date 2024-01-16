#!/usr/bin/env nu
#
# Compiles bunch of SASS files into CSS files putting them into a folder.
#
# Dependencies:
# - nushell
# - dart-sass
# - optional for watching files: task.nu (refer to: https://www.nushell.sh/book/background_task.html)
#
# João Farias © 2023 BeyondMagic <beyondmagic@mail.ru>

$env.folder = './distribution/'
$env.name_group = 'sass-youtube'

def compile [--watch (-w), input: any, outname: any] {
	let output = ($outname | prepend ($env.folder) | str join)
	if $watch {
		use task.nu
		task spawn --group $env.name_group {
			sass --watch --no-source-map ($input) ($output)
		}
	} else {
		sass --no-source-map ($input) ($output)
	}
}

def main [--watch (-w), --clean (-c)] {	
	if $clean and $watch {
		echo "You can't use both flags (--watch/-w and --clean/-c) at the same time!"
		exit 1
	}

	if $clean {
		use task.nu
		task kill --group $env.name_group
		task clean --group $env.name_group
		task group remove $env.name_group
	}

	if $watch {
		use task.nu
		task group add $env.name_group
	}

	compile -w `Group Page.scss` `sidebery-group_page.css`
	compile -w `Sidebar.scss` `sidebery-sidebar.css`
	compile -w `userChrome.scss` `firefox-userchrome.css`
	compile -w `userContent.scss` `firefox-usercontent.css`

	if $watch {
		use task.nu
		echo (task status)
		echo "Use `./helper.nu --clean` to remove the new processes created!"
	}
}
