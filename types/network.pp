type Docker::Network = Struct[{
  Optional[check_duplicate] => Boolean,
  Optional[driver] => String,
  Optional[Internal] => Boolean,
  Optional[IPAM] => Hash,
  Optional[enable_ipv6] => Boolean,
  Optional[options] => Hash,
  Optional[labels] => Hash,
  Optional[ensure] => Enum["present", "absent"]
}]
