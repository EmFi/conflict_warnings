require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class FilterConflictsTest < ActionController::TestCase
  context "filter conflicts" do
    teardown do
      @controller =nil
      @request = nil
      @response   = nil
      
    end
    setup do
      @request = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new
      @request.env["HTTP_REFERER"] = "/"
    end

    context "without options" do
      context "accepts html" do
        setup do
          class FilterConflictWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
          
            filter_conflicts
            #cattr_accessor :controller_name
          end
          @controller = FilterConflictWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          FilterConflictWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            FilterConflictWithoutOptionsTestController.controller_name = "timestamps"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should"raise ArgumentError" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end
            context "with timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :page_rendered_at =>Time.now.to_i
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :page_rendered_at =>Time.now.to_i
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
            context "with timestamp in the future" do
              context "without template" do
                should "redirect" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                  assert_match /out of date/, flash[:warning]
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  FilterConflictWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = FilterConflictWithoutOptionsTestController.new
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response 409
                  assert_template("action1_conflict")
                  assert_match /Updated In the Future/, @response.body
                end # should not redirect and render default template
              end # context with template
            end # context with timestamp in the future

          end # context with conflict
          context "alternate id key based on model name" do
            context "without conflict" do
              context "past timestamp without rendered at" do
                should "redirect" do
                  get :action1, :timestamp_id => 3
                  assert_redirected_to "/"
                end
              end
              context "future timestamp without rendered at" do
                should "redirect" do
                  get :action1, :timestamp_id => 2
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, :timestamp_id => 2, :page_rendered_at => Time.now.to_i
                assert_redirected_to "/"
              end
            end
          end #alternate id

        end # context with basic timestamp

        context "with custom accessible timestamp" do
          setup do
            FilterConflictWithoutOptionsTestController.controller_name = "timestamp_with_custom_accessors"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end
            context "with timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, {:id => 1, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, {:id => 3, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
            end
          end
          context "with conflict" do
            context "with timestamp in the future" do
              context "without template" do
                should "not redirect" do
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
              context "with template" do
                should "not redirect and render default template" do
                  FilterConflictWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
            end
          end
        end # context with custom accessro timestamp
        context "with updated_at timestamp" do
          setup do
            FilterConflictWithoutOptionsTestController.controller_name = "timestamp_with_updated_ats"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should "not redirect" do
                get :action1, {:id => 1, :page_rendered_at =>Time.now.to_i}
                assert_response :success
              end
            end
            context "with timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, {:id => 1, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, {:id => 3, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
            context "with timestamp in the future" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1, :id => 2
                  assert_redirected_to "/"
                end
              end
              context "without template" do
                should "redirect" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                  assert_match /out of date/, flash[:warning]
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  FilterConflictWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_template("action1_conflict")
                end # should not redirect and render default template
              end # context with template
            end # context with timestamp in the future

          end # context with conflict
        end # context with updated_at timestamp
      end #accepts html
      context "accepts js" do
        setup do
          class FilterConflictWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            filter_conflicts
            #cattr_accessor :controller_name
          end
          @controller = FilterConflictWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }          
          FilterConflictWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            FilterConflictWithoutOptionsJSTestController.controller_name = "timestamps"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do
                  get :action1, :format => "js"
                end
              end
            end
            context "with timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
            context "with timestamp in the future" do
              context "without template" do
                should "redirect" do

                  get :action1, :id => 2, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response 409                  
                  assert_match(/alert/, @response.body)
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  FilterConflictWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = FilterConflictWithoutOptionsJSTestController.new
                  get :action1, :id => 2, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response 409
                  assert_template("action1_conflict.rjs")
                  assert_match /Updated In the Future/, @response.body
                end # should not redirect and render default template
              end # context with template
            end # context with timestamp in the future

          end # context with conflict
          context "alternate id key based on model name" do
            context "without conflict" do
              should "not redirect" do
                get :action1, :timestamp_id => 3, :format => "js",
                  :page_rendered_at => Time.now.to_i
                assert_response :success
              end
            end
            context "with conflict" do
              context "past timestamp without rendered at" do
                should "not redirect" do
                  get :action1, :timestamp_id => 3, :format => "js"
                  assert_response 409
                end
              end
              context "future timestamp without rendered at" do
                should "redirect" do
                  get :action1, :timestamp_id => 2, :format => "js"
                  assert_response 409
                end
              end
              context "future timestamp with rendered at" do
                should "redirect" do
                  get :action1, :timestamp_id => 2, :page_rendered_at => Time.now.to_i,
                    :format => "js"
                  assert_response 409
                  assert_match(/alert/, @response.body)
                end
              end
            end
          end #alternate id
        end # context with basic timestamp

      end #accepts js
    end # context without options
    context "using options" do
      context "filter options" do
        context "with only" do
          setup do
            class FilterConflictWithOnlyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :only => :action1
            end
            FilterConflictWithOnlyTestsController.view_paths = ['...']
            @controller = FilterConflictWithOnlyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithOnlyTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on action in only" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end
                  end
                  should "redirect" do

                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                    assert_redirected_to "/"
                    assert_match /out of date/, flash[:warning]
                  end
                end # on action in only

                context "on action not covered in only" do
                  should "not redirect" do
                    get :action2, {:id => 2, :page_rendered_at =>Time.now.to_i}
                    assert_response :success
                  end # should not redirect and render default template
                end # on action not covered in only
              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp

        end # with only
        context "with except" do
          setup do
            class FilterConflictWithExceptTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :except => :action2
            end
            FilterConflictWithExceptTestsController.view_paths = ['...']
            @controller = FilterConflictWithExceptTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithExceptTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on excepted action" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end
                  end
                  should "redirect" do

                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                    assert_redirected_to "/"
                    assert_match /out of date/, flash[:warning]
                  end
                end # on action in only

                context "on action not covered by except" do
                  should "not redirect" do
                    get :action2, {:id => 2, :page_rendered_at =>Time.now.to_i}
                    assert_response :success
                  end # should not redirect and render default template
                end # on action not covered in only
              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp

        end # with except
      end #filter options
      context "with flash key" do
        context "without message" do
          setup do
            class FilterConflictWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :flash_key => :error
            end
            FilterConflictWithFlashKeyTestsController.view_paths = ['...']
            @controller = FilterConflictWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithFlashKeyTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "set flash[:error]" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                  assert_match /not be processed/, flash[:error]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
              
                context "without timestamp parameter" do
                  should "set flash[:error]" do
                    get :action1, :id => 2
                  assert_redirected_to "/"
                    assert_match /not be processed/, flash[:error]
                  end
                end
                should "set flash[:error]" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                  assert_match /out of date/, flash[:error]
                end
              
              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
        end # context without message
        context "with message" do
          setup do
            class FilterConflictWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :flash_key => :error, :message => "CONFLICT!"
            end
            FilterConflictWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = FilterConflictWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithFlashKeyAndMessageTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "set flash[:error]" do
                  get :action1, :id => 1
assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:error]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do

                context "without timestamp parameter" do
                  should "set flash[:error]" do
                    get :action1, :id => 2
assert_redirected_to "/"
                    assert_match /CONFLICT!/, flash[:error]
                  end
                end
                should "set flash[:error]" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:error]
                end

              end # context with timestamp in the future
            end # with basic timestamp
          end # context with conflict
        end # context with message
      end # with flash key
      context "without flash key" do
        context "with message" do
          setup do
            class FilterConflictWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :message => "CONFLICT!"
            end
            FilterConflictWithMessageTestsController.view_paths = ['...']
            @controller = FilterConflictWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithMessageTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "set flash[:error]" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:warning]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do

                context "without timestamp parameter" do
                  should "set flash[:error]" do
                    get :action1, :id => 2
                    assert_redirected_to "/"
                    assert_match /CONFLICT!/, flash[:warning]
                  end
                end
                should "set flash[:error]" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:warning]
                end

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
          context "accepts js" do
            setup do
              class FilterConflictWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :message => "CONFLICT"
              end
              @controller = FilterConflictWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              FilterConflictWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithMessageJSTestController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should"raise ArgumentError" do
                    assert_raise(ArgumentError) do
                      get :action1, :format => "js"
                    end
                  end
                end
                context "with timestamp parameter" do
                  context "with timestamp missing on record" do
                    should "not redirect " do
                      get :action1, :id => 1, :page_rendered_at =>Time.now.to_i, :format => "js"
                      assert_response :success
                    end
                  end
                  context "With timestamp in the past" do
                    should "not redirect" do
                      get :action1, :id => 3, :page_rendered_at =>Time.now.to_i, :format => "js"
                      assert_response :success
                    end
                  end
                end
              end

              context "with conflict" do
                context "with timestamp in the future" do
                  context "without template" do
                    should "redirect" do

                      get :action1, :id => 2, :page_rendered_at =>Time.now.to_i, :format => "js"
                      assert_response 409
                      assert_match(/alert\('CONFLICT'\)/, @response.body)
                    end
                  end # context without template

                  context "with template" do
                    should "not redirect and render default template" do
                      FilterConflictWithMessageJSTestController.append_view_path TestViewPath
                      @controller = FilterConflictWithMessageJSTestController.new
                      get :action1, :id => 2, :page_rendered_at =>Time.now.to_i, :format => "js"
                      assert_response 409
                      assert_template("action1_conflict.rjs")
                    end # should not redirect and render default template
                  end # context with template
                end # context with timestamp in the future

              end # context with conflict
            end # context with basic timestamp

          end #acceepts js
        end # with message
      end # context without flashkey
      context "with model" do
        setup do
          class FilterConflictWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            filter_conflicts :model => TimestampWithCustomAccessor
          end
          FilterConflictWithModelTestsController.view_paths = ['...']
          @controller = FilterConflictWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic timestamp" do
          setup do
            FilterConflictWithModelTestsController.controller_name = "timestamps"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should "redirect" do
                get :action1, :id => 1
