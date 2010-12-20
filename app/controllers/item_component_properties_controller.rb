class ItemComponentPropertiesController < ApplicationController
  def destroy
    @association = ItemComponentProperty.find(params[:id])
    @item = @association.item
    @association.destroy
    
    if request.xhr?
      render :json => {:updated => 'success'}
    else
      respond_to do |format|
        format.html { redirect_to item_path(@item) }
        format.xml  { head :ok }
      end
    end
  end
end
