require File.dirname(__FILE__) + '/../test_helper'
require 'price_classes_controller'

# Re-raise errors caught by the controller.
class PriceClassesController; def rescue_action(e) raise e end; end

class PriceClassesControllerTest < Test::Unit::TestCase
  fixtures :price_classes

  def setup
    @controller = PriceClassesController.new
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

    assert_not_nil assigns(:price_classes)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:price_class)
    assert assigns(:price_class).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:price_class)
  end

  def test_create
    num_price_classes = PriceClass.count

    post :create, :price_class => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_price_classes + 1, PriceClass.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:price_class)
    assert assigns(:price_class).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil PriceClass.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      PriceClass.find(1)
    }
  end
end
