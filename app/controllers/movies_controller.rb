class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # if movies_path gets a :sort_accordance => 'title' parameter, sort according to title.
  # if movies_path gets a :sort_accordance => 'date' parameter, sort according to release_date.
  # else just show the table as it is.
  
  def index
    # view give model 'params[:param_id]'
    # model give view @instance_variables
    
    # in this example:
    # view gives model params[:sort_accordance] (a string) and params[:ratings] (a list of strings)
    # model sets @all_ratings, @selected_ratings, @movies, @title_html_class and @date_html_class for view to use.
    
    # Get @all_ratings:
    @all_ratings = [] # initialize as empty list.
    movies_list = Movie.all # get all movies
    movies_list.each do |movie|
      rating = movie.rating # for each movie, get its rating.
      if !@all_ratings.include? rating # if we see a new rating, add it to the list.
        @all_ratings += [rating]
      end
    end
    # Get @all_ratings finished
    
    # At the very beginning of the session:
    # if flash[:ratings].nil?
    #   # initialize @selected_ratings as @all_ratings at the start of the session.
    #   # The first time the user visits the page, all checkboxes should be checked by default (so the user will see all movies).
    #   @selected_ratings = @all_ratings
    # end
    
    # Sorting part:
    if params[:sort_accordance].nil?
      sort_accordance = session[:sort_accordance]
    else
      sort_accordance = params[:sort_accordance]
      session[:sort_accordance] = params[:sort_accordance]
    end
    # @title_html_class and @date_html_class are passed to view as <th>'s class element in index.html.haml
    # initialize as empty array.
    # empty array means no hilite in css.
    # only the <th> whose class is 'hilite' will be highlighted.
    @title_html_class = '' 
    @date_html_class = ''
    if sort_accordance == 'title'
      @movies = Movie.all.order('title')
      @title_html_class = 'hilite'
    elsif sort_accordance == 'date'
      @movies = Movie.all.order('release_date')
      @date_html_class = 'hilite'
    else
      @movies = Movie.all
    end
    # Sorting finish. Get sorted movie list in @movies
    
    # Selecting part:
    if params[:ratings].nil?
      if session[:ratings].nil?
        @selected_ratings = @all_ratings # At the very beginning of the session.
      else
        @selected_ratings = session[:ratings]
      end
    else
      @selected_ratings = params[:ratings]
      session[:ratings] = params[:ratings]
    end
    @movies = @movies.where({rating: @selected_ratings})
    # #where will also accept a hash condition, in which the keys are fields and the values are values to be searched for.
    #Selection finished. Get sorted and selected movie list in @movies
    
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
