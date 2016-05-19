module ModelViewRoute
  class Base < ::ActionController::Base
    include ModelViewRoute::Concerns::CRUD

    before_action :initalize_instance_variable,
      only: [:index, :show, :new, :create, :edit, :update, :destroy]
    before_action :modify_object,
      only: [:create, :update, :destroy]
    before_action :render_layout

    def index
    end

    def new
    end

    def show
    end

    def create
    end

    def edit
    end

    def update
    end

    def destroy
    end
  end
end
