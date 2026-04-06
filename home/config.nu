$env.config.buffer_editor = "emacs"
$env.config.history = {
    file_format: sqlite
    max_size: 1_000_000
    sync_on_enter: true
    isolation: true
}
$env.config.hooks.command_not_found = {|cmd|
    let pkgs = (nix-locate $"bin/($cmd)" --minimal | lines | par-each {|it| str replace .out ""} | par-each {|it| {pkg: $it, length: ($it | str length)}})
    let pretty_commands = {|list|
        $list | each {|cmd|
            $"    (ansi {fg: "default" attr: "di"})($cmd)(ansi reset)"
        }
    }
    let commands_in_path = (if ($nu.os-info.name == windows) {
        $env.Path | each {|directory|
                if ($directory | path exists) {
                    let cmd_exts = $env.PATHEXT | str downcase | split row ';' | str trim --char .
                    ls $directory | get name | path parse | where {|it| $cmd_exts | any {|ext| $ext == ($it.extension | str downcase)} } | get stem
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
        if ($pkgs | length | $in > 0) {
	   return $"\n($cmd) is found in:\n(do $pretty_commands ($pkgs | sort-by length | get pkg)| str join "\n")"
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
$env.config.completions.external = {enable: true, completer: $completers}
def --wrapped emacs [...rest] { job spawn {^emacs ...$rest} }
