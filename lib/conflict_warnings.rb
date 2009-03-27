# FilterStaleContent
module ConflictWarnings #:nodoc: 
  module ActionView    
    module Base
      def self.included(base)
        base.send :include, InstanceMethods
      end
      
      module InstanceMethods
        
        def link_to_with_timestamp(*args, &block)
          if block_given?
            options      = args.first || {}
            html_options = args.second
            if String === options then
              options << (options.match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
            elsif Hash === options then
              options.update(:page_rendered_at, Time.now.to_i)
            end
            
            concat(link_to(capture(&block), options, html_options))
          else
            
            name         = args.first
            options      = args.second || {}
            html_options = args.third    
            if String === options then
              options << (options.match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
            elsif Hash === options then
              options.update(:page_rendered_at, Time.now.to_i)
            end
            link_to(name,options,html_options)
          end          
        end
        
        
        def link_to_remote_with_timestamp(name,options ={},html_options = nil)          
          if String === options[:url] then
            options[:url] << (options[:url].match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
          elsif Hash === options[:url] then
            options.update(:page_rendered_at, Time.now.to_i)
          end          
          link_to_remote(name, options, html_options)                        
        end
        
        def link_to_remote_with_timestamp_and_fallback(link, options = {}, html_options = {})
          if String === options[:url] then
            options[:url] << (options[:url].match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
          elsif Hash === options[:url] then
            options.update(:page_rendered_at, Time.now.to_i)
          end
          html_options[:href] = url_for(options[:url])
          link_to_remote_with_timestamp(link, options, html_options)
        end
      end      
    end
    
  end
  module ActionController
    module Base
      def self.included(base)
        base.send :include, InstanceMethods
        base.send :extend, ClassMethods
      end 
      
      module ClassMethods  
        
        mattr_accessor :valid_keys_for_conflict_warnings
        @@valid_keys_for_conflict_warnings = [               
        :simulate_conflict_on_requests_before, :message, :flash_key,:except, :only, :model, :id, 
        :time_stamp_key, :column_name, :params_id_key, :template ]
        
        
        def catch_conflicts(options = {},&block)
          options.assert_valid_keys(valid_keys_for_conflict_warnings)
          
          except = options[:except] ? options.delete(:except) : nil
          only = options[:only] ? options.delete(:only) : nil
          before_filter :except => except, :only => only do |controller|
            
            controller.redirect_if_content_changed(options,&block)              
          end
        end
        
      end
      
      module InstanceMethods        
        def redirect_if_content_changed(options = {},&block)
          if options[:simulate_conflict_on_requests_before].nil? && params[options[:params_id_key]].nil? && params[:id].nil? && options[:id].nil? 
            raise ArgumentError, "filter_fresh_request: You must provide a method of generating a time used to decide which requests are fresh. Please see filter_stale_content documentation."
          elsif options[:simulate_conflict_on_requests_before] && options[:params_id_key] 
            raise ArgumentError, "filter_fresh_request: Only needs one of :redirect_before or :param options is required, both were supplied."
          end
          @redirect_requests_before =
          if options[:simulate_conflict_on_requests_before]
            options[:simulate_conflict_on_requests_before]
          else
            model = options[:model] || self.controller_name.singularize
            model = model.to_s.camelcase
            model = Kernel.const_get(model)
            model.column_names.grep(/(updated_(at|on))/)
            column_name = options[:column_name] || $1
            
            id = options[:id] || params[options[:params_id_key]] || params[:id]
            @instance = model.find(id)
            @instance.send(column_name)         
          end
          @redirect_requests_after = options[:simulate_conflict_on_requests_after]
          time_stamp_key = options[:time_stamp_key]|| :page_rendered_at 
          time_stamp = params[time_stamp_key]
          flash_key = options[:flash_key] || :warning          
          message = options [:message] || "Your request will not be processed because the data you were viewing is out of date. The page has been refreshed. Please try again."
          @rendered_at = Time.at(time_stamp.to_i) if time_stamp
          
          if @rendered_at && (@redirect_requests_before && @rendered_at < @redirect_requests_before ||
                              @redirect_requests_after && @rendered_at > @redirect_requests_after)
            flash[flash_key] = message unless message.blank?
            if block_given?             
              instance_eval(&block) 
            else
              template_to_use = options[:template] || File.join(controller_name, action_name)
              template_to_use.sub!(/(_conflict)?$/, "_conflict")
              respond_to do |format|
                format.html {
                  if template_exists?(template_to_use)
                    render :file => template_to_use, :status => 409
                  else
                    redirect_to :back#, :status => 409
                  end
                  }
                
                format.js {
                  if template_exists?(template_to_use)
                    render :file => template_to_use,  :status => 409
                  else
                   render(:update, :status => 409) do |page| 
                    
                    page.redirect_to :back
                    alert(message)
                   end
                   
                  end
                  flash.discard
                }
              end
            end                  
          end
          
        end
      end #InstanceMethods
      
    end
  end
  
end #module ConflictWarnings