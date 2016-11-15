function docker::build_options($options, $i = 0) {
  if $options =~ Hash {
    $r = $options.map |$k, $v| {
      if size($k) > 1 and $i == 0 {
        $option_prefix = '--'
      } else {
        $option_prefix = '-'
      }

      $value = docker::build_options($v, $i + 1)
      if $v =~ Hash {
        "${option_prefix}${k}${value}"
      } elsif $v =~ Array {
        join($v.map |$i| { "${option_prefix}${k}=${i}" }, ' ')
      } else {
        "${option_prefix}${k}=${value}"
      }
    }
    join($r, ' ')
  } else {
    $options
  }
}
