class PriceOverridesController < ApplicationController
  before_filter :authenticate

  
  
  # GET /price_overrides
  # GET /price_overrides.xml
  def index
    @price_overrides = PriceOverride.find(:all, :conditions => ["user_id = ?", @current_user.id], :select => "id, user_id, item_id, price_per")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @price_overrides }
    end
  end

  # GET /price_overrides/1
  # GET /price_overrides/1.xml
  def show
    @price_override = PriceOverride.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, item_id, user_id, price_per")

    respond_to do |format|
      if @price_override.user_id == @current_user.id  then
        format.html # show.html.erb
        format.xml  { render :xml => @price_override }
      else
        format.html { redirect_to(signin_path, :notice => 'You can only view your own price overrides')}
      end
    end
  end

  # GET /price_overrides/new
  # GET /price_overrides/new.xml
  def new
    @price_override = PriceOverride.new
    @items = Item.find(:all, :select => 'id, description', :order => 'description', :conditions => ["isaugmented = ? and soulboundtrigger <> ? and rarity <>  ?", false, "BindOnPickup", "Trash"])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @price_override }
    end
  end

  # GET /price_overrides/1/edit
  def edit
    @price_override = PriceOverride.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, item_id, user_id, price_per")
    @items = Item.find(:all, :select => "id, description", :order => "description")
    if @price_override.user_id != @current_user.id then
      redirect_to(signin_path, :notice => 'You can only edit your own price overrides')
    end
  end

  # POST /price_overrides
  # POST /price_overrides.xml
  def create
    @price_override = PriceOverride.new(params[:price_override])
    @items = Item.find(:all, :select => "id, description", :order => "description")
    respond_to do |format|
      if @price_override.save
        
        format.html { redirect_to(@price_override, :notice => 'Price override was successfully created.') }
        format.xml  { render :xml => @price_override, :status => :created, :location => @price_override }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @price_override.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /price_overrides/1
  # PUT /price_overrides/1.xml
  def update
    @price_override = PriceOverride.find(params[:id])
    PriceOverride.clear_cached_price_override_for_item_for_user(current_user[:id], @price_override.item_id)
    respond_to do |format|
      if @price_override.update_attributes(params[:price_override])
        
        format.html { redirect_to(@price_override, :notice => 'Price override was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @price_override.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /price_overrides/1
  # DELETE /price_overrides/1.xml
  def destroy
    @price_override = PriceOverride.find(:first, :conditions => ["id = ?", params[:id]], :select => "id, item_id, user_id, price_per")
    PriceOverride.clear_cached_price_override_for_item_for_user(current_user[:id], @price_override.item_id)
    @price_override.destroy
    
    respond_to do |format|
      format.html { redirect_to(price_overrides_url) }
      format.xml  { head :ok }
    end
  end
end
