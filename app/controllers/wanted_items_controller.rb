class WantedItemsController < ApplicationController
  before_filter :authenticate
  # GET /wanted_items
  # GET /wanted_items.xml
  def index
    toon_list = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]], :select => "id")
    @wanted_items = WantedItem.find(:all, :conditions => ["is_public = ? or toon_id in (?)", true, toon_list])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @wanted_items }
    end
  end

  # GET /wanted_items/1
  # GET /wanted_items/1.xml
  def show
    @wanted_item = WantedItem.find(params[:id])
    @toons = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    respond_to do |format|
      if Toon.find(:all, :conditions => ["id = ?", @wanted_item.toon_id]).first.user_id == current_user[:id] then
        format.html # show.html.erb
        format.xml  { render :xml => @wanted_item }
      else
        format.html { redirect_to(signin_path, :notice => 'You can only view your own wanted items') }
      end
    end
  end

  # GET /wanted_items/new
  # GET /wanted_items/new.xml
  def new
    @wanted_item = WantedItem.new
    @items = Item.find(:all, :select => 'id, description', :order => 'description', :conditions => ["isaugmented = ? and soulboundtrigger not in (?, ?) and rarity <> ? and source_id <> ?", false, "BindOnPickup", "BindOnEquip", "Trash", 10])
    @toons = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @wanted_item }
    end
  end

  # GET /wanted_items/1/edit
  def edit
    @wanted_item = WantedItem.find(params[:id])
    @items = Item.find(:all, :select => 'id, description', :order => 'description', :conditions => ["isaugmented = ? and soulboundtrigger not in (?, ?) and rarity <> ? and source_id <> ?", false, "BindOnPickup", "BindOnEquip", "Trash", 10])
    @toons = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    respond_to do |format|
      if Toon.find(:all, :conditions => ["id = ?", @wanted_item.toon_id]).first.user_id == current_user[:id] then
        format.html # show.html.erb
        format.xml  { render :xml => @wanted_item }
      else
        format.html { redirect_to(signin_path, :notice => 'You can only edit your own wanted items') }
      end
    end
  end

  # POST /wanted_items
  # POST /wanted_items.xml
  def create
    @wanted_item = WantedItem.new(params[:wanted_item])
    @items = Item.find(:all, :select => 'id, description', :order => 'description', :conditions => ["isaugmented = ? and soulboundtrigger not in (?, ?) and rarity <> ? and source_id <> ?", false, "BindOnPickup", "BindOnEquip", "Trash", 10])
    @toons = Toon.find(:all, :conditions => ["user_id = ?", current_user[:id]])
    respond_to do |format|
      if @wanted_item.save
        format.html { redirect_to(@wanted_item, :notice => 'Wanted item was successfully created.') }
        format.xml  { render :xml => @wanted_item, :status => :created, :location => @wanted_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @wanted_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /wanted_items/1
  # PUT /wanted_items/1.xml
  def update
    @wanted_item = WantedItem.find(params[:id])

    respond_to do |format|
      if @wanted_item.update_attributes(params[:wanted_item])
        format.html { redirect_to(@wanted_item, :notice => 'Wanted item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @wanted_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /wanted_items/1
  # DELETE /wanted_items/1.xml
  def destroy
    @wanted_item = WantedItem.find(params[:id])

    respond_to do |format|
      if Toon.find(:all, :conditions => ["id = ?", @wanted_item.toon_id]).first.user_id == current_user[:id] then
        @wanted_item.destroy
        format.html { redirect_to(wanted_items_url) }
        format.xml  { head :ok }
      else
        format.html { redirect_to(signin_path, :notice => 'you can only delete your own wanted items') }
        format.xml  { head :ok }
      end
    end
  end
end
