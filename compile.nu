#!/usr/bin/env nu
#
# Compiles bunch of SASS files into CSS files putting them into a folder.
#
# Dependencies:
# - nushell
# - dart-sass
#
# João Farias © 2023 BeyondMagic <beyondmagic@mail.ru>

$env.folder = './distribution/'

def compile [input: any, outname: any] {
	mut $output = ($outname | prepend ($env.folder) | str join)
	sass --no-source-map ($input) ($output)
}

def main [] {
	compile `Group Page.scss` `sidebery-group_page.css`
	compile `Sidebar.scss` `sidebery-sidebar.css`
	compile `userChrome.scss` `firefox-userchrome.css`
	compile `userContent.scss` `firefox-usercontent.css`
}