assert_redirected_to "/"
              end
            end
          end #without conflict
          context "with conflict" do
            context "with timestamp in the future" do
              context "on action in only" do
                context "without timestamp parameter" do
                  should "redirect" do
                    get :action1, :id => 2
assert_redirected_to "/"
                  end
                end
                should "not redirect" do
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end # on action in only
            
            end # context with timestamp in the future

          end # context with conflict
        end # context with basic timestamp
        context "with accessor" do
          context "with bogus accessor" do
            setup do
              class FilterConflictWithModelAndBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :model => Timestamp, :accessor => :bogus
              end
              should "raise no method error" do
                assert_raise(NoMethodError) do
                  get :action1, :id => 3
                end
              end
            end
          end #bogus accessor
          context "without id" do
            setup do
              class FilterConflictWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :model => TimestampWithCustomAccessor, :accessor => :timestamp
              end
              FilterConflictWithModelAndAccessorTestsController.view_paths = ['...']
              @controller = FilterConflictWithModelAndAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithModelAndAccessorTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "redirect" do
                    get :action1, :id => 1
assert_redirected_to "/"
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with timestamp in the future" do
                  context "on action in only" do
                    context "without timestamp parameter" do
                      should "redirect" do
                        get :action1, :id => 2
assert_redirected_to "/"
                      end
                    end
                    should "not redirect" do

                      get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                      assert_redirected_to "/"
                    end
                  end # on action in only

                end # context with timestamp in the future

              end # context with conflict
              context "alternate id key based on model name" do
                context "without conflict" do
                  context "past timestamp without rendered at" do
                    should "redirect" do
                      get :action1, :timestamp_with_custom_accessor_id => 3
assert_redirected_to "/"
                    end
                  end
                  context "future timestamp without rendered at" do
                    should "redirect" do
                      get :action1, :timestamp_with_custom_accessor_id => 2
assert_redirected_to "/"
                    end
                  end
                end #without conflict
                context "with conflict" do
                  should "redirect" do
                    get :action1, :timestamp_with_custom_accessor_id => 2, :page_rendered_at => Time.now.to_i
                    assert_redirected_to "/"
                  end
                end
              end #alternate id
            end # context with basic timestamp
          end #context without id
          context "with id" do
            setup do
              class FilterConflictWithModelAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :model => TimestampWithCustomAccessor, :id => 2, :accessor=> :timestamp
              end
              FilterConflictWithModelAccessorAndIdTestsController.view_paths = ['...']
              @controller = FilterConflictWithModelAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithModelAccessorAndIdTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "redirect" do

                    get :action1, :id => 1
assert_redirected_to "/"
                  end
                  context "with timestamp parameter" do
                    should "redirect" do

                      get :action1, :id => 1, :page_rendered_at => Time.now.to_i
                      assert_redirected_to "/"
                    end
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with timestamp in the future" do
                  should "without timestamp parameter should redirect" do
                    get :action1, :id => 2
assert_redirected_to "/"
                  end
                  should "with timestamp should redirect" do

                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                    assert_redirected_to "/"
                  end

                end # context with timestamp in the future

              end # context with conflict
            end # context with basic timestamp

          end #with id
        end # with accessor

        context "with id" do
          setup do
            class FilterConflictWithModelAndIdTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :model => Timestamp, :id => 2
            end
            FilterConflictWithModelAndIdTestsController.view_paths = ['...']
            @controller = FilterConflictWithModelAndIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithModelAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do

                  get :action1, :id => 1
assert_redirected_to "/"
                end
                context "with timestamp parameter" do
                  should "redirect" do

                    get :action1, :id => 1, :page_rendered_at => Time.now.to_i
                    assert_redirected_to "/"
                  end
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                should "without timestamp parameter should redirect" do
                  get :action1, :id => 2
assert_redirected_to "/"
                end
                should "with timestamp should redirect" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                end

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp

        end #with id
        context "with params id key" do
          setup do
            class FilterConflictWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :model => TimestampWithCustomAccessor, :params_id_key => :name
            end
            FilterConflictWithModelAndParamsIdKeyTestsController.view_paths = ['...']
            @controller = FilterConflictWithModelAndParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithModelAndParamsIdKeyTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do

                  get :action1, :id => 1, :name => 2
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on action in only" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end
                  end
                  should "not redirect" do

                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                    assert_response :success
                  end
                end # on action in only

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
          context "with accessor" do
            context "without id" do
              setup do
                class FilterConflictWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_conflicts :model => TimestampWithCustomAccessor,
                    :accessor => :timestamp, :params_id_key => :name
                end
                FilterConflictWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = FilterConflictWithModelAndParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  FilterConflictWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "timestamps"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 3, :name => 2
                      assert_redirected_to "/"
                    end
                  end
                  context "with timestamp parameter" do
                    should "redirect" do

                      get :action1, :id => 1, :name => 2, :page_rendered_at => Time.now.to_i
                      assert_redirected_to "/"
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with timestamp in the future" do
                    
                    context "without timestamp parameter" do
                      should "redirect" do
                        get :action1, :id => 2, :name => 2
                        assert_redirected_to "/"
                      end
                    end
                    should "redirect" do

                      get :action1, {:id => 2, :name => 2, :page_rendered_at =>Time.now.to_i}
                      assert_redirected_to "/"
                    end
                    

                  end # context with timestamp in the future

                end # context with conflict
              end # context with basic timestamp
            end #context without id
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :model => TimestampWithCustomAccessor,
                      :id => 2, :accessor=> :timestamp, :params_id_key => :name
                  end
                end
              end
            end #with id
          end # with accessor
          context "without accessor" do
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :model => Timestamp, :id => 2, :params_id_key => :name
                  end
                end
              end
            end #with id
          end #without accessor
        end
        context "with find options" do
          setup do
            class FilterConflictWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :model => TimestampWithCustomAccessor,
                :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
            end
            FilterConflictWithModelAndFindOptionsTestsController.view_paths = ['...']
            @controller = FilterConflictWithModelAndFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithModelAndFindOptionsTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1, :id => 1, :name => "Updated In the Future"
assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on action in only" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 2, :name => "Updated In the Future"
assert_redirected_to "/"
                    end
                  end
                  should "not redirect" do
                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                      :name => "Updated In the Future"}
                    assert_response :success
                  end
                end # on action in only

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
          context "with accessor" do
            context "without id" do
              setup do
                class FilterConflictWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_conflicts :model => TimestampWithCustomAccessor,
                    :accessor => :timestamp, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                end
                FilterConflictWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = FilterConflictWithModelAndFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  FilterConflictWithModelAndFindOptionsAndAccessorTestsController.controller_name = "timestamps"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 1, :name => "Updated In the Future"
assert_redirected_to "/"
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with timestamp in the future" do
                    context "on action in only" do
                      context "without timestamp parameter" do
                        should "redirect" do
                          get :action1, :id => 2, :name => "Updated In the Future"
assert_redirected_to "/"
                        end
                      end
                      should "not redirect" do

                        get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                          :name => "Updated In the Future"}
                        assert_redirected_to "/"
                      end
                    end # on action in only

                  end # context with timestamp in the future

                end # context with conflict
              end # context with basic timestamp
            end #context without id
            context "with id" do
              should "raise ArgumentError" do
                assert_raise(ArgumentError) do class FilterConflictWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :model => TimestampWithCustomAccessor,
                      :id => 2, :accessor=> :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end #with id
          end # with accessor
          context "with id" do
            context "without accessor" do
              should "Raise ArgumentError"do
                assert_raise(ArgumentError) do
                  class FilterConflictWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :model => Timestamp, :id => 2,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
          end #with id
          context "with params id key" do
            context "without accessor" do
              should "raise ArgumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :model => TimestampWithCustomAccessor,
                      :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
            context "with accessor" do
              context "without id" do
                should "raise ArgumentError"do
                  assert_raise(ArgumentError) do
                    class FilterConflictWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_conflicts :model => TimestampWithCustomAccessor,
                        :accessor => :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #context without id
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class FilterConflictWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_conflicts :model => TimestampWithCustomAccessor,
                        :id => 2, :accessor=> :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #with id
            end # with accessor
            context "without accessor" do
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class FilterConflictWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_conflicts :model => Timestamp, :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end

              end #with id
            end  #without accessor
          end #with params id key
        end # with find options
        context "as active record object" do
          context "instance without timestamp" do
            setup do
              class FilterConflictWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :model => Timestamp.first
              end
              FilterConflictWithModelARObjectTestsController.view_paths = ['...']
              @controller = FilterConflictWithModelARObjectTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithModelARObjectTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "redirect" do
                    get :action1, :id => 1
assert_redirected_to "/"
                  end
                end
                should " not redirect" do
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end

              end # context with conflict
            end # context with basic timestamp
          end # instance without timestamp
          context "instance without timestamp in past" do
            setup do
              class FilterConflictWithModelARObjectInPastTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :model => Timestamp.find(3)
              end
              FilterConflictWithModelARObjectInPastTestsController.view_paths = ['...']
              @controller = FilterConflictWithModelARObjectInPastTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithModelARObjectInPastTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "redirect" do
                    get :action1, :id => 1
