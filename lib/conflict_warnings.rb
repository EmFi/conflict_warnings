module ConflictWarnings #:nodoc:
  module ActionView #:nodoc:
    module Helpers #:nodoc:

      # +conflict_warnings+ provides a form tag helper that add the a rendered at time
      # to your form's parameters for use with
      # ConflictWarnings::ActionController::Base::ClassMethods#filter_conflicts and
      # ConflictWarnings::ActionController::Base::ClassMethods#catch_conflicts
      module FormTagHelper
        # Adds a timestamp with the given parameter name.
        # Usage:
        #     <%= timestamp_tag %>
        # produces
        #    <input id=\"page_rendered_at\" name=\"page_rendered_at\" type=\"hidden\" value=\"#{Time.now.to_i}\" />
        def timestamp_tag(name = 'page_rendered_at')
          hidden_field_tag name, Time.now.to_i
        end
      end
      # +conflict_warnings+ provides a form helper that add the a rendered at time
      # to your form's parameters for use with
      # ConflictWarnings::ActionController::Base::ClassMethods#filter_conflicts and
      # ConflictWarnings::ActionController::Base::ClassMethods#catch_conflicts
      module FormHelper
        # Adds a timestamp with the given parameter name.
        # Usage:
        #       f.timestamp :timestamp
        #
        # produces:        
        #     <input id=\"timestamp\" name=\"timestamp\" type=\"hidden\" value=\"#{Time.now.to_i}\" />
        #
        # N.B. this is really just an alias for
        # ConflictWarnings::ActionView::Helpers::FormTag:Helper#timestamp_tag
        # created so that you could use the timestamp in a form_for block
        def timestamp(object_name, name= 'page_rendered_at')
          hidden_field_tag name, Time.now.to_i
        end
      end
      
      module FormBuilder #:nodoc:
        def timestamp(name = 'page_rendered_at')
          @template.timestamp(@object_name, name)
        end
      end


      # conflict_warnings provides some handy link_to wrappers that provide
      # a timestamp parameter for use with +catch_conflicts+ or +filter_conflicts+.
      #
      # The all take the same options as their basic link_to equivalents
      #
      # If options are provided as a string then page_rendered_at=Time.now.to_i
      # is appended to the link.
      #
      # Otherwise the params key used for the timestamp can be changed by providing
      # the :timestamp_key option to as part of the url hash.
      #
      #
      module UrlHelper 
        # Wrapper for link_to that adds a page_rendered_at=DateTime.now paramater to the
        #  target url.
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

        # Wrapper for link_to_if that adds a page_rendered_at=DateTime.now paramater to the
        #  target url.

        def link_to_with_timestamp_if(condition, name, options = {}, html_options = {}, &block)
          link_to_with_timestamp_unless(!condition, name, options, html_options , &block)
        end

        # Wrapper for link_to_unless that adds a page_rendered_at=DateTime.now paramater to the
        #  target url.

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
      end #UrlHelper


      # conflict_warnings provides some handy link_to_remote wrappers that provide
      # a timestamp parameter for use with +catch_conflicts+ or +filter_conflicts+.
      #
      # The all take the same options as their basic link_to_remote equivalents
      #
      # If options are provided as a string then page_rendered_at=Time.now.to_i
      # is appended to the link.
      #
      # Otherwise the params key used for the timestamp can be changed by providing
      # the :timestamp_key option to as part of the url hash.
      module PrototypeHelper 
        # Wrapper for link_to remote that adds a page_rendered_at=Time.now parameter
        # to the target url.

               
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

        # Wrapper for link_to_remote_with_timestamp that sets the html_options argument
        # to link_to_with_timestamp. Allowing for AJAX conflict warnings that successfully
        # fall back go html requests.
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
      end #PrototypeHelper
    end #Helpers
  end #ActionView
  
  module ActionController #:nodoc:
    module Base #:nodoc:
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
        
      CWValidKeysForCatchConflicts = [
        :simulate_conflict_on_requests_before, :simulate_conflict_on_requests_after,
        :timestamp_key ] + CWCommonValidKeys
      CWValidKeysForFilterConflicts= CWFilterOptions +
        CWValidKeysForCatchConflicts
      CWValidKeysForCatchResourcesUnavailable = [:class_method] + CWCommonValidKeys
      CWValidKeysForFilterResourcesUnavailable =  CWFilterOptions +
        CWValidKeysForCatchResourcesUnavailable



      # Conflict Warnings introduces two approaches to identify situations that could 
      # result in inconsistent data.
      #
      # +filter_conflicts+ and +filter_resources_unavailable+ identify problem cases
      # based on their arguments, the parameters of the current requests
      # allowing you to display relevant errors and warnings and/or more importantly
      # update information.
      #
      # +filter_conflicts+ and +filter_resources_unavailable+ use timestamps
      # and resources respectively to identify problem requests.
      #
      # In either case, conflict_warnings will make reasonable guesses when options are
      # omitted.
      #
      # For requests accepting html, the default action in the event of a conflict
      # is to <tt>redirect_to :back</tt>, reloading the referring page, and adding
      # the default warning message to <tt>flash[:warning]</tt>. For :js format requests,
      # the page is reloaded and an alert box displays the default message.
      # Currently conflict_warnings filter methods do not have default actions for other formats.
      # However, any block given to +filter_conflicts+ or +filter_resources_unavailable+
      # will be executed in the event of a problem request.
      #
      # If a request is identified as problematic, the status of the response is
      # 409 Conflict, unless the supplied block states otherwise, or a template
      # was not found in a HTTP request. Some browsers will not follow a redirection
      # who's status is not 302 Redirected.
      #
      # == Common Options for filters
      #
      # [<tt>:model</tt>] ActiveRecord model that will be used to determine if 
      #                   there is a conflict. Default value is derived from the current
      #                   controller name. Can be a provided, as a string, symbol, constant, or
      #                   instance of ActiveRecord::Base. If a record is supplied this option
      #                   cannot be used with <tt>:id, :params_id_key,</tt> or<tt> :find_options.</tt>
      #    
      #
      # [<tt>:id</tt>] Record id used to determine if there is a conflict. Default value is 
      #                <tt>params["#{model)_id"]</tt> if it extsts, with <tt>params[:id]</tt> as a fallback.
      #                Cannot be used with <tt>:params_id_key, :find_options</tt>,  or <tt>:model</tt>
      #                if the <tt>:model</tt> option is an instance of an ActiveRecord::Base descendent.
      #
      # [<tt>:params_id_key</tt>] Parameter hash key linking to the id to be used in selecting an
      #                           record to generate timestamp or resource availability information used
      #                           to identify problem requests.
      #                           Cannot be used with <tt>:id, :find_options</tt>,  or <tt>:model</tt>
      #                           if the <tt>:model</tt> option is an instance of an ActiveRecord::Base descendent.
      #
      # [<tt>:find_options</tt>] Proc that evailuates to options passed to find(:first) to be used in selecting an
      #                          record to generate timestamp or resource availability information used
      #                          to identify problem requests. This needs to be a Proc because the scope +filter_conflicts+ 
      #                          +filter_resources_unavailable+ will be called in does not have access to
      #                          the parameter hash. Ensure that the proc returns a hash.
      #                          Cannot be used with <tt>:id,
      #                          :params_id_key</tt>,  or <tt>:model</tt> if the <tt>:model</tt> option
      #                          is an instance of an ActiveRecord::Base descendent.
      #
      # [<tt>:accessor</tt>]  Method sent to the selected record that returns the timestamp or availability information
      #                       used to identify problem requests.
      #                       In catch_conflicts the default is updated_at or updated_on, if such a column 
      #                       exists. In catch_resource_conflicts the default is the first column with
      #                       a name matching /available/.
      #
      # [<tt>:template</tt>]  Template file to render in event of a conflict. For catch_conflicts,
      #                       the default value is "#{controller_name}/#{action_name}_conflict". For
      #                       catch_resource_conflicts, the default value is
      #                       "#{controller_name}/#{action_name}_resource_unavailable". 
      #                       When a conflict is identified on search for a html.erb, .rhtml,
      #                       or .rjs file depending on the request. If one isn't found the default action 
      #                       is taken.
      #
      # [<tt>:message</tt>] Message added to the flash hash. The catch_conflicts default value
      #                     is "Your request will not be processed becasue the data you were viewing is
      #                     out of date. The page has been refreshed. Please try again."
      #                     The catch_resource_conflicts default value is "Your request will not be
      #                     processed because the resource you require is no longer available."
      #
      # [<tt>:flash_key</tt>] The flash hash key to store the message in. Default value
      #                       is <tt>:warning</tt>
      #
      # [<tt>:except, :only</tt>] Arguments to be passed to the underlying before_filter call
      #
      # [<tt>&block</tt>] This block is evaulated when a problem request is identified
      #                   If no block is provided, the default action as described above is taken.
      #


      module ClassMethods

        # Filters requests by comparing a timestamp embedded in the parameters hash
        # against a record. See common options, to understand how +filter_conflicts+
        # acquires a timestamp from a record.
        #
        # Using timestamps to catch conflicts is a two step process.
        #
        # Step one: Embed a timestamp paramaters in potentially dangerous links.
        # This is easist done with the link_to_with_timestamp helper from your views.
        # See <tt>ConflictWarnings::ActionView::Helpers::UrlHelper</tt> and
        # <tt>Conflict::Warnings::ActionView::Helpers::PrototypeHelper</tt> for a list of provided
        # helpers and their uses. +filter_conflicts+ is expecting the timestamp as an integer
        # in seconds since the UNIX Epoch
        #
        # Step two: Catch undesireable timestamps using +filter_conflicts+.
        # The options given are used to find a timestamp to compare against the timestamp of
        # the referring page. The most common uses of +filter_conflicts+ compare the time at
        # which the referrant was rendered against the updated_at field on the record to
        # be changed. If the timestamp provided in the parameters is deteremined to be invalid
        # the request is interrupted.
        #
        # +filter_conflicts+ accepts three additional options to the ones described above.
        #
        # [<tt>:simulate_conflicts_on_requests_before</tt>] Instead of using a record to
        #                                                   select a timestamp for determine conflicts,
        #                                                   use the provide timestamp. Can be used to
        #                                                   shut off portions of your application at
        #                                                   a given time. Accepts any Date,DateTime or Time object.
        #                                                   Cannot be used with <tt>:id,
        #                                                   :params_id_key, :find_options</tt>,  or <tt>:model</tt>
        #                                                   if the <tt>:model</tt> option is an instance
        #                                                   of an ActiveRecord::Base descendent.
        #
        # [<tt>:simulate_conflicts_on_requests_after</tt>] Instead of using a record to
        #                                                  select a timestamp for determine conflicts,
        #                                                  use the provide timestamp. Can be used to
        #                                                  active portions of your application at
        #                                                  a given time. Accepts any Date,DateTime or Time object.
        #                                                  Cannot be used with <tt>:id,
        #                                                  :params_id_key, :find_options</tt>,  or <tt>:model</tt>
        #                                                  if the <tt>:model</tt> option is an instance
        #                                                  of an ActiveRecord::Base descendent.
        #
        # [<tt>:timestamp_key</tt>] Parameter hash key containing the time the referring page was rendered.
        #                           The value of <tt>params[options[:timestamp_key]</tt> is compared against
        #                           the last modified time of the record selected to identify conflicts. If there is
        #                           no parameter hash key matching the value of <tt>options[:timestamp_key]</tt>
        #                           the requests is considered to be inconflict. Default value is <tt>:page_rendered_at</tt>
        #
        # ===== Example
        #
        # Given these rows in the MultiAccessResources table,
        #     +--+----------+-------+----------------------+
        #     |id|project_id| value |  updated_at          |
        #     +--+----------+-------+----------------------+
        #     | 1|   17     | 1123  |  Jan 1 12:00:45 2009 |
        #     | 2|   23     | 5422  |  Dec 1 23:43:45 2009 |
        #     | 3|   52     | 52312 |       NULL           |
        #     +--+----------+-------+----------------------+
        #
        # and this call to filter_conflicts,
        #
        #    class MultiAccessResourceController < ApplicationController
        #      filter_conflicts  :only => :update, :find_options => lambda {{:conditions => ["project_id = ?", params[:proj_id]]}} 
        #    end
        #
        # this will be interrupted:
        #
        # * put: :project_id => 17, :action => :update, :page_rendered_at => 1253005253 (September 15 2009)
        # * put: :project_id => 52, :action => :update
        #
        # these requests will not be:
        #
        # * post: :project_id => 42, :action => :create, :page_rendered_at => 1253005253 (September 15 2009)
        # * put: :project_id => 52, :action => :update, :page_rendered_at => 1253005253 (September 15 2009)
        # * put: :project_id => 17, :action => :update, :page_rendered_at => 1253005253 (September 15 2009)
        # * get: :id => 1, :action => :show


        def filter_conflicts(options = {},&block)
          options.assert_valid_keys(CWValidKeysForFilterConflicts)
          valid_options_for_conflict_warnings?(:filter_resource_conflicts, options)
          except = options[:except] ? options.delete(:except) : nil
          only = options[:only] ? options.delete(:only) : nil          
          before_filter :except => except, :only => only do |controller|
            controller.catch_conflicts(options,&block)
          end
        end

        # Filters requests by checking a record or model for availability
        # See common options, to understand how +filter_resources_unavailable+
        # selects a record or model and determins availability.
        #
        # Without any arguments, the model, id, and accessor are used to
        # select the resource. Unless options dictate otherwise, the model, is taken from
        # the controller name, id is from the params[:id] field, and accessor is the first
        # field containing the name "available" on the instance of the model with the
        # given id.
        #
        # If accessor returns 0, or a false value the request is interrupted.
        # If a record cannot be found with the given options, then the request will
        # proceed without triggering the conflict action.
        #
        # See the common options for other ways of specifying the deadline.
        #
        # The request is interrupted if the accessor returning false, or an numeric
        # value less than or equal to 0.
        #
        # In addition to the common options listed above, +filter_resources_unavailable+
        # also accepts the following option:
        #
        # [<tt>:class_method</tt>] Default is nil. If true, accessor is treated as a class method
        #                          instead of an instance method. If a symbol or string is provided,
        #                          the accessor is ignored.
        #
        #
        # ==== Example
        #
        # Given these rows in the events table,
        #     +--+------------+
        #     |id|tickets_left|
        #     +--+------------+
        #     | 1|   17       |
        #     | 2|    0       |
        #     | 3|   NULL     |
        #     +--+------------+
        #
        #     class OrdersController < ApplicatoinController
        #      filter_resources_unavaliable :only => :create, :model => Event,
        #         :accessor => :tickets_left
        #       end
        #     end
        # 
        # The following requests will be interrupted:
        #
        # post: :action => :create, :event_id => 2
        # post: :action => :create, :event_id => 3
        # post: :action => :create, :event_id => 4
        #
        # The following requests will not be interrupted:
        #
        # post :action => :create, :event_id => 1
        #



        def filter_resources_unavailable(options = {},&block)
          options.assert_valid_keys(CWValidKeysForFilterResourcesUnavailable)
          valid_options_for_conflict_warnings?(:filter_resource_conflicts, options)
          except = options[:except] ? options.delete(:except) : nil
          only = options[:only] ? options.delete(:only) : nil
          before_filter :except => except, :only => only do |controller|
            controller.catch_resources_unavailable(options,&block)
          end
        end
        
        private
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
          elsif instance_keys_provided.count + (options[:model].is_a?(ActiveRecord::Base) ? 1 : 0)   > 1
            raise ArgumentError, "#{method}: Ambiguous options provided." +
              "Only one of #{CWInstanceSelectionKeys.join(",")} may be used."
          elsif options[:find_options] && !options[:find_options].is_a?(Proc)
            raise ArgumentError, "#{method}: Proc expected for :find_options"          
          end
          
        end
      end


      # These methods are used in +filter_conflicts+ and +filter_resources_unavailable+
      # They are provided for use in your own custom filters.
      #
      # +catch_conflicts+ and +catch_resources_unavailable+ identify problem cases
      # based on their arguments, the parameters of the current requests
      # allowing you to display relevant errors and warnings and/or more importantly
      # update information.
      #
      # +catch_conflicts+ and +catch_resources_unavailable+ use timestamps
      # and resources respectively to identify problem requests.
      #
      # In either case, conflict_warnings will make reasonable guesses when options are
      # omitted.
      #
      # For requests accepting html, the default action in the event of a conflict
      # is to <tt>redirect_to :back</tt>, reloading the referring page, and adding
      # the default warning message to <tt>flash[:warning]</tt>. For :js format requests,
      # the page is reloaded and an alert box displays the default message.
      # Currently conflict_warnings catch methods do not have default actions for other formats.
      # However, any block given to +catch_conflicts+ or +catch_resources_unavailable+
      # will be executed in the event of a problem request.
      #
      # If a request is identified as problematic, the status of the response is
      # 409 Conflict, unless the supplied block states otherwise, or a template
      # was not found in a HTTP request. Some browsers will not follow a redirection
      # who's status is not 302 Redirected.
      #
      # Both of these methods return true if a request was interrupted, otherwise
      # they return false.
      #
      # == Common Options for catches
      #
      # [<tt>:model</tt>] ActiveRecord model that will be used to determine if
      #                   there is a conflict. Default value is derived from the current
      #                   controller name. Can be a provided, as a string, symbol, constant, or
      #                   instance of ActiveRecord::Base. If a record is supplied this option
      #                   cannot be used with <tt>:id, :params_id_key,</tt> or<tt> :find_options.</tt>
      #
      #
      # [<tt>:id</tt>] Record id used to determine if there is a conflict. Default value is
      #                <tt>params["#{model)_id"]</tt> if it extsts, with <tt>params[:id]</tt> as a fallback.
      #                Cannot be used with <tt>:params_id_key, :find_options</tt>,  or <tt>:model</tt>
      #                if the <tt>:model</tt> option is an instance of an ActiveRecord::Base descendent.
      #
      # [<tt>:params_id_key</tt>] Parameter hash key linking to the id to be used in selecting an
      #                           record to generate timestamp or resource availability information used
      #                           to identify problem requests.
      #                           Cannot be used with <tt>:id, :find_options</tt>,  or <tt>:model</tt>
      #                           if the <tt>:model</tt> option is an instance of an ActiveRecord::Base descendent.
      #
      # [<tt>:find_options</tt>] Proc that evailuates to options passed to find(:first) to be used in selecting an
      #                          record to generate timestamp or resource availability information used
      #                          to identify problem requests. This needs to be a Proc because the scope +catch_conflicts+
      #                          +catch_resources_unavailable+ will be called in does not have access to
      #                          the parameter hash. Ensure that the proc returns a hash.
      #                          Cannot be used with <tt>:id,
      #                          :params_id_key</tt>,  or <tt>:model</tt> if the <tt>:model</tt> option
      #                          is an instance of an ActiveRecord::Base descendent.
      #
      # [<tt>:accessor</tt>]  Method sent to the selected record that returns the timestamp or availability information
      #                       used to identify problem requests.
      #                       In catch_conflicts the default is updated_at or updated_on, if such a column
      #                       exists. In catch_resource_conflicts the default is the first column with
      #                       a name matching /available/.
      #
      # [<tt>:template</tt>]  Template file to render in event of a conflict. For catch_conflicts,
      #                       the default value is "#{controller_name}/#{action_name}_conflict". For
      #                       catch_resource_conflicts, the default value is
      #                       "#{controller_name}/#{action_name}_resource_unavailable".
      #                       When a conflict is identified on search for a html.erb, .rhtml,
      #                       or .rjs file depending on the request. If one isn't found the default action
      #                       is taken.
      #
      # [<tt>:message</tt>] Message added to the flash hash. The catch_conflicts default value
      #                     is "Your request will not be processed becasue the data you were viewing is
      #                     out of date. The page has been refreshed. Please try again."
      #                     The catch_resource_conflicts default value is "Your request will not be
      #                     processed because the resource you require is no longer available."
      #
      # [<tt>:flash_key</tt>] The flash hash key to store the message in. Default value
      #                       is <tt>:warning</tt>
      #
      # [<tt>&block</tt>] This block is evaulated when a problem request is identified
      #                   If no block is provided, the default action as described above is taken.
      #

      module InstanceMethods

        # catches requests by comparing a timestamp embedded in the parameters hash
        # against a record. See common options, to understand how +catch_conflicts+
        # acquires a timestamp from a record.
        #
        # Using timestamps to catch conflicts is a two step process.
        #
        # Step one: Embed a timestamp paramaters in potentially dangerous links.
        # This is easist done with the link_to_with_timestamp helper from your views.
        # See <tt>ConflictWarnings::ActionView::Helpers::UrlHelper</tt> and
        # <tt>Conflict::Warnings::ActionView::Helpers::PrototypeHelper</tt> for a list of provided
        # helpers and their uses. +catch_conflicts+ is expecting the timestamp as an integer
        # in seconds since the UNIX Epoch
        #
        # Step two: Catch undesireable timestamps using +catch_conflicts+.
        # The options given are used to find a timestamp to compare against the timestamp of
        # the referring page. The most common uses of +catch_conflicts+ compare the time at
        # which the referrant was rendered against the updated_at field on the record to
        # be changed. If the timestamp provided in the parameters is deteremined to be invalid
        # the request is interrupted.
        #
        # +catch_conflicts+ accepts three additional options to the ones described above.
        #
        # [<tt>:simulate_conflicts_on_requests_before</tt>] Instead of using a record to
        #                                                   select a timestamp for determine conflicts,
        #                                                   use the provide timestamp. Can be used to
        #                                                   shut off portions of your application at
        #                                                   a given time. Accepts any Date,DateTime or Time object.
        #                                                   Cannot be used with <tt>:id,
        #                                                   :params_id_key, :find_options</tt>,  or <tt>:model</tt>
        #                                                   if the <tt>:model</tt> option is an instance
        #                                                   of an ActiveRecord::Base descendent.
        #
        # [<tt>:simulate_conflicts_on_requests_after</tt>] Instead of using a record to
        #                                                  select a timestamp for determine conflicts,
        #                                                  use the provide timestamp. Can be used to
        #                                                  active portions of your application at
        #                                                  a given time. Accepts any Date,DateTime or Time object.
        #                                                  Cannot be used with <tt>:id,
        #                                                  :params_id_key, :find_options</tt>,  or <tt>:model</tt>
        #                                                  if the <tt>:model</tt> option is an instance
        #                                                  of an ActiveRecord::Base descendent.
        #
        # [<tt>:timestamp_key</tt>] Parameter hash key containing the time the referring page was rendered.
        #                           The value of <tt>params[options[:timestamp_key]</tt> is compared against
        #                           the last modified time of the record selected to identify conflicts. If there is
        #                           no parameter hash key matching the value of <tt>options[:timestamp_key]</tt>
        #                           the requests is considered to be inconflict. Default value is <tt>:page_rendered_at</tt>
        #
        # ==== Example
        #
        # Given these views, and controller...
        #
        #
        # ===== controllers/sample_controller_rb
        #     class SampleController < ApplicationController
        #       before_filter :only => confirm do |controller|
        #         controller.catch_conflicts
        #       end
        #
        #       def confirm
        #        #not executed in a conflict
        #        ...
        #       end
        #       ...
        #     end
        #
        # ==== views/sample/show.html.erb
        #     <div id="warnings">
        #       </div>
        #     <div id="static_content">
        #     ...
        #     </div>
        #     <div id="dynamic_content">
        #       <=%render :partial => dynamic_content%>
        #     </div>
        #     ...
        #     <%=link_to_remote_with_timestamp "Confirm", confirm_sample_path(@sample)%>
        #
        # ===== views/sample/confirm_conflict.rjs
        #
        #     #updates relevant portions of page and highlights changes.
        #     page.replace_html :warning, "We cannot complete your request at this time."
        #     page.replace html :dynamic_content, render :partial => 'sample/dynamic_content'
        #     page.visual_effect :highlight :dynamic_content, :duration => 5
        #
        #
        # In the event that a user modifies the sample record that another user is
        # viewing through the show action, before that second user clicks the confirm link.
        # The second user's confirmation will be interrupted and the RJS contained in
        # views/sample/confirm_conflict.rjs will be executed, in their browser. Updating only
        # a warning, the dynamic content of the show view, and highlighting the changes.
        #


        def catch_conflicts(options = {},&block)
          options.assert_valid_keys(CWValidKeysForCatchConflicts)
          self.class.send :valid_options_for_conflict_warnings?, :catch_conflict, options
          model = options[:model] || self.controller_name.singularize
          instance = model if model.is_a?(ActiveRecord::Base)
          model = get_model model
          if options[:simulate_conflict_on_requests_before].nil? &&
              options[:simulate_conflict_on_requests_after].nil? &&
              CWInstanceSelectionKeys.all?{|k| options[k].nil?} &&
              [params[options[:params_id_key]], params[:id],
              params[model.to_s.underscore + "_id"]].all? {|k| k.nil?} && instance.nil?
            raise ArgumentError, "catch_conflicts: You must provide a method of " +
              "generating a time used to decide which requests are fresh. Please " +
              "see redirect if conflict documentation for more details."
          elsif (options[:timestamp_key] && params[options[:timestamp_key]].nil?) &&
              params[:page_rendered_at].nil?
            # no timestamp provided
            return
            
          end          
          redirect_requests_before =
            if options[:simulate_conflict_on_requests_before]
            options[:simulate_conflict_on_requests_before]
          elsif options[:simulate_conflict_on_requests_after]
            nil
          else
            accessor = options[:accessor] || model.column_names.grep(/(updated_(at|on))/).first            
            unless instance || model.nil?
              find_options = {}
              id = options[:id] || params[options[:params_id_key]] || 
                (options[:params_id_key].nil? &&( params[model.to_s.underscore + "_id"] ||params[:id]))
              if options[:find_options]
                find_options = instance_eval(&options[:find_options])
              elsif id
                find_options = {:conditions => {:id => id}}
              end
              unless find_options.is_a?(Hash)
                raise ArgumentError, "Find options does not evaluate to a Hash"
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
          
          if rendered_at.nil? || rendered_at &&
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
                  flash.discard(:warnings)
                }
              end
            end
            return true
          end
          false
        end


        # catches requests by checking a record or model for availability
        # See common options, to understand how +catch_resources_unavailable+
        # selects a record or model and determins availability.
        #
        # Without any arguments, the model, id, and accessor are used to
        # select the resource. Unless options dictate otherwise, the model, is taken from
        # the controller name, id is from the params[:id] field, and accessor is the first
        # field containing the name "available" on the instance of the model with the
        # given id.
        #
        # If accessor returns 0, or a false value the request is interrupted.
        # If a record cannot be found with the given options, then the request will
        # proceed without triggering the conflict action.
        #
        # See the common options for other ways of specifying the deadline.
        #
        # The request is interrupted if the accessor returning false, or an numeric
        # value less than or equal to 0.
        #
        # In addition to the common options listed above, +catch_resources_unavailable+
        # also accepts the following option:
        #
        # [<tt>:class_method</tt>] Default is nil. If true, accessor is treated as a class method
        #                          instead of an instance method. If a symbol or string is provided,
        #                          the accessor is ignored.
        #
        #
        # ==== Example
        #
        #     class CustomFilterExampleController < ApplicationController
        #       before_filter :check_lock
        #
        #       protected
        #       def check_lock
        #         unless catch_resources_unavailable :accessor => :unlocked
        #           acquire_lock
        #         end
        #       end
        #     end
        #
        # Will interrupt a request if the record being accessed is locked.
        #
        
        def catch_resources_unavailable(options = {},&block)
          options.assert_valid_keys(CWValidKeysForCatchResourcesUnavailable)
          self.class.send :valid_options_for_conflict_warnings?, :catch_resource_unavailable, options
          model = options[:model] || self.controller_name.singularize
          instance = model if model.is_a?(ActiveRecord::Base)
          model = get_model model
          if CWInstanceSelectionKeys.all?{|k| options[k].nil?} &&
              [params[options[:params_id_key]], params[model.to_s.underscore + "_id"],
              params[:id], options[:class_method]].all? {|option|
              option.nil?} && instance.nil?
            raise ArgumentError, "catch_resource_conflicts: You must supply a " +
              "method of determining which resource to work with. "+
              "Please see redirect if resource unavailable documentation."
          end
          accessor = options[:accessor]
          accessor ||= case options[:class_method]
          when nil           
            model.column_names.grep(/(available)/).first
          when true
            model.methods.grep(/available$/).first
          else
            options[:class_method]
          end
          
          result = if options[:class_method]
            model.send(accessor)
          else
            unless instance
              find_options = {}
              id = options[:id] || params[options[:params_id_key]] ||
                (options[:params_id_key].nil? &&
                  (params[model.to_s.underscore + "_id"] ||params[:id]))
              if options[:find_options]
                find_options = instance_eval(&options[:find_options])
              elsif id
                find_options = {:conditions => {:id => id}}                
              
              end
              unless find_options.is_a?(Hash)
                raise ArgumentError, "Find options does not evaluate to a Hash"
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
            return true
          end
          false
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
