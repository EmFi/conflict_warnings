require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class CatchConflictsTest < ActionController::TestCase
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
          class CatchConflictsWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
            attr_accessor :return_value
            before_filter do |controller|
              controller.return_value = controller.catch_conflicts()
            end
            #cattr_accessor :controller_name
          end
          @controller = CatchConflictsWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchConflictsWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            CatchConflictsWithoutOptionsTestController.controller_name = "timestamps"
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
                  assert_equal false, assigns(:return_value)
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
                  assert_equal true, assigns(:return_value)
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  CatchConflictsWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = CatchConflictsWithoutOptionsTestController.new
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
            CatchConflictsWithoutOptionsTestController.controller_name = "timestamp_with_custom_accessors"
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
                  CatchConflictsWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
            end
          end
        end # context with custom accessro timestamp
        context "with updated_at timestamp" do
          setup do
            CatchConflictsWithoutOptionsTestController.controller_name = "timestamp_with_updated_ats"
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
                  CatchConflictsWithoutOptionsTestController.append_view_path TestViewPath
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
          class CatchConflictsWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.catch_conflicts()
            end
          end
          @controller = CatchConflictsWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchConflictsWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            CatchConflictsWithoutOptionsJSTestController.controller_name = "timestamps"
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
                  CatchConflictsWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = CatchConflictsWithoutOptionsJSTestController.new
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
            class CatchConflictsWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :flash_key => :error)
              end
            end
            CatchConflictsWithFlashKeyTestsController.view_paths = ['...']
            @controller = CatchConflictsWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithFlashKeyTestsController.controller_name = "timestamps"
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
            class CatchConflictsWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :flash_key => :error, :message => "CONFLICT!")
              end
            end
            CatchConflictsWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = CatchConflictsWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithFlashKeyAndMessageTestsController.controller_name = "timestamps"
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
            class CatchConflictsWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :message => "CONFLICT!")
              end
            end
            CatchConflictsWithMessageTestsController.view_paths = ['...']
            @controller = CatchConflictsWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithMessageTestsController.controller_name = "timestamps"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:warning]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with timestamp in the future" do

                context "without timestamp parameter" do
                  should "not set flash[:error]" do
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
              class CatchConflictsWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :message => "CONFLICT")
                end
              end
              @controller = CatchConflictsWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              CatchConflictsWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithMessageJSTestController.controller_name = "timestamps"
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
                      CatchConflictsWithMessageJSTestController.append_view_path TestViewPath
                      @controller = CatchConflictsWithMessageJSTestController.new
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
          class CatchConflictsWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.catch_conflicts( :model => TimestampWithCustomAccessor)
            end
          end
          CatchConflictsWithModelTestsController.view_paths = ['...']
          @controller = CatchConflictsWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic timestamp" do
          setup do
            CatchConflictsWithModelTestsController.controller_name = "timestamps"
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
              class CatchConflictsWithModelAndBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :model => Timestamp, :accessor => :bogus)
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
              class CatchConflictsWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :model => TimestampWithCustomAccessor, :accessor => :timestamp)
                end
              end
              CatchConflictsWithModelAndAccessorTestsController.view_paths = ['...']
              @controller = CatchConflictsWithModelAndAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithModelAndAccessorTestsController.controller_name = "timestamps"
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
              class CatchConflictsWithModelAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :model => TimestampWithCustomAccessor, :id => 2, :accessor=> :timestamp)
                end
              end
              CatchConflictsWithModelAccessorAndIdTestsController.view_paths = ['...']
              @controller = CatchConflictsWithModelAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithModelAccessorAndIdTestsController.controller_name = "timestamps"
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
            class CatchConflictsWithModelAndIdTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :model => Timestamp, :id => 2)
              end
            end
            CatchConflictsWithModelAndIdTestsController.view_paths = ['...']
            @controller = CatchConflictsWithModelAndIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithModelAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
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
            class CatchConflictsWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :model => TimestampWithCustomAccessor, :params_id_key => :name)
              end
            end
            CatchConflictsWithModelAndParamsIdKeyTestsController.view_paths = ['...']
            @controller = CatchConflictsWithModelAndParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithModelAndParamsIdKeyTestsController.controller_name = "timestamps"
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
                class CatchConflictsWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                      :accessor => :timestamp, :params_id_key => :name)
                  end
                end
                CatchConflictsWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = CatchConflictsWithModelAndParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictsWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "timestamps"
                end
                context "without conflict" do
                  context "without timestamp parameter" do
                    should "redirect" do
                      get :action1, :id => 1, :name => 2
                      assert_redirected_to "/"
                    end
                  end
                  context "with timestamp parameter" do
                    should "not redirect" do

                      get :action1, :id => 1, :name => 3, :page_rendered_at => Time.now.to_i
                      assert_response :success
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
              setup do
                class CatchConflictsWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                      :id => 2, :accessor=> :timestamp, :params_id_key => :name)
                  end
                end
                @controller = CatchConflictsWithModelAndParamsIdKeyAccessorAndIdTestsController.new
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
                class CatchConflictsWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts(:model => Timestamp, :id => 2, :params_id_key => :name)
                  end
                end
                @controller = CatchConflictsWithModelAndParamsIdKeyAndIdTestsController.new
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
            class CatchConflictsWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                  :find_options => lambda {{:conditions => {:name => params[:name]}}})
              end
            end
            CatchConflictsWithModelAndFindOptionsTestsController.view_paths = ['...']
            @controller = CatchConflictsWithModelAndFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithModelAndFindOptionsTestsController.controller_name = "timestamps"
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
                class CatchConflictsWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                      :accessor => :timestamp, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                CatchConflictsWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = CatchConflictsWithModelAndFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictsWithModelAndFindOptionsAndAccessorTestsController.controller_name = "timestamps"
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
              setup do
                class CatchConflictsWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                      :id => 2, :accessor=> :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = CatchConflictsWithModelAndFindOptionsAccessorAndIdTestsController.new
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
                class CatchConflictsWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :model => Timestamp, :id => 2,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = CatchConflictsWithModelAndFindOptionsAndIdTestsController.new
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
                class CatchConflictsWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                      :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = CatchConflictsWithModelAndFindOptionsAndParamsIdKeyTestsController.new
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
                  class CatchConflictsWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                        :accessor => :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = CatchConflictsWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end
              end #context without id
              context "with id" do
                setup do
                  class CatchConflictsWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_conflicts( :model => TimestampWithCustomAccessor,
                        :id => 2, :accessor=> :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = CatchConflictsWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
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
                  class CatchConflictsWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_conflicts( :model => Timestamp, :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = CatchConflictsWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController.new
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
              class CatchConflictsWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :model => Timestamp.first)
                end
              end
              CatchConflictsWithModelARObjectTestsController.view_paths = ['...']
              @controller = CatchConflictsWithModelARObjectTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithModelARObjectTestsController.controller_name = "timestamps"
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
              class CatchConflictsWithModelARObjectInPastTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :model => Timestamp.find(3))
                end
              end
              CatchConflictsWithModelARObjectInPastTestsController.view_paths = ['...']
              @controller = CatchConflictsWithModelARObjectInPastTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithModelARObjectInPastTestsController.controller_name = "timestamps"
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
              class CatchConflictsWithModelARObjectInFutureTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :model => Timestamp.find(2))
                end
              end
              CatchConflictsWithModelARObjectInFutureTestsController.view_paths = ['...']
              @controller = CatchConflictsWithModelARObjectInFutureTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithModelARObjectInFutureTestsController.controller_name = "timestamps"
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
            class CatchConflictsWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :model => :timestamp)
              end
            end
            CatchConflictsWithModelSymbolTestsController.view_paths = ['...']
            @controller = CatchConflictsWithModelSymbolTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithModelSymbolTestsController.controller_name = "timestamp_with_custom_accessors"
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
            class CatchConflictsWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :model => "timestamp")
              end
            end
            CatchConflictsWithModelStringTestsController.view_paths = ['...']
            @controller = CatchConflictsWithModelStringTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithModelStringTestsController.controller_name = "timestamp_with_custom_accessors"
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
              class CatchConflictsWithBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :accessor => :bogus)
                end
              end
              CatchConflictsWithBogusAccessorTestsController.controller_name = "timestamps"
              should "raise no method error" do
                assert_raise(NoMethodError) do
                  get :action1, :id => 3
                end
              end
            end
          end #bogus accessor
          context "without id" do
            setup do
              class CatchConflictsWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts(  :accessor => :timestamp)
                end
              end
              CatchConflictsWithAccessorTestsController.view_paths = ['...']
              @controller = CatchConflictsWithAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
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
            end # context with basic timestamp
          end #context without id
          context "with id" do
            setup do
              class CatchConflictsWithAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts(  :id => 2, :accessor=> :timestamp)
                end
              end
              CatchConflictsWithAccessorAndIdTestsController.view_paths = ['...']
              @controller = CatchConflictsWithAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictsWithAccessorAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
              end
              context "without conflict" do
                context "without timestamp parameter" do
                  should "redirect" do

                    get :action1, :id => 3
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
            class CatchConflictsWithIdTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts(  :id => 2)
              end
            end
            CatchConflictsWithIdTestsController.view_paths = ['...']
            @controller = CatchConflictsWithIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithIdTestsController.controller_name = "timestamp"
            end
            context "without conflict" do
              context "without timestamp parameter" do
                should "redirect" do

                  get :action1, :id => 3
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
            class CatchConflictsWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts(  :params_id_key => :name)
              end
            end
            CatchConflictsWithParamsIdKeyTestsController.view_paths = ['...']
            @controller = CatchConflictsWithParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithParamsIdKeyTestsController.controller_name = "timestamps"
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
                class CatchConflictsWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :accessor => :timestamp, :params_id_key => :name)
                  end
                end
                CatchConflictsWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = CatchConflictsWithParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictsWithParamsIdKeyAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
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
              setup do
                class CatchConflictsWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :id => 2, :accessor=> :timestamp, :params_id_key => :name)
                  end
                end
                @controller = CatchConflictsWithParamsIdKeyAccessorAndIdTestsController.new
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
                class CatchConflictsWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts(  :id => 2, :params_id_key => :name)
                  end
                end
                @controller = CatchConflictsWithParamsIdKeyAndIdTestsController.new
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
            class CatchConflictsWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts(  :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
              end
            end
            CatchConflictsWithFindOptionsTestsController.view_paths = ['...']
            @controller = CatchConflictsWithFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictsWithFindOptionsTestsController.controller_name = "timestamps"
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
                class CatchConflictsWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :accessor => :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                CatchConflictsWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = CatchConflictsWithFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictsWithFindOptionsAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
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
              setup do
                class CatchConflictsWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :id => 2, :accessor=> :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = CatchConflictsWithFindOptionsAccessorAndIdTestsController.new
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
                class CatchConflictsWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts(  :id => 2,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                  @controller = CatchConflictsWithFindOptionsAndIdTestsController.new
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
                class CatchConflictsWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :params_id_key => :name,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = CatchConflictsWithFindOptionsAndParamsIdKeyTestsController.new
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
                  class CatchConflictsWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_conflicts(  :accessor => :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = CatchConflictsWithFindOptionsAndParamsIdKeyAndAccessorTestsController.new
                end
                should "raise Argument Error" do
                  assert_raise(ArgumentError) do
                    get :action1, :id => 3
                  end
                end
              end #context without id
              context "with id" do
                setup do
                  class CatchConflictsWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_conflicts( :id => 2, :accessor=> :timestamp, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = CatchConflictsWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
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
                  class CatchConflictsWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_conflicts(  :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                  @controller = CatchConflictsWithFindOptionsAndParamsIdKeyAndIdTestsController.new
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
              class CatchConflictsBadFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :find_options => {:conditions => {:name => "Test value"}})
                end
              end
              @controller = CatchConflictsBadFindOptionsTestsController.new
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
            class CatchConflictsWithSimulateConflictsOnRequestsBeforeTestController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :simulate_conflict_on_requests_before => Time.now - 2.minutes)
              end
            end
            @controller = CatchConflictsWithSimulateConflictsOnRequestsBeforeTestController.new
            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }
            CatchConflictsWithSimulateConflictsOnRequestsBeforeTestController.view_paths = ['...']
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
            class CatchConflictsWithSimulateConflictsOnRequestsAfterTestController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_conflicts( :simulate_conflict_on_requests_after => (Time.now + 5.minutes))
              end
            end
            @controller = CatchConflictsWithSimulateConflictsOnRequestsAfterTestController.new
            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }
            CatchConflictsWithSimulateConflictsOnRequestsAfterTestController.view_paths = ['...']
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
              class CatchConflictsWithBothSimulateConflictKeysOneRangeTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :simulate_conflict_on_requests_before => (Time.now + 5.minutes),
                    :simulate_conflict_on_requests_after => (Time.now - 5.minutes))
                end
              end
              @controller = CatchConflictsWithBothSimulateConflictKeysOneRangeTestController.new
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
              class CatchConflictsWithBothSimulateConflictKeysTwoRangesTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_conflicts( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                    :simulate_conflict_on_requests_after => (Time.now + 5.minutes))
                end
              end
              @controller = CatchConflictsWithBothSimulateConflictKeysTwoRangesTestController.new
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
              setup do
                class CatchConflictsWithSimulateBeforeAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :model => Timestamp)
                  end
                end
                @controller = CatchConflictsWithSimulateBeforeAndModelKeysTestController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with model
            context "with params id key" do
              setup do
                class CatchConflictsWithSimulateBeforeAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts(:simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :params_id_key => :something)
                  end
                end
                @controller = CatchConflictsWithSimulateBeforeAndParamsIdKeyTestController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with params_id_key
            context "with id" do
              setup do
                class CatchConflictsWithSimulateBeforeAndIdTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :id => 5)
                  end
                end
                @controller = CatchConflictsWithSimulateBeforeAndIdTestController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with id
            context "with find options" do
              setup do
                class CatchConflictsWithSimulateBeforeAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = CatchConflictsWithSimulateBeforeAndFindOptionsTestController.new
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
                class CatchConflictsWithSimulateAfterAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :model => Timestamp)
                  end
                end
                @controller = CatchConflictsWithSimulateAfterAndModelKeysTestController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with model
            context "with params id key" do
              setup do
                class CatchConflictsWithSimulateAfterAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :params_id_key => :something)
                  end
                end
                @controller = CatchConflictsWithSimulateAfterAndParamsIdKeyTestController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with params_id_key
            context "with id" do
              setup do
                class CatchConflictsWithSimulateAfterAndIdTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :id => 5)
                  end
                end
                @controller = CatchConflictsWithSimulateAfterAndIdTestController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with id
            context "with find options" do
              setup do
                class CatchConflictsWithSimulateAfterAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_conflicts( :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                @controller = CatchConflictsWithSimulateAfterAndFindOptionsTestController.new
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
          class CatchConflictsWithTimeStampKeyTestController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.catch_conflicts( :timestamp_key => :timestamp)
            end
          end
          @controller = CatchConflictsWithTimeStampKeyTestController.new
        end
        context "with basic timestamp" do
          setup do
            CatchConflictsWithTimeStampKeyTestController.controller_name = "timestamps"
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
          class CatchConflictsWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            before_filter do |controller|
              controller.catch_conflicts( :template => "custom/custom")
            end
            #cattr_accessor :controller_name
          end
          @controller = CatchConflictsWithTemplateTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchConflictsWithTemplateTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            CatchConflictsWithTemplateTestController.controller_name = "timestamps"
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
                  CatchConflictsWithTemplateTestController.append_view_path TestViewPath
                  @controller = CatchConflictsWithTemplateTestController.new
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
        class CatchConflictsWithBlockTestController < ::ConflictWarningsTest::ControllerStub
          before_filter do |controller|
            controller.catch_conflicts() do
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
        @controller = CatchConflictsWithBlockTestController.new
        ActionController::Routing::Routes.draw {|map|
          map.connect "/:action", :controller => @controller.controller_path
          map.connect "/:action/:id", :controller => @controller.controller_path
        }
        CatchConflictsWithBlockTestController.view_paths = ['...']

        CatchConflictsWithBlockTestController.controller_name = "timestamps"
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