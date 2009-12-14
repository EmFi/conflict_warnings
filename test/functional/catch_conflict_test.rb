require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../functional_test_helper')

class CatchConflictWarningsBasicTest < ActionController::TestCase
  #  class StubController < ActionController::Base
  #     ConflictWarningsTest::ControllerBits
  #  end
  #  #fixtures :timestamps, :resources, :resources_with_custom_accessors,
  #  :timestamps_with_custom_accessors, :timestamps_with_updated_ats
  context "catch conflicts" do
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
          class CatchConflictWithoutOptionsTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits
          
            catch_conflicts
            #cattr_accessor :controller_name
          end
          @controller = CatchConflictWithoutOptionsTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchConflictWithoutOptionsTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            CatchConflictWithoutOptionsTestController.controller_name = "timestamps"
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
                  CatchConflictWithoutOptionsTestController.append_view_path TestViewPath
                  @controller = CatchConflictWithoutOptionsTestController.new
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
            CatchConflictWithoutOptionsTestController.controller_name = "timestamp_with_custom_accessors"
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
                  CatchConflictWithoutOptionsTestController.append_view_path TestViewPath
                  get :action1, {:id => 2, :page_rendered_at =>Time.now.to_i}
                  assert_response :success
                end
              end
            end
          end
        end # context with custom accessro timestamp
        context "with updated_at timestamp" do
          setup do
            CatchConflictWithoutOptionsTestController.controller_name = "timestamp_with_updated_ats"
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
                  CatchConflictWithoutOptionsTestController.append_view_path TestViewPath
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
          class CatchConflictWithoutOptionsJSTestController < ::ConflictWarningsTest::ControllerStub
            #include ::ConflictWarningsTest::ControllerBits

            catch_conflicts
            #cattr_accessor :controller_name
          end
          @controller = CatchConflictWithoutOptionsJSTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }          
          CatchConflictWithoutOptionsJSTestController.view_paths = ['...']
        end
        context "with basic timestamp" do
          setup do
            CatchConflictWithoutOptionsJSTestController.controller_name = "timestamps"
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
                  CatchConflictWithoutOptionsJSTestController.append_view_path TestViewPath
                  @controller = CatchConflictWithoutOptionsJSTestController.new
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
      context "filter options" do
        context "with only" do
          setup do
            class CatchConflictWithOnlyTestsController < ::ConflictWarningsTest::ControllerStub
              catch_conflicts :only => :action1
            end
            CatchConflictWithOnlyTestsController.view_paths = ['...']
            @controller = CatchConflictWithOnlyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictWithOnlyTestsController.controller_name = "timestamps"
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
            class CatchConflictWithExceptTestsController < ::ConflictWarningsTest::ControllerStub
              catch_conflicts :except => :action2
            end
            CatchConflictWithExceptTestsController.view_paths = ['...']
            @controller = CatchConflictWithExceptTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictWithExceptTestsController.controller_name = "timestamps"
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
                context "on excepted action" do
                  context "without timestamp parameter" do
                    should "not redirect" do
                      get :action1, :id => 2
                      assert_response :success
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
            class CatchConflictWithFlashKeyTestsController < ::ConflictWarningsTest::ControllerStub
              catch_conflicts :flash_key => :error
            end
            CatchConflictWithFlashKeyTestsController.view_paths = ['...']
            @controller = CatchConflictWithFlashKeyTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictWithFlashKeyTestsController.controller_name = "timestamps"
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
            class CatchConflictWithFlashKeyAndMessageTestsController < ::ConflictWarningsTest::ControllerStub
              catch_conflicts :flash_key => :error, :message => "CONFLICT!"
            end
            CatchConflictWithFlashKeyAndMessageTestsController.view_paths = ['...']
            @controller = CatchConflictWithFlashKeyAndMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictWithFlashKeyAndMessageTestsController.controller_name = "timestamps"
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
            class CatchConflictWithMessageTestsController < ::ConflictWarningsTest::ControllerStub
              catch_conflicts :message => "CONFLICT!"
            end
            CatchConflictWithMessageTestsController.view_paths = ['...']
            @controller = CatchConflictWithMessageTestsController.new


            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }

          end
          context "with basic timestamp" do
            setup do
              CatchConflictWithMessageTestsController.controller_name = "timestamps"
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
              class CatchConflictWithMessageJSTestController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :message => "CONFLICT"
              end
              @controller = CatchConflictWithMessageJSTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              CatchConflictWithMessageJSTestController.view_paths = ['...']
            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithMessageJSTestController.controller_name = "timestamps"
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
                      CatchConflictWithMessageJSTestController.append_view_path TestViewPath
                      @controller = CatchConflictWithMessageJSTestController.new
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
          class CatchConflictWithModelTestsController < ::ConflictWarningsTest::ControllerStub
            catch_conflicts :model => TimestampWithCustomAccessor
          end
          CatchConflictWithModelTestsController.view_paths = ['...']
          @controller = CatchConflictWithModelTestsController.new

          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }

        end
        context "with basic timestamp" do
          setup do
            CatchConflictWithModelTestsController.controller_name = "timestamps"
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
              class CatchConflictWithModelAndBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :model => Timestamp, :accessor => :bogus
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
                class CatchConflictWithModelAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts :model => TimestampWithCustomAccessor, :accessor => :timestamp
                end
                CatchConflictWithModelAndAccessorTestsController.view_paths = ['...']
                @controller = CatchConflictWithModelAndAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictWithModelAndAccessorTestsController.controller_name = "timestamps"
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
                class CatchConflictWithModelAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts :model => TimestampWithCustomAccessor, :id => 2, :accessor=> :timestamp
                end
                CatchConflictWithModelAccessorAndIdTestsController.view_paths = ['...']
                @controller = CatchConflictWithModelAccessorAndIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictWithModelAccessorAndIdTestsController.controller_name = "timestamps"
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
              class CatchConflictWithModelAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :model => Timestamp, :id => 2
              end
              CatchConflictWithModelAndIdTestsController.view_paths = ['...']
              @controller = CatchConflictWithModelAndIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithModelAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
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
              class CatchConflictWithModelAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :model => TimestampWithCustomAccessor, :params_id_key => :name
              end
              CatchConflictWithModelAndParamsIdKeyTestsController.view_paths = ['...']
              @controller = CatchConflictWithModelAndParamsIdKeyTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithModelAndParamsIdKeyTestsController.controller_name = "timestamps"
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
                  class CatchConflictWithModelAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_conflicts :model => TimestampWithCustomAccessor,
                      :accessor => :timestamp, :params_id_key => :name
                  end
                  CatchConflictWithModelAndParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                  @controller = CatchConflictWithModelAndParamsIdKeyAndAccessorTestsController.new


                  ActionController::Routing::Routes.draw {|map|
                    map.connect "/:action", :controller => @controller.controller_path
                    map.connect "/:action/:id", :controller => @controller.controller_path
                  }

                end
                context "with basic timestamp" do
                  setup do
                    CatchConflictWithModelAndParamsIdKeyAndAccessorTestsController.controller_name = "timestamps"
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
                should "raise error" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithModelAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :model => TimestampWithCustomAccessor,
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
                    class CatchConflictWithModelAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :model => Timestamp, :id => 2, :params_id_key => :name
                    end
                  end
                end
              end #with id
            end #without accessor
          end
          context "with find options" do
            setup do
              class CatchConflictWithModelAndFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :model => TimestampWithCustomAccessor,
                  :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
              end
              CatchConflictWithModelAndFindOptionsTestsController.view_paths = ['...']
              @controller = CatchConflictWithModelAndFindOptionsTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithModelAndFindOptionsTestsController.controller_name = "timestamps"
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
                  class CatchConflictWithModelAndFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_conflicts :model => TimestampWithCustomAccessor,
                      :accessor => :timestamp, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                  CatchConflictWithModelAndFindOptionsAndAccessorTestsController.view_paths = ['...']
                  @controller = CatchConflictWithModelAndFindOptionsAndAccessorTestsController.new


                  ActionController::Routing::Routes.draw {|map|
                    map.connect "/:action", :controller => @controller.controller_path
                    map.connect "/:action/:id", :controller => @controller.controller_path
                  }

                end
                context "with basic timestamp" do
                  setup do
                    CatchConflictWithModelAndFindOptionsAndAccessorTestsController.controller_name = "timestamps"
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
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do class CatchConflictWithModelAndFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :model => TimestampWithCustomAccessor,
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
                    class CatchConflictWithModelAndFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :model => Timestamp, :id => 2,
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
                    class CatchConflictWithModelAndFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :model => TimestampWithCustomAccessor,
                        :params_id_key => :name, :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end # without accessor
              context "with accessor" do
                context "without id" do
                  should "raise ArgumentError"do
                    assert_raise(ArgumentError) do
                      class CatchConflictWithModelAndFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                        catch_conflicts :model => TimestampWithCustomAccessor,
                          :accessor => :timestamp, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                      end
                    end
                  end
                end #context without id
                context "with id" do
                  should "raise ArgumentError" do
                    assert_raise(ArgumentError) do
                      class CatchConflictWithModelAndFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                        catch_conflicts :model => TimestampWithCustomAccessor,
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
                      class CatchConflictWithModelAndFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                        catch_conflicts :model => Timestamp, :id => 2, :params_id_key => :name,
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
                class CatchConflictWithModelARObjectTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts :model => Timestamp.first
                end
                CatchConflictWithModelARObjectTestsController.view_paths = ['...']
                @controller = CatchConflictWithModelARObjectTestsController.new

                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictWithModelARObjectTestsController.controller_name = "timestamps"
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
                class CatchConflictWithModelARObjectInPastTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts :model => Timestamp.find(3)
                end
                CatchConflictWithModelARObjectInPastTestsController.view_paths = ['...']
                @controller = CatchConflictWithModelARObjectInPastTestsController.new

                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictWithModelARObjectInPastTestsController.controller_name = "timestamps"
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
                class CatchConflictWithModelARObjectInFutureTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts :model => Timestamp.find(2)
                end
                CatchConflictWithModelARObjectInFutureTestsController.view_paths = ['...']
                @controller = CatchConflictWithModelARObjectInFutureTestsController.new

                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictWithModelARObjectInFutureTestsController.controller_name = "timestamps"
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
              class CatchConflictWithModelSymbolTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :model => :timestamp
              end
              CatchConflictWithModelSymbolTestsController.view_paths = ['...']
              @controller = CatchConflictWithModelSymbolTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithModelSymbolTestsController.controller_name = "timestamp_with_custom_accessors"
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
              class CatchConflictWithModelStringTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :model => "timestamp"
              end
              CatchConflictWithModelStringTestsController.view_paths = ['...']
              @controller = CatchConflictWithModelStringTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithModelStringTestsController.controller_name = "timestamp_with_custom_accessors"
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
              class CatchConflictWithBogusAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :accessor => :bogus
              end
              CatchConflictWithBogusAccessorTestsController.controller_name = "timestamps"
              should "raise no method error" do
                assert_raise(NoMethodError) do
                  get :action1, :id => 3
                end
              end
            end
          end #bogus accessor
            context "without id" do
              setup do
                class CatchConflictWithAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts  :accessor => :timestamp
                end
                CatchConflictWithAccessorTestsController.view_paths = ['...']
                @controller = CatchConflictWithAccessorTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictWithAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
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
                class CatchConflictWithAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts  :id => 2, :accessor=> :timestamp
                end
                CatchConflictWithAccessorAndIdTestsController.view_paths = ['...']
                @controller = CatchConflictWithAccessorAndIdTestsController.new


                ActionController::Routing::Routes.draw {|map|
                  map.connect "/:action", :controller => @controller.controller_path
                  map.connect "/:action/:id", :controller => @controller.controller_path
                }

              end
              context "with basic timestamp" do
                setup do
                  CatchConflictWithAccessorAndIdTestsController.controller_name = "timestamp_with_custom_accessors"
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
              class CatchConflictWithIdTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts  :id => 2
              end
              CatchConflictWithIdTestsController.view_paths = ['...']
              @controller = CatchConflictWithIdTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithIdTestsController.controller_name = "timestamp"
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
              class CatchConflictWithParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts  :params_id_key => :name
              end
              CatchConflictWithParamsIdKeyTestsController.view_paths = ['...']
              @controller = CatchConflictWithParamsIdKeyTestsController.new


              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithParamsIdKeyTestsController.controller_name = "timestamps"
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
                  class CatchConflictWithParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_conflicts :accessor => :timestamp, :params_id_key => :name
                  end
                  CatchConflictWithParamsIdKeyAndAccessorTestsController.view_paths = ['...']
                  @controller = CatchConflictWithParamsIdKeyAndAccessorTestsController.new


                  ActionController::Routing::Routes.draw {|map|
                    map.connect "/:action", :controller => @controller.controller_path
                    map.connect "/:action/:id", :controller => @controller.controller_path
                  }

                end
                context "with basic timestamp" do
                  setup do
                    CatchConflictWithParamsIdKeyAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
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
                should "raise error" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :id => 2, :accessor=> :timestamp, :params_id_key => :name
                    end
                  end
                end
              end #with id
            end # with accessor
            context "without accessor" do
              context "with id" do
                should "raise error" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts  :id => 2, :params_id_key => :name
                    end
                  end
                end
              end #with id
            end #without accessor
          end
          context "with find options" do
            setup do
              class CatchConflictWithFindOptionsTestsController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts  :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
              end
              CatchConflictWithFindOptionsTestsController.view_paths = ['...']
              @controller = CatchConflictWithFindOptionsTestsController.new

              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }

            end
            context "with basic timestamp" do
              setup do
                CatchConflictWithFindOptionsTestsController.controller_name = "timestamps"
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
                  class CatchConflictWithFindOptionsAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_conflicts :accessor => :timestamp,
                      :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                  end
                  CatchConflictWithFindOptionsAndAccessorTestsController.view_paths = ['...']
                  @controller = CatchConflictWithFindOptionsAndAccessorTestsController.new


                  ActionController::Routing::Routes.draw {|map|
                    map.connect "/:action", :controller => @controller.controller_path
                    map.connect "/:action/:id", :controller => @controller.controller_path
                  }

                end
                context "with basic timestamp" do
                  setup do
                    CatchConflictWithFindOptionsAndAccessorTestsController.controller_name = "timestamp_with_custom_accessors"
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
                should "raise ArgumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithFindOptionsAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :id => 2, :accessor=> :timestamp,
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
                    class CatchConflictWithFindOptionsAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts  :id => 2,
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
                    class CatchConflictWithFindOptionsAndParamsIdKeyTestsController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :params_id_key => :name,
                        :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                    end
                  end
                end
              end # without accessor
              context "with accessor" do
                context "without id" do
                  should "raise ArgumentError"do
                    assert_raise(ArgumentError) do
                      class CatchConflictWithFindOptionsAndParamsIdKeyAndAccessorTestsController < ::ConflictWarningsTest::ControllerStub
                        catch_conflicts  :accessor => :timestamp, :params_id_key => :name,
                          :find_options => Proc.new {{:conditions => {:name => params[:name]}}}
                      end
                    end
                  end
                end #context without id
                context "with id" do
                  should "raise ArgumentError" do
                    assert_raise(ArgumentError) do
                      class CatchConflictWithFindOptionsAndParamsIdKeyAccessorAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                        catch_conflicts :id => 2, :accessor=> :timestamp, :params_id_key => :name,
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
                      class CatchConflictWithFindOptionsAndParamsIdKeyAndIdTestsController < ::ConflictWarningsTest::ControllerStub
                        catch_conflicts  :id => 2, :params_id_key => :name,
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
                  class CatchConflictBadFindOptinsTestsController < ::ConflictWarningsTest::ControllerStub
                    catch_conflicts :find_options => {:conditions => {:name => "Test value"}}
                  end
                end
              end
            end
          end # with find options

        end # instance selectors without model
        context "simulation keys" do
          context "with simulate conflicts on requests before" do
            setup do
              class CatchConflictWithSimulateConflictsOnRequestsBeforeTestController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :simulate_conflict_on_requests_before => Time.now - 2.minutes
              end
              @controller = CatchConflictWithSimulateConflictsOnRequestsBeforeTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              CatchConflictWithSimulateConflictsOnRequestsBeforeTestController.view_paths = ['...']
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
              class CatchConflictWithSimulateConflictsOnRequestsAfterTestController < ::ConflictWarningsTest::ControllerStub
                catch_conflicts :simulate_conflict_on_requests_after => (Time.now + 5.minutes)
              end
              @controller = CatchConflictWithSimulateConflictsOnRequestsAfterTestController.new
              ActionController::Routing::Routes.draw {|map|
                map.connect "/:action", :controller => @controller.controller_path
                map.connect "/:action/:id", :controller => @controller.controller_path
              }
              CatchConflictWithSimulateConflictsOnRequestsAfterTestController.view_paths = ['...']
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
                class CatchConflictWithBothSimulateConflictKeysOneRangeTestController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts :simulate_conflict_on_requests_before => (Time.now + 5.minutes),
                    :simulate_conflict_on_requests_after => (Time.now - 5.minutes)
                end
                @controller = CatchConflictWithBothSimulateConflictKeysOneRangeTestController.new
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
                class CatchConflictWithBothSimulateConflictKeysTwoRangesTestController < ::ConflictWarningsTest::ControllerStub
                  catch_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                    :simulate_conflict_on_requests_after => (Time.now + 5.minutes)
                end
                @controller = CatchConflictWithBothSimulateConflictKeysTwoRangesTestController.new
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
                should "raise ArumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithSimulateBeforeAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                        :model => Timestamp
                    end
                  end
                end
              end #with model
              context "with params id key" do
                should "raise ArumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithSimulateBeforeAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                        :parmas_id_key => :something
                    end
                  end
                end
              end #with params_id_key
              context "with id" do
                should "raise ArumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithSimulateBeforeAndIdTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
                        :id => 5
                    end
                  end
                end
              end #with id
              context "with find options" do
                should "raise ArumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithSimulateBeforeAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_before => (Time.now - 5.minutes),
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
                    class CatchConflictWithSimulateAfterAndModelKeysTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                        :model => Timestamp
                    end
                  end
                end
              end #with model
              context "with params id key" do
                should "raise ArumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithSimulateAfterAndParamsIdKeyTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                        :parmas_id_key => :something
                    end
                  end
                end
              end #with params_id_key
              context "with id" do
                should "raise ArumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithSimulateAfterAndIdTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
                        :id => 5
                    end
                  end
                end
              end #with id
              context "with find options" do
                should "raise ArumentError" do
                  assert_raise(ArgumentError) do
                    class CatchConflictWithSimulateAfterAndFindOptionsTestController < ::ConflictWarningsTest::ControllerStub
                      catch_conflicts :simulate_conflict_on_requests_after => (Time.now - 5.minutes),
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
            class CatchConflictWithTimeStampKeyTestController < ::ConflictWarningsTest::ControllerStub
              catch_conflicts :timestamp_key => :timestamp
            end
            @controller = CatchConflictWithTimeStampKeyTestController.new
          end
          context "with basic timestamp" do
            setup do
              CatchConflictWithTimeStampKeyTestController.controller_name = "timestamps"
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
            class CatchConflictWithTemplateTestController < ::ConflictWarningsTest::ControllerStub
              #include ::ConflictWarningsTest::ControllerBits

              catch_conflicts :template => "custom/custom"
              #cattr_accessor :controller_name
            end
            @controller = CatchConflictWithTemplateTestController.new
            ActionController::Routing::Routes.draw {|map|
              map.connect "/:action", :controller => @controller.controller_path
              map.connect "/:action/:id", :controller => @controller.controller_path
            }
            CatchConflictWithTemplateTestController.view_paths = ['...']
          end
          context "with basic timestamp" do
            setup do
              CatchConflictWithTemplateTestController.controller_name = "timestamps"
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
                    CatchConflictWithTemplateTestController.append_view_path TestViewPath
                    @controller = CatchConflictWithTemplateTestController.new
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
          class CatchConflictWithBlockTestController < ::ConflictWarningsTest::ControllerStub
            catch_conflicts do
              respond_to do |format|
                format.html {render :text => "Live from the block"}
                format.js { render :update do |page|
                    page << "alert('JS from the block')"
                  end
                }
              end
            end
          end
          @controller = CatchConflictWithBlockTestController.new
          ActionController::Routing::Routes.draw {|map|
            map.connect "/:action", :controller => @controller.controller_path
            map.connect "/:action/:id", :controller => @controller.controller_path
          }
          CatchConflictWithBlockTestController.view_paths = ['...']

          CatchConflictWithBlockTestController.controller_name = "timestamps"
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