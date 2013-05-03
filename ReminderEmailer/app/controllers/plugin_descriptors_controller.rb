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

  def edit
    @plugin = PluginDescriptor.find params[:id]
  end

  def update
    @movie = PluginDescriptor.find params[:id]
    @movie.update_attributes!(params[:plugin])
    redirect_to plugin_descriptors_path
  end

  def destroy
    @movie = PluginDescriptor.find params[:id]
    @movie.destroy
    redirect_to plugin_descriptors_path
  end
end