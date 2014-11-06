class PiecesController < ApplicationController

  def new
  end

  def update
    @piece = Piece.find(params[:id])
    @piece.update(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space))
    @piece.folder_list = params[:piece][:folders]
    @piece.save
    @piece.reload

    params[:piece][:piece_id] = @piece.id
    @log = Log.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space, :piece_id))
    @log.save

    respond_to do | format |  
      format.json { render :json => @piece.id }
    end
  end
 
  def create
    # render text: params.inspect

    @piece = Piece.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space))
    @piece.folder_list = params[:piece][:folders]
    @piece.save
    @piece.reload

    params[:piece][:piece_id] = @piece.id
    @log = Log.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space, :piece_id))
    @log.save

    respond_to do | format |  
      format.html { redirect_to @piece }
      format.json { render :json => @piece.id }
    end
  end

  def show
    @piece = Piece.find(params[:id])
    @pieces = Piece.all
    @folder = Piece.folder_counts
    @log = Log.where(piece_id: @piece.id)
  end

  def index
    @pieces = Piece.all
    @folder = Piece.folder_counts
  end

  def pos
    text = params[:text]

    tgr = EngTagger.new
    possed_text = tgr.add_tags(text) 

    params[:possed] = possed_text

    # result = []
    # result[:unpossed] = text
    # result[possed] = possed_text

    respond_to do | format |  
      format.html { render :html => "asdf" }
      format.json { render :json => params }
    end
  end

  # def piece_params
  #   params.require(:user).permit(:name, :tag_list) ## Rails 4 strong params usage
  # end

end
