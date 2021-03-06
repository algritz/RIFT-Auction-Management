class CraftedItemsController < ApplicationController
  before_filter :authenticate_admin
  
  
  # GET /crafted_items
  # GET /crafted_items.xml
  def index
    if params[:search] == nil then
      @crafted_items = CraftedItem.all_cached_crafted_item.paginate(:page => params[:page])
    else
      @crafted_items = CraftedItem.search(params[:search], params[:page])
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @crafted_items }
    end
  end

  # GET /crafted_items/1
  # GET /crafted_items/1.xml
  def show
    @crafted_item = CraftedItem.cached_crafted_item(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @crafted_item }
    end
  end

  # GET /crafted_items/new
  # GET /crafted_items/new.xml
  def new
    @crafted_item = CraftedItem.new
    @craft_item_ids = Item.find(:all, :conditions => ["is_crafted = ?", true], :select => "id, description", :order => "description")
    @item_ids = Item.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @crafted_item }
    end
  end

  # GET /crafted_items/1/edit
  def edit
    @crafted_item = CraftedItem.cached_crafted_item(params[:id])
    @item_ids = Item.find(:all, :select => "id, description", :order => "description")
    @craft_item_ids = Item.find(:all, :conditions => ["is_crafted = ?", true], :select => "id, description", :order => "description")
  end

  # POST /crafted_items
  # POST /crafted_items.xml
  def create
    @crafted_item = CraftedItem.new(params[:crafted_item])
    @craft_item_ids = Item.find(:all, :conditions => ["is_crafted = ?", true], :select => "id, description", :order => "description")
    @item_ids = Item.find(:all, :select => "id, description", :order => "description")
    
    CraftedItem.clear_all_cached_crafted_item
    respond_to do |format|
      if @crafted_item.save
        
        format.html { redirect_to(@crafted_item, :notice => 'Crafted item was successfully created.') }
        format.xml  { render :xml => @crafted_item, :status => :created, :location => @crafted_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @crafted_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /crafted_items/1
  # PUT /crafted_items/1.xml
  def update
    @crafted_item = CraftedItem.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, crafted_item_generated_id, crafted_item_stacksize, component_item_id, component_item_quantity")
    CraftedItem.clear_cached_crafted_item(params[:id])
    CraftedItem.clear_cached_source_description_for_crafted_item(params[:id])
    CraftedItem.clear_cached_crafted_item_by_component_item_id(@crafted_item.crafted_item_generated_id)
    CraftedItem.clear_cached_crafted_item_count(@crafted_item.crafted_item_generated_id)
    CraftedItem.clear_all_cached_crafted_item
    
    respond_to do |format|
      if @crafted_item.update_attributes(params[:crafted_item])
        
        format.html { redirect_to(@crafted_item, :notice => 'Crafted item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @crafted_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /crafted_items/1
  # DELETE /crafted_items/1.xml
  def destroy
    @crafted_item = CraftedItem.cached_crafted_item(params[:id])
    CraftedItem.clear_cached_crafted_item(params[:id])
    CraftedItem.clear_all_cached_crafted_item
    CraftedItem.clear_cached_source_description_for_crafted_item(params[:id])
    CraftedItem.clear_cached_crafted_item_by_component_item_id(@crafted_item.crafted_item_generated_id)
    CraftedItem.clear_cached_crafted_item_count(@crafted_item.crafted_item_generated_id)
    @crafted_item.destroy
    
    respond_to do |format|
      format.html { redirect_to(crafted_items_url) }
      format.xml  { head :ok }
    end
  end
end
