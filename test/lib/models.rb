class Timestamp < ActiveRecord::Base
  def timestamp_at time
    time
  end
end

class Resource < ActiveRecord::Base
  class << self
    def resources_left
      return 4
    end
    def no_resources_left
      return 0
    end
    def somethings_available
      return 3
    end
    def returns_true
      true
    end
    def returns_false
      false
    end
  end
  def acquire_lock_for_user user    
    return user == "Granted"
  end
end

class TimestampWithCustomAccessor < ActiveRecord::Base
end

class TimestampWithUpdatedAt < ActiveRecord::Base
end

class ResourceWithCustomAccessor < ActiveRecord::Base
end

