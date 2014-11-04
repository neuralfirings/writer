class PiecesController < ApplicationController

  def new
  end

  def update
    # @id = params[:id]
    # render text: @id
    @piece = Piece.find(params[:id])
    @piece.update(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space))

    params[:piece][:piece_id] = @piece.id
    @log = Log.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space, :piece_id))
    @log.save
    
    respond_to do | format |  
      format.json { render :json => @piece.id }
    end
    #   redirect_to @piece
    # else
    #   render 'show'
    # end
  end
 
  def create
    # render text: params.inspect

    @piece = Piece.new(params.require(:piece).permit(:title, :body, :words, :chars, :chars_no_space))
    @piece.save

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

end
