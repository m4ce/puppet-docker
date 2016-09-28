type Docker::Image = Struct[{
  Optional[image] => String,
  Optional[image_tag] => String,
  Optional[force] => Boolean,
  Optional[ensure] => Enum["latest", "present", "absent"]
}]
