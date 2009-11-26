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
        @@common_valid_keys = [
        
          :message, :flash_key, :except, :only, :model, :id,
          :accessor, :params_id_key, :find_options, :template ]

        @@valid_keys_for_conflict_warnings = [
          :simulate_conflict_on_requests_before, :simulate_conflict_on_requests_after,
          :time_stamp_key ] + @@common_valid_keys

        @@valid_keys_for_resource_warnings = [:class_method] + @@common_valid_keys


        def catch_conflicts(options = {},&block)
          options.assert_valid_keys(valid_keys_for_conflict_warnings)

          except = options[:except] ? options.delete(:except) : nil
          only = options[:only] ? options.delete(:only) : nil
          before_filter :except => except, :only => only do |controller|
            controller.redirect_if_content_changed(options,&block)
          end
        end

        def catch_resource_conflicts(options = {},&block)
          options.assert_valid_keys(valid_keys_for_resource_warnings)

          except = options[:except] ? options.delete(:except) : nil
          only = options[:only] ? options.delete(:only) : nil
          before_filter :except => except, :only => only do |controller|
            controller.redirect_if_resource_unavailable(options,&block)
          end
        end

      end

      module InstanceMethods
        def redirect_if_content_changed(options = {},&block)
          if options[:simulate_conflict_on_requests_before].nil? && 
              options[:simulate_conflict_on_requests_after.nil?] &&
              params[options[:params_id_key]].nil? && params[:id].nil? && options[:id].nil?
            raise ArgumentError, "catch_conflicts: You must provide a method of " +
              "generating a time used to decide which requests are fresh. Please " +
              "see filter_stale_content documentation."
          elsif options[:simulate_conflict_on_requests_before] &&
              options[:simulate_conflict_on_requests_after] &&
              options[:params_id_key]
            raise ArgumentError, "catch_conflicts: Only needs one of "+
              ":redirect_before or :param options is required, both were supplied."
          elsif options[:time_stamp_key] && params[options[:time_stamp_key]].nil? &&
              params[:page_rendered_at].nil?
            return
          end
          @redirect_requests_before =
            if options[:simulate_conflict_on_requests_before]
            options[:simulate_conflict_on_requests_before]
          else
            model = options[:model] || self.controller_name.singularize
            model = model.to_s.camelcase
            model = Kernel.const_get(model)
            model.column_names.grep(/(updated_(at|on))/)
            accessor = options[:accessor] || $1

            id = options[:id] || params[options[:params_id_key]] || params[:id]
            if id
              find_options = {:conditions => {:id => id}}
            elsif options[:find_options]
              find_options = options[:find_options]
            end
            @instance = model.find(:first, find_options)
            @instance && @instance.send(accessor)
          end
          @redirect_requests_after = options[:simulate_conflict_on_requests_after]
          time_stamp_key = options[:time_stamp_key] || :page_rendered_at
          time_stamp = params[time_stamp_key]
          flash_key = options[:flash_key] || :warning
          message = options [:message] || "Your request will not be processed " +
            "because the data you were viewing is out of date. The page has " +
            "been refreshed. Please try again."
          @rendered_at = Time.at(time_stamp.to_i) if time_stamp

          if @rendered_at && (@redirect_requests_before && @rendered_at < @redirect_requests_before ||
                @redirect_requests_after && @rendered_at > @redirect_requests_after)
            flash[flash_key] = message unless message.blank?
            if block_given?
              instance_eval(&block)
            else
              template_to_use = options[:template] || File.join(controller_name, action_name)
              template_to_use.sub!(/_conflict)?$/, "_conflict")
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

        def redirect_if_resource_unavailable(options = {},&block)
          if [params[options[:params_id_key]], params[:id],
              options[:id], options[:class_method],options[:find_options]].all?{|option|option.nil?}
            raise ArgumentError, "catch_resource_conflicts: You must supply a " +
              "method of determining which resource to work with. "+
              "Please see conflict_warnings documentation."
          end

          model = options[:model] || self.controller_name.singularize
          model = model.to_s.camelcase
          model = Kernel.const_get(model)
          model.column_names.grep(/(available)/)
          accessor = options[:accessor] || $1


          @result = if options[:class_method]
            model.send(options[:accessor])
          else
            id = options[:id] || params[options[:params_id_key]] || params[:id]
            if id
              find_options = {:conditions => {:id => id}}
            elsif options[:find_options]
              find_options = options[:find_options]
            end
            @instance = model.find(:first, find_options)
            
            @instance && @instance.send(accessor)
          end
          

          flash_key = options[:flash_key] || :warning
          message = options [:message] || "Your request will not be processed " +
            "because the resource you require is no longer available." 

          unless (@result.is_a?(Numeric) && @result.respond_to?(">") && @result > 0) || @result
          
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
                      alert(message)
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
        unless ActionController::Base.private_instance_methods.include? 'template_exists?'
          def template_exists? (template = "#{controller_name}/#{action_name}")
            self.view_paths.find_template(template, response.template.template_format)
          rescue ActionView::MissingTemplate
            false
          end
        end

      end #InstanceMethods

    end
  end

end #module ConflictWarnings

