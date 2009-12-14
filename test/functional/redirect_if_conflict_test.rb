require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class RedirectIfConflictWarningsBasicTest < ActionController::TestCase
  #  class StubController < ActionController::Base
  #     ConflictWarningsTest::ControllerBits
  #  end
  #  #fixtures :timestamps, :resources, :resources_with_custom_accessors,
  #  :timestamps_with_custom_accessors, :timestamps_with_updated_ats
  context "redirect if conflicts" do
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
          class RedirectIfConflictWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
          
            before_filter do |controller|
              controller.redirect_if_conflict()
            end
            #cattr_accessor :controller_name
          end
          @controller = RedirectIfConflictWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          RedirectIfConflictWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            RedirectIfConflictWithoutOptionsTestController.controller_name = "timestamps"
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
                  RedirectIfConflictWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = RedirectIfConflictWithoutOptionsTestController.new
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response 409
                  assert_template("action1_conflict")
                end # should not redirect and render default template
              end # context with template
            end # context with timestamp in the future

          end # context with conflict
          context "alternate id key based on model name" do
            context "without conflict" do
              context "past timestamp without rendered at" do
                should "not redirect" do
                  get :action1, :timestamp_id => 3
                  assert_response :success
                end
              end
              context "future timestamp without rendered at" do
                should "redirect" do
                  get :action1, :timestamp_id => 2
                  assert_response :success
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
            RedirectIfConflictWithoutOptionsTestController.controller_name = "timestamp_with_custom_accessors"
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
                  RedirectIfConflictWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
            end
          end
        end # context with custom accessro timestamp
        context "with updated_at timestamp" do
          setup do
            RedirectIfConflictWithoutOptionsTestController.controller_name = "timestamp_with_updated_ats"
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
                should "not redirect" do
                  get :action1, :id => 2
                  assert_response :success
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
                  RedirectIfConflictWithoutOptionsTestController.append_view_path TestViewPath
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
          class RedirectIfConflictWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.redirect_if_conflict()
            end
          end
          @controller = RedirectIfConflictWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          RedirectIfConflictWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            RedirectIfConflictWithoutOptionsJSTestController.controller_name = "timestamps"
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
                  RedirectIfConflictWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = RedirectIfConflictWithoutOptionsJSTestController.new
                  get :action1, :id => 2, :page_rendered_at =>Time.now.to_i, :format => "js"
                  assert_response 409
                  assert_template("action1_conflict.rjs")
                end # should not redirect and render default template
              end # context with template
            end # context with timestamp in the future

          end # context with conflict
          context "alternate id key based on model name" do
            context "without conflict" do
              context "past timestamp without rendered at" do
                should "not redirect" do
                  get :action1, :timestamp_id => 3, :format => "js"
                  assert_response :success
                end
              end
              context "future timestamp without rendered at" do
                should "redirect" do
                  get :action1, :timestamp_id => 2, :foramt => "js"
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, :timestamp_id => 2, :page_rendered_at => Time.now.to_i,
                  :format => "js"
                assert_response 409
                assert_match(/alert/, @response.body)
              end
            end
          end #alternate id
        end # context with basic timestamp

      end #accepts js
    end # context without options
    context "using options" do
      context "with flash key" do
        context "without message" do
          setup do
            class RedirectIfConflictWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :flash_key => :error)
              end
            end
            RedirectIfConflictWithFlashKeyTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithFlashKeyTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 1
                  assert_response :success
                  assert_no_match /not be processed/, flash[:error]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
              
                context "without timestamp parameter" do
                  should "not set flash[:error]" do
                    get :action1, :id => 2
                    assert_response :success
                    assert_no_match /not be processed/, flash[:error]
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
            class RedirectIfConflictWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :flash_key => :error, :message => "CONFLICT!")
              end
            end
            RedirectIfConflictWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithFlashKeyAndMessageTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 1
                  assert_response :success
                  assert_no_match /CONFLICT!/, flash[:error]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do

                context "without timestamp parameter" do
                  should "not set flash[:error]" do
                    get :action1, :id => 2
                    assert_response :success
                    assert_no_match /CONFLICT!/, flash[:error]
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
            class RedirectIfConflictWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :message => "CONFLICT!")
              end
            end
            RedirectIfConflictWithMessageTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithMessageTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 1
                  assert_response :success
                  assert_no_match /CONFLICT!/, flash[:warning]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do

                context "without timestamp parameter" do
                  should "not set flash[:error]" do
                    get :action1, :id => 2
                    assert_response :success
                    assert_no_match /CONFLICT!/, flash[:warning]
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
              class RedirectIfConflictWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :message => "CONFLICT")
                end
              end
              @controller = RedirectIfConflictWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              RedirectIfConflictWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithMessageJSTestController.controller_name = "timestamps"
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
                      RedirectIfConflictWithMessageJSTestController.append_view_path TestViewPath
                      @controller = RedirectIfConflictWithMessageJSTestController.new
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
          class RedirectIfConflictWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.redirect_if_conflict( :model => TimestampWithCustomAccessor)
            end
          end
          RedirectIfConflictWithModelTestsController.view_paths = ['...']
          @controller = RedirectIfConflictWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic timestamp" do
          setup do
            RedirectIfConflictWithModelTestsController.controller_name = "timestamps"
          end
          context "without conflict" do
            context "without timestamp parameter" do
              should "not redirect" do
                get :action1, :id => 1
                assert_response :success
              end
            end
          end #without conflict
          context "with conflict" do
            context "with timestamp in the future" do
              context "on action in only" do
                context "without timestamp parameter" do
                  should "not redirect" do
                    get :action1, :id => 2
                    assert_response :success
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
              class RedirectIfConflictWithModelAndBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :model => Timestamp, :accessor => :bogus)
                end
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
              class RedirectIfConflictWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :model => TimestampWithCustomAccessor, :accessor => :timestamp)
                end
              end
              RedirectIfConflictWithModelAndAccessorTestsController.view_paths = ['...']
              @controller = RedirectIfConflictWithModelAndAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithModelAndAccessorTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do
                    get :action1, :id => 1
                    assert_response :success
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with timestamp in the future" do
                  context "on action in only" do
                    context "without timestamp parameter" do
                      should "not redirect" do
                        get :action1, :id => 2
                        assert_response :success
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
                    should "not redirect" do
                      get :action1, :timestamp_with_custom_accessor_id => 3
                      assert_response :success
                    end
                  end
                  context "future timestamp without rendered at" do
                    should "redirect" do
                      get :action1, :timestamp_with_custom_accessor_id => 2
                      assert_response :success
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
              class RedirectIfConflictWithModelAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :model => TimestampWithCustomAccessor, :id => 2, :accessor=> :timestamp)
                end
              end
              RedirectIfConflictWithModelAccessorAndIdTestsController.view_paths = ['...']
              @controller = RedirectIfConflictWithModelAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithModelAccessorAndIdTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do

                    get :action1, :id => 1
                    assert_response :success
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
                    get :action1, :id => 2
                    assert_response :success
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
            class RedirectIfConflictWithModelAndIdTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :model => Timestamp, :id => 2)
              end
            end
            RedirectIfConflictWithModelAndIdTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithModelAndIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithModelAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not redirect" do

                  get :action1, :id => 1
                  assert_response :success
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
                  get :action1, :id => 2
                  assert_response :success
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
            class RedirectIfConflictWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :model => TimestampWithCustomAccessor, :params_id_key => :name)
              end
            end
            RedirectIfConflictWithModelAndParamsIdKeyTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithModelAndParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithModelAndParamsIdKeyTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do

                  get :action1, :id => 1, :name => 2
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on action in only" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 2
                      assert_response :success
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
                class RedirectIfConflictWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                      :accessor => :timestamp, :params_id_key => :name)
                  end
                end
                RedirectIfConflictWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfConflictWithModelAndParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  RedirectIfConflictWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "timestamps"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => 2
                      assert_response :success
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
                      should "not redirect" do
                        get :action1, :id => 2, :name => 2
                        assert_response :success
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
              setup do
                class RedirectIfConflictWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                      :id => 2, :accessor=> :timestamp, :params_id_key => :name)
                  end
                end
                @controller = RedirectIfConflictWithModelAndParamsIdKeyAccessorAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              
              end
            end #with id
          end # with accessor
          context "without accessor" do
            context "with id" do
              
              setup do
                class RedirectIfConflictWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict(:model => Timestamp, :id => 2, :params_id_key => :name)
                  end
                end
                @controller = RedirectIfConflictWithModelAndParamsIdKeyAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
              
            end #with id
          end #without accessor
        end
        context "with find options" do
          setup do
            class RedirectIfConflictWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                  :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
              end
            end
            RedirectIfConflictWithModelAndFindOptionsTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithModelAndFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithModelAndFindOptionsTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not redirect" do
                  get :action1, :id => 1, :name => "Upated In the Future"
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on action in only" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 2, :name => "Upated In the Future"
                      assert_response :success
                    end
                  end
                  should "not redirect" do
                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                      :name => "Upated In the Future"}
                    assert_response :success
                  end
                end # on action in only

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
          context "with accessor" do
            context "without id" do
              setup do
                class RedirectIfConflictWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                      :accessor => :timestamp, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                RedirectIfConflictWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfConflictWithModelAndFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  RedirectIfConflictWithModelAndFindOptionsAndAccessorTestsController.controller_name = "timestamps"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => "Upated In the Future"
                      assert_response :success
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with timestamp in the future" do
                    context "on action in only" do
                      context "without timestamp parameter" do
                        should "not redirect" do
                          get :action1, :id => 2, :name => "Upated In the Future"
                          assert_response :success
                        end
                      end
                      should "not redirect" do

                        get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                          :name => "Upated In the Future"}
                        assert_redirected_to "/"
                      end
                    end # on action in only

                  end # context with timestamp in the future

                end # context with conflict
              end # context with basic timestamp
            end #context without id
            context "with id" do
              setup do
                class RedirectIfConflictWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                      :id => 2, :accessor=> :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = RedirectIfConflictWithModelAndFindOptionsAccessorAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with id
          end # with accessor
          context "with id" do
            context "without accessor" do
              setup do
                class RedirectIfConflictWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :model => Timestamp, :id => 2,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = RedirectIfConflictWithModelAndFindOptionsAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
              
            end # without accessor
          end #with id
          context "with params id key" do
            context "without accessor" do
              setup do
                class RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                      :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end           
            end # without accessor
            context "with accessor" do
              context "without id" do
                setup do
                  class RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                        :accessor => :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end
              end #context without id
              context "with id" do
                setup do
                  class RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :model => TimestampWithCustomAccessor,
                        :id => 2, :accessor=> :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end
              end #with id
            end # with accessor
            context "without accessor" do
              context "with id" do
                setup do
                  class RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :model => Timestamp, :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = RedirectIfConflictWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end

              end #with id
            end  #without accessor
          end #with params id key
        end # with find options
        context "as active record object" do
          context "instance without timestamp" do
            setup do
              class RedirectIfConflictWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :model => Timestamp.first)
                end
              end
              RedirectIfConflictWithModelARObjectTestsController.view_paths = ['...']
              @controller = RedirectIfConflictWithModelARObjectTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithModelARObjectTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do
                    get :action1, :id => 1
                    assert_response :success
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
              class RedirectIfConflictWithModelARObjectInPastTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :model => Timestamp.find(3))
                end
              end
              RedirectIfConflictWithModelARObjectInPastTestsController.view_paths = ['...']
              @controller = RedirectIfConflictWithModelARObjectInPastTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithModelARObjectInPastTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do
                    get :action1, :id => 1
                    assert_response :success
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
              class RedirectIfConflictWithModelARObjectInFutureTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :model => Timestamp.find(2))
                end
              end
              RedirectIfConflictWithModelARObjectInFutureTestsController.view_paths = ['...']
              @controller = RedirectIfConflictWithModelARObjectInFutureTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithModelARObjectInFutureTestsController.controller_name = "timestamps"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do
                    get :action1, :id => 1
                    assert_response :success
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
            class RedirectIfConflictWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :model => :timestamp)
              end
            end
            RedirectIfConflictWithModelSymbolTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithModelSymbolTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithModelSymbolTestsController.controller_name = "timestamp_with_custom_accessors"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not redirect" do
                  get :action1, :id => 1
                  assert_response :success
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
            class RedirectIfConflictWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :model => "timestamp")
              end
            end
            RedirectIfConflictWithModelStringTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithModelStringTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithModelStringTestsController.controller_name = "timestamp_with_custom_accessors"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not redirect" do
                  get :action1, :id => 1
                  assert_response :success
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
              class RedirectIfConflictWithBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :accessor => :bogus)
                end
              end
              RedirectIfConflictWithBogusAccessorTestsController.controller_name = "timestamps"
              should "raise no method error" do
                assert_raise(NoMethodError) do
                  get :action1, :id => 3
                end
              end
            end
          end #bogus accessor
          context "without id" do
            setup do
              class RedirectIfConflictWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict(  :accessor => :timestamp)
                end
              end
              RedirectIfConflictWithAccessorTestsController.view_paths = ['...']
              @controller = RedirectIfConflictWithAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do
                    get :action1, :id => 1
                    assert_response :success
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with timestamp in the future" do
                  context "on action in only" do
                    context "without timestamp parameter" do
                      should "not redirect" do
                        get :action1, :id => 2
                        assert_response :success
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
              class RedirectIfConflictWithAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict(  :id => 2, :accessor=> :timestamp)
                end
              end
              RedirectIfConflictWithAccessorAndIdTestsController.view_paths = ['...']
              @controller = RedirectIfConflictWithAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                RedirectIfConflictWithAccessorAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "not redirect" do

                    get :action1, :id => 1
                    assert_response :success
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
                    get :action1, :id => 2
                    assert_response :success
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
            class RedirectIfConflictWithIdTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict(  :id => 2)
              end
            end
            RedirectIfConflictWithIdTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithIdTestsController.controller_name = "timestamp"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not redirect" do

                  get :action1, :id => 1
                  assert_response :success
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
                  get :action1, :id => 2
                  assert_response :success
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
            class RedirectIfConflictWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict(  :params_id_key => :name)
              end
            end
            RedirectIfConflictWithParamsIdKeyTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithParamsIdKeyTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do

                  get :action1, :id => 1, :name => 2
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "without params_id_key parameter" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 2
                      assert_response :success
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
                    should "not redirect" do
                      get :action1, :id => 2, :name => 2
                      assert_response :success
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
                class RedirectIfConflictWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :accessor => :timestamp, :params_id_key => :name)
                  end
                end
                RedirectIfConflictWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfConflictWithParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  RedirectIfConflictWithParamsIdKeyAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => 2
                      assert_response :success
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
                      should "not redirect" do
                        get :action1, :id => 2, :name => 2
                        assert_response :success
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
              setup do
                class RedirectIfConflictWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :id => 2, :accessor=> :timestamp, :params_id_key => :name)
                  end
                end
                @controller = RedirectIfConflictWithParamsIdKeyAccessorAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with id
          end # with accessor
          context "without accessor" do
            context "with id" do
              setup do
                class RedirectIfConflictWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict(  :id => 2, :params_id_key => :name)
                  end
                end
                @controller = RedirectIfConflictWithParamsIdKeyAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with id
          end #without accessor
        end
        context "with find options" do
          setup do
            class RedirectIfConflictWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict(  :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
              end
            end
            RedirectIfConflictWithFindOptionsTestsController.view_paths = ['...']
            @controller = RedirectIfConflictWithFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              RedirectIfConflictWithFindOptionsTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not redirect" do
                  get :action1, :id => 1, :name => "Upated In the Future"
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do
                context "on action in only" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 2, :name => "Upated In the Future"
                      assert_response :success
                    end
                  end
                  should "redirect" do
                    get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                      :name => "Upated In the Future"}
                    assert_redirected_to "/"
                  end
                end # on action in only

              end # context with timestamp in the future

            end # context with conflict
          end # context with basic timestamp
          context "with accessor" do
            context "without id" do
              setup do
                class RedirectIfConflictWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :accessor => :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                RedirectIfConflictWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfConflictWithFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  RedirectIfConflictWithFindOptionsAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => "Upated In the Future"
                      assert_response :success
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with timestamp in the future" do
                    context "on action in only" do
                      context "without timestamp parameter" do
                        should "not redirect" do
                          get :action1, :id => 2, :name => "Upated In the Future"
                          assert_response :success
                        end
                      end
                      should "not redirect" do

                        get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i,
                          :name => "Upated In the Future"}
                        assert_redirected_to "/"
                      end
                    end # on action in only

                  end # context with timestamp in the future

                end # context with conflict
              end # context with basic timestamp
            end #context without id
            context "with id" do
              setup do
                class RedirectIfConflictWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :id => 2, :accessor=> :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = RedirectIfConflictWithFindOptionsAccessorAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with id
          end # with accessor
          context "with id" do
            context "without accessor" do
              setup do
                class RedirectIfConflictWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict(  :id => 2,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                  @controller = RedirectIfConflictWithFindOptionsAndIdTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end
              end
            end # without accessor
          end #with id
          context "with params id key" do
            context "without accessor" do
              setup do
                class RedirectIfConflictWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_conflict( :params_id_key => :name,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = RedirectIfConflictWithFindOptionsAndParamsIdKeyTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end # without accessor
            context "with accessor" do
              context "without id" do
                setup do
                  class RedirectIfConflictWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict(  :accessor => :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = RedirectIfConflictWithFindOptionsAndParamsIdKeyAndAccessorTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end
              end #context without id
              context "with id" do
                setup do
                  class RedirectIfConflictWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :id => 2, :accessor=> :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = RedirectIfConflictWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end
              end #with id
            end # with accessor
            context "without accessor" do
              context "with id" do
                setup do
                  class RedirectIfConflictWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict(  :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = RedirectIfConflictWithFindOptionsAndParamsIdKeyAndIdTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end

              end #with id
            end  #without accessor
          end #with params id key
          context "with bad find options" do
            setup do
              class RedirectIfConflictBadFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :find_options => {:conditions => {:name => "Test value"}})
                end
              end
              @controller = RedirectIfConflictBadFindOptionsTestsController.new
            end
            should "raise Argument Error" do
              assert_raise(ArgumentError) do
                get :action1, :id => 3
              end
            end
          end
        end # with find options

      end # instance selectors without model
      context "simulation keys" do
        context "with simulate conflicts on requests before" do
          setup do
            class RedirectIfConflictWithSimulateConflictsOnRequestsBeforeTestController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :simulate_conflict_on_requests_before => Time.now - 2.minutes)
              end
            end
            @controller = RedirectIfConflictWithSimulateConflictsOnRequestsBeforeTestController.new
            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }
            RedirectIfConflictWithSimulateConflictsOnRequestsBeforeTestController.view_paths = ['...']
          end
          context "with basic timestamp" do

            context "without simulated conflict" do
              context "without timestamp parameter" do
                should "not redirect" do
                  get :action1
                  assert_response :success
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
            class RedirectIfConflictWithSimulateConflictsOnRequestsAfterTestController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_conflict( :simulate_conflict_on_requests_after => (Time.now + 5.minutes))
              end
            end
            @controller = RedirectIfConflictWithSimulateConflictsOnRequestsAfterTestController.new
            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }
            RedirectIfConflictWithSimulateConflictsOnRequestsAfterTestController.view_paths = ['...']
          end
          context "with basic timestamp" do
            
            context "without simulated conflict" do
              context "without timestamp parameter" do
                should "not redirect" do
                  get :action1
                  assert_response :success
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
              class RedirectIfConflictWithBothSimulateConflictKeysOneRangeTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :simulate_conflict_on_requests_before => (Time.now + 5.minutes),
                    :simulate_conflict_on_requests_after => (Time.now - 5.minutes))
                end
              end
              @controller = RedirectIfConflictWithBothSimulateConflictKeysOneRangeTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
            end
            context "without conflict" do

              context "rendered without timestamp" do
                should "not redirect" do
                  get :action1
                  assert_response :success
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
              class RedirectIfConflictWithBothSimulateConflictKeysTwoRangesTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_conflict( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                    :simulate_conflict_on_requests_after => (Time.now + 5.minutes))
                end
              end
              @controller = RedirectIfConflictWithBothSimulateConflictKeysTwoRangesTestController.new
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
                should "not redirect" do
                  get :action1
                  assert_response :success
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
              setup do
                  class RedirectIfConflictWithSimulateBeforeAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                        :model => Timestamp)
                    end
                  end
                @controller = RedirectIfConflictWithSimulateBeforeAndModelKeysTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #with model
            context "with params id key" do
             setup do
                  class RedirectIfConflictWithSimulateBeforeAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict(:simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                        :params_id_key => :something)
                    end
                  end
                @controller = RedirectIfConflictWithSimulateBeforeAndParamsIdKeyTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #with params_id_key
            context "with id" do
              setup do
                  class RedirectIfConflictWithSimulateBeforeAndIdTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                        :id => 5)
                    end
                  end
                @controller = RedirectIfConflictWithSimulateBeforeAndIdTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #with id
            context "with find options" do
              setup do
                  class RedirectIfConflictWithSimulateBeforeAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfConflictWithSimulateBeforeAndFindOptionsTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #with model
          end # with requests before
          context "with requests_after" do
            context "with model" do
              setup do
                  class RedirectIfConflictWithSimulateAfterAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                        :model => Timestamp)
                    end
                  end
                @controller = RedirectIfConflictWithSimulateAfterAndModelKeysTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #with model
            context "with params id key" do
              setup do
                  class RedirectIfConflictWithSimulateAfterAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                        :params_id_key => :something)
                    end
                  end
                @controller = RedirectIfConflictWithSimulateAfterAndParamsIdKeyTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #with params_id_key
            context "with id" do
              setup do
                  class RedirectIfConflictWithSimulateAfterAndIdTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                        :id => 5)
                    end
                  end
                @controller = RedirectIfConflictWithSimulateAfterAndIdTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #with id
            context "with find options" do
              setup do
                  class RedirectIfConflictWithSimulateAfterAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_conflict( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfConflictWithSimulateAfterAndFindOptionsTestController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
              end
            end #find options
          end # with requests after
        end # context with a simulate conflict key and model or instance key
      end #simulate keys
      context "timestamp key" do
        setup do
          class RedirectIfConflictWithTimeStampKeyTestController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.redirect_if_conflict( :timestamp_key => :timestamp)
            end
          end
          @controller = RedirectIfConflictWithTimeStampKeyTestController.new
        end
        context "with basic timestamp" do
          setup do
            RedirectIfConflictWithTimeStampKeyTestController.controller_name = "timestamps"
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
              context "with timestamp in the future" do
                should "not redirect" do
                  get :action1, {:id => 2, :page_rendered_at => Time.now.to_i}
                  assert_response :success
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
          class RedirectIfConflictWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            before_filter do |controller|
              controller.redirect_if_conflict( :template => "custom/custom")
            end
            #cattr_accessor :controller_name
          end
          @controller = RedirectIfConflictWithTemplateTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          RedirectIfConflictWithTemplateTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            RedirectIfConflictWithTemplateTestController.controller_name = "timestamps"
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
                  RedirectIfConflictWithTemplateTestController.append_view_path TestViewPath
                  @controller = RedirectIfConflictWithTemplateTestController.new
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
        class RedirectIfConflictWithBlockTestController < ::ConflictWarningsTest::ControllerStub
          before_filter do |controller|
            controller.redirect_if_conflict() do
              respond_to do |format|
                format.html {render :text => "Live from the block"}
                format.js { render :update do |page|
                    page << "alert('JS from the block')"
                  end
                }
              end
            end
          end
        end
        @controller = RedirectIfConflictWithBlockTestController.new
        ActionController::Routing::Routes.draw {|map|
          map.connect "/:action", :controller => @controller.controller_path
          map.connect "/:action/:id", :controller => @controller.controller_path
        }
        RedirectIfConflictWithBlockTestController.view_paths = ['...']

        RedirectIfConflictWithBlockTestController.controller_name = "timestamps"
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
  end #context catch conflicts
end