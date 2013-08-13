require File.dirname(__FILE__) + '/../test_helper'
require 'watermark_cache_targets_controller'

# Re-raise errors caught by the controller.
class WatermarkCacheTargetsController; def rescue_action(e) raise e end; end

class WatermarkCacheTargetsControllerTest < Test::Unit::TestCase
  fixtures :watermark_cache_targets

  def setup
    @controller = WatermarkCacheTargetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:watermark_cache_targets)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:watermark_cache_target)
    assert assigns(:watermark_cache_target).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:watermark_cache_target)
  end

  def test_create
    num_watermark_cache_targets = WatermarkCacheTarget.count

    post :create, :watermark_cache_target => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_watermark_cache_targets + 1, WatermarkCacheTarget.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:watermark_cache_target)
    assert assigns(:watermark_cache_target).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil WatermarkCacheTarget.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      WatermarkCacheTarget.find(1)
    }
  end
end
