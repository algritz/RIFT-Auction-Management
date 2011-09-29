class ItemsController < ApplicationController
  before_filter :authenticate_admin
  caches_action :index, :layout => false
  caches_action :show, :layout => false
  
  # GET /items
  # GET /items.xml
  def index

    if params[:search] != nil then
      expire_action :action => :index
      @items = Item.search(params[:search], params[:page])
    else
      @items = Item.paginate(:page => params[:page], :conditions => ["rarity <>  ?", "Trash"], :select => "id, description, vendor_selling_price, vendor_buying_price, source_id, itemkey", :order => "description")
    end


    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, description, vendor_selling_price, vendor_buying_price, source_id, item_level, is_crafted, to_list, note")

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new
    @source = Source.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, description, vendor_selling_price, vendor_buying_price, source_id, item_level, is_crafted, to_list, note")
    @source = Source.find(:all, :select => "id, description", :order => "description")
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])
    @source = Source.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      if @item.save
        expire_action :action => :index
        format.html { redirect_to(@item, :notice => 'Item was successfully created.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, description, vendor_selling_price, vendor_buying_price, source_id, item_level, is_crafted, to_list, note")
    @source = Source.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      if @item.update_attributes(params[:item])
        expire_action :action => :index
        format.html { redirect_to(@item, :notice => 'Item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, description, vendor_selling_price, vendor_buying_price, source_id, item_level, is_crafted, to_list, note")
    @item.destroy
    expire_action :action => :index
    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end

## start of private block ##

## end of private block

end
