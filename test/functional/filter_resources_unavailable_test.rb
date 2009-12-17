require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class FilterResourcesUnavailableTestTest < ActionController::TestCase
  context "filter resource conflicts" do
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
          class FilterResourcesUnavailableWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
          
            filter_resources_unavailable
            #cattr_accessor :controller_name
          end
          @controller = FilterResourcesUnavailableWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          FilterResourcesUnavailableWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            FilterResourcesUnavailableWithoutOptionsTestController.controller_name = "resources"
          end
          context "without conflict" do
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
              context "With resource available" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
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
                  FilterResourcesUnavailableWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = FilterResourcesUnavailableWithoutOptionsTestController.new
                  get :action1, :id => 2
                  assert_response 409
                  assert_template("action1_resource_unavailable")
                  assert_match /No Resources Remaining/, @response.body
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with conflict
          context "alternate id key based on model name" do
            context "without conflict" do
              should "not redirect" do
                get :action1, :resource_id => 3
                assert_response :success
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, :resource_id => 2
                assert_redirected_to "/"
              end
            end
          end #alternate id
        end # context with basic resource

        context "with custom accessible resource" do
          setup do
            FilterResourcesUnavailableWithoutOptionsTestController.controller_name = "resource_with_custom_accessors"
          end
          context "without conflict" do
            context "without resource parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do
                  get :action1
                end
              end
            end            
            context "With resource available" do
              should "not redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end
          end
          
          context "with conflict" do
            context "with resource parameter" do
              context "with resource unset avaliability" do
                should "not redirect " do
                  get :action1, :id => 1
                  assert_redirected_to "/"
                end
              end
              context "with template" do
                should "not redirect and render default template" do
                  FilterResourcesUnavailableWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, :id => 2
                  assert_response 409
                end
              end
            end
          end
          context "alternate id key based on model name" do
            context "without conflict" do
              should "not redirect" do
                get :action1, :resource_with_custom_accessor_id => 3
                assert_redirected_to "/"
              end
            end #without conflict
            context "with conflict" do
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
          class FilterResourcesUnavailableWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            filter_resources_unavailable
            #cattr_accessor :controller_name
          end
          @controller = FilterResourcesUnavailableWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }          
          FilterResourcesUnavailableWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            FilterResourcesUnavailableWithoutOptionsJSTestController.controller_name = "resources"
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
          context "without conflict" do
            context "With resource available" do
              should "not redirect" do
                get :action1, :id => 3, :format => "js"
                assert_response :success
              end
            end
          end

          context "with conflict" do
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
                  FilterResourcesUnavailableWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = FilterResourcesUnavailableWithoutOptionsJSTestController.new
                  get :action1, :id => 2,  :format => "js"
                  assert_response 409
                  assert_template("action1_resource_unavailable.rjs")
                  assert_match /No Resources Remaining/, @response.body
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with conflict
          context "alternate id key based on model name" do
            context "without conflict" do
              should "not redirect" do
                get :action1, :resource_id => 3
                assert_response :success
              end
            end #without conflict
            context "with conflict" do
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
      context "filter options" do
        context "with only" do
          setup do
            class FilterResourcesUnavailableWithOnlyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :only => :action1
            end
            FilterResourcesUnavailableWithOnlyTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithOnlyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithOnlyTestsController.controller_name = "resources"
            end
            context "without conflict" do              
              should "not redirect" do
                get :action1, :id => 3
                assert_response :success
              end
            end #without conflict
            context "with conflict" do
              context "with resource unavailable" do
                should "redirect" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /no longer available/, flash[:warning]
                end
                
                context "on action not covered in only" do
                  should "not redirect" do
                    get :action2, :id => 2
                    assert_response :success
                  end # should not redirect and render default template
                end # on action not covered in only
              end # context with resource unavailable

            end # context with conflict
          end # context with basic resource

        end # with only
        context "with except" do
          setup do
            class FilterResourcesUnavailableWithExceptTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :except => :action2
            end
            FilterResourcesUnavailableWithExceptTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithExceptTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithExceptTestsController.controller_name = "resources"
            end
            context "without conflict" do
              context "without resource parameter" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              context "with resource unavailable" do
                context "on unexcepted action" do
                  should "redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                    assert_match /no longer available/, flash[:warning]
                  end
                end # on action in only

                context "on action not covered by except" do
                  should "not redirect" do
                    get :action2, :id => 2
                    assert_response :success
                  end # should not redirect and render default template
                end # on action not covered in only
              end # context with resource unavailable

            end # context with conflict
          end # context with basic resource

        end # with except
      end #filter options
      context "with flash key" do
        context "without message" do
          setup do
            class FilterResourcesUnavailableWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :flash_key => :error
            end
            FilterResourcesUnavailableWithFlashKeyTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithFlashKeyTestsController.controller_name = "resources"
            end
            context "without conflict" do
              context "without resource parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 3
                  assert_response :success
                  assert_no_match /not be processed/, flash[:error]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with resource unavailable" do
              
                should "set flash[:error]" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /no longer available/, flash[:error]
                end
              
              end # context with resource unavailable

            end # context with conflict
          end # context with basic resource
        end # context without message
        context "with message" do
          setup do
            class FilterResourcesUnavailableWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :flash_key => :error, :message => "CONFLICT!"
            end
            FilterResourcesUnavailableWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithFlashKeyAndMessageTestsController.controller_name = "resources"
            end
            context "without conflict" do
              context "without resource parameter" do
                should "not set flash[:error]" do
                  get :action1, :id => 3
                  assert_response :success
                  assert_no_match /CONFLICT!/, flash[:error]
                end
              end
            end #without conflict
            context "with conflict" do
              context "with resource unavailable" do               
                should "set flash[:error]" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                  assert_match /CONFLICT!/, flash[:error]
                end

              end # context with resource unavailable
            end # with basic resource
          end # context with conflict
        end # context with message
      end # with flash key
      context "without flash key" do
        context "with message" do
          setup do
            class FilterResourcesUnavailableWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :message => "CONFLICT!"
            end
            FilterResourcesUnavailableWithMessageTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithMessageTestsController.controller_name = "resources"
            end
            context "without conflict" do
              should "set flash[:error]" do

                get :action1, :id => 3
                assert_response :success
                assert_no_match /CONFLICT!/, flash[:warning]
              end
            end #without conflict
            context "with conflict" do
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

            end # context with conflict
          end # context with basic resource
          context "accepts js" do
            setup do
              class FilterResourcesUnavailableWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :message => "CONFLICT"
              end
              @controller = FilterResourcesUnavailableWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              FilterResourcesUnavailableWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithMessageJSTestController.controller_name = "resources"
              end
              context "without conflict" do
                context "without resource parameter" do
                  should "raise ArgumentError" do
                    assert_raise(ArgumentError) do
                      get :action1, :format => "js"
                    end
                  end
                end
                
                  
                context "With resource available" do
                  should "not redirect" do
                    get :action1, :id => 3, :format => "js"
                    assert_response :success
                  end
                end

              end

              context "with conflict" do
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
                      FilterResourcesUnavailableWithMessageJSTestController.append_view_path TestViewPath
                      @controller = FilterResourcesUnavailableWithMessageJSTestController.new
                      get :action1, :id => 2, :format => "js"
                      assert_response 409
                      assert_template("action1_resource_unavailable.rjs")
                    end # should not redirect and render default template
                  end # context with template
                end # context with resource unavailable

              end # context with conflict
            end # context with basic resource

          end #acceepts js
        end # with message
      end # context without flashkey
      context "with model" do
        setup do
          class FilterResourcesUnavailableWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            filter_resources_unavailable :model => ResourceWithCustomAccessor
          end
          FilterResourcesUnavailableWithModelTestsController.view_paths = ['...']
          @controller = FilterResourcesUnavailableWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic resource" do
          setup do
            FilterResourcesUnavailableWithModelTestsController.controller_name = "resources"
          end
          context "without conflict" do
            context "without resource parameter" do
              should "redirect" do
                get :action1, :id => 1
                assert_redirected_to "/"
              end
            end
          end #without conflict
          context "with conflict" do
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

          end # context with conflict
        end # context with basic resource
        context "with accessor" do
          context "with bogus accessor" do
            setup do

              class FilterResourcEconflictWithModelAndBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => "resource", :accessor => :bogus
              end
              FilterResourcEconflictWithModelAndBogusAccessorTestsController.view_paths = ['...']
              @controller = FilterResourcEconflictWithModelAndBogusAccessorTestsController.new


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
              class FilterResourcesUnavailableWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => ResourceWithCustomAccessor, :accessor => :resources_left
              end
              FilterResourcesUnavailableWithModelAndAccessorTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAndAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAndAccessorTestsController.controller_name = "resources"
              end
              context "without conflict" do
                context "without resource parameter" do
                  should "not redirect" do
                    get :action1, :id => 3
                    assert_response :success
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with resource unavailable" do
                
                  should "not redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                
                  end # context with resource unavailable
                end
              end # context with conflict
            end # context with basic resource
            context "alternate id key based on model name" do
              context "without conflict" do
                should "not redirect" do
                  get :action1, :resource_with_custom_accessor_id => 3
                  assert_response :success
                end
              end #without conflict
              context "with conflict" do
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
                class FilterResourcesUnavailableWithModelAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :model => Resource, :id => 4
                end
                FilterResourcesUnavailableWithModelAndNonExistantIdTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithModelAndNonExistantIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithModelAndNonExistantIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without conflict" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_redirected_to "/"
                    end

                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end

                  end # context with resource unavailable

                end # context with conflict
              end # context with basic resource
            end #nonexistant resource
            context "Existing resource" do
              setup do
                class FilterResourcesUnavailableWithModelAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :model => Resource, :id => 3
                end
                FilterResourcesUnavailableWithModelAndExistingIdTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithModelAndExistingIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithModelAndExistingIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without conflict" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_response :success
                    end

                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_response :success
                    end

                  end # context with resource unavailable

                end # context with conflict
              end # context with basic resource
            end #exisitng resource
          end #with id
        end # with accessor

        context "with id" do
          context "Non Existant resource" do
            setup do
              class FilterResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => ResourceWithCustomAccessor, :id => 4, :accessor=> :resources_left
              end
              FilterResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAccessorAndNonExistantIdTestsController.controller_name = "resources"
              end
              context "without conflict" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_redirected_to "/"
                  end

                end
              end #without conflict
              context "with conflict" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                  end

                end # context with resource unavailable

              end # context with conflict
            end # context with basic resource
          end #nonexistant resource
          context "Existing resource" do
            setup do
              class FilterResourcesUnavailableWithModelAccessorAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => ResourceWithCustomAccessor, :id => 3, :accessor=> :resources_left
              end
              FilterResourcesUnavailableWithModelAccessorAndExistingIdTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAccessorAndExistingIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAccessorAndExistingIdTestsController.controller_name = "resources"
              end
              context "without conflict" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_response :success
                  end

                end
              end #without conflict
              context "with conflict" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_response :success
                  end

                end # context with resource unavailable

              end # context with conflict
            end # context with basic resource
          end #exisitng resource
        end #with id
        context "with params id key" do
          setup do
            class FilterResourcesUnavailableWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :model => ResourceWithCustomAccessor, :params_id_key => :name
            end
            FilterResourcesUnavailableWithModelAndParamsIdKeyTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithModelAndParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithModelAndParamsIdKeyTestsController.controller_name = "resources"
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
                class FilterResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :model => ResourceWithCustomAccessor,
                    :accessor => :resources_left, :params_id_key => :name
                end
                FilterResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "resources"
                end
                context "without conflict" do
                  context "with resource parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => 3
                      assert_response :success
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    should "redirect" do

                      get :action1, :id => 2, :name => 2
                      assert_redirected_to "/"
                    end
                  end # context with resource unavailable
                end # context with conflict
              end # context with basic resource
            end #context without id
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterResourcesUnavailableWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :model => ResourceWithCustomAccessor,
                      :id => 2, :accessor=> :resource, :params_id_key => :name
                  end
                end
              end
            end #with id
          end # with accessor
          context "without accessor" do
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterResourcesUnavailableWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :model => Resource, :id => 2, :params_id_key => :name
                  end
                end
              end
            end #with id
          end #without accessor
        end
        context "with find options" do
          setup do
            class FilterResourcesUnavailableWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :model => ResourceWithCustomAccessor, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
            end
            FilterResourcesUnavailableWithModelAndFindOptionsTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithModelAndFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithModelAndFindOptionsTestsController.controller_name = "resources"
            end
            context "without conflict" do
              context "without resource parameter" do
                should "not redirect" do
                  get :action1, :id => 1, :name => "Resources Available"
                  assert_redirected_to "/"
                end
              end
            end #without conflict
            context "with conflict" do
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

            end # context with conflict
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class FilterResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :model => ResourceWithCustomAccessor,
                    :accessor => :resources_left, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                end
                FilterResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithModelAndFindOptionsAndAccessorTestsController.controller_name = "resources"
                end
                context "without conflict" do
                  context "without resource parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => "Resources Available"
                      assert_response :success
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    
                    should "redirect" do

                      get :action1, {:id => 2,
                        :name => "No Resources Remaining"}
                      assert_redirected_to "/"
                    end

                  end # context with resource unavailable

                end # context with conflict
              end # context with basic resource
            end #context without id
            context "with id" do
              should "raise ArgumentError" do
                assert_raise(ArgumentError) do class FilterResourcesUnavailableWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :model => ResourceWithCustomAccessor,
                      :id => 2, :accessor=> :resource,
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
                  class FilterResourcesUnavailableWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :model => Resource, :id => 2,
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
                  class FilterResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :model => ResourceWithCustomAccessor,
                      :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
            context "with accessor" do
              context "without id" do
                should "raise ArgumentError"do
                  assert_raise(ArgumentError) do
                    class FilterResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_resources_unavailable :model => ResourceWithCustomAccessor,
                        :accessor => :resource_left, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #context without id
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class FilterResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_resources_unavailable :model => ResourceWithCustomAccessor,
                        :id => 2, :accessor=> :resource, :params_id_key => :name,
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
                    class FilterResourcesUnavailableWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_resources_unavailable :model => Resource, :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end

              end #with id
            end  #without accessor
          end #with params id key
        end # with find options
        context "with class method" do
          context "with undefined class method" do
            setup do
              class FilterResourcesUnavailableWithModelAndUndefinedClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => Resource, :class_method => :nothing
              end
              FilterResourcesUnavailableWithModelAndUndefinedClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAndUndefinedClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAndUndefinedClassMethodTestsController.controller_name = "resource_with_custom_accessors"
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
              class FilterResourcesUnavailableWithModelAndTrueClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => Resource, :class_method => :returns_true
              end
              FilterResourcesUnavailableWithModelAndTrueClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAndTrueClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAndTrueClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns true
          context "that returns numeric" do
            setup do
              class FilterResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => Resource, :class_method => :resources_left
              end
              FilterResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAndTrueNumericClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns numeric
          context "that returns false" do
            setup do
              class FilterResourcesUnavailableWithModelAndFalseClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => Resource, :class_method => :returns_false
              end
              FilterResourcesUnavailableWithModelAndFalseClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAndFalseClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAndFalseClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns false
          context "that returns zero" do
            setup do
              class FilterResourcesUnavailableWithModelAndZeroClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => Resource, :class_method => :no_resources_left
              end
              FilterResourcesUnavailableWithModelAndZeroClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAndZeroClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAndZeroClassMethodTestsController.controller_name = "resource_with_custom_accessors"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns 0          
          context "is true" do
            setup do
              class FilterResourcesUnavailableWithModelAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :model => Resource, :class_method => true
              end
              FilterResourcesUnavailableWithModelAndClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithModelAndClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithModelAndClassMethodTestsController.controller_name = "resource_with_custom_accessors"
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
            class FilterResourcesUnavailableWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :model => Resource.last
            end
            FilterResourcesUnavailableWithModelARObjectTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithModelARObjectTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithModelARObjectTestsController.controller_name = "resource_with_custom_accessors"
            end
            context "without conflict" do
              context "without resource parameter" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, :id => 2
                assert_response :success
              end

            end # context with conflict
            context "alternate id key based on model name" do
              context "without conflict" do
                should "not redirect" do
                  get :action1, :resource_id => 3
                  assert_response :success
                end
              end #without conflict
              context "with conflict" do
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
            class FilterResourcesUnavailableWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :model => :resource
            end
            FilterResourcesUnavailableWithModelSymbolTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithModelSymbolTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithModelSymbolTestsController.controller_name = "resource_with_custom_accessors"
            end
            context "without conflict" do
              should "not redirect" do
                get :action1, :id => 3
                assert_response :success
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, :id => 2
                assert_redirected_to "/"
              end

            end # context with conflict

            context "alternate id key based on model name" do
              context "without conflict" do
                should "not redirect" do
                  get :action1, :resource_id => 3
                  assert_response :success
                end
              end #without conflict
              context "with conflict" do
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
            class FilterResourcesUnavailableWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable :model => "resource"
            end
            FilterResourcesUnavailableWithModelStringTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithModelStringTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithModelStringTestsController.controller_name = "resource_with_custom_accessors"
            end
            context "without conflict" do
              should "not redirect" do
                get :action1, :id => 3
                assert_response :success
              end
            end #without conflict
            context "with conflict" do
              should "redirect" do
                get :action1, :id => 2
                assert_redirected_to "/"
              end

            end # context with conflict

            context "alternate id key based on model name" do
              context "without conflict" do
                should "not redirect" do
                  get :action1, :resource_id => 3
                  assert_response :success
                end
              end #without conflict
              context "with conflict" do
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
              class FilterResourcesUnavailableWithUndefinedClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :class_method => :nothing
              end
              FilterResourcesUnavailableWithUndefinedClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithUndefinedClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithUndefinedClassMethodTestsController.controller_name = "resources"
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
              class FilterResourcesUnavailableWithTrueClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable  :class_method => :returns_true
              end
              FilterResourcesUnavailableWithTrueClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithTrueClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithTrueClassMethodTestsController.controller_name = "resources"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns true
          context "that returns numeric" do
            setup do
              class FilterResourcesUnavailableWithTrueNumericClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :class_method => :resources_left
              end
              FilterResourcesUnavailableWithTrueNumericClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithTrueNumericClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithTrueNumericClassMethodTestsController.controller_name = "resources"
              end
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end # context with basic resource
          end #returns numeric
          context "that returns false" do
            setup do
              class FilterResourcesUnavailableWithFalseClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :class_method => :returns_false
              end
              FilterResourcesUnavailableWithFalseClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithFalseClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithFalseClassMethodTestsController.controller_name = "resources"
              end
              should "redirect" do
                get :action1, :id => 3
                assert_redirected_to "/"
              end
            end # context with basic resource
          end #returns false
          context "that returns zero" do
            setup do
              class FilterResourcesUnavailableWithZeroClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :class_method => :no_resources_left
              end
              FilterResourcesUnavailableWithZeroClassMethodTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithZeroClassMethodTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithZeroClassMethodTestsController.controller_name = "resources"
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
              class FilterResourcesUnavailableWithAccessorAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :accessor => :resources_left, :class_method => true
              end
              @controller = FilterResourcesUnavailableWithAccessorAndClassMethodTestsController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
            end
            context "instance that should redirect" do
              should "not redirect" do
                get :action1, :id => 2
                assert_response :success
              end
            end
          end #with Class method

          context "without id" do
            setup do
              class FilterResourcesUnavailableWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable  :accessor => :resources_left
              end
              FilterResourcesUnavailableWithAccessorTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithAccessorTestsController.controller_name = "resource_with_custom_accessors"
              end
              context "without conflict" do
                context "without resource parameter" do
                  should "not redirect" do
                    get :action1, :id => 3
                    assert_response :success
                  end
                end
              end #without conflict
              context "with conflict" do
                context "with resource unavailable" do
                  should "not redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                  end
                end # context with resource unavailable
              end # context with conflict
            end # context with basic resource
          end #context without id
          context "with id" do
            context "Non Existant resource" do
              setup do
                class FilterResourcesUnavailableWithAccessorAndNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :id => 4, :accessor=> :resources_left
                end
                FilterResourcesUnavailableWithAccessorAndNonExistantIdTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithAccessorAndNonExistantIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithAccessorAndNonExistantIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without conflict" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_redirected_to "/"
                    end

                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_redirected_to "/"
                    end

                  end # context with resource unavailable

                end # context with conflict
              end # context with basic resource
            end #nonexistant resource
            context "Existing resource" do
              setup do
                class FilterResourcesUnavailableWithAccessorAndExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :id => 3, :accessor=> :resources_left
                end
                FilterResourcesUnavailableWithAccessorAndExistingIdTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithAccessorAndExistingIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithAccessorAndExistingIdTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without conflict" do
                  context "without resource parameter" do
                    should "not redirect" do

                      get :action1, :id => 3
                      assert_response :success
                    end

                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    should "with resource should redirect" do

                      get :action1, :id => 2
                      assert_response :success
                    end

                  end # context with resource unavailable

                end # context with conflict
              end # context with basic resource
            end #exisitng resource
          end #with id
        end # with accessor

        context "with id" do
          context "Non Existant resource" do
            setup do
              class FilterResourcesUnavailableWithNonExistantIdTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :id => 4
              end
              FilterResourcesUnavailableWithNonExistantIdTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithNonExistantIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithNonExistantIdTestsController.controller_name = "resources"
              end
              context "without conflict" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_redirected_to "/"
                  end

                end
              end #without conflict
              context "with conflict" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_redirected_to "/"
                  end

                end # context with resource unavailable

              end # context with conflict
            end # context with basic resource
          end #nonexistant resource
          context "Existing resource" do
            setup do
              class FilterResourcesUnavailableWithExistingIdTestsController < ::ConflictWarningsTest::ControllerStub
                filter_resources_unavailable :id => 3
              end
              FilterResourcesUnavailableWithExistingIdTestsController.view_paths = ['...']
              @controller = FilterResourcesUnavailableWithExistingIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                FilterResourcesUnavailableWithExistingIdTestsController.controller_name = "resources"
              end
              context "without conflict" do
                context "without resource parameter" do
                  should "not redirect" do

                    get :action1, :id => 3
                    assert_response :success
                  end

                end
              end #without conflict
              context "with conflict" do
                context "with resource unavailable" do
                  should "with resource should redirect" do

                    get :action1, :id => 2
                    assert_response :success
                  end

                end # context with resource unavailable

              end # context with conflict
            end # context with basic resource
          end #exisitng resource

          context "with class method" do
            should "raise Argument Error" do
              assert_raise(ArgumentError) do
                class FilterResourcesUnavailableWithIdAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :id => 2, :class_method => true
                end
              end
              
            end
          end #with Class method
        end #with id
        context "with params id key" do
          setup do
            class FilterResourcesUnavailableWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable  :params_id_key => :name
            end
            FilterResourcesUnavailableWithParamsIdKeyTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithParamsIdKeyTestsController.controller_name = "resources"
            end
            context "without conflict" do

              should "redirect" do
                get :action1, :id => 1, :name => 3
                assert_response :success
              end
            end #without conflict
            context "with conflict" do
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

            end # context with conflict
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class FilterResourcesUnavailableWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :accessor => :resources_left, :params_id_key => :name
                end
                FilterResourcesUnavailableWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithParamsIdKeyAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without conflict" do
                  context "with resource parameter" do
                    should "redirect" do

                      get :action1, :id => 1, :name => 3
                      assert_response :success
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    should "redirect" do

                      get :action1, :id => 2, :name => 2
                      assert_redirected_to "/"
                    end
                  end # context with resource unavailable
                end # context with conflict
              end # context with basic resource
            end #context without id
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterResourcesUnavailableWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :id => 2, :accessor=> :resource, :params_id_key => :name
                  end
                end
              end
            end #with id
          end # with accessor
          context "without accessor" do
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class FilterResourcesUnavailableWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable  :id => 2, :params_id_key => :name
                  end
                end
              end
            end #with id
          end #without accessor
          context "with class method" do
            should "raise Argument Error" do
              assert_raise(ArgumentError) do
                class FilterResourcesUnavailableWithParamsIdKeyAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :params_id_key => :new_key, :class_method => true
                end
              end
            end
          end #with Class method
        end #with params id key
        context "with find options" do
          setup do
            class FilterResourcesUnavailableWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              filter_resources_unavailable  :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
            end
            FilterResourcesUnavailableWithFindOptionsTestsController.view_paths = ['...']
            @controller = FilterResourcesUnavailableWithFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              FilterResourcesUnavailableWithFindOptionsTestsController.controller_name = "resources"
            end
            context "without conflict" do
              context "without resource parameter" do
                should "not redirect" do
                  get :action1, :id => 1, :name => "Resources Available"
                  assert_response :success
                end
              end
            end #without conflict
            context "with conflict" do
              context "with resource unavailable" do
                should "redirect" do
                  get :action1, {:id => 2,
                    :name => "No Resources Remaining"}
                  assert_redirected_to "/"
                end
                

              end # context with resource unavailable

            end # context with conflict
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class FilterResourcesUnavailableWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :accessor => :resources_left,
                    :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                end
                FilterResourcesUnavailableWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = FilterResourcesUnavailableWithFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  FilterResourcesUnavailableWithFindOptionsAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
                end
                context "without conflict" do
                  context "without resource parameter" do
                    should "not redirect" do
                      get :action1, :id => 1, :name => "Resources Available"
                      assert_response :success
                    end
                  end
                end #without conflict
                context "with conflict" do
                  context "with resource unavailable" do
                    should "not redirect" do

                      get :action1, {:id => 2,
                        :name => "No Resources Remaining"}
                      assert_redirected_to "/"
                    end
                  end # context with resource unavailable
                end # context with conflict
              end # context with basic resource
            end #context without id
            context "with id" do
              should "raise ArgumentError" do
                assert_raise(ArgumentError) do
                  class FilterResourcesUnavailableWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :id => 2, :accessor=> :resource,
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
                  class FilterResourcesUnavailableWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable  :id => 2,
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
                  class FilterResourcesUnavailableWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    filter_resources_unavailable :params_id_key => :name,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
            context "with accessor" do
              context "without id" do
                should "raise ArgumentError"do
                  assert_raise(ArgumentError) do
                    class FilterResourcesUnavailableWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_resources_unavailable  :accessor => :resource_left, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #context without id
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class FilterResourcesUnavailableWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_resources_unavailable :id => 2, :accessor=> :resource, :params_id_key => :name,
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
                    class FilterResourcesUnavailableWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      filter_resources_unavailable  :id => 2, :params_id_key => :name,
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
                class FilterResourcesUnavailableBadFindOptinsTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :find_options => {:conditions => {:name => "Test value"}}
                end
              end
            end
          end
          context "with class method" do
            should "raise Argument Error" do
              assert_raise(ArgumentError) do
                class FilterResourcesUnavailableWithFindOptionsAndClassMethodTestsController < ::ConflictWarningsTest::ControllerStub
                  filter_resources_unavailable :class_method => true,
                    :find_options => Proc.new {{:conditions => {:id => 3}}}
                end
              end
            end
          end #with Class method
        end # with find options

      end # instance selectors without model
            
      context "template" do
        setup do
          class FilterResourcesUnavailableWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            filter_resources_unavailable :template => "custom/custom"
            #cattr_accessor :controller_name
          end
          @controller = FilterResourcesUnavailableWithTemplateTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          FilterResourcesUnavailableWithTemplateTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            FilterResourcesUnavailableWithTemplateTestController.controller_name = "resources"
          end
          context "without conflict" do
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
              context "With resource available" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
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
                  FilterResourcesUnavailableWithTemplateTestController.append_view_path TestViewPath
                  @controller = FilterResourcesUnavailableWithTemplateTestController.new
                  get :action1, :id => 2
                  assert_response 409
                  assert_template("custom/custom_resource_unavailable")
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with conflict
        end # context with basic resource
      end #template
    end # context with options
    context "with block" do
      setup do
        class FilterResourcesUnavailableWithBlockTestController < ::ConflictWarningsTest::ControllerStub
          filter_resources_unavailable do
            respond_to do |format|
              format.html {render :text => "Live from the block"}
              format.js { render :update do |page|
                  page << "alert('JS from the block')"
                end
              }
            end
          end
        end
        @controller = FilterResourcesUnavailableWithBlockTestController.new
        ActionController::Routing::Routes.draw {|map|
          map.connect "/:action", :controller => @controller.controller_path
          map.connect "/:action/:id", :controller => @controller.controller_path
        }
        FilterResourcesUnavailableWithBlockTestController.view_paths = ['...']

        FilterResourcesUnavailableWithBlockTestController.controller_name = "resources"
      end #setup
      context "accepts html" do
        context "with basic resource" do
          context "without conflict" do
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
              context "With resource available" do
                should "not redirect" do
                  get :action1, :id => 3
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
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

          end # context with conflict
        end # context with basic resource
      end #accepts html
      context "accepts js" do
        context "with basic resource" do
          context "without conflict" do
            context "without resource parameter" do
              should "raise argument error" do
                assert_raise(ArgumentError) do
                  get :action1, :format => "js"
                end
              end
            end
            context "with resource parameter" do
              context "With resource available" do
                should "not redirect" do
                  get :action1, :id => 3, :format => "js"
                  assert_response :success
                end
              end
            end
          end

          context "with conflict" do
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

          end # context with conflict
        end # context with basic resource
      end #accepts js
    end #with block
  end #context filter resource conflicts
end