require File.expand_path(File.dirname(__FILE__) + '/lib/models')
ActionController::Base.send(:session=, { :key => "_myapp_session", :secret => "some secret phrase that doesn't matter" })
TestViewPath = File.expand_path(File.dirname(__FILE__) + '/templates')




module ConflictWarningsTest
  class ControllerStub < ActionController::Base
    
    def rescue_action(e) raise e end;
    def action1
      render :text => "Action1 Successful"
    end
    def action2
      render :text => "Action2 Successful"
    end
   

    def get_model model
      m = model
      unless ActiveRecord::Base.send(:subclasses).include?(model)
        if model.is_a?(ActiveRecord::Base)          
          m = model.class
        else
          m = model.to_s.camelcase
          m = Kernel.const_get(m)
        end
      end
      m
 
    end


    attr_accessor :model
    def self.controller_name
      @@controller_name
    end
    def self.controller_name= value
      @@controller_name = value
    end
  end
end


