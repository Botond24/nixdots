$env.config.buffer_editor = "emacs"
$env.config.history = {
    file_format: sqlite
    max_size: 1_000_000
    sync_on_enter: true
    isolation: true
}

$env.config.hooks.command_not_found = {|cmd|
    let pretty_commands = {|list|
        $list | each {|com|
            $"    (ansi {fg: "default" attr: "di"})($com)(ansi reset)"
        }
    }
    let commands_in_path = (if ($nu.os-info.name == windows) {
        $env.Path | each {|directory|
                if ($directory | path exists) {
                    let cmd_exts = $env.PATHEXT | str lowercase | split row ';' | str trim --char .
                    ls $directory | get name | path parse | where {|it| $cmd_exts | any {|ext| $ext == ($it.extension | str lowercase)} } | get stem
                }
            }
    } else {
        $env.PATH | each {|directory|
                if ($directory | path exists) {
                    ls $directory | get name | path parse | update parent "" | path join
                }
            }
    } | flatten | wrap cmd)
    let closest_commands = (
        $commands_in_path | insert distance {|it|
            $it.cmd | str distance $cmd
        } | uniq | sort-by distance
    )
    if (
        $closest_commands | get distance | first | $in >= 3
    ) {
        let pkgs = (nix-locate $"bin/($cmd)" --minimal | lines | each {|it| str replace .out ""} | each {|it| {pkg: $it, length: ($it | str length)}})
        if ($pkgs | length | $in > 0) {
	   return $"\n($cmd) is found in:\n(do $pretty_commands ($pkgs | sort-by length | get pkg | first 3) | str join "\n")"
	} else {
	   return $"\n($cmd) does not exist"
	}
    }
    $"\ndid you mean?\n(do $pretty_commands ($closest_commands | get cmd | first 3) | str join "\n")"
}

let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'" | from tsv --flexible --noheaders --no-infer | rename value description | update value {|row|
      let value = $row.value
      let need_quote = ["\\" ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
      if ($need_quote and ($value | path exists)) {
         let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
         $'"($expanded_path | str replace --all "\"" "\\\"")"'
      } else {$value}
    }
}

let completers = {|spans|
    let expanded_alias = (
        scope aliases | where name == $spans.0 | get 0 | get expansion
    )
    # overwrite
    let spans = (if $expanded_alias != null {
        # put the first word of the expanded alias first in the span
        $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
    } else { $spans })
    do $fish_completer $spans
}
$env.config.completions.external = {enable: true, completer: $fish_completer}

def --wrapped emacs [...rest] { job spawn {^emacs ...$rest} }

def pls [] { ^sudo ...(history | enumerate | drop 1 | last | get item.command | split row ' ')}

def --env "nh os update" [
--flake: string,
...inputs: string
] {
  let fin_flake = ($flake | default "/etc/nixos/")
  nix flake update --flake $fin_flake ...$inputs
}

#def --wrapped "nh os switch" [
#--message (-m): string
#...rest: string
#] {
#  git -C $env.NH_FLAKE add $"$env.NH_FLAKE/."
#  nh os switch;
#  match $message {
#  	null => {git commit},
#	_ => {git commit -m $"$message"}
#  }
#  git -C $env.NH_FLAKE push
#}
