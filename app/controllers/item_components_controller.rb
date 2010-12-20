class ItemComponentsController < ApplicationController
  def destroy
    @component = ItemComponent.find(params[:id])
    @component.destroy
    
    if request.xhr?
      render :json => {:updated => 'success'}
    else
      respond_to do |format|
        format.html { redirect_to items_url }
        format.xml  { head :ok }
      end
    end
  end
end
