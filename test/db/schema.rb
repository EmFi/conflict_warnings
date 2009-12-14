ActiveRecord::Schema.define do
  create_table "resources", :force => true do |t|
    t.column "name", :text
    t.column "resources_available", :integer
  end
  
  create_table "timestamps", :force => true do |t|
    t.column "name", :text
    t.column "updated_on", :datetime
  end

  create_table "timestamp_with_updated_ats", :force => true do |t|
    t.column "name", :text
    t.column "updated_at", :datetime
  end  

  create_table "resource_with_custom_accessors", :force => true do |t|
    t.column "name", :text
    t.column "resources_left", :integer
  end
  
  create_table "timestamp_with_custom_accessors", :force => true do |t|
    t.column "name", :text
    t.column "timestamp", :datetime
  end
end
