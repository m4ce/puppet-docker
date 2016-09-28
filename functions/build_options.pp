function docker::build_options($options, $i = 0) {
  if $options =~ Array {
    join($options, ',')
  } elsif $options =~ Hash {
    $r = $options.map |$k, $v| {
      if size($k) > 1 and $i == 0 {
        $option_prefix = '--'
      } else {
        $option_prefix = '-'
      }

      $value = docker::build_options($v, $i + 1)
      if $v =~ Hash {
        "${option_prefix}${k}${value}"
      } else {
        "${option_prefix}${k}=${value}"
      }
    }
    join($r, ' ')
  } else {
    $options
  }
}
