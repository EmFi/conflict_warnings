require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class CatchResourcesUnavailableWarningsBasicTest < ActionController::TestCase
  context "redirect if resource unavailables" do
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
          class CatchResourcesUnavailableWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
            attr_accessor :return_value
            before_filter do |controller|
              controller.return_value = controller.catch_resources_unavailable()
            end
            #cattr_accessor :controller_name
          end
          @controller = CatchResourcesUnavailableWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchResourcesUnavailableWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            CatchResourcesUnavailableWithoutOptionsTestController.controller_name = "resources"
          end
          context "without available" do
            context "without resource parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end
            context "with resource parameter" do
              context "with resource unset avaliability" do
                should "redirect " do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                  assert_equal true, assigns(:return_value)
                end
              end
              context "With resource unavailable" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                  assert_equal false, assigns(:return_value)
                end
              end
            end
          end

          context "with unavailable" do
            context "with resource unavailable" do
              context "without template" do
                should "redirect" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /no longer available/, flash[:warning]
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  CatchResourcesUnavailableWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = CatchResourcesUnavailableWithoutOptionsTestController.new
                  get :action1, :id => 2
                  assert_response 409
                  assert_template("action1_resource_unavailable")
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with unavailable
          context "alternate id key based on model name" do
            context "without available" do
              should "not redirect" do
                get :action1, :resource_id => 3
                assert_response :success
              end
            end #without available
            context "with unavailable" do
              should "redirect" do
                get :action1, :resource_id => 2
                assert_redirected_to "/"
              end
            end
          end #alternate id
        end # context with basic resource

        context "with custom accessible resource" do
          setup do
            CatchResourcesUnavailableWithoutOptionsTestController.controller_name = "resource_with_custom_accessors"
          end
          context "without available" do
            context "without resource parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end            
            context "With resource unavailable" do
              should "not redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end
          end
          
          context "with unavailable" do
            context "with resource parameter" do
              context "with resource unset avaliability" do
                should "not redirect " do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
              end
              context "with template" do
                should "not redirect and render default template" do
                  CatchResourcesUnavailableWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, :id => 2
                  assert_response 409
                end
              end
            end
          end
          context "alternate id key based on model name" do
            context "without available" do
              should "not redirect" do
                get :action1, :resource_with_custom_accessor_id => 3
                assert_redirected_to "/"
              end
            end #without available
            context "with unavailable" do
              should "redirect" do
                get :action1, :resource_with_custom_accessor_id => 2
                assert_redirected_to "/"
              end
            end
          end #alternate id
        end # context with custom accessor resource
      end #accepts html
      context "accepts js" do
        setup do
          class CatchResourcesUnavailableWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            before_filter do |controller|
              controller.catch_resources_unavailable()
            end
            #cattr_accessor :controller_name
          end
          @controller = CatchResourcesUnavailableWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }          
          CatchResourcesUnavailableWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            CatchResourcesUnavailableWithoutOptionsJSTestController.controller_name = "resources"
          end
          context "invalid inputs" do
            context "without resource parameter" do
              should "not redirect" do
                assert_raise(ArgumentError) do
                  get :action1, :format => "js"
                end
              end
            end
            context "with resource that does not have resource unavailable set" do
              should "redirect" do
                get :action1, :id => 1, :format => "js"
                assert_response 409
                assert_match(/alert/, @response.body)
              end
            end
          end
          context "without available" do
            context "With resource unavailable" do
              should "not redirect" do
                get :action1, :id => 3, :format => "js"
                assert_response :success
              end
            end
          end

          context "with unavailable" do
            context "with resource unavailable" do
              context "without template" do
                should "redirect" do

                  get :action1, :id => 2, :format => "js"
                  assert_response 409
                  assert_match(/alert/, @response.body)
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  CatchResourcesUnavailableWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = CatchResourcesUnavailableWithoutOptionsJSTestController.new
                  get :action1, :id => 2,  :format => "js"
                  assert_response 409
                  assert_template("action1_resource_unavailable.rjs")
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with unavailable
          context "alternate id key based on model name" do
            context "without available" do
              should "not redirect" do
                get :action1, :resource_id => 3
                assert_response :success
              end
            end #without available
            context "with unavailable" do
              should "redirect" do
                get :action1, :resource_id => 2
                assert_redirected_to "/"
              end
            end
          end #alternate id
        end # context with basic resource

      end #accepts js
    end # context without options
    context "using options" do      
      context "with flash key" do
        context "without message" do
          setup do
            class CatchResourcesUnavailableWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :flash_key => :error)
              end
            end
            CatchResourcesUnavailableWithFlashKeyTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithFlashKeyTestsController.controller_name = "resources"
            end
            context "without available" do
              context "without resource parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 3
                  assert_response :success
                  assert_no_match /not be processed/, flash[:error]
                end
              end
            end #without available
            context "with unavailable" do
              context "with resource unavailable" do
              
                should "set flash[:error]" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /no longer available/, flash[:error]
                end
              
              end # context with resource unavailable

            end # context with unavailable
          end # context with basic resource
        end # context without message
        context "with message" do
          setup do
            class CatchResourcesUnavailableWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :flash_key => :error, :message => "CONFLICT!")
              end
            end
            CatchResourcesUnavailableWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithFlashKeyAndMessageTestsController.controller_name = "resources"
            end
            context "without available" do
              context "without resource parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 3
                  assert_response :success
                  assert_no_match /CONFLICT!/, flash[:error]
                end
              end
            end #without available
            context "with unavailable" do
              context "with resource unavailable" do
                should "set flash[:error]" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:error]
                end

              end # context with resource unavailable
            end # with basic resource
          end # context with unavailable
        end # context with message
      end # with flash key
      context "without flash key" do
        context "with message" do
          setup do
            class CatchResourcesUnavailableWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :message => "CONFLICT!")
              end
            end
            CatchResourcesUnavailableWithMessageTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithMessageTestsController.controller_name = "resources"
            end
            context "without available" do
              should "set flash[:error]" do

                get :action1, :id => 3
                assert_response :success
                assert_no_match /CONFLICT!/, flash[:warning]
              end
            end #without available
            context "with unavailable" do
              context "with resource unavailable" do
                context "without resource parameter" do
                  should "sets flash[:error]" do
                    get :action1, :id => 1
                    assert_redirected_to "/"
                    assert_match /CONFLICT!/, flash[:warning]
                  end
                end                
                should "set flash[:error]" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:warning]
                end

              end # context with resource unavailable

            end # context with unavailable
          end # context with basic resource
          context "accepts js" do
            setup do
              class CatchResourcesUnavailableWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :message => "CONFLICT")
                end
              end
              @controller = CatchResourcesUnavailableWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              CatchResourcesUnavailableWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithMessageJSTestController.controller_name = "resources"
              end
              context "without available" do
                context "without resource parameter" do
                  should "raise ArgumentError" do
                    assert_raise(ArgumentError) do
                      get :action1, :format => "js"
                    end
                  end
                end
                
                  
                context "With resource unavailable" do
                  should "not redirect" do
                    get :action1, :id => 3, :format => "js"
                    assert_response :success
                  end
                end

              end

              context "with unavailable" do
                context "with resource unavailable" do

                  context "without template" do
                    context "with resource unset avaliability" do
                      should "redirect " do
                        get :action1, :id => 1, :format => "js"
                        assert_response 409
                        assert_match(/alert\('CONFLICT'\)/, @response.body)
                      end
                    end
                    context "with unavailable resource" do
                      should "redirect" do

                        get :action1, :id => 2, :format => "js"
                        assert_response 409
                        assert_match(/alert\('CONFLICT'\)/, @response.body)
                      end
                    end
                  end # context without template

                  context "with template" do
                    should "not redirect and render default template" do
                      CatchResourcesUnavailableWithMessageJSTestController.append_view_path TestViewPath
                      @controller = CatchResourcesUnavailableWithMessageJSTestController.new
                      get :action1, :id => 2, :format => "js"
                      assert_response 409
                      assert_template("action1_resource_unavailable.rjs")
                    end # should not redirect and render default template
                  end # context with template
                end # context with resource unavailable

              end # context with unavailable
            end # context with basic resource

          end #acceepts js
        end # with message
      end # context without flashkey
      context "with model" do
        setup do
          class CatchResourcesUnavailableWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor)
            end
          end
          CatchResourcesUnavailableWithModelTestsController.view_paths = ['...']
          @controller = CatchResourcesUnavailableWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic resource" do
          setup do
            CatchResourcesUnavailableWithModelTestsController.controller_name = "resources"
          end
          context "without available" do
            context "without resource parameter" do
              should "redirect" do
                get :action1, :id => 1
                assert_redirected_to "/"
              end
            end
          end #without available
          context "with unavailable" do
            context "with resource unavailable" do
              context "without resource parameter" do
                should "redirect" do
                  get :action1, :id => 2
                  assert_redirected_to "/"
                end
              end
              should "redirect" do
                get :action1, :id => 2
                assert_redirected_to "/"
              end
            
            end # context with resource unavailable

          end # context with unavailable
        end # context with basic resource
        context "with accessor" do
          context "with bogus accessor" do
            setup do

              class RedirectIfResourcEunavailableWithModelAndBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => "resource", :accessor => :bogus)
                end
              end
              RedirectIfResourcEunavailableWithModelAndBogusAccessorTestsController.view_paths = ['...']
              @controller = RedirectIfResourcEunavailableWithModelAndBogusAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
            end
            should "raise no method error" do
              assert_raise(NoMethodError) do
                get :action1, :id => 3
              end
            end
          end # bogus accessor
          context "without id" do
            setup do
              class CatchResourcesUnavailableWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor, :accessor => :resources_left)
                end
              end
              CatchResourcesUnavailableWithModelAndAccessorTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAndAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAndAccessorTestsController.controller_name = "resources"
              end
              context "without available" do
                context "without resource parameter" do
                  should "not redirect" do
                    get :action1, :id => 3
                    assert_response :success
                  end
                end
              end #without available
              context "with unavailable" do
                context "with resource unavailable" do
                
                  should "not redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                
                  end # context with resource unavailable
                end
              end # context with unavailable
            end # context with basic resource
            context "alternate id key based on model name" do
              context "without available" do
                should "not redirect" do
                  get :action1, :resource_with_custom_accessor_id => 3
                  assert_response :success
                end
              end #without available
              context "with unavailable" do
                should "redirect" do
                  get :action1, :resource_with_custom_accessor_id => 2
                  assert_redirected_to "/"
                end
              end
            end #alternate id
          end #context without id
          context "with id" do
            context "Non Existant resource" do
              setup do
                class CatchResourcesUnavailableWithModelAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :model => Resource, :id => 4)
                  end
                end
                CatchResourcesUnavailableWithModelAndNonExistantIdTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithModelAndNonExistantIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithModelAndNonExistantIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without available" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_redirected_to "/"
                    end

                  end
                end #without available
                context "with unavailable" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end

                  end # context with resource unavailable

                end # context with unavailable
              end # context with basic resource
            end #nonexistant resource
            context "Existing resource" do
              setup do
                class CatchResourcesUnavailableWithModelAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :model => Resource, :id => 3)
                  end
                end
                CatchResourcesUnavailableWithModelAndExistingIdTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithModelAndExistingIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithModelAndExistingIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without available" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_response :success
                    end

                  end
                end #without available
                context "with unavailable" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_response :success
                    end

                  end # context with resource unavailable

                end # context with unavailable
              end # context with basic resource
            end #exisitng resource
          end #with id
        end # with accessor

        context "with id" do
          context "Non Existant resource" do
            setup do
              class CatchResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor, :id => 4, :accessor=> :resources_left)
                end
              end
              CatchResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController.controller_name = "resources"
              end
              context "without available" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_redirected_to "/"
                  end

                end
              end #without available
              context "with unavailable" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                  end

                end # context with resource unavailable

              end # context with unavailable
            end # context with basic resource
          end #nonexistant resource
          context "Existing resource" do
            setup do
              class CatchResourcesUnavailableWithModelAccessorAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor, :id => 3, :accessor=> :resources_left)
                end
              end
              CatchResourcesUnavailableWithModelAccessorAndExistingIdTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAccessorAndExistingIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAccessorAndExistingIdTestsController.controller_name = "resources"
              end
              context "without available" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_response :success
                  end

                end
              end #without available
              context "with unavailable" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_response :success
                  end

                end # context with resource unavailable

              end # context with unavailable
            end # context with basic resource
          end #exisitng resource
        end #with id
        context "with params id key" do
          setup do
            class CatchResourcesUnavailableWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor, :params_id_key => :name)
              end
            end
            CatchResourcesUnavailableWithModelAndParamsIdKeyTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithModelAndParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithModelAndParamsIdKeyTestsController.controller_name = "resources"
            end           
            context "with resource unavailable" do
              context "without accessor" do
                should "redirect" do
                  get :action1, :id => 1, :name => 3
                  assert_redirected_to "/"
                end
              end
            end
            context "with non existant resource" do
              should "redirect" do
                get :action1, :id => 1, :name => 50
                assert_redirected_to "/"
              end
            end
            
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class CatchResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor,
                      :accessor => :resources_left, :params_id_key => :name)
                  end
                end
                CatchResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "resources"
                end
                context "without available" do
                  context "with resource parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => 3
                      assert_response :success
                    end
                  end
                end #without available
                context "with unavailable" do
                  context "with resource unavailable" do
                    should "redirect" do

                      get :action1, :id => 2, :name => 2
                      assert_redirected_to "/"
                    end
                  end # context with resource unavailable
                end # context with unavailable
              end # context with basic resource
            end #context without id
            context "with id" do
              setup do
                class CatchResourcesUnavailableWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor,
                      :id => 2, :accessor=> :resource, :params_id_key => :name)
                  end
                end
                @controller = CatchResourcesUnavailableWithModelAndParamsIdKeyAccessorAndIdTestsController.new
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
                  class CatchResourcesUnavailableWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable( :model => Resource, :id => 2, :params_id_key => :name)
                    end
                  end
                @controller = CatchResourcesUnavailableWithModelAndParamsIdKeyAndIdTestsController.new
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
            class CatchResourcesUnavailableWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
              end
            end
            CatchResourcesUnavailableWithModelAndFindOptionsTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithModelAndFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithModelAndFindOptionsTestsController.controller_name = "resources"
            end
            context "without available" do
              context "without resource parameter" do
                should "not redirect" do
                  get :action1, :id => 1, :name => "Resources Unavailable"
                  assert_redirected_to "/"
                end
              end
            end #without available
            context "with unavailable" do
              context "with resource unavailable" do
                context "on action in only" do
                  context "without resource parameter" do
                    should "not redirect" do
                      get :action1, :id => 2, :name => "No Resources Remaining"
                      assert_redirected_to "/"
                    end
                  end
                  should "not redirect" do
                    get :action1, {:id => 2,
                      :name => "No Resources Remaining"}
                    assert_redirected_to "/"
                  end
                end # on action in only

              end # context with resource unavailable

            end # context with unavailable
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class CatchResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor,
                      :accessor => :resources_left, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                CatchResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController.controller_name = "resources"
                end
                context "without available" do
                  context "without resource parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => "Resources Available"
                      assert_response :success
                    end
                  end
                end #without available
                context "with available" do
                  context "with resource unavailable" do
                    
                    should "redirect" do

                      get :action1, {:id => 2,
                        :name => "No Resources Remaining"}
                      assert_redirected_to "/"
                    end

                  end # context with resource unavailable

                end # context with unavailable
              end # context with basic resource
            end #context without id
            context "with id" do
              setup do
                class CatchResourcesUnavailableWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor,
                        :id => 2, :accessor=> :resource,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = CatchResourcesUnavailableWithModelAndFindOptionsAccessorAndIdTestsController.new
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
              setup  do
                  class CatchResourcesUnavailableWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable( :model => Resource, :id => 2,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = CatchResourcesUnavailableWithModelAndFindOptionsAndIdTestsController.new
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
                  class CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor,
                        :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyTestsController.new
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
                    class CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor,
                          :accessor => :resource_left, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
                end
              end #context without id
              context "with id" do
                setup do
                    class CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.catch_resources_unavailable( :model => ResourceWithCustomAccessor,
                          :id => 2, :accessor=> :resource, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
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
                    class CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.catch_resources_unavailable( :model => Resource, :id => 2, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = CatchResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController.new
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
        context "with class method" do
          context "with undefined class method" do
            setup do
              class CatchResourcesUnavailableWithModelAndUndefinedClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => Resource, :class_method => :nothing)
                end
              end
              CatchResourcesUnavailableWithModelAndUndefinedClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAndUndefinedClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAndUndefinedClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end          
              should "Raise NoMethodError" do
                assert_raise(NoMethodError) do
                  get :action1, :id => 2
                end
              end            
            end # context with basic resource
          end #undefined class method
          context "that returns true" do
            setup do
              class CatchResourcesUnavailableWithModelAndTrueClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => Resource, :class_method => :returns_true)
                end
              end
              CatchResourcesUnavailableWithModelAndTrueClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAndTrueClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAndTrueClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns true
          context "that returns numeric" do
            setup do
              class CatchResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => Resource, :class_method => :resources_left)
                end
              end
              CatchResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns numeric
          context "that returns false" do
            setup do
              class CatchResourcesUnavailableWithModelAndFalseClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => Resource, :class_method => :returns_false)
                end
              end
              CatchResourcesUnavailableWithModelAndFalseClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAndFalseClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAndFalseClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns false
          context "that returns zero" do
            setup do
              class CatchResourcesUnavailableWithModelAndZeroClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => Resource, :class_method => :no_resources_left)
                end
              end
              CatchResourcesUnavailableWithModelAndZeroClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAndZeroClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAndZeroClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns 0          
          context "is true" do
            setup do
              class CatchResourcesUnavailableWithModelAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :model => Resource, :class_method => true)
                end
              end
              CatchResourcesUnavailableWithModelAndClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithModelAndClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithModelAndClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns 0

        end# class method
        context "with model as active record object" do
          setup do
            class CatchResourcesUnavailableWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :model => Resource.last)
              end
            end
            CatchResourcesUnavailableWithModelARObjectTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithModelARObjectTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithModelARObjectTestsController.controller_name = "resource_with_custom_accessors"
            end
            context "without available" do
              context "without resource parameter" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end #without available
            context "with unavailable" do
              should "redirect" do
                get :action1, :id => 2
                assert_response :success
              end

            end # context with unavailable
            context "alternate id key based on model name" do
              context "without available" do
                should "not redirect" do
                  get :action1, :resource_id => 3
                  assert_response :success
                end
              end #without available
              context "with unavailable" do
                should "redirect" do
                  get :action1, :resource_id => 2
                  assert_response :success
                end
              end
            end #alternate id
          end # context with basic resource
        end # model as activeRecord object
        context "with model as symbol" do
          setup do
            class CatchResourcesUnavailableWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :model => :resource)
              end
            end
            CatchResourcesUnavailableWithModelSymbolTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithModelSymbolTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithModelSymbolTestsController.controller_name = "resource_with_custom_accessors"
            end
            context "without available" do
              should "not redirect" do
                get :action1, :id => 3
                assert_response :success
              end
            end #without available
            context "with unavailable" do
              should "redirect" do
                get :action1, :id => 2
                assert_redirected_to "/"
              end

            end # context with unavailable

            context "alternate id key based on model name" do
              context "without available" do
                should "not redirect" do
                  get :action1, :resource_id => 3
                  assert_response :success
                end
              end #without available
              context "with unavailable" do
                should "redirect" do
                  get :action1, :resource_id => 2
                  assert_redirected_to "/"
                end
              end
            end #alternate id
          end # context with basic resource
        end # model as symbol
        context "with model as string" do
          setup do
            class CatchResourcesUnavailableWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable( :model => "resource")
              end
            end
            CatchResourcesUnavailableWithModelStringTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithModelStringTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithModelStringTestsController.controller_name = "resource_with_custom_accessors"
            end
            context "without available" do
              should "not redirect" do
                get :action1, :id => 3
                assert_response :success
              end
            end #without available
            context "with unavailable" do
              should "redirect" do
                get :action1, :id => 2
                assert_redirected_to "/"
              end

            end # context with unavailable

            context "alternate id key based on model name" do
              context "without available" do
                should "not redirect" do
                  get :action1, :resource_id => 3
                  assert_response :success
                end
              end #without available
              context "with unavailable" do
                should "redirect" do
                  get :action1, :resource_id => 2
                  assert_redirected_to "/"
                end
              end #alternate id
            end # context with basic resource
          end # model as string
        end

      end # with model

      context "instance selectors without model" do
        context "with class method" do
          context "with undefined class method" do
            setup do
              class CatchResourcesUnavailableWithUndefinedClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :class_method => :nothing)
                end
              end
              CatchResourcesUnavailableWithUndefinedClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithUndefinedClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithUndefinedClassMethodTestsController.controller_name = "resources"
              end
              should "Raise NoMethodError" do
                assert_raise(NoMethodError) do
                  get :action1, :id => 2
                end
              end
            end # context with basic resource
          end #undefined class method
          context "that returns true" do
            setup do
              class CatchResourcesUnavailableWithTrueClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable(  :class_method => :returns_true)
                end
              end
              CatchResourcesUnavailableWithTrueClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithTrueClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithTrueClassMethodTestsController.controller_name = "resources"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns true
          context "that returns numeric" do
            setup do
              class CatchResourcesUnavailableWithTrueNumericClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :class_method => :resources_left)
                end
              end
              CatchResourcesUnavailableWithTrueNumericClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithTrueNumericClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithTrueNumericClassMethodTestsController.controller_name = "resources"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns numeric
          context "that returns false" do
            setup do
              class CatchResourcesUnavailableWithFalseClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :class_method => :returns_false)
                end
              end
              CatchResourcesUnavailableWithFalseClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithFalseClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithFalseClassMethodTestsController.controller_name = "resources"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns false
          context "that returns zero" do
            setup do
              class CatchResourcesUnavailableWithZeroClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :class_method => :no_resources_left)
                end
              end
              CatchResourcesUnavailableWithZeroClassMethodTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithZeroClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithZeroClassMethodTestsController.controller_name = "resources"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns 0

        end# class method
        context "with accessor" do
          context "with class method" do
            setup do
              class CatchResourcesUnavailableWithAccessorAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :accessor => :resources_left, :class_method => true)
                end
              end

              @controller = CatchResourcesUnavailableWithAccessorAndClassMethodTestsController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
            end
            context "instance that should redirect" do

              should "not redirect" do
                CatchResourcesUnavailableWithAccessorAndClassMethodTestsController.controller_name = "resources"
                get :action1, :id => 2
                assert_response :success
              end
            end
          end #with Class method

          context "without id" do
            setup do
              class CatchResourcesUnavailableWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable(  :accessor => :resources_left)
                end
              end
              CatchResourcesUnavailableWithAccessorTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithAccessorTestsController.controller_name = "resource_with_custom_accessors"
              end
              context "without available" do
                context "without resource parameter" do
                  should "not redirect" do
                    get :action1, :id => 3
                    assert_response :success
                  end
                end
              end #without available
              context "with unavailable" do
                context "with resource unavailable" do
                  should "not redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                  end
                end # context with resource unavailable
              end # context with unavailable
            end # context with basic resource
          end #context without id
          context "with id" do
            context "Non Existant resource" do
              setup do
                class CatchResourcesUnavailableWithAccessorAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :id => 4, :accessor=> :resources_left)
                  end
                end
                CatchResourcesUnavailableWithAccessorAndNonExistantIdTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithAccessorAndNonExistantIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithAccessorAndNonExistantIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without available" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_redirected_to "/"
                    end

                  end
                end #without available
                context "with unavailable" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end

                  end # context with resource unavailable

                end # context with unavailable
              end # context with basic resource
            end #nonexistant resource
            context "Existing resource" do
              setup do
                class CatchResourcesUnavailableWithAccessorAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :id => 3, :accessor=> :resources_left)
                  end
                end
                CatchResourcesUnavailableWithAccessorAndExistingIdTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithAccessorAndExistingIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithAccessorAndExistingIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without available" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_response :success
                    end

                  end
                end #without available
                context "with unavailable" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_response :success
                    end

                  end # context with resource unavailable

                end # context with unavailable
              end # context with basic resource
            end #exisitng resource
          end #with id
        end # with accessor

        context "with id" do
          context "Non Existant resource" do
            setup do
              class CatchResourcesUnavailableWithNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :id => 4)
                end
              end
              CatchResourcesUnavailableWithNonExistantIdTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithNonExistantIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithNonExistantIdTestsController.controller_name = "resources"
              end
              context "without available" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_redirected_to "/"
                  end

                end
              end #without available
              context "with unavailable" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                  end

                end # context with resource unavailable

              end # context with unavailable
            end # context with basic resource
          end #nonexistant resource
          context "Existing resource" do
            setup do
              class CatchResourcesUnavailableWithExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.catch_resources_unavailable( :id => 3)
                end
              end
              CatchResourcesUnavailableWithExistingIdTestsController.view_paths = ['...']
              @controller = CatchResourcesUnavailableWithExistingIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourcesUnavailableWithExistingIdTestsController.controller_name = "resources"
              end
              context "without available" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_response :success
                  end

                end
              end #without available
              context "with unavailable" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_response :success
                  end

                end # context with resource unavailable

              end # context with unavailable
            end # context with basic resource
          end #exisitng resource

          context "with class method" do
            setup do
                class CatchResourcesUnavailableWithIdAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :id => 2, :class_method => true)
                  end
                end
              @controller = CatchResourcesUnavailableWithIdAndClassMethodTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              
            end
          end #with Class method
        end #with id
        context "with params id key" do
          setup do
            class CatchResourcesUnavailableWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable(  :params_id_key => :name)
              end
            end
            CatchResourcesUnavailableWithParamsIdKeyTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithParamsIdKeyTestsController.controller_name = "resources"
            end
            context "without available" do

              should "redirect" do
                get :action1, :id => 1, :name => 3
                assert_response :success
              end
            end #without available
            context "with unavailable" do
              context "with resource unavailable" do
                context "without params_id_key parameter" do
                  should "not redirect" do
                    get :action1, :id => 2
                    assert_redirected_to "/"
                  end
                end # without params id key parameter
                context "with params id key parameter" do
                  context "with resource parameter" do
                    should "redirect" do
                      get :action1, :id => 2, :name => 2
                      assert_redirected_to "/"
                    end
                  end
                end

              end # context with resource unavailable

            end # context with unavailable
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class CatchResourcesUnavailableWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :accessor => :resources_left, :params_id_key => :name)
                  end
                end
                CatchResourcesUnavailableWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithParamsIdKeyAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without available" do
                  context "with resource parameter" do
                    should "redirect" do

                      get :action1, :id => 1, :name => 3
                      assert_response :success
                    end
                  end
                end #without available
                context "with unavailable" do
                  context "with resource unavailable" do
                    should "redirect" do

                      get :action1, :id => 2, :name => 2
                      assert_redirected_to "/"
                    end
                  end # context with resource unavailable
                end # context with unavailable
              end # context with basic resource
            end #context without id
            context "with id" do
              setup do
                  class CatchResourcesUnavailableWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable( :id => 2, :accessor=> :resource, :params_id_key => :name)
                    end
                  end
                @controller = CatchResourcesUnavailableWithParamsIdKeyAccessorAndIdTestsController.new
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
                  class CatchResourcesUnavailableWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable(  :id => 2, :params_id_key => :name)
                    end
                  end
                @controller = CatchResourcesUnavailableWithParamsIdKeyAndIdTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
              end
            end #with id
          end #without accessor
          context "with class method" do
            setup do
                class CatchResourcesUnavailableWithParamsIdKeyAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :params_id_key => :new_key, :class_method => true)
                  end
                end
              @controller = CatchResourcesUnavailableWithParamsIdKeyAndClassMethodTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
            end
          end #with Class method
        end #with params id key
        context "with find options" do
          setup do
            class CatchResourcesUnavailableWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.catch_resources_unavailable(  :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
              end
            end
            CatchResourcesUnavailableWithFindOptionsTestsController.view_paths = ['...']
            @controller = CatchResourcesUnavailableWithFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourcesUnavailableWithFindOptionsTestsController.controller_name = "resources"
            end
            context "without available" do
              context "without resource parameter" do
                should "not redirect" do
                  get :action1, :id => 1, :name => "Resources Available"
                  assert_response :success
                end
              end
            end #without available
            context "with unavailable" do
              context "with resource unavailable" do
                should "redirect" do
                  get :action1, {:id => 2,
                    :name => "No Resources Remaining"}
                  assert_redirected_to "/"
                end
                

              end # context with resource unavailable

            end # context with unavailable
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class CatchResourcesUnavailableWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :accessor => :resources_left,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                CatchResourcesUnavailableWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourcesUnavailableWithFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourcesUnavailableWithFindOptionsAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without available" do
                  context "without resource parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => "Resources Available"
                      assert_response :success
                    end
                  end
                end #without available
                context "with unavailable" do
                  context "with resource unavailable" do
                    should "not redirect" do

                      get :action1, {:id => 2,
                        :name => "No Resources Remaining"}
                      assert_redirected_to "/"
                    end
                  end # context with resource unavailable
                end # context with unavailable
              end # context with basic resource
            end #context without id
            context "with id" do
              setup do
                  class CatchResourcesUnavailableWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable( :id => 2, :accessor=> :resource,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = CatchResourcesUnavailableWithFindOptionsAccessorAndIdTestsController.new
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
                  class CatchResourcesUnavailableWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable(  :id => 2,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = CatchResourcesUnavailableWithFindOptionsAndIdTestsController.new
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
                  class CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.catch_resources_unavailable( :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyTestsController.new
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
                    class CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.catch_resources_unavailable(  :accessor => :resource_left, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyAndAccessorTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
                end
              end #context without id
              context "with id" do
                setup do
                    class CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.catch_resources_unavailable( :id => 2, :accessor=> :resource, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
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
                    class CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.catch_resources_unavailable(  :id => 2, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = CatchResourcesUnavailableWithFindOptionsAndParamsIdKeyAndIdTestsController.new
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
                class CatchResourcesUnavailableBadFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :find_options => {:conditions => {:name => "Test value"}})
                  end
                end
            @controller = CatchResourcesUnavailableBadFindOptionsTestsController.new
              end
              should "raise Argument Error when find options is not a proc" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
            end
          end
          context "with class method" do
            setup do
                class CatchResourcesUnavailableWithFindOptionsAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.catch_resources_unavailable( :class_method => true,
                      :find_options => Proc.new {{:conditions => {:id => 3}}})
                  end
                end
              @controller = CatchResourcesUnavailableWithFindOptionsAndClassMethodTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
            end
          end #with Class method
        end # with find options

      end # instance selectors without model
            
      context "template" do
        setup do
          class CatchResourcesUnavailableWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            before_filter do |controller|
              controller.catch_resources_unavailable( :template => "custom/custom")
            end
            #cattr_accessor :controller_name
          end
          @controller = CatchResourcesUnavailableWithTemplateTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchResourcesUnavailableWithTemplateTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            CatchResourcesUnavailableWithTemplateTestController.controller_name = "resources"
          end
          context "without available" do
            context "without resource parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do

                  get :action1
                end
              end
            end
            context "with resource parameter" do
              context "with resource unset avaliability" do
                should "redirect" do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
              end
              context "With resource unavailable" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end
          end

          context "with unavailable" do
            context "with resource unavailable" do
              context "without template" do
                should "redirect" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /no longer available/, flash[:warning]
                end
              end # context without template

              context "with template" do
                should "not redirect and render default template" do
                  CatchResourcesUnavailableWithTemplateTestController.append_view_path TestViewPath
                  @controller = CatchResourcesUnavailableWithTemplateTestController.new
                  get :action1, :id => 2
                  assert_response 409
                  assert_template("custom/custom_resource_unavailable")
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with unavailable
        end # context with basic resource
      end #template
    end # context with options
    context "with block" do
      setup do
        class CatchResourcesUnavailableWithBlockTestController < ::ConflictWarningsTest::ControllerStub
          before_filter do |controller|
            controller.catch_resources_unavailable() do
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
        @controller = CatchResourcesUnavailableWithBlockTestController.new
        ActionController::Routing::Routes.draw {|map|
          map.connect "/:action", :controller => @controller.controller_path
          map.connect "/:action/:id", :controller => @controller.controller_path
        }
        CatchResourcesUnavailableWithBlockTestController.view_paths = ['...']

        CatchResourcesUnavailableWithBlockTestController.controller_name = "resources"
      end #setup
      context "accepts html" do
        context "with basic resource" do
          context "without available" do
            context "without resource parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do

                  get :action1
                end
              end
            end
            context "with resource parameter" do
              context "with resource unset avaliability" do
                should "not redirect " do
                  get :action1, :id => 1
                  assert_response :success
                end
              end
              context "With resource unavailable" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end
          end

          context "with unavailable" do
            context "with resource unavailable" do
              context "without template" do
                should "redirect" do

                  get :action1, :id => 2
                  assert_match /Live from the block/, @response.body
                  assert_match /no longer available/, flash[:warning]
                  assert_response :success
                end
              end # context without template
            end # context with resource unavailable

          end # context with unavailable
        end # context with basic resource
      end #accepts html
      context "accepts js" do
        context "with basic resource" do
          context "without available" do
            context "without resource parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do
                  get :action1, :format => "js"
                end
              end
            end
            context "with resource parameter" do
              context "With resource unavailable" do
                should "not redirect" do
                  get :action1, :id => 3, :format => "js"
                  assert_response :success
                end
              end
            end
          end

          context "with unavailable" do
            context "with resource unavailable" do
              context "without template" do
                context "with resource unset avaliability" do
                  should "redirect " do
                    get :action1, :id => 1, :format => "js"
                    assert_response :success
                    assert_match(/alert\('JS/, @response.body)
                  end
                end

                should "redirect" do

                  get :action1, :id => 2, :format => "js"
                  assert_response :success
                  assert_match(/alert\('JS/, @response.body)
                end
              end # context without template

            end # context with resource unavailable

          end # context with unavailable
        end # context with basic resource
      end #accepts js
    end #with block
  end #context catch resource unavailables
end