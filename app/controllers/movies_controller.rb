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
    sort_accordance = params[:sort_accordance] || session[:sort_accordance]
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
