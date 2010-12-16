class MatricesController < ApplicationController
  def index
  end

  def new
    @matrix = Matrix.new params[:matrix]
    if @matrix.valid?
      render :action => :edit
    else
      render :action => :index
    end
  end

  def edit
    @matrix = Matrix.find(params[:id])
  end

  def create
    @matrix= Matrix.new(params[:matrix])
    if @matrix.valid?
      @matrix.solve
    else
      render :action => :edit
    end
  end
end
