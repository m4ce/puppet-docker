type Docker::Volume = Struct[{
  Optional[driver] => String,
  Optional[driver_opts] => Hash,
  Optional[labels] => Hash,
  Optional[ensure] => Enum["present", "absent"]
}]
