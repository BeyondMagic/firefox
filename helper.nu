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
]: nothing -> any {
	mut folder = ''
	if ($profile | is-empty) {

		# Roadmap 1.: automatic deduction of the Firefox profile folder.
		let host = (sys host | get long_os_version | str downcase)
		assert ($host | str contains 'linux')

		let mozilla_folder = glob '~/.mozilla/firefox/' | first

		# Exit if fails to find one mozilla .default folder.

		if not ($mozilla_folder | path exists) or (ls $mozilla_folder | where name =~ '.default' | is-empty) {
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

export def compile [
	input: string
	outname: string
]: nothing -> nothing {
	let output = $distribution + $outname
	^sass --no-source-map $input $output
}

export def main [] {
	compile `Group Page.scss` $sidebery_group_page
	compile `Sidebar.scss` $sidebery_sidebar
	compile `userChrome.scss` $firefox_chrome
	compile `userContent.scss` $firefox_content
}
