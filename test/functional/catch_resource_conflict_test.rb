require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class ConflictWarningsBasicTest < ActionController::TestCase
  #  class StubController < ActionController::Base
  #     ConflictWarningsTest::ControllerBits
  #  end
  #  #fixtures :resources, :resources, :resources_with_custom_accessors,
  #  :resources_with_custom_accessors, :Resources_with_updated_ats
  context "catch resource conflicts" do
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
          class CatchResourceConflictWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
          
            catch_resource_conflicts
            #cattr_accessor :controller_name
          end
          @controller = CatchResourceConflictWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchResourceConflictWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            CatchResourceConflictWithoutOptionsTestController.controller_name = "resources"
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
                  CatchResourceConflictWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = CatchResourceConflictWithoutOptionsTestController.new
                  get :action1, :id => 2
                  assert_response 409
                  assert_template("action1_resource_unavailable")
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with conflict
        end # context with basic resource

        context "with custom accessible resource" do
          setup do
            CatchResourceConflictWithoutOptionsTestController.controller_name = "resource_with_custom_accessors"
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
                  CatchResourceConflictWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, :id => 2
                  assert_response 409
                end
              end
            end
          end
        end # context with custom accessro resource        
      end #accepts html
      context "accepts js" do
        setup do
          class CatchResourceConflictWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            catch_resource_conflicts
            #cattr_accessor :controller_name
          end
          @controller = CatchResourceConflictWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }          
          CatchResourceConflictWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            CatchResourceConflictWithoutOptionsJSTestController.controller_name = "resources"
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
                  CatchResourceConflictWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = CatchResourceConflictWithoutOptionsJSTestController.new
                  get :action1, :id => 2,  :format => "js"
                  assert_response 409
                  assert_template("action1_resource_unavailable.rjs")
                end # should not redirect and render default template
              end # context with template
            end # context with resource unavailable

          end # context with conflict
        end # context with basic resource

      end #accepts js
    end # context without options
    context "using options" do
      context "filter options" do
        context "with only" do
          setup do
            class CatchResourceConflictWithOnlyTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :only => :action1
            end
            CatchResourceConflictWithOnlyTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithOnlyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithOnlyTestsController.controller_name = "resources"
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
            class CatchResourceConflictWithExceptTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :except => :action2
            end
            CatchResourceConflictWithExceptTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithExceptTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithExceptTestsController.controller_name = "resources"
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
            class CatchResourceConflictWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :flash_key => :error
            end
            CatchResourceConflictWithFlashKeyTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithFlashKeyTestsController.controller_name = "resources"
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
            class CatchResourceConflictWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :flash_key => :error, :message => "CONFLICT!"
            end
            CatchResourceConflictWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithFlashKeyAndMessageTestsController.controller_name = "resources"
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
            class CatchResourceConflictWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :message => "CONFLICT!"
            end
            CatchResourceConflictWithMessageTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithMessageTestsController.controller_name = "resources"
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
              class CatchResourceConflictWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                catch_resource_conflicts :message => "CONFLICT"
              end
              @controller = CatchResourceConflictWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              CatchResourceConflictWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic resource" do
              setup do
                CatchResourceConflictWithMessageJSTestController.controller_name = "resources"
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
                      CatchResourceConflictWithMessageJSTestController.append_view_path TestViewPath
                      @controller = CatchResourceConflictWithMessageJSTestController.new
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
          class CatchResourceConflictWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            catch_resource_conflicts :model => ResourceWithCustomAccessor
          end
          CatchResourceConflictWithModelTestsController.view_paths = ['...']
          @controller = CatchResourceConflictWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic resource" do
          setup do
            CatchResourceConflictWithModelTestsController.controller_name = "resources"
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
          context "without id" do
            setup do
              class CatchResourceConflictWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                catch_resource_conflicts :model => ResourceWithCustomAccessor, :accessor => :resources_left
              end
              CatchResourceConflictWithModelAndAccessorTestsController.view_paths = ['...']
              @controller = CatchResourceConflictWithModelAndAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourceConflictWithModelAndAccessorTestsController.controller_name = "resources"
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
          end #context without id
          context "with id" do
            setup do
              class CatchResourceConflictWithModelAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                catch_resource_conflicts :model => ResourceWithCustomAccessor, :id => 2, :accessor=> :resources_left
              end
              CatchResourceConflictWithModelAccessorAndIdTestsController.view_paths = ['...']
              @controller = CatchResourceConflictWithModelAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourceConflictWithModelAccessorAndIdTestsController.controller_name = "resources"
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

          end #with id
        end # with accessor

        context "with id" do
          setup do
            class CatchResourceConflictWithModelAndIdTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :model => Resource, :id => 2
            end
            CatchResourceConflictWithModelAndIdTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithModelAndIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithModelAndIdTestsController.controller_name = "resource_with_custom_accessors"
            end
            context "without conflict" do
              context "without resource parameter" do
                should "not redirect" do

                  get :action1, :id => 3
                  assert_redirected_to "/"
                end
                context "with resource parameter" do
                  should "redirect" do

                    get :action1, :id => 1
                    assert_redirected_to "/"
                  end
                end
              end
            end #without conflict
            context "with conflict" do
              context "with resource unavailable" do
                should "without resource parameter should not redirect" do
                  get :action1, :id => 3
                  assert_redirected_to "/"
                end
                should "with resource should redirect" do

                  get :action1, :id => 2
                  assert_redirected_to "/"
                end

              end # context with resource unavailable

            end # context with conflict
          end # context with basic resource

        end #with id
        context "with params id key" do
          setup do
            class CatchResourceConflictWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :model => ResourceWithCustomAccessor, :params_id_key => :name
            end
            CatchResourceConflictWithModelAndParamsIdKeyTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithModelAndParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithModelAndParamsIdKeyTestsController.controller_name = "resources"
            end
            context "with conflict" do
              context "with resource unavailable" do
                context "without accessor" do
                  should "redirect" do
                    get :action1, :id => 1, :name => 3
                    assert_redirected_to "/"
                  end
                end
              end
              

            

            end # context with conflict
          end # context with basic resource
          context "with accessor" do
            context "without id" do
              setup do
                class CatchResourceConflictWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_resource_conflicts :model => ResourceWithCustomAccessor,
                    :accessor => :resources_left, :params_id_key => :name
                end
                CatchResourceConflictWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourceConflictWithModelAndParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourceConflictWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "resources"
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
                  class CatchResourceConflictWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :model => ResourceWithCustomAccessor,
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
                  class CatchResourceConflictWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :model => Resource, :id => 2, :params_id_key => :name
                  end
                end
              end
            end #with id
          end #without accessor
        end
        context "with find options" do
          setup do
            class CatchResourceConflictWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :model => ResourceWithCustomAccessor, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
            end
            CatchResourceConflictWithModelAndFindOptionsTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithModelAndFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithModelAndFindOptionsTestsController.controller_name = "resources"
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
                class CatchResourceConflictWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_resource_conflicts :model => ResourceWithCustomAccessor,
                    :accessor => :resources_left, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                end
                CatchResourceConflictWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourceConflictWithModelAndFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourceConflictWithModelAndFindOptionsAndAccessorTestsController.controller_name = "resources"
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
                assert_raise(ArgumentError) do class CatchResourceConflictWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :model => ResourceWithCustomAccessor,
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
                  class CatchResourceConflictWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :model => Resource, :id => 2,
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
                  class CatchResourceConflictWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :model => ResourceWithCustomAccessor,
                      :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
            context "with accessor" do
              context "without id" do
                should "raise ArgumentError"do
                  assert_raise(ArgumentError) do
                    class CatchResourceConflictWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_resource_conflicts :model => ResourceWithCustomAccessor,
                        :accessor => :resource_left, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #context without id
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class CatchResourceConflictWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_resource_conflicts :model => ResourceWithCustomAccessor,
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
                    class CatchResourceConflictWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_resource_conflicts :model => Resource, :id => 2, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end

              end #with id
            end  #without accessor
          end #with params id key
        end # with find options
        context "with model as active record object" do
          setup do
            class CatchResourceConflictWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :model => Resource.last
            end
            CatchResourceConflictWithModelARObjectTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithModelARObjectTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithModelARObjectTestsController.controller_name = "resource_with_custom_accessors"
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
          end # context with basic resource
        end # model as activeRecord object
        context "with model as symbol" do
          setup do
            class CatchResourceConflictWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :model => :resource
            end
            CatchResourceConflictWithModelSymbolTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithModelSymbolTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithModelSymbolTestsController.controller_name = "resource_with_custom_accessors"
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
          end # context with basic resource
        end # model as symbol
        context "with model as string" do
          setup do
            class CatchResourceConflictWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts :model => "resource"
            end
            CatchResourceConflictWithModelStringTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithModelStringTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithModelStringTestsController.controller_name = "resource_with_custom_accessors"
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
          end # context with basic resource
        end # model as string

      end # with model

      context "instance selectors without model" do
        context "with accessor" do
          context "without id" do
            setup do
              class CatchResourceConflictWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                catch_resource_conflicts  :accessor => :resources_left
              end
              CatchResourceConflictWithAccessorTestsController.view_paths = ['...']
              @controller = CatchResourceConflictWithAccessorTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourceConflictWithAccessorTestsController.controller_name = "resource_with_custom_accessors"
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
            setup do
              class CatchResourceConflictWithAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                catch_resource_conflicts  :id => 2, :accessor=> :resources_left
              end
              CatchResourceConflictWithAccessorAndIdTestsController.view_paths = ['...']
              @controller = CatchResourceConflictWithAccessorAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic resource" do
              setup do
                CatchResourceConflictWithAccessorAndIdTestsController.controller_name = "resource_with_custom_accessors"
              end
              context "without conflict" do
                should "redirect" do
                  get :action1, :id => 3
                  assert_redirected_to "/"
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

          end #with id
        end # with accessor

        context "with id" do
          setup do
            class CatchResourceConflictWithIdTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts  :id => 2
            end
            CatchResourceConflictWithIdTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithIdTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithIdTestsController.controller_name = "resource"
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

        end #with id
        context "with params id key" do
          setup do
            class CatchResourceConflictWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts  :params_id_key => :name
            end
            CatchResourceConflictWithParamsIdKeyTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithParamsIdKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithParamsIdKeyTestsController.controller_name = "resources"
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
                class CatchResourceConflictWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_resource_conflicts :accessor => :resources_left, :params_id_key => :name
                end
                CatchResourceConflictWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourceConflictWithParamsIdKeyAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourceConflictWithParamsIdKeyAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
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
                  class CatchResourceConflictWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :id => 2, :accessor=> :resource, :params_id_key => :name
                  end
                end
              end
            end #with id
          end # with accessor
          context "without accessor" do
            context "with id" do
              should "raise error" do
                assert_raise(ArgumentError) do
                  class CatchResourceConflictWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts  :id => 2, :params_id_key => :name
                  end
                end
              end
            end #with id
          end #without accessor
        end
        context "with find options" do
          setup do
            class CatchResourceConflictWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
              catch_resource_conflicts  :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
            end
            CatchResourceConflictWithFindOptionsTestsController.view_paths = ['...']
            @controller = CatchResourceConflictWithFindOptionsTestsController.new

            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic resource" do
            setup do
              CatchResourceConflictWithFindOptionsTestsController.controller_name = "resources"
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
                class CatchResourceConflictWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_resource_conflicts :accessor => :resources_left,
                    :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                end
                CatchResourceConflictWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                @controller = CatchResourceConflictWithFindOptionsAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic resource" do
                setup do
                  CatchResourceConflictWithFindOptionsAndAccessorTestsController.controller_name = "resource_with_custom_accessors"
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
                  class CatchResourceConflictWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :id => 2, :accessor=> :resource,
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
                  class CatchResourceConflictWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts  :id => 2,
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
                  class CatchResourceConflictWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_resource_conflicts :params_id_key => :name,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                end
              end
            end # without accessor
            context "with accessor" do
              context "without id" do
                should "raise ArgumentError"do
                  assert_raise(ArgumentError) do
                    class CatchResourceConflictWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_resource_conflicts  :accessor => :resource_left, :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end #context without id
              context "with id" do
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class CatchResourceConflictWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_resource_conflicts :id => 2, :accessor=> :resource, :params_id_key => :name,
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
                    class CatchResourceConflictWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_resource_conflicts  :id => 2, :params_id_key => :name,
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
                class CatchResourceConflictBadFindOptinsTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_resource_conflicts :find_options => {:conditions => {:name => "Test value"}}
                end
              end
            end
          end
        end # with find options

      end # instance selectors without model
            
      context "template" do
        setup do
          class CatchResourceConflictWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            catch_resource_conflicts :template => "custom/custom"
            #cattr_accessor :controller_name
          end
          @controller = CatchResourceConflictWithTemplateTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchResourceConflictWithTemplateTestController.view_paths = ['...']
        end
        context "with basic resource" do
          setup do
            CatchResourceConflictWithTemplateTestController.controller_name = "resources"
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
                  CatchResourceConflictWithTemplateTestController.append_view_path TestViewPath
                  @controller = CatchResourceConflictWithTemplateTestController.new
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
        class CatchResourceConflictWithBlockTestController < ::ConflictWarningsTest::ControllerStub
          catch_resource_conflicts do
            respond_to do |format|
              format.html {render :text => "Live from the block"}
              format.js { render :update do |page|
                  page << "alert('JS from the block')"
                end
              }
            end
          end
        end
        @controller = CatchResourceConflictWithBlockTestController.new
        ActionController::Routing::Routes.draw {|map|
          map.connect "/:action", :controller => @controller.controller_path
          map.connect "/:action/:id", :controller => @controller.controller_path
        }
        CatchResourceConflictWithBlockTestController.view_paths = ['...']

        CatchResourceConflictWithBlockTestController.controller_name = "resources"
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

  end #context catch resource conflicts
end