Puppet::Type.newtype(:docker_image) do
  @doc = 'Docker image'

  ensurable do
    defaultvalues
    defaultto(:present)

    newvalue(:latest) do
      provider.create
    end

    def issync?(is)
      @lateststamp ||= (Time.now.to_i - 1000)

      @should.each do |should|
        case should
          when :present
            return true unless is == :absent
          when :latest
            # Short-circuit images that are not present
            return false if is == :absent

            # Don't run 'latest' more than about every 5 minutes
            if @latest and ((Time.now.to_i - @lateststamp) / 60) < 5
              self.debug "Skipping latest check"
            else
              @lateststamp = Time.now.to_i
            end
         end
       end
       false
    end
  end

  newparam(:name) do
    desc "Docker image name"
    isnamevar
  end

  newparam(:image_name) do
    desc "Specifies the image name"

    isnamevar
    isrequired
  end

  newparam(:image_tag) do
    desc "Specifies the image tag"

    isnamevar
    isrequired
    defaultto :latest
  end

  newparam(:force) do
    desc "Force image removal"

    defaultto(:false)
    newvalues(:true, :false)
  end

  # Our title_patterns method for mapping titles to namevars for supporting
  # composite namevars.
  def self.title_patterns
    identity = lambda {|x| x}
    [
      [
        /^((.*?):(.*?))$/,
        [
          [ :name, identity ],
          [ :image_name, identity ],
          [ :image_tag, identity ]
        ]
      ],
      [
        /^((.+))$/,
        [
          [ :name, identity ],
          [ :image_name, identity ]
        ]
      ]
    ]
  end

  autorequire(:service) do
    ["docker"]
  end
end
