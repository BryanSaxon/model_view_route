module CRUDConcern extend ::ActiveSupport::Concern
  attr_reader :klass

  def initialize
    Rails.application.eager_load! if Rails.env.development?
    @klass = define_klass(self.class.name.gsub('Controller', '').singularize)
  end

  def render_layout
    render layout: layout
  end

  def initalize_instance_variable
    self.instance_variable_set(send("#{ivar_type}_name"), send("#{ivar_type}_value"))
  end

  def modify_object
    send("modify_object_#{action_name.to_sym}", object_value)
  end

  private

  def define_klass(klass)
    return klass if Object.const_defined?(klass)
    define_klass(klass.split('::').drop(1).join('::'))
  end

  def layout
    'application'
  end

  def ivar_type
    action_name == 'index' ? :collection : :object
  end

  def collection_name
    "@#{klass.gsub('::', '_').downcase.pluralize}"
  end

  def collection_value
    klass.constantize.all
  end

  def object_name
    "@#{klass.gsub('::', '_').downcase}"
  end

  def object_value
    params[:id] ? klass.constantize.find(params[:id]) : klass.constantize.new
  end

  def modify_object_create(object)
    object.assign_attributes(permitted_params)

    if object.save
      flash[:success] = success_message('created')
      redirect_to send("#{route_name}_path", object)
    else
      flash[:danger] = error_message(object, 'creating')
      render action: :new, layout: layout
    end
  end

  def modify_object_update(object)
    if object.update_attributes(permitted_params)
      flash[:success] = success_message('updated')
      redirect_to send("#{route_name}_path", object)
    else
      flash[:danger] = error_message(object, 'updating')
      render action: :edit, layout: layout
    end
  end

  def modify_object_destroy(object)
    if object.destroy
      flash[:success] = success_message('destroyed')
      redirect_to send("#{route_name.pluralize}_path")
    else
      flash[:danger] = error_message(object, 'destroying')
      render action: :show, layout: layout
    end
  end

  def route_name
    self.class.name.gsub('Controller', '').singularize.underscore.gsub('/', '_')
  end

  def success_message(action)
    "#{klass.titleize} #{action}."
  end

  def error_message(object, action)
    "Error #{action} #{klass.downcase}: #{errors(object)}"
  end

  def errors(object)
    object.errors.full_messages.join(', ')
  end

  def permitted_params
    params.require(klass.gsub('::', '_').downcase.to_sym).permit(modifiable_params)
  end

  def modifiable_params
    klass.constantize.new.attributes.keys.map(&:to_sym) - locked_params
  end

  def locked_params
    [:id, :created_at, :updated_at]
  end
end