assert_redirected_to "/"
                  end
                end
                should "not redirect" do
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end

              end # context with conflict
            end # context with basic timestamp
          end # instance with timestamp in past
          context "instance without timestamp in future" do
            setup do
              class FilterConflictWithModelARObjectInFutureTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :model => Timestamp.find(2)
              end
              FilterConflictWithModelARObjectInFutureTestsController.view_paths = ['...']
              @controller = FilterConflictWithModelARObjectInFutureTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithModelARObjectInFutureTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "redirect" do
                    get :action1, :id => 1
                    assert_redirected_to "/"
                  end
                end
              end
              context "with conflict" do
                should "not redirect" do
                  get :action1, {:id => 2, :page_rendered_at => Time.now.to_i}
                  assert_redirected_to "/"
                end

              end # context with conflict
            end # context with basic timestamp
          end # instance with timestamp in past
        end # as activeRecord object
        context "with model as symbol" do
          setup do
            class FilterConflictWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :model => :timestamp
            end
            FilterConflictWithModelSymbolTestsController.view_paths = ['...']
            @controller = FilterConflictWithModelSymbolTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithModelSymbolTestsController.controller_name = "timestamp_with_custom_accessors"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                assert_redirected_to "/"
              end

            end # context with conflict
          end # context with basic timestamp
        end # model as symbol
        context "with model as string" do
          setup do
            class FilterConflictWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :model => "timestamp"
            end
            FilterConflictWithModelStringTestsController.view_paths = ['...']
            @controller = FilterConflictWithModelStringTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithModelStringTestsController.controller_name = "timestamp_with_custom_accessors"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                assert_redirected_to "/"
              end

            end # context with conflict
          end # context with basic timestamp
        end # model as string

      end # with model

      context "instance selectors without model" do
        context "with accessor" do
          context "with bogus accessor" do
            setup do
              class FilterConflictWithBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :accessor => :bogus
              end
              FilterConflictWithBogusAccessorTestsController.controller_name = "timestamps"
              should "raise no method error" do
                assert_raise(NoMethodError) do
                  get :action1, :id => 3
                end
              end
            end
          end #bogus accessor
          context "without id" do
            setup do
              class FilterConflictWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts  :accessor => :timestamp
              end
              FilterConflictWithAccessorTestsController.view_paths = ['...']
              @controller = FilterConflictWithAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do
                    get :action1, :id => 1
                    assert_redirected_to "/"
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with timestamp in the future" do
                  context "on action in only" do
                    context "without timestamp parameter" do
                      should "redirect" do
                        get :action1, :id => 3
                        assert_redirected_to "/"
                      end
                    end
                    should "not redirect" do

                      get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                      assert_redirected_to "/"
                    end
                  end # on action in only

                end # context with timestamp in the future

              end # context with conflict
            end # context with basic timestamp
          end #context without id
          context "with id" do
            setup do
              class FilterConflictWithAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts  :id => 2, :accessor=> :timestamp
              end
              FilterConflictWithAccessorAndIdTestsController.view_paths = ['...']
              @controller = FilterConflictWithAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                FilterConflictWithAccessorAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "redirect" do

                    get :action1, :id => 1
                    assert_redirected_to "/"
                  end
                  context "with timestamp parameter" do
                    should "redirect" do

                      get :action1, :id => 1, :page_rendered_at => Time.now.to_i
                      assert_redirected_to "/"
                    end
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with timestamp in the future" do
                  should "without timestamp parameter should not redirect" do
                    get :action1, :id => 3
                    assert_redirected_to "/"
                  end
                  should "with timestamp should redirect" do

                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                    assert_redirected_to "/"
                  end

                end # context with timestamp in the future

              end # context with conflict
            end # context with basic timestamp

          end #with id
        end # with accessor

        context "with id" do
          setup do
            class FilterConflictWithIdTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts  :id => 2
            end
            FilterConflictWithIdTestsController.view_paths = ['...']
            @controller = FilterConflictWithIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithIdTestsController.controller_name = "timestamp"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do

                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
                context "with timestamp parameter" do
                  should "redirect" do

                    get :action1, :id => 1, :page_rendered_at => Time.now.to_i
                    assert_redirected_to "/"
                  end
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                should "without timestamp parameter should redirect" do
                  get :action1, :id => 2
                  assert_redirected_to "/"
                end
                should "with timestamp should redirect" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                end

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp

        end #with id
        context "with params id key" do
          setup do
            class FilterConflictWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts  :params_id_key => :name
            end
            FilterConflictWithParamsIdKeyTestsController.view_paths = ['...']
            @controller = FilterConflictWithParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithParamsIdKeyTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do

                  get :action1, :id => 1, :name => 2
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "without params_id_key parameter" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end
                  end
                  context "with timestamp parameter" do
                    should "not redirect" do
                      get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                      assert_response :success
                    end
                  end
                end # without params id key parameter
                context "with params id key parameter" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 2, :name => 2
                      assert_redirected_to "/"
                    end
                  end
                  context "with timestamp parameter" do
                    should "redirect" do
                      get :action1, {:id => 2, :name => 2, :page_rendered_at =>Time.now.to_i}
                      assert_redirected_to "/"
                    end
                  end
                end

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
          context "with accessor" do
            context "without id" do
              setup do
                class FilterConflictWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_conflicts :accessor => :timestamp, :params_id_key => :name
                end
                FilterConflictWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = FilterConflictWithParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  FilterConflictWithParamsIdKeyAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 1, :name => 2
                      assert_redirected_to "/"
                    end
                  end
                  context "with timestamp parameter" do
                    should "redirect" do

                      get :action1, :id => 1, :name => 2, :page_rendered_at => Time.now.to_i
                      assert_redirected_to "/"
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with timestamp in the future" do

                    context "without timestamp parameter" do
                      should "redirect" do
                        get :action1, :id => 2, :name => 2
                        assert_redirected_to "/"
                      end
                    end
                    should "redirect" do

                      get :action1, {:id => 2, :name => 2, :page_rendered_at =>Time.now.to_i}
                      assert_redirected_to "/"
                    end


                  end # context with timestamp in the future

                end # context with conflict
              end # context with basic timestamp
            end #context without id
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :id => 2, :accessor=> :timestamp, :params_id_key => :name
                  end
                end
              end
            end #with id
          end # with accessor
          context "without accessor" do
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts  :id => 2, :params_id_key => :name
                  end
                end
              end
            end #with id
          end #without accessor
        end
        context "with find options" do
          setup do
            class FilterConflictWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts  :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
            end
            FilterConflictWithFindOptionsTestsController.view_paths = ['...']
            @controller = FilterConflictWithFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              FilterConflictWithFindOptionsTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1, :id => 1, :name => "Updated In the Future"
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on action in only" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 2, :name => "Updated In the Future"
                      assert_redirected_to "/"
                    end
                  end
                  should "redirect" do
                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                      :name => "Updated In the Future"}
                    assert_redirected_to "/"
                  end
                end # on action in only

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
          context "with accessor" do
            context "without id" do
              setup do
                class FilterConflictWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_conflicts :accessor => :timestamp,
                    :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                end
                FilterConflictWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = FilterConflictWithFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  FilterConflictWithFindOptionsAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 1, :name => "Updated In the Future"
                      assert_redirected_to "/"
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with timestamp in the future" do
                    context "on action in only" do
                      context "without timestamp parameter" do
                        should "redirect" do
                          get :action1, :id => 2, :name => "Updated In the Future"
                          assert_redirected_to "/"
                        end
                      end
                      should "not redirect" do

                        get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                          :name => "Updated In the Future"}
                        assert_redirected_to "/"
                      end
                    end # on action in only

                  end # context with timestamp in the future

                end # context with conflict
              end # context with basic timestamp
            end #context without id
            context "with id" do
              should "raise ArgumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :id => 2, :accessor=> :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end #with id
          end # with accessor
          context "with id" do
            context "without accessor" do
              should "Raise ArgumentError"do
                assert_raise(ArgumentError) do
                  class FilterConflictWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts  :id => 2,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
          end #with id
          context "with params id key" do
            context "without accessor" do
              should "raise ArgumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :params_id_key => :name,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
            context "with accessor" do
              context "without id" do
                should "raise ArgumentError"do
                  assert_raise(ArgumentError) do
                    class FilterConflictWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_conflicts  :accessor => :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #context without id
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class FilterConflictWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_conflicts :id => 2, :accessor=> :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #with id
            end # with accessor
            context "without accessor" do
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class FilterConflictWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_conflicts  :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end

              end #with id
            end  #without accessor
          end #with params id key
          context "with bad find options" do
            should "raise error when find options is not a proc" do
              assert_raise(ArgumentError) do
                class FilterConflictBadFindOptinsTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_conflicts :find_options => {:conditions => {:name => "Test value"}}
                end
              end
            end
          end
        end # with find options

      end # instance selectors without model
      context "simulation keys" do
        context "with simulate conflicts on requests before" do
          setup do
            class FilterConflictWithSimulateConflictsOnRequestsBeforeTestController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :simulate_conflict_on_requests_before => Time.now - 2.minutes
            end
            @controller = FilterConflictWithSimulateConflictsOnRequestsBeforeTestController.new
            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }
            FilterConflictWithSimulateConflictsOnRequestsBeforeTestController.view_paths = ['...']
          end
          context "with basic timestamp" do

            context "without simulated conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1
                  assert_redirected_to "/"
                end
              end
              context "with timestamp parameter" do
                context "with timestamp missing on record" do
                  should "not redirect " do
                    get :action1, :id => 1, :page_rendered_at =>(Time.now + 5.minutes).to_i
                    assert_response :success
                  end
                end
                context "with timestamp in the future" do
                  should "not redirect" do
                    get :action1, :id => 2, :page_rendered_at => (Time.now + 5.minutes).to_i
                    assert_response :success
                  end
                end # context with timestamp in the future
                context "with timestamp in the past" do
                  should "not redirect" do
                    get :action1, :id => 3, :page_rendered_at => (Time.now + 5.minutes).to_i
                    assert_response :success
                  end
                end # context with timestamp in the future
              end
            end

            context "with conflict" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :page_rendered_at =>(Time.now - 5.minutes).to_i
                  assert_redirected_to "/"
                end
              end
              context "with timestamp in the future" do
                should "not redirect" do
                  get :action1, :id => 2, :page_rendered_at => (Time.now - 5.minutes).to_i
                  assert_redirected_to "/"
                end
              end # context with timestamp in the future
              context "with timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :page_rendered_at => (Time.now - 5.minutes).to_i
                  assert_redirected_to "/"
                end
              end # context with timestamp in the future


            end # with conflict
          end #with basic timestapm
        end #with simulate conlfict on requests before

        context "with simulate conflicts on requests after" do
          setup do
            class FilterConflictWithSimulateConflictsOnRequestsAfterTestController < ::ConflictWarningsTest::ControllerStub
              filter_conflicts :simulate_conflict_on_requests_after => (Time.now + 5.minutes)
            end
            @controller = FilterConflictWithSimulateConflictsOnRequestsAfterTestController.new
            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }
            FilterConflictWithSimulateConflictsOnRequestsAfterTestController.view_paths = ['...']
          end
          context "with basic timestamp" do
            
            context "without simulated conflict" do
              context "without timestamp parameter" do
                should "redirect" do
                  get :action1
                  assert_redirected_to "/"
                end
              end
              context "with timestamp parameter" do
                context "with timestamp missing on record" do
                  should "not redirect " do
                    get :action1, :id => 1, :page_rendered_at =>(Time.now - 5.minutes).to_i
                    assert_response :success
                  end
                end
                context "with timestamp in the future" do
                  should "not redirect" do
                    get :action1, :id => 2, :page_rendered_at => (Time.now - 5.minutes).to_i
                    assert_response :success
                  end
                end # context with timestamp in the future
                context "with timestamp in the past" do
                  should "not redirect" do
                    get :action1, :id => 3, :page_rendered_at => (Time.now - 5.minutes).to_i
                    assert_response :success
                  end
                end # context with timestamp in the future
              end
            end

            context "with conflict" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :page_rendered_at =>(Time.now + 10.minutes).to_i
                  assert_redirected_to "/"
                end
              end
              context "with timestamp in the future" do
                should "not redirect" do
                  get :action1, :id => 2, :page_rendered_at => (Time.now + 10.minutes).to_i
                  assert_redirected_to "/"
                end
              end # context with timestamp in the future
              context "with timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :page_rendered_at => (Time.now + 10.minutes).to_i
                  assert_redirected_to "/"
                end
              end # context with timestamp in the future
              

            end # with conflict
          end #with basic timestapm
        end #with simulate conlfict on requests before
        context "with both simulate conflict keys" do
          context "simulate conflict before > simulate conflict after" do
            setup do
              class FilterConflictWithBothSimulateConflictKeysOneRangeTestController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :simulate_conflict_on_requests_before => (Time.now + 5.minutes),
                  :simulate_conflict_on_requests_after => (Time.now - 5.minutes)
              end
              @controller = FilterConflictWithBothSimulateConflictKeysOneRangeTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
            end
            context "without conflict" do

              context "rendered without timestamp" do
                should "redirect" do
                  get :action1
                  assert_redirected_to "/"
                end
              end
              context "rendered after simulate conflicts before" do
                should "not redirect" do
                  get :action1, :page_rendered_at => (Time.now + 10.minutes).to_i
                  assert_response :success
                end
              end
              context "rendered before simulate conflicts after" do
                should "not redirect" do
                  get :action1, :page_rendered_at => (Time.now - 10.minutes).to_i
                  assert_response :success
                end
              end
            end
            context "with conflict" do
              context "rendered between redirect after and redirect before" do
                should "redirect" do
                  get :action1, :page_rendered_at => Time.now.to_i
                  assert_redirected_to "/"
                end
              end
            end
          end

          context "simulate conflict before < simulate conflict after" do
            setup do
              class FilterConflictWithBothSimulateConflictKeysTwoRangesTestController < ::ConflictWarningsTest::ControllerStub
                filter_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                  :simulate_conflict_on_requests_after => (Time.now + 5.minutes)
              end
              @controller = FilterConflictWithBothSimulateConflictKeysTwoRangesTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
            end
            context "with conflict" do

              context "rendered after simulate conflicts after" do
                should "redirect" do
                  get :action1, :page_rendered_at => (Time.now + 10.minutes).to_i
                  assert_redirected_to "/"
                end
              end
              context "rendered before simulate conflicts before" do
                should "redirect" do
                  get :action1, :page_rendered_at => (Time.now - 10.minutes).to_i
                  assert_redirected_to "/"
                end
              end
            end
            context "without conflict" do
              context "rendered without timestamp" do
                should "redirect" do
                  get :action1
                  assert_redirected_to "/"
                end
              end
              context "rendered between redirect after and redirect before" do
                should "redirect" do
                  get :action1, :page_rendered_at => Time.now.to_i
                  assert_response :success
                end
              end
            end
          end
        end # context with both simulate conflict keys
        context "with a simulate conflict key and model or instance key" do
          context "with requests_before" do
            context "with model" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateBeforeAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :model => Timestamp
                  end
                end
              end
            end #with model
            context "with params id key" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateBeforeAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :parmas_id_key => :something
                  end
                end
              end
            end #with params_id_key
            context "with id" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateBeforeAndIdTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :id => 5
                  end
                end
              end
            end #with id
            context "with find options" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateBeforeAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end #with model
          end # with requests before
          context "with requests_after" do
            context "with model" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateAfterAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :model => Timestamp
                  end
                end
              end
            end #with model
            context "with params id key" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateAfterAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :parmas_id_key => :something
                  end
                end
              end
            end #with params_id_key
            context "with id" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateAfterAndIdTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :id => 5
                  end
                end
              end
            end #with id
            context "with find options" do
              should "raise ArumentError" do
                assert_raise(ArgumentError) do
                  class FilterConflictWithSimulateAfterAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                    filter_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end #find options
          end # with requests after
        end # context with a simulate conflict key and model or instance key
      end #simulate keys
      context "timestamp key" do
        setup do
          class FilterConflictWithTimeStampKeyTestController < ::ConflictWarningsTest::ControllerStub
            filter_conflicts :timestamp_key => :timestamp
          end
          @controller = FilterConflictWithTimeStampKeyTestController.new
        end
        context "with basic timestamp" do
          setup do
            FilterConflictWithTimeStampKeyTestController.controller_name = "timestamps"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should"raise ArgumentError" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end
            context "with standard timestamp parameter" do
              context "with timestamp missing on record" do
                should "redirect " do
                  get :action1, :id => 1, :page_rendered_at =>Time.now.to_i
                  assert_redirected_to "/"
                end
              end
              context "With timestamp in the past" do
                should "redirect" do
                  get :action1, :id => 3, :page_rendered_at =>Time.now.to_i
                  assert_redirected_to "/"
                end
              end
              context "with timestamp in the future" do
                should "redirect" do
                  get :action1, {:id => 2, :page_rendered_at => Time.now.to_i}
                  assert_redirected_to "/"
                end
              end
            end # with standard timestamp parameter
            context "with new timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :timestamp => Time.now.to_i
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :timestamp => Time.now.to_i
                  assert_response :success
                end
              end
            end #with new timestamp paremeter
          end #without conflict
          context "with conflict" do
            context "with new timestamp parameter" do
              context "With model's timestamp in future" do
                should "redirect" do
                  get :action1, :id => 2, :timestamp => Time.now.to_i
                  assert_redirected_to "/"
                end
              end
              
            end #with new timestamp parameter
          end #with conflict
        end #basic time stamp
        
      end # timestamp key
      context "template" do
        setup do
          class FilterConflictWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            filter_conflicts :template => "custom/custom"
            #cattr_accessor :controller_name
          end
          @controller = FilterConflictWithTemplateTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          FilterConflictWithTemplateTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            FilterConflictWithTemplateTestController.controller_name = "timestamps"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should"raise ArgumentError" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end
            context "with timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :page_rendered_at =>Time.now.to_i
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :page_rendered_at =>Time.now.to_i
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
            context "with timestamp in the future" do
              context "without template" do
                should "redirect" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_redirected_to "/"
                  assert_match /out of date/, flash[:warning]
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  FilterConflictWithTemplateTestController.append_view_path TestViewPath
                  @controller = FilterConflictWithTemplateTestController.new
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response 409
                  assert_template("custom/custom_conflict")                  
                end # should not redirect and render default template
              end # context with template
            end # context with timestamp in the future

          end # context with conflict
        end # context with basic timestamp
      end #template
    end # context with options
    context "with block" do
      setup do
        class FilterConflictWithBlockTestController < ::ConflictWarningsTest::ControllerStub
          filter_conflicts do
            respond_to do |format|
              format.html {render :text => "Live from the block"}
              format.js { render :update do |page|
                  page << "alert('JS from the block')"
                end
              }
            end
          end
        end
        @controller = FilterConflictWithBlockTestController.new
        ActionController::Routing::Routes.draw {|map|
          map.connect "/:action", :controller => @controller.controller_path
          map.connect "/:action/:id", :controller => @controller.controller_path
        }
        FilterConflictWithBlockTestController.view_paths = ['...']

        FilterConflictWithBlockTestController.controller_name = "timestamps"
      end #setup
      context "accepts html" do
        context "with basic timestamp" do
          context "without conflict" do
            context "without timestamp parameter" do
              should"raise ArgumentError" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end
            context "with timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :page_rendered_at =>Time.now.to_i
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :page_rendered_at =>Time.now.to_i
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
            context "with timestamp in the future" do
              context "without template" do
                should "redirect" do

                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_match /Live from the block/, @response.body
                  assert_match /out of date/, flash[:warning]
                  assert_response :success
                end
              end # context without template
            end # context with timestamp in the future

          end # context with conflict
        end # context with basic timestamp
      end #accepts html
      context "accepts js" do
        context "with basic timestamp" do
          context "without conflict" do
            context "without timestamp parameter" do
              should"raise ArgumentError" do
                assert_raise(ArgumentError) do
                  get :action1, :format => "js"
                end
              end
            end
            context "with timestamp parameter" do
              context "with timestamp missing on record" do
                should "not redirect " do
                  get :action1, :id => 1, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response :success
                end
              end
              context "With timestamp in the past" do
                should "not redirect" do
                  get :action1, :id => 3, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
            context "with timestamp in the future" do
              context "without template" do
                should "redirect" do

                  get :action1, :id => 2, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response :success
                  assert_match(/alert\('JS/, @response.body)
                end
              end # context without template

            end # context with timestamp in the future

          end # context with conflict
        end # context with basic timestamp

      end #accepts js

    end #with block
  end #context filter conflicts
end