class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings=Movie.ratings
    # Has the user pressed Refresh button?
    rating_filter = params[:ratings]
    # logger.debug(">>>CI<<< " + "in index method." + "rating filter is " + rating_filter.to_s)    
    if rating_filter != nil
      @movies = Movie.where(rating: rating_filter.keys).all
      session[:rating_filter] = rating_filter
    else
      # Refresh not called
      session[:first?]=true unless session[:first?]==false
      if session[:first?]
        # logger.debug(">>>CI<<< " + "First call.") 
        # All checkbox enabled
        session[:rating_filter] = Hash[@all_ratings.zip [1]*@all_ratings.length]
        # Prepare for next invocation of index method
        session[:first?] = false
      else
        logger.debug(">>>CI<<< " + "Call after first.") 
      end
      # logger.debug(">>>CI<<< " + rating_filter.to_s)
      key = params[:key]
      if key == "title"
        @movies = Movie.order(title: :asc)
        @title_header_class='hilite'
        @release_date_header_class=''
      elsif key == "release_date"
        @movies = Movie.order(release_date: :asc)
        @title_header_class=''
        @release_date_header_class='hilite'      
      else    
        @movies = Movie.all
      end
    end
    # logger.debug(">>>CI<<< " + session[:rating_filter].to_s)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
end
