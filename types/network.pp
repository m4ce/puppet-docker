type Docker::Network = Struct[{
  Optional[check_duplicate] => Boolean,
  Optional[driver] => String,
  Optional[internal] => Boolean,
  Optional[ipam] => Hash,
  Optional[enable_ipv6] => Boolean,
  Optional[options] => Hash,
  Optional[labels] => Hash,
  Optional[ensure] => Enum["present", "absent"]
}]
