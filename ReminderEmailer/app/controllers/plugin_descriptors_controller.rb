class PluginDescriptorsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @plugins = PluginDescriptor.all
  end

  def show
    @plugin = PluginDescriptor.find params[:id]
  end

  def new
    
  end

  def create
    @plugin = PluginDescriptor.create!(params[:plugin])
    redirect_to plugin_descriptors_path
  end

  def update

  end

  def destroy

  end
end