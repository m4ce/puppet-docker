class docker::install {
  $docker::packages.each |String $package_name, Hash $package| {
    package {$package_name:
      * => $package
    }
  }
}
