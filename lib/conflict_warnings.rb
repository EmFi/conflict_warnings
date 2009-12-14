#require 'pp'

module ConflictWarnings #:nodoc:
  module ActionView
    module Helpers
      module UrlHelper
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
                options[:timestamp_key] ||= :page_rendered_at
                options.merge!({options.delete(:timestamp_key) =>  Time.now.to_i})
              elsif Symbol === options then
                raise ArgumentError, "link_to_with_timestamp cannot be used with symbol targets such as :back"
              end
              
              concat(link_to(capture(&block), options, html_options))
            else
              
              name         = args.first
              options      = args.second || {}
              html_options = args.third
              if String === options then
                options << (options.match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
              elsif Hash === options then
                options[:timestamp_key] ||= :page_rendered_at
                options.merge!({options.delete(:timestamp_key) => Time.now.to_i})
              elsif Symbol === options then
                raise ArgumentError, "link_to_with_timestamp cannot be used with symbol targets such as :back"
              end
              link_to(name,options,html_options)
            end
          end
          
          def link_to_with_timestamp_if(condition, name, options = {}, html_options = {}, &block)
            link_to_with_timestamp_unless(!condition, name, options, html_options , &block)
          end
          
          def link_to_with_timestamp_unless(condition, name, options = {}, html_options = {}, &block)
            if condition
              if block_given?
                block.arity <= 1 ? yield(name) : yield(name, options, html_options)
              else
                name
              end
            else
              link_to_with_timestamp(name, options, html_options)
            end
          end
          
          def link_to_remote_with_timestamp(name,options ={},html_options = nil)
            if String === options[:url] then
              options[:url] << (options[:url].match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
            elsif Hash === options[:url] then
              options[:timestamp_key] ||= :page_rendered_at
              options.merge!({options.delete(:timestamp_key)=> Time.now.to_i})
            elsif Symbol === options then
              raise ArgumentError, "link_to_remote_with_timestamp cannot be used with symbol targets such as :back"
            end
            link_to_remote(name, options, html_options)
          end
          
          def link_to_remote_with_timestamp_and_fallback(link, options = {}, html_options = {})
            if String === options[:url] then
              options[:url] << (options[:url].match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
            elsif Hash === options[:url] then
              options[:timestamp_key] ||= :page_rendered_at
              options.merge!({options.delete(:timestamp_key) => Time.now.to_i})
            elsif Symbol === options then
              raise ArgumentError, "link_to_remote_with_timestamp_and_fallback cannot be used with symbol targets such as :back"
            end
            html_options[:href] = url_for(options[:url])
            link_to_remote_with_timestamp(link, options, html_options)
          end
        end #InstanceMEthods
      end #UrlHelper
      
      module PrototypeHelper
        def self.included(base)
          base.send :include, InstanceMethods
        end
        
        module InstanceMethods
          def link_to_with_timestamp_unless(condition, name, options = {}, html_options = {}, &block)
            if condition
              if block_given?
                block.arity <= 1 ? yield(name) : yield(name, options, html_options)
              else
                name
              end
            else
              link_to_with_timestamp(name, options, html_options)
            end
          end
          
          def link_to_remote_with_timestamp(name,options ={},html_options = nil)
            if String === options[:url] then
              options[:url] << (options[:url].match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
            elsif Hash === options[:url] then
              options[:timestamp_key] ||= :page_rendered_at
              options.merge!({options.delete(:timestamp_key)=> Time.now.to_i})
            elsif Symbol === options then
              raise ArgumentError, "link_to_remote_with_timestamp cannot be used with symbol targets such as :back"
            end
            link_to_remote(name, options, html_options)
          end
          
          def link_to_remote_with_timestamp_and_fallback(link, options = {}, html_options = {})
            if String === options[:url] then
              options[:url] << (options[:url].match(/\?/) ? "&" : "?") + "page_rendered_at=#{Time.now.to_i}"
            elsif Hash === options[:url] then
              options[:timestamp_key] ||= :page_rendered_at
              options.merge!({options.delete(:timestamp_key) => Time.now.to_i})
            elsif Symbol === options then
              raise ArgumentError, "link_to_remote_with_timestamp_and_fallback cannot be used with symbol targets such as :back"
            end
            html_options[:href] = url_for(options[:url])
            link_to_remote_with_timestamp(link, options, html_options)
          end
        end #InstanceMEthods
      end #PrototypeHelper
    end #Helpers
  end #ActionView
  
  module ActionController
    module Base
      def self.included(base)                
        base.send :include, InstanceMethods
        base.send :extend, ClassMethods
      end
      

      
      CWCommonValidKeys = [
        :message, :flash_key, :model, :id,
        :accessor, :params_id_key, :find_options, :template ]
        
      CWInstanceSelectionKeys =[:id, :params_id_key, :find_options, :class_method]
        
      CWModelSelectionKeys = [:model]
        
      CWFilterOptions = [:only, :except]
        
      CWSimulationKeys = [:simulate_conflict_on_requests_before,
        :simulate_conflict_on_requests_after]
        
      CWValidKeysForConflictRedicection = [
        :simulate_conflict_on_requests_before, :simulate_conflict_on_requests_after,
        :timestamp_key ] + CWCommonValidKeys
      CWValidKeysForConflictWarnings = CWFilterOptions +
        CWValidKeysForConflictRedicection
      CWValidKeysForResourceRedirection = [:class_method] + CWCommonValidKeys
      CWValidKeysForResourceWarnings =  CWFilterOptions +
        CWValidKeysForResourceRedirection


      module ClassMethods

        
        
        
        def catch_conflicts(options = {},&block)
          options.assert_valid_keys(CWValidKeysForConflictWarnings)
          valid_options_for_conflict_warnings?(:catch_resource_conflicts, options)
          except = options[:except] ? options.delete(:except) : nil
          only = options[:only] ? options.delete(:only) : nil          
          before_filter :except => except, :only => only do |controller|
            controller.redirect_if_conflict(options,&block)
          end
        end
        
        def catch_resource_conflicts(options = {},&block)
          options.assert_valid_keys(CWValidKeysForResourceWarnings)
          valid_options_for_conflict_warnings?(:catch_resource_conflicts, options)
          except = options[:except] ? options.delete(:except) : nil
          only = options[:only] ? options.delete(:only) : nil
          before_filter :except => except, :only => only do |controller|
            controller.redirect_if_resource_unavailable(options,&block)
          end
        end
        
        
        def valid_options_for_conflict_warnings? method, options
          # no more than one simulation key:
          simulation_keys_provided = CWSimulationKeys.select{|k|options.keys.include?(k)}
          instance_keys_provided = CWInstanceSelectionKeys.select{|k|options.keys.include?(k)}
          model_keys_provided = CWModelSelectionKeys.select{|k|options.keys.include?(k)}
          if simulation_keys_provided.count == 1 &&
              (instance_keys_provided.count > 0 || model_keys_provided.count > 0)
            raise ArgumentError, "#{method}: Ambiguous options provided. "+
              "#{CWSimulationKeys.join(" or ")} cannot be used with any of "+
              "#{(CWInstanceSelectionKeys + CWModelSelectionKeys).join(',')}"
          elsif instance_keys_provided.count > 1
            raise ArgumentError, "#{method}: Ambiguous options provided." +
              "Only one of #{CWInstanceSelectionKeys.join(",")} may be used."
          elsif options[:find_options] && !options[:find_options].is_a?(Proc)
            raise ArgumentError, "#{method}: Proc expected for :find_options"
          end
          
        end
      end
      
      module InstanceMethods
        def redirect_if_conflict(options = {},&block)
          self.class.valid_options_for_conflict_warnings? :redirect_if_conflict, options
          if options[:simulate_conflict_on_requests_before].nil? &&
              options[:simulate_conflict_on_requests_after].nil? &&
              CWInstanceSelectionKeys.all?{|k| options[k].nil?} &&
              params[options[:params_id_key]].nil? && params[:id].nil?
            raise ArgumentError, "catch_conflicts: You must provide a method of " +
              "generating a time used to decide which requests are fresh. Please " +
              "see redirect if conflict documentation for more details."
          elsif (options[:timestamp_key] && params[options[:timestamp_key]].nil?) &&
              params[:page_rendered_at].nil?
            # no timestamp provided
            return
            
          end
          instance = nil
          redirect_requests_before =
            if options[:simulate_conflict_on_requests_before]
            options[:simulate_conflict_on_requests_before]
          elsif options[:simulate_conflict_on_requests_after]
            nil
          else
            model = options[:model] || self.controller_name.singularize
            instance = model if model.is_a?(ActiveRecord::Base)
            model = get_model model
            accessor = options[:accessor] || model.column_names.grep(/(updated_(at|on))/).first
            
            unless instance || model.nil?
              id = options[:id] || params[options[:params_id_key]] || 
                (options[:params_id_key].nil? &&( params[model.to_s.underscore + "_id"] ||params[:id]))
               if options[:find_options]
                find_options = instance_eval(&options[:find_options])
              elsif id
                find_options = {:conditions => {:id => id}}
              end
              instance = model.find(:first, find_options)
            end
            instance && accessor && instance.send(accessor)
          end
          redirect_requests_after = options[:simulate_conflict_on_requests_after]
          timestamp_key = options[:timestamp_key] || :page_rendered_at
          time_stamp = params[timestamp_key]          
          flash_key = options[:flash_key] || :warning
          message = options [:message] || "Your request will not be processed " +
            "because the data you were viewing is out of date. The page has " +
            "been refreshed. Please try again."
          rendered_at = Time.at(time_stamp.to_i) if time_stamp
          
          if rendered_at && 
              #case where both are provided
            (
              (redirect_requests_before && redirect_requests_after &&
                  (( redirect_requests_before > redirect_requests_after &&
                      ((redirect_requests_after..redirect_requests_before) === rendered_at))||
                    (redirect_requests_before <= redirect_requests_after &&
                      !((redirect_requests_before..redirect_requests_after) === rendered_at))
                )) ||
                (
                (redirect_requests_before && redirect_requests_after.nil? &&
                    rendered_at < redirect_requests_before) ||
                  (redirect_requests_after && redirect_requests_before.nil? &&
                    rendered_at > redirect_requests_after)
              )
            )
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
                      page << "alert('#{ escape_javascript message}')"
                    end
                    
                  end
                  flash.discard
                }
              end
            end
          end
          
        end
        
        def redirect_if_resource_unavailable(options = {},&block)
          self.class.valid_options_for_conflict_warnings? :redirect_if_resource_unavailable, options
          if CWInstanceSelectionKeys.all?{|k| options[k].nil?} &&
              [params[options[:params_id_key]], params[:id], options[:class_method]].all? {|option|
              option.nil?}
            raise ArgumentError, "catch_resource_conflicts: You must supply a " +
              "method of determining which resource to work with. "+
              "Please see redirect if resource unavailable documentation."
          end
          instance = nil
          model = options[:model] || self.controller_name.singularize
          instance = model if model.is_a?(ActiveRecord::Base)
          model = get_model model
          accessor = options[:accessor] || model.column_names.grep(/(available)/).first          
          
          result = if options[:class_method]
            model.send(options[:accessor])
          else
            unless instance
              id = options[:id] || params[options[:params_id_key]] ||
                (options[:params_id_key].nil? &&
                  (params[model.to_s.underscore + "_id"] ||params[:id]))
              if options[:find_options]
                find_options = instance_eval(&options[:find_options])
              elsif id
                find_options = {:conditions => {:id => id}}                
              end
              instance = model.find(:first, find_options)
            end
            instance && accessor && instance.send(accessor)
          end
          
          
          flash_key = options[:flash_key] || :warning
          message = options [:message] || "Your request will not be processed " +
            "because the resource you require is no longer available."
          
          unless (result.is_a?(Numeric) && result.respond_to?(">") && result > 0) ||
              (!result.is_a?(Numeric) && result)
            
            flash[flash_key] = message unless message.blank?
            if block_given?
              instance_eval(&block)
            else
              template_to_use = options[:template] || File.join(controller_name, action_name)
              template_to_use.sub!(/(_resource_unavailable)?$/, "_resource_unavailable")
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
                      page << "alert('#{escape_javascript message}')"
                    end
                    
                  end
                  flash.discard
                }
              end
            end
          end
        end
        
        
        private
        
        # Define template_exists? for Rails 2.3
        unless ::ActionController::Base.private_instance_methods.include? 'template_exists?'
          def template_exists? (template = "#{controller_name}/#{action_name}")
            self.view_paths.find_template(template, response.template.template_format)
          rescue ::ActionView::MissingTemplate
            false
          end
        end
        
        def get_model model
          unless ActiveRecord::Base.send(:subclasses).include? model
            if model.is_a?(ActiveRecord::Base)              
              model = model.class
            else
              model = model.to_s.camelcase
            end
            model = Kernel.const_get(model)
          end
          model
        end
      end #InstanceMethods
      
    end
  end
  
end #module ConflictWarnings
