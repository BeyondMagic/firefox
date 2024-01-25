#!/usr/bin/env nu
#
# Compiles bunch of SASS files into CSS files putting them into a folder.
#
# Dependencies:
#	nushell
#	dart-sass
#	optional for watching files: task.nu (refer to: https://www.nushell.sh/book/background_task.html)
#
# João Farias © 2023-2024 BeyondMagic <beyondmagic@mail.ru>

const distribution = './distribution/'
const name_group = 'sass-youtube'
const firefox_content = 'firefox-usercontent.css'
const firefox_chrome = 'firefox-userchrome.css'
const sidebery_sidebar = 'sidebery-sidebar.css'
const sidebery_group_page = 'sidebery-group_page.css'

use std log
use std assert

# Link files a mozilla profile.
export def link [
	--profile : string, # Profile, by default the latest (last modified) firefox profile.
] -> int {
	mut folder = ''
	if ($profile | is-empty) {

		# Roadmap 1.: automatic deduction of the Firefox profile folder.
		let host = (sys | get host | get long_os_version | str downcase)
		assert ($host | str contains 'linux')

		const mozilla_folder = '~/.mozilla/firefox/'

		# Exit if fails to find one mozilla .default folder.
		if not ($mozilla_folder | path exists) or (ls $mozilla_folder | find '.default' | is-empty) {
			log critical $'Found no firefox folders at "($mozilla_folder | path expand)". You should specify one instead.'
			return 1
		}

		$folder = ((ls $mozilla_folder | sort-by 'modified' | reverse | first).name | path expand)
	}

	let chrome = $folder + '/chrome/'
	mkdir $chrome

	print $'Linking files at "($chrome)".'
	^ln -sf ($distribution + $firefox_content | path expand) ($chrome + 'userContent.css' | path expand)
	^ln -sf ($distribution + $firefox_chrome | path expand) ($chrome + 'userChrome.css' | path expand)

	print $'Files at "($chrome)" are now:'
	(ls $chrome)
}

export def compile [--watch (-w), input: any, outname: any] {
	let output = ($outname | prepend ($distribution) | str join)
	if $watch {
		use task.nu
		task spawn --group $name_group {
			sass --watch --no-source-map ($input) ($output)
		}
	} else {
		sass --no-source-map ($input) ($output)
	}
}

export def main [--watch (-w), --clean (-c)] {	
	if $clean and $watch {
		echo "You can't use both flags (--watch/-w and --clean/-c) at the same time!"
		exit 1
	}

	if $clean {
		use task.nu
		task kill --group $name_group
		task clean --group $name_group
		task group remove $name_group
	}

	if $watch {
		use task.nu
		task group add $name_group
	}

	compile -w `Group Page.scss` $sidebery_group_page
	compile -w `Sidebar.scss` $sidebery_sidebar
	compile -w `userChrome.scss` $firefox_chrome
	compile -w `userContent.scss` $firefox_content

	if $watch {
		use task.nu
		echo (task status)
		echo "Use `./helper.nu --clean` to remove the new processes created!"
	}
}
