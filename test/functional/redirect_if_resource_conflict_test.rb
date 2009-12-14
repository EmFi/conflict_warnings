require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class RedirectIfResourceUnavailableWarningsBasicTest < ActionController::TestCase
  #  class StubController < ActionController::Base
  #     ConflictWarningsTest::ControllerBits
  #  end
  #  #fixtures :resources, :resources, :resources_with_custom_accessors,
  #  :resources_with_custom_accessors, :Resources_with_updated_ats
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
          class RedirectIfResourceUnavailableWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
          
            before_filter do |controller|
              controller.redirect_if_resource_unavailable()
            end
            #cattr_accessor :controller_name
          end
          @controller = RedirectIfResourceUnavailableWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          RedirectIfResourceUnavailableWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            RedirectIfResourceUnavailableWithoutOptionsTestController.controller_name = "resources"
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
                  RedirectIfResourceUnavailableWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = RedirectIfResourceUnavailableWithoutOptionsTestController.new
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
            RedirectIfResourceUnavailableWithoutOptionsTestController.controller_name = "resource_with_custom_accessors"
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
                  RedirectIfResourceUnavailableWithoutOptionsTestController.append_view_path TestViewPath
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
          class RedirectIfResourceUnavailableWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            before_filter do |controller|
              controller.redirect_if_resource_unavailable()
            end
            #cattr_accessor :controller_name
          end
          @controller = RedirectIfResourceUnavailableWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }          
          RedirectIfResourceUnavailableWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            RedirectIfResourceUnavailableWithoutOptionsJSTestController.controller_name = "resources"
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
                  RedirectIfResourceUnavailableWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = RedirectIfResourceUnavailableWithoutOptionsJSTestController.new
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
            class RedirectIfResourceUnavailableWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :flash_key => :error)
              end
            end
            RedirectIfResourceUnavailableWithFlashKeyTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithFlashKeyTestsController.controller_name = "resources"
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
            class RedirectIfResourceUnavailableWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :flash_key => :error, :message => "CONFLICT!")
              end
            end
            RedirectIfResourceUnavailableWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithFlashKeyAndMessageTestsController.controller_name = "resources"
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
            class RedirectIfResourceUnavailableWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :message => "CONFLICT!")
              end
            end
            RedirectIfResourceUnavailableWithMessageTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithMessageTestsController.controller_name = "resources"
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
              class RedirectIfResourceUnavailableWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :message => "CONFLICT")
                end
              end
              @controller = RedirectIfResourceUnavailableWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              RedirectIfResourceUnavailableWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithMessageJSTestController.controller_name = "resources"
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
                      RedirectIfResourceUnavailableWithMessageJSTestController.append_view_path TestViewPath
                      @controller = RedirectIfResourceUnavailableWithMessageJSTestController.new
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
          class RedirectIfResourceUnavailableWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            before_filter do |controller|
              controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor)
            end
          end
          RedirectIfResourceUnavailableWithModelTestsController.view_paths = ['...']
          @controller = RedirectIfResourceUnavailableWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic resource" do
          setup do
            RedirectIfResourceUnavailableWithModelTestsController.controller_name = "resources"
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
                  controller.redirect_if_resource_unavailable( :model => "resource", :accessor => :bogus)
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
              class RedirectIfResourceUnavailableWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor, :accessor => :resources_left)
                end
              end
              RedirectIfResourceUnavailableWithModelAndAccessorTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAndAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAndAccessorTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithModelAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :model => Resource, :id => 4)
                  end
                end
                RedirectIfResourceUnavailableWithModelAndNonExistantIdTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithModelAndNonExistantIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithModelAndNonExistantIdTestsController.controller_name = "resource_with_custom_accessors"
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
                class RedirectIfResourceUnavailableWithModelAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :model => Resource, :id => 3)
                  end
                end
                RedirectIfResourceUnavailableWithModelAndExistingIdTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithModelAndExistingIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithModelAndExistingIdTestsController.controller_name = "resource_with_custom_accessors"
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
              class RedirectIfResourceUnavailableWithModelAccessorAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor, :id => 4, :accessor=> :resources_left)
                end
              end
              RedirectIfResourceUnavailableWithModelAccessorAndNonExistantIdTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAccessorAndNonExistantIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAccessorAndNonExistantIdTestsController.controller_name = "resources"
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
              class RedirectIfResourceUnavailableWithModelAccessorAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor, :id => 3, :accessor=> :resources_left)
                end
              end
              RedirectIfResourceUnavailableWithModelAccessorAndExistingIdTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAccessorAndExistingIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAccessorAndExistingIdTestsController.controller_name = "resources"
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
            class RedirectIfResourceUnavailableWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor, :params_id_key => :name)
              end
            end
            RedirectIfResourceUnavailableWithModelAndParamsIdKeyTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithModelAndParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithModelAndParamsIdKeyTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor,
                      :accessor => :resources_left, :params_id_key => :name)
                  end
                end
                RedirectIfResourceUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor,
                      :id => 2, :accessor=> :resource, :params_id_key => :name)
                  end
                end
                @controller = RedirectIfResourceUnavailableWithModelAndParamsIdKeyAccessorAndIdTestsController.new
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
                  class RedirectIfResourceUnavailableWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable( :model => Resource, :id => 2, :params_id_key => :name)
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithModelAndParamsIdKeyAndIdTestsController.new
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
            class RedirectIfResourceUnavailableWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
              end
            end
            RedirectIfResourceUnavailableWithModelAndFindOptionsTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithModelAndFindOptionsTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor,
                      :accessor => :resources_left, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                RedirectIfResourceUnavailableWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithModelAndFindOptionsAndAccessorTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor,
                        :id => 2, :accessor=> :resource,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsAccessorAndIdTestsController.new
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
                  class RedirectIfResourceUnavailableWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable( :model => Resource, :id => 2,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsAndIdTestsController.new
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
                  class RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor,
                        :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyTestsController.new
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
                    class RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor,
                          :accessor => :resource_left, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
                end
              end #context without id
              context "with id" do
                setup do
                    class RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.redirect_if_resource_unavailable( :model => ResourceWithCustomAccessor,
                          :id => 2, :accessor=> :resource, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
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
                    class RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.redirect_if_resource_unavailable( :model => Resource, :id => 2, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = RedirectIfResourceUnavailableWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController.new
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
              class RedirectIfResourceUnavailableWithModelAndUndefinedClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => Resource, :class_method => :nothing)
                end
              end
              RedirectIfResourceUnavailableWithModelAndUndefinedClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAndUndefinedClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAndUndefinedClassMethodTestsController.controller_name = "resource_with_custom_accessors"
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
              class RedirectIfResourceUnavailableWithModelAndTrueClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => Resource, :class_method => :returns_true)
                end
              end
              RedirectIfResourceUnavailableWithModelAndTrueClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAndTrueClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAndTrueClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns true
          context "that returns numeric" do
            setup do
              class RedirectIfResourceUnavailableWithModelAndTrueNumericClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => Resource, :class_method => :resources_left)
                end
              end
              RedirectIfResourceUnavailableWithModelAndTrueNumericClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAndTrueNumericClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAndTrueNumericClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns numeric
          context "that returns false" do
            setup do
              class RedirectIfResourceUnavailableWithModelAndFalseClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => Resource, :class_method => :returns_false)
                end
              end
              RedirectIfResourceUnavailableWithModelAndFalseClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAndFalseClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAndFalseClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns false
          context "that returns zero" do
            setup do
              class RedirectIfResourceUnavailableWithModelAndZeroClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => Resource, :class_method => :no_resources_left)
                end
              end
              RedirectIfResourceUnavailableWithModelAndZeroClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAndZeroClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAndZeroClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns 0          
          context "is true" do
            setup do
              class RedirectIfResourceUnavailableWithModelAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :model => Resource, :class_method => true)
                end
              end
              RedirectIfResourceUnavailableWithModelAndClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithModelAndClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithModelAndClassMethodTestsController.controller_name = "resource_with_custom_accessors"
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
            class RedirectIfResourceUnavailableWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :model => Resource.last)
              end
            end
            RedirectIfResourceUnavailableWithModelARObjectTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithModelARObjectTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithModelARObjectTestsController.controller_name = "resource_with_custom_accessors"
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
            class RedirectIfResourceUnavailableWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :model => :resource)
              end
            end
            RedirectIfResourceUnavailableWithModelSymbolTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithModelSymbolTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithModelSymbolTestsController.controller_name = "resource_with_custom_accessors"
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
            class RedirectIfResourceUnavailableWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable( :model => "resource")
              end
            end
            RedirectIfResourceUnavailableWithModelStringTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithModelStringTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithModelStringTestsController.controller_name = "resource_with_custom_accessors"
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
              class RedirectIfResourceUnavailableWithUndefinedClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :class_method => :nothing)
                end
              end
              RedirectIfResourceUnavailableWithUndefinedClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithUndefinedClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithUndefinedClassMethodTestsController.controller_name = "resources"
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
              class RedirectIfResourceUnavailableWithTrueClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable(  :class_method => :returns_true)
                end
              end
              RedirectIfResourceUnavailableWithTrueClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithTrueClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithTrueClassMethodTestsController.controller_name = "resources"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns true
          context "that returns numeric" do
            setup do
              class RedirectIfResourceUnavailableWithTrueNumericClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :class_method => :resources_left)
                end
              end
              RedirectIfResourceUnavailableWithTrueNumericClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithTrueNumericClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithTrueNumericClassMethodTestsController.controller_name = "resources"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns numeric
          context "that returns false" do
            setup do
              class RedirectIfResourceUnavailableWithFalseClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :class_method => :returns_false)
                end
              end
              RedirectIfResourceUnavailableWithFalseClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithFalseClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithFalseClassMethodTestsController.controller_name = "resources"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns false
          context "that returns zero" do
            setup do
              class RedirectIfResourceUnavailableWithZeroClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :class_method => :no_resources_left)
                end
              end
              RedirectIfResourceUnavailableWithZeroClassMethodTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithZeroClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithZeroClassMethodTestsController.controller_name = "resources"
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
              class RedirectIfResourceUnavailableWithAccessorAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :accessor => :resources_left, :class_method => true)
                end
              end

              @controller = RedirectIfResourceUnavailableWithAccessorAndClassMethodTestsController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
            end
            context "instance that should redirect" do

              should "not redirect" do
                RedirectIfResourceUnavailableWithAccessorAndClassMethodTestsController.controller_name = "resources"
                get :action1, :id => 2
                assert_response :success
              end
            end
          end #with Class method

          context "without id" do
            setup do
              class RedirectIfResourceUnavailableWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable(  :accessor => :resources_left)
                end
              end
              RedirectIfResourceUnavailableWithAccessorTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithAccessorTestsController.controller_name = "resource_with_custom_accessors"
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
                class RedirectIfResourceUnavailableWithAccessorAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :id => 4, :accessor=> :resources_left)
                  end
                end
                RedirectIfResourceUnavailableWithAccessorAndNonExistantIdTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithAccessorAndNonExistantIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithAccessorAndNonExistantIdTestsController.controller_name = "resource_with_custom_accessors"
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
                class RedirectIfResourceUnavailableWithAccessorAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :id => 3, :accessor=> :resources_left)
                  end
                end
                RedirectIfResourceUnavailableWithAccessorAndExistingIdTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithAccessorAndExistingIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithAccessorAndExistingIdTestsController.controller_name = "resource_with_custom_accessors"
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
              class RedirectIfResourceUnavailableWithNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :id => 4)
                end
              end
              RedirectIfResourceUnavailableWithNonExistantIdTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithNonExistantIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithNonExistantIdTestsController.controller_name = "resources"
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
              class RedirectIfResourceUnavailableWithExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                before_filter do |controller|
                  controller.redirect_if_resource_unavailable( :id => 3)
                end
              end
              RedirectIfResourceUnavailableWithExistingIdTestsController.view_paths = ['...']
              @controller = RedirectIfResourceUnavailableWithExistingIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                RedirectIfResourceUnavailableWithExistingIdTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithIdAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :id => 2, :class_method => true)
                  end
                end
              @controller = RedirectIfResourceUnavailableWithIdAndClassMethodTestsController.new
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
            class RedirectIfResourceUnavailableWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable(  :params_id_key => :name)
              end
            end
            RedirectIfResourceUnavailableWithParamsIdKeyTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithParamsIdKeyTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :accessor => :resources_left, :params_id_key => :name)
                  end
                end
                RedirectIfResourceUnavailableWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithParamsIdKeyAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
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
                  class RedirectIfResourceUnavailableWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable( :id => 2, :accessor=> :resource, :params_id_key => :name)
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithParamsIdKeyAccessorAndIdTestsController.new
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
                  class RedirectIfResourceUnavailableWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable(  :id => 2, :params_id_key => :name)
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithParamsIdKeyAndIdTestsController.new
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
                class RedirectIfResourceUnavailableWithParamsIdKeyAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :params_id_key => :new_key, :class_method => true)
                  end
                end
              @controller = RedirectIfResourceUnavailableWithParamsIdKeyAndClassMethodTestsController.new
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
            class RedirectIfResourceUnavailableWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              before_filter do |controller|
                controller.redirect_if_resource_unavailable(  :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
              end
            end
            RedirectIfResourceUnavailableWithFindOptionsTestsController.view_paths = ['...']
            @controller = RedirectIfResourceUnavailableWithFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              RedirectIfResourceUnavailableWithFindOptionsTestsController.controller_name = "resources"
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
                class RedirectIfResourceUnavailableWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :accessor => :resources_left,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                  end
                end
                RedirectIfResourceUnavailableWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = RedirectIfResourceUnavailableWithFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  RedirectIfResourceUnavailableWithFindOptionsAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
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
                  class RedirectIfResourceUnavailableWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable( :id => 2, :accessor=> :resource,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithFindOptionsAccessorAndIdTestsController.new
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
                  class RedirectIfResourceUnavailableWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable(  :id => 2,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithFindOptionsAndIdTestsController.new
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
                  class RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    before_filter do |controller|
                      controller.redirect_if_resource_unavailable( :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                    end
                  end
                @controller = RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyTestsController.new
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
                    class RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.redirect_if_resource_unavailable(  :accessor => :resource_left, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyAndAccessorTestsController.new
              end
              should "raise Argument Error" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
                end
              end #context without id
              context "with id" do
                setup do
                    class RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.redirect_if_resource_unavailable( :id => 2, :accessor=> :resource, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController.new
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
                    class RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      before_filter do |controller|
                        controller.redirect_if_resource_unavailable(  :id => 2, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}})
                      end
                    end
                  @controller = RedirectIfResourceUnavailableWithFindOptionsAndParamsIdKeyAndIdTestsController.new
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
                class RedirectIfResourceUnavailableBadFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :find_options => {:conditions => {:name => "Test value"}})
                  end
                end
            @controller = RedirectIfResourceUnavailableBadFindOptionsTestsController.new
              end
              should "raise Argument Error when find options is not a proc" do
                assert_raise(ArgumentError) do
                  get :action1, :id => 3
                end
            end
          end
          context "with class method" do
            setup do
                class RedirectIfResourceUnavailableWithFindOptionsAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  before_filter do |controller|
                    controller.redirect_if_resource_unavailable( :class_method => true,
                      :find_options => Proc.new {{:conditions => {:id => 3}}})
                  end
                end
              @controller = RedirectIfResourceUnavailableWithFindOptionsAndClassMethodTestsController.new
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
          class RedirectIfResourceUnavailableWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            before_filter do |controller|
              controller.redirect_if_resource_unavailable( :template => "custom/custom")
            end
            #cattr_accessor :controller_name
          end
          @controller = RedirectIfResourceUnavailableWithTemplateTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          RedirectIfResourceUnavailableWithTemplateTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            RedirectIfResourceUnavailableWithTemplateTestController.controller_name = "resources"
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
                  RedirectIfResourceUnavailableWithTemplateTestController.append_view_path TestViewPath
                  @controller = RedirectIfResourceUnavailableWithTemplateTestController.new
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
        class RedirectIfResourceUnavailableWithBlockTestController < ::ConflictWarningsTest::ControllerStub
          before_filter do |controller|
            controller.redirect_if_resource_unavailable() do
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
        @controller = RedirectIfResourceUnavailableWithBlockTestController.new
        ActionController::Routing::Routes.draw {|map|
          map.connect "/:action", :controller => @controller.controller_path
          map.connect "/:action/:id", :controller => @controller.controller_path
        }
        RedirectIfResourceUnavailableWithBlockTestController.view_paths = ['...']

        RedirectIfResourceUnavailableWithBlockTestController.controller_name = "resources"
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