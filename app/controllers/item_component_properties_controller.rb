class ItemComponentPropertiesController < ApplicationController
  def destroy
    @association = ItemComponentProperty.find(params[:id])
    @item_component = @association.item_component
    @association.destroy
    
    if request.xhr?
      render :json => {:updated => 'success'}
    else
      respond_to do |format|
        format.html { redirect_to item_component_path(@item_component) }
        format.xml  { head :ok }
      end
    end
  end
end
