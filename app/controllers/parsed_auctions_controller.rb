class ParsedAuctionsController < ApplicationController
  before_filter :load
  def load
    @parsed_auctions = ParsedAuction.all
    @parsed_auction = ParsedAuction.new
  end

  respond_to :html, :js

  # GET /parsed_auctions
  # GET /parsed_auctions.json
  def index

  end

  # POST /parsed_auctions
  # POST /parsed_auctions.json
  def create
    @parsed_auction = ParsedAuction.new(params[:parsed_auction])
    @parsed_auction.save
    if @parsed_auction.save
    flash[:notice] = "Successfully created parsed auctions."
    @parsed_auctions = ParsedAuction.all
    end

  end

  # DELETE /parsed_auctions/1l
  # DELETE /parsed_auctions/1.json
  def destroy
    @parsed_auction = ParsedAuction.find(params[:id])
    @parsed_auction.destroy

    flash[:notice] = "Successfully destroyed parsed auctions."
    @parsed_auctions = ParsedAuction.all
  end
end
