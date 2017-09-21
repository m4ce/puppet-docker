type Docker::Gc::Options = Struct[{
  Optional[grace_period_seconds]    => Integer,
  Optional[force_image_removal]     => Boolean,
  Optional[force_container_removal] => Boolean,
  Optional[minimum_image_to_save]   => Integer
}]
